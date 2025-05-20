import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  
  AuthProvider(this._firebaseService) {
    _initialize();
  }
  
  bool _isLoading = true;
  bool _isAuthenticated = false;
  UserModel? _currentUser;
  String? _error;
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  String? get error => _error;
  
  Future<void> _initialize() async {
    _firebaseService.authStateChanges().listen((User? user) async {
      _isLoading = true;
      notifyListeners();
      
      if (user != null) {
        try {
          _currentUser = await _firebaseService.getCurrentUser();
          _isAuthenticated = true;
        } catch (e) {
          _error = e.toString();
          _isAuthenticated = false;
          _currentUser = null;
        }
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
      
      _isLoading = false;
      notifyListeners();
    });
  }
  
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseService.signIn(email, password);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseService.signUp(email, password, name);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseService.signOut();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseService.resetPassword(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (_currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      await _firebaseService.updateUserProfile(_currentUser!.id, data);
      
      // Refresh user data
      _currentUser = await _firebaseService.getCurrentUser();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}