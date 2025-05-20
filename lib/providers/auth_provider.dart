import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

/// Provider for handling authentication and user state
class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  AuthProvider(this._firebaseService);

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  /// Initialize the provider and listen to auth state changes
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Listen to authentication state changes
      _firebaseService.auth.authStateChanges().listen((User? firebaseUser) async {
        if (firebaseUser == null) {
          // User is signed out
          _currentUser = null;
          _isInitialized = true;
          _isLoading = false;
          notifyListeners();
        } else {
          // User is signed in, fetch additional data from Firestore
          try {
            await _fetchUserData(firebaseUser.uid);
          } catch (e) {
            _error = 'Failed to fetch user data: $e';
            _isLoading = false;
            notifyListeners();
          }
        }
      });
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Fetch current user data from Firestore
  Future<void> _fetchUserData(String userId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      } else {
        // User exists in Auth but not in Firestore
        _error = 'User profile not found';
        _currentUser = null;
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch user data: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh the current user data
  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fetchUserData(_currentUser!.id);
    } catch (e) {
      _error = 'Failed to refresh user: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Attempt to sign in
      await _firebaseService.signInWithEmailAndPassword(email, password);
      
      // User data will be fetched by the auth state listener
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found with this email';
          break;
        case 'wrong-password':
          _error = 'Wrong password';
          break;
        case 'user-disabled':
          _error = 'This account has been disabled';
          break;
        case 'too-many-requests':
          _error = 'Too many attempts. Try again later';
          break;
        default:
          _error = 'Failed to sign in: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to sign in: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new user with email and password
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create the user in Firebase Auth
      final userCredential = await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );

      // Create the user profile in Firestore
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: UserRole.client, // Default role for new users
        credits: 0, // New users start with 0 credits
        createdAt: DateTime.now(),
      );

      await _firebaseService.firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore());

      // User data will be fetched by the auth state listener
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'This email is already registered';
          break;
        case 'invalid-email':
          _error = 'Invalid email address';
          break;
        case 'weak-password':
          _error = 'Password is too weak';
          break;
        case 'operation-not-allowed':
          _error = 'Email/password accounts are not enabled';
          break;
        default:
          _error = 'Failed to register: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to register: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    if (_currentUser == null) {
      _error = 'You must be logged in to update your profile';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update user data in Firestore
      final updatedData = {
        if (name != null) 'name': name,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firebaseService.firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updatedData);

      // Refresh user data
      await refreshUser();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user credits
  Future<bool> updateCredits(int amount, {required String reason}) async {
    if (_currentUser == null) {
      _error = 'You must be logged in to update credits';
      notifyListeners();
      return false;
    }

    if (_currentUser!.credits + amount < 0) {
      _error = 'Insufficient credits';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get a reference to the user document
      final userRef = _firebaseService.firestore
          .collection('users')
          .doc(_currentUser!.id);

      // Start a transaction for data consistency
      await _firebaseService.firestore.runTransaction((transaction) async {
        // Get the latest user data
        final userDoc = await transaction.get(userRef);
        final currentCredits = userDoc.data()?['credits'] ?? 0;
        
        // Update credits atomically
        transaction.update(userRef, {
          'credits': currentCredits + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Log the credit transaction
        final creditLogRef = _firebaseService.firestore.collection('creditLogs').doc();
        transaction.set(creditLogRef, {
          'userId': _currentUser!.id,
          'amount': amount,
          'reason': reason,
          'previousBalance': currentCredits,
          'newBalance': currentCredits + amount,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      // Refresh user data
      await refreshUser();
      return true;
    } catch (e) {
      _error = 'Failed to update credits: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.signOut();
      // Auth state listener will handle clearing the user
      return true;
    } catch (e) {
      _error = 'Failed to sign out: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset password for a user
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _error = 'Invalid email address';
          break;
        case 'user-not-found':
          _error = 'No user found with this email';
          break;
        default:
          _error = 'Failed to send reset email: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to send reset email: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change user password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null || _firebaseService.currentUser == null) {
      _error = 'You must be logged in to change your password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Re-authenticate the user first
      final credential = EmailAuthProvider.credential(
        email: _firebaseService.currentUser!.email!,
        password: currentPassword,
      );

      await _firebaseService.currentUser!.reauthenticateWithCredential(credential);
      
      // Change the password
      await _firebaseService.currentUser!.updatePassword(newPassword);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _error = 'Current password is incorrect';
          break;
        case 'weak-password':
          _error = 'New password is too weak';
          break;
        case 'requires-recent-login':
          _error = 'Please sign in again before changing your password';
          break;
        default:
          _error = 'Failed to change password: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to change password: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount(String password) async {
    if (_currentUser == null || _firebaseService.currentUser == null) {
      _error = 'You must be logged in to delete your account';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Re-authenticate the user first
      final credential = EmailAuthProvider.credential(
        email: _firebaseService.currentUser!.email!,
        password: password,
      );

      await _firebaseService.currentUser!.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore first
      await _firebaseService.firestore
          .collection('users')
          .doc(_currentUser!.id)
          .delete();
      
      // Delete the user account from Auth
      await _firebaseService.currentUser!.delete();
      
      // Auth state listener will handle clearing the user
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _error = 'Password is incorrect';
          break;
        case 'requires-recent-login':
          _error = 'Please sign in again before deleting your account';
          break;
        default:
          _error = 'Failed to delete account: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete account: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}