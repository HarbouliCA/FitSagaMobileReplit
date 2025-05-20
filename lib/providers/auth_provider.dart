import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  // Constructor - initialize by listening to auth state changes
  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }
  
  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get user document from Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
      } else {
        // Create new user document if it doesn't exist
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toFirestore());
        _currentUser = newUser;
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load user data: $e';
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (_currentUser != null) {
        await _firestore.collection('users').doc(_currentUser!.id).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Register with email and password
  Future<bool> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // User document will be created in _onAuthStateChanged
      
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firebaseAuth.signOut();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = 'Failed to sign out: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? bio,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return false;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_currentUser!.id).update(updates);
        
        // Update current user model
        _currentUser = _currentUser!.copyWith(
          name: name,
          phone: phone,
          bio: bio,
          photoUrl: photoUrl,
        );
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update password for logged in user
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null || _firebaseAuth.currentUser == null || _currentUser!.email.isEmpty) {
      _error = 'You must be logged in to change your password';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email,
        password: currentPassword,
      );
      
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
      
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get user by ID (for admin or instructor use)
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      
      return null;
    } catch (e) {
      _error = 'Failed to get user: $e';
      return null;
    }
  }
  
  // Get all users (for admin use only)
  Future<List<UserModel>> getAllUsers({int limit = 20}) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      _error = 'Only admins can access all users';
      notifyListeners();
      return [];
    }
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('name')
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = 'Failed to get users: $e';
      notifyListeners();
      return [];
    }
  }
  
  // Handle Firebase Auth errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'This email address is already in use';
        case 'weak-password':
          return 'The password is too weak';
        case 'invalid-email':
          return 'The email address is invalid';
        case 'user-disabled':
          return 'This user account has been disabled';
        case 'too-many-requests':
          return 'Too many unsuccessful login attempts. Please try again later';
        case 'operation-not-allowed':
          return 'This operation is not allowed';
        case 'requires-recent-login':
          return 'This operation requires recent authentication. Please log in again';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An unexpected error occurred: $error';
  }

  // Demo mode methods - these are used for testing without Firebase
  void setDemoUser({bool isAdmin = false, bool isInstructor = false}) {
    _currentUser = UserModel(
      id: 'demo-user-id',
      email: 'demo@example.com',
      name: isAdmin ? 'Admin User' : (isInstructor ? 'Instructor User' : 'Client User'),
      phone: '+1234567890',
      bio: 'This is a demo user account for testing purposes.',
      photoUrl: null,
      isAdmin: isAdmin,
      isInstructor: isInstructor,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
    );
    _error = null;
    notifyListeners();
  }

  void clearDemoUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}