import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/credit_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

class CreditProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  int _creditBalance = 0;
  List<CreditTransaction> _creditHistory = [];
  List<CreditPackage> _availablePackages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  CreditProvider(this._firebaseService);

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  int get creditBalance => _creditBalance;
  List<CreditTransaction> get creditHistory => _creditHistory;
  List<CreditPackage> get availablePackages => _availablePackages;

  // Computed properties
  int get totalCreditsPurchased {
    return _creditHistory
        .where((tx) => tx.isCredit && tx.type == CreditTransactionType.purchase)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  int get totalCreditsUsed {
    return _creditHistory
        .where((tx) => !tx.isCredit)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  // Check if user has sufficient credits for a transaction
  bool hasSufficientCredits(int amount) {
    return _creditBalance >= amount;
  }

  // Load user's credit balance and transaction history
  Future<void> loadUserCredits(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load credit balance
      final userCreditDoc = await _firebaseService.firestore
          .collection('user_credits')
          .doc(userId)
          .get();

      if (userCreditDoc.exists) {
        final data = userCreditDoc.data() as Map<String, dynamic>;
        _creditBalance = data['balance'] ?? 0;
      } else {
        // Create a new credit document for the user with initial balance
        await _firebaseService.firestore
            .collection('user_credits')
            .doc(userId)
            .set({
          'balance': 5, // Initial free credits for new users
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Record the initial credit transaction
        await _firebaseService.firestore
            .collection('credit_transactions')
            .add({
          'userId': userId,
          'amount': 5,
          'isCredit': true,
          'type': 'initial',
          'description': 'Welcome credits',
          'createdAt': FieldValue.serverTimestamp(),
        });

        _creditBalance = 5;
      }

      // Load credit transaction history
      final transactionsSnapshot = await _firebaseService.firestore
          .collection('credit_transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _creditHistory = transactionsSnapshot.docs
          .map((doc) => CreditTransaction.fromFirestore(doc))
          .toList();

      // Load available credit packages
      final packagesSnapshot = await _firebaseService.firestore
          .collection('credit_packages')
          .where('isActive', isEqualTo: true)
          .get();

      _availablePackages = packagesSnapshot.docs
          .map((doc) => CreditPackage.fromFirestore(doc))
          .toList();

      // Sort packages by credit amount
      _availablePackages.sort((a, b) => a.credits.compareTo(b.credits));

      _isInitialized = true;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load credit data: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Purchase credits using a selected package
  Future<bool> purchaseCredits(CreditPackage package, String userId, {String? paymentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, we would process payment here
      // For now, we'll simulate a successful payment

      // Update user credits in a transaction
      await _firebaseService.firestore.runTransaction((transaction) async {
        // Get the latest credit balance
        final userCreditRef = _firebaseService.firestore
            .collection('user_credits')
            .doc(userId);
        
        final userCreditDoc = await transaction.get(userCreditRef);
        
        // Calculate new balance
        int currentBalance = 0;
        if (userCreditDoc.exists) {
          final data = userCreditDoc.data() as Map<String, dynamic>;
          currentBalance = data['balance'] ?? 0;
        }
        
        final newBalance = currentBalance + package.credits;
        
        // Update the balance
        if (userCreditDoc.exists) {
          transaction.update(userCreditRef, {
            'balance': newBalance,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(userCreditRef, {
            'balance': newBalance,
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Record the transaction
        final transactionRef = _firebaseService.firestore
            .collection('credit_transactions')
            .doc();
        
        transaction.set(transactionRef, {
          'userId': userId,
          'amount': package.credits,
          'isCredit': true,
          'type': 'purchase',
          'description': 'Purchased ${package.name}',
          'referenceId': paymentId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      
      // Update local state
      _creditBalance += package.credits;
      
      // Add the new transaction to history
      final newTransaction = CreditTransaction(
        id: '', // This will be set by Firestore
        userId: userId,
        amount: package.credits,
        isCredit: true,
        type: CreditTransactionType.purchase,
        description: 'Purchased ${package.name}',
        referenceId: paymentId,
        createdAt: DateTime.now(),
      );
      
      _creditHistory.insert(0, newTransaction);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to purchase credits: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add admin credits (for admins to add credits to users)
  Future<bool> addAdminCredits(
    String userId, 
    int amount, 
    String description,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verify current user is an admin
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        _error = 'You must be logged in to perform this action';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final adminDoc = await _firebaseService.firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!adminDoc.exists) {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (adminData['role'] != 'admin') {
        _error = 'Only administrators can add credits';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update user credits in a transaction
      await _firebaseService.firestore.runTransaction((transaction) async {
        // Get the latest credit balance
        final userCreditRef = _firebaseService.firestore
            .collection('user_credits')
            .doc(userId);
        
        final userCreditDoc = await transaction.get(userCreditRef);
        
        // Calculate new balance
        int currentBalance = 0;
        if (userCreditDoc.exists) {
          final data = userCreditDoc.data() as Map<String, dynamic>;
          currentBalance = data['balance'] ?? 0;
        }
        
        final newBalance = currentBalance + amount;
        
        // Update the balance
        if (userCreditDoc.exists) {
          transaction.update(userCreditRef, {
            'balance': newBalance,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(userCreditRef, {
            'balance': newBalance,
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Record the transaction
        final transactionRef = _firebaseService.firestore
            .collection('credit_transactions')
            .doc();
        
        transaction.set(transactionRef, {
          'userId': userId,
          'amount': amount,
          'isCredit': true,
          'type': 'admin',
          'description': description,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      
      // If adding credits to the current user, update local state
      if (userId == currentUser.uid) {
        _creditBalance += amount;
        
        // Add the new transaction to history
        final newTransaction = CreditTransaction(
          id: '', // This will be set by Firestore
          userId: userId,
          amount: amount,
          isCredit: true,
          type: CreditTransactionType.admin,
          description: description,
          createdAt: DateTime.now(),
        );
        
        _creditHistory.insert(0, newTransaction);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add credits: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh credit data
  Future<void> refreshCredits(String userId) async {
    return loadUserCredits(userId);
  }

  // Clear all data (used during logout)
  void clear() {
    _creditBalance = 0;
    _creditHistory = [];
    _availablePackages = [];
    _isInitialized = false;
    _error = null;
    notifyListeners();
  }
}