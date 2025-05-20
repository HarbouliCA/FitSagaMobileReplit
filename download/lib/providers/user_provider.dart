import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/models/instructor_model.dart';
import 'package:fitsaga/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  User? _firebaseUser;
  UserModel? _userModel;
  List<UserModel> _allUsers = [];
  List<InstructorModel> _allInstructors = [];
  bool _loading = false;
  String? _error;
  
  UserProvider(this._firebaseUser) {
    if (_firebaseUser != null) {
      _fetchCurrentUser();
    }
  }
  
  UserModel? get user => _userModel;
  List<UserModel> get allUsers => _allUsers;
  List<InstructorModel> get allInstructors => _allInstructors;
  bool get loading => _loading;
  String? get error => _error;
  
  Future<void> _fetchCurrentUser() async {
    if (_firebaseUser == null) return;
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _userModel = await _userService.getCurrentUser();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchAllUsers() async {
    if (_firebaseUser == null) return;
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _allUsers = await _userService.getAllUsers();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchAllInstructors() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _allInstructors = await _userService.getAllInstructors();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _userService.getUserById(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<InstructorModel?> getInstructorById(String instructorId) async {
    try {
      return await _userService.getInstructorById(instructorId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    if (_firebaseUser == null || _userModel == null) return false;
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _userService.updateUserProfile(_firebaseUser!.uid, data);
      
      // Refresh user data
      _userModel = await _userService.getCurrentUser();
      
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> completeOnboarding() async {
    if (_firebaseUser == null || _userModel == null) return false;
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _userService.completeOnboarding(_firebaseUser!.uid);
      
      // Refresh user data
      _userModel = await _userService.getCurrentUser();
      
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
