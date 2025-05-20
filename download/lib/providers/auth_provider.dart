import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

/// Provider class for handling authentication-related state and operations
class AuthProvider with ChangeNotifier {
  /// Instance of the Firebase service
  final FirebaseService _firebaseService = FirebaseService();
  
  /// Current authenticated user
  UserModel? _currentUser;
  
  /// Loading state for authentication operations
  bool _isLoading = false;
  
  /// Error message if authentication fails
  String? _error;
  
  /// Returns the current authenticated user
  UserModel? get currentUser => _currentUser;
  
  /// Returns whether an authentication operation is in progress
  bool get isLoading => _isLoading;
  
  /// Returns any error message from the last authentication operation
  String? get error => _error;
  
  /// Returns whether a user is currently authenticated
  bool get isAuthenticated => _currentUser != null;
  
  /// Initializes the provider by checking for an existing authenticated user
  Future<void> initialize() async {
    try {
      _setLoading(true);
      
      // Check if user is already signed in
      if (await _firebaseService.isSignedIn()) {
        _currentUser = await _firebaseService.getCurrentUser();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
      print('Auth initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Signs in a user with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _firebaseService.signInWithEmail(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Login failed. Please check your credentials and try again.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Signs up a new user with email, password, and name
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _firebaseService.signUpWithEmail(email, password, name);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed. Please try again.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email address is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Signs out the current user
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firebaseService.signOut();
      _currentUser = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sends a password reset email to the specified email address
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firebaseService.resetPassword(email);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        default:
          errorMessage = 'Password reset failed: ${e.message}';
          break;
      }
      
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Updates the current user's profile information
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _setError('No authenticated user.');
        return false;
      }
      
      // Update user data
      final updatedUser = _currentUser!.copyWith(
        name: name,
        photoUrl: photoUrl,
      );
      
      // Save to Firestore
      final success = await _firebaseService.updateUser(updatedUser);
      
      if (success) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile.');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refreshes the current user data from Firestore
  Future<bool> refreshUserData() async {
    try {
      _setLoading(true);
      
      if (_currentUser == null) {
        return false;
      }
      
      final user = await _firebaseService.getUserById(_currentUser!.id);
      
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Failed to refresh user data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Admin function to update a user's role
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Check if current user is admin
      if (_currentUser == null || !_currentUser!.isAdmin) {
        _setError('Permission denied. Only administrators can update user roles.');
        return false;
      }
      
      // Update role in Firestore
      final success = await _firebaseService.updateUserRole(userId, newRole);
      
      if (!success) {
        _setError('Failed to update user role.');
      }
      
      return success;
    } catch (e) {
      _setError('Failed to update user role: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sets the loading state and notifies listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Sets an error message and notifies listeners
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  /// Clears any existing error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}