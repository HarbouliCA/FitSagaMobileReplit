import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/credit_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

/// Provider class for managing user credits in the FitSAGA app
class CreditProvider with ChangeNotifier {
  /// Instance of the Firebase service
  final FirebaseService _firebaseService = FirebaseService();
  
  /// User's current credit balance
  int _creditBalance = 0;
  
  /// User's credit transaction history
  List<CreditModel> _creditHistory = [];
  
  /// Loading state for credit operations
  bool _isLoading = false;
  
  /// Error message if credit operations fail
  String? _error;
  
  /// Flag to track if credit data has been loaded
  bool _isInitialized = false;
  
  /// Flag indicating whether user has unlimited credits
  bool _hasUnlimitedCredits = false;
  
  /// Returns the user's current credit balance
  int get creditBalance => _creditBalance;
  
  /// Returns the user's credit transaction history
  List<CreditModel> get creditHistory => _creditHistory;
  
  /// Returns whether a credit operation is in progress
  bool get isLoading => _isLoading;
  
  /// Returns any error message from the last credit operation
  String? get error => _error;
  
  /// Returns whether credit data has been loaded
  bool get isInitialized => _isInitialized;
  
  /// Returns whether the user has unlimited credits
  bool get hasUnlimitedCredits => _hasUnlimitedCredits;
  
  /// Returns the total available credits
  int get totalCredits => _creditBalance;
  
  /// Returns formatted credits for display
  String get displayCredits => hasUnlimitedCredits ? "∞" : _creditBalance.toString();
  
  /// Loads a user's credit balance and history
  Future<void> loadUserCredits(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Load user's credit balance
      _creditBalance = await _firebaseService.getUserCreditBalance(userId);
      
      // Load user's credit history
      _creditHistory = await _firebaseService.getUserCreditHistory(userId);
      _creditHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load credit information: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Purchases new credits (client only)
  Future<bool> purchaseCredits(String userId, int amount, String paymentReference) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.purchaseCredits(userId, amount, paymentReference);
      
      if (success) {
        // Reload credit data to ensure it's up to date
        await loadUserCredits(userId);
        return true;
      } else {
        _setError('Failed to purchase credits.');
        return false;
      }
    } catch (e) {
      _setError('Failed to purchase credits: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gifts credits to a user (admin only)
  Future<bool> giftCredits(String userId, int amount, String reason) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.giftCredits(userId, amount, reason);
      
      if (success) {
        // If crediting the current user, reload their credit data
        if (userId == _creditHistory.first.userId) {
          await loadUserCredits(userId);
        }
        return true;
      } else {
        _setError('Failed to gift credits.');
        return false;
      }
    } catch (e) {
      _setError('Failed to gift credits: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets credit transactions filtered by type
  List<CreditModel> getTransactionsByType(CreditTransactionType type) {
    return _creditHistory.where((credit) => credit.type == type).toList();
  }
  
  /// Gets credit increases (purchases, initial credits, refunds)
  List<CreditModel> get creditIncreases {
    return _creditHistory.where((credit) => credit.isCredit).toList();
  }
  
  /// Gets credit decreases (session bookings)
  List<CreditModel> get creditDecreases {
    return _creditHistory.where((credit) => credit.isDebit).toList();
  }
  
  /// Gets recent transactions (last 30 days)
  List<CreditModel> get recentTransactions {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _creditHistory
        .where((credit) => credit.createdAt.isAfter(thirtyDaysAgo))
        .toList();
  }
  
  /// Calculates total credits purchased
  int get totalCreditsPurchased {
    return _creditHistory
        .where((credit) => credit.type == CreditTransactionType.purchase)
        .fold(0, (sum, credit) => sum + credit.amount);
  }
  
  /// Calculates total credits used
  int get totalCreditsUsed {
    return _creditHistory
        .where((credit) => credit.type == CreditTransactionType.usage)
        .fold(0, (sum, credit) => sum + credit.amount);
  }
  
  /// Checks if user has sufficient credits for booking a session
  bool hasSufficientCredits(int requiredCredits) {
    return _creditBalance >= requiredCredits;
  }
  
  /// Sets the loading state and notifies listeners if changed
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// Sets an error message and notifies listeners
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  /// Clears any existing error message
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
  
  /// Refreshes credit data for a user
  Future<void> refreshCredits(String userId) async {
    await loadUserCredits(userId);
  }
  
  /// Calculates remaining credits after a booking
  int remainingAfterBooking(int requiredCredits) {
    if (hasUnlimitedCredits) return _creditBalance;
    return _creditBalance - requiredCredits;
  }
  
  /// Clears all credit data (used for sign out)
  void clear() {
    _creditBalance = 0;
    _creditHistory = [];
    _isInitialized = false;
    _hasUnlimitedCredits = false;
    _clearError();
    notifyListeners();
  }
}