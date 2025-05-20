import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  AuthProvider(this._firebaseService);
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  // Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          // User is signed in, get user data from Firestore
          await _fetchUserData(user.uid);
        } else {
          // User is signed out
          _currentUser = null;
          notifyListeners();
        }
      });
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize authentication: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseService.signInWithEmailAndPassword(
        email.trim(),
        password,
      );
      
      // Get user data from Firestore
      await _fetchUserData(userCredential.user!.uid);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred during sign in: ${e.message}';
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Register with email and password
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Create user with Firebase Auth
      final userCredential = await _firebaseService.registerWithEmailAndPassword(
        email.trim(),
        password,
      );
      
      // Update user profile with display name
      await _firebaseService.updateUserProfile(
        displayName: name.trim(),
      );
      
      // Create user document in Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        role: UserRole.client, // Default role for new users
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      await _firebaseService.setUserData(newUser);
      
      // Set current user
      _currentUser = newUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak. Please use a stronger password.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An error occurred during registration: ${e.message}';
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<bool> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firebaseService.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to sign out: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firebaseService.resetPassword(email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred while resetting password: ${e.message}';
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Make sure user is authenticated
      if (_currentUser == null || _firebaseService.currentUser == null) {
        _error = 'You must be logged in to update your profile.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Update Firebase Auth profile
      await _firebaseService.updateUserProfile(
        displayName: name,
        photoUrl: photoUrl,
      );
      
      // Create updated user model
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        updatedAt: DateTime.now(),
      );
      
      // Update Firestore document
      await _firebaseService.setUserData(updatedUser);
      
      // Update local user data
      _currentUser = updatedUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_firebaseService.currentUser == null) {
      return;
    }
    
    await _fetchUserData(_firebaseService.currentUser!.uid);
  }
  
  // Private method to fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      final userData = await _firebaseService.getUserData(uid);
      if (userData != null) {
        _currentUser = userData;
      } else {
        // User document doesn't exist yet, create it
        final authUser = _firebaseService.currentUser;
        if (authUser != null) {
          final newUser = UserModel(
            id: authUser.uid,
            email: authUser.email ?? '',
            name: authUser.displayName ?? 'User',
            role: UserRole.client, // Default role
            photoUrl: authUser.photoURL,
            isActive: true,
            createdAt: DateTime.now(),
          );
          
          await _firebaseService.setUserData(newUser);
          _currentUser = newUser;
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch user data: $e';
      notifyListeners();
      rethrow;
    }
  }
}