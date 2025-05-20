import 'package:flutter/foundation.dart';
// Temporarily commented out for web compatibility
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _initUser();
  }

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  // Initialize user on app start
  Future<void> _initUser() async {
    _setLoading(true);
    
    try {
      // Check if user is already logged in
      final User? firebaseUser = _auth.currentUser;
      
      if (firebaseUser != null) {
        // Fetch user data from Firestore
        await _fetchUserData(firebaseUser.uid);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        _user = UserModel.fromJson({...userData, 'uid': uid});
        notifyListeners();
      } else {
        _setError('User data not found');
      }
    } catch (e) {
      _setError('Error fetching user data: ${e.toString()}');
    }
  }

  // Register new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(name);
        
        // Create user document in Firestore
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: email,
          displayName: name,
          phoneNumber: phone,
          role: 'client',
          credits: UserCredits(gymCredits: 5, intervalCredits: 2), // Starting credits
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toJson());
        
        // Set the user in the provider
        _user = newUser;
        notifyListeners();
      }
    } catch (e) {
      _setError(_handleAuthError(e));
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Login existing user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Sign in with Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // Update last login time
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        
        // Fetch user data
        await _fetchUserData(firebaseUser.uid);
      }
    } catch (e) {
      _setError(_handleAuthError(e));
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Sign out user
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Error signing out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    if (_user == null) {
      _setError('No user logged in');
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final Map<String, dynamic> updates = {};
      
      if (name != null && name.isNotEmpty) {
        updates['displayName'] = name;
      }
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        updates['phoneNumber'] = phoneNumber;
      }
      
      if (photoUrl != null && photoUrl.isNotEmpty) {
        updates['photoUrl'] = photoUrl;
      }
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_user!.uid).update(updates);
        
        // Update local user data
        _user = _user!.copyWith(
          displayName: name ?? _user!.displayName,
          phoneNumber: phoneNumber ?? _user!.phoneNumber,
          photoUrl: photoUrl ?? _user!.photoUrl,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Error updating profile: ${e.toString()}');
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _setError(_handleAuthError(e));
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Update credits
  Future<void> updateCredits({
    int? gymCredits,
    int? intervalCredits,
  }) async {
    if (_user == null) {
      _setError('No user logged in');
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final UserCredits currentCredits = _user!.credits;
      final UserCredits updatedCredits = currentCredits.copyWith(
        gymCredits: gymCredits,
        intervalCredits: intervalCredits,
      );
      
      await _firestore.collection('users').doc(_user!.uid).update({
        'credits': updatedCredits.toJson(),
      });
      
      // Update local user data
      _user = _user!.copyWith(credits: updatedCredits);
      
      notifyListeners();
    } catch (e) {
      _setError('Error updating credits: ${e.toString()}');
      throw Exception(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Add credits
  Future<void> addCredits({
    int gymCredits = 0,
    int intervalCredits = 0,
  }) async {
    if (_user == null) {
      _setError('No user logged in');
      return;
    }
    
    final UserCredits currentCredits = _user!.credits;
    
    await updateCredits(
      gymCredits: currentCredits.gymCredits + gymCredits,
      intervalCredits: currentCredits.intervalCredits + intervalCredits,
    );
  }

  // Deduct credits
  Future<bool> deductCredits({
    int gymCredits = 0,
    int intervalCredits = 0,
  }) async {
    if (_user == null) {
      _setError('No user logged in');
      return false;
    }
    
    final UserCredits currentCredits = _user!.credits;
    
    // Check if user has enough credits
    if (currentCredits.gymCredits < gymCredits || 
        currentCredits.intervalCredits < intervalCredits) {
      _setError('Not enough credits');
      return false;
    }
    
    try {
      await updateCredits(
        gymCredits: currentCredits.gymCredits - gymCredits,
        intervalCredits: currentCredits.intervalCredits - intervalCredits,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _handleAuthError(dynamic error) {
    String errorMessage = 'An error occurred';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Authentication error: ${error.message}';
      }
    } else {
      errorMessage = 'Error: ${error.toString()}';
    }
    
    return errorMessage;
  }
}