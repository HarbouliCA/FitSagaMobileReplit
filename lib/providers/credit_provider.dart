import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fitsaga/models/credit_model.dart';
import 'package:fitsaga/services/firebase_service.dart';
import 'package:fitsaga/theme/app_theme.dart';

class CreditProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  
  CreditProvider(this._firebaseService);
  
  bool _loading = false;
  String? _error;
  List<CreditModel> _userCredits = [];
  List<CreditPackageModel> _availablePackages = [];
  
  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<CreditModel> get userCredits => _userCredits;
  List<CreditPackageModel> get availablePackages => _availablePackages;
  
  // Computed values
  int get totalCredits {
    if (_userCredits.any((credit) => credit.isUnlimited)) {
      return -1; // -1 indicates unlimited credits
    }
    
    return _userCredits.fold(0, (sum, credit) => sum + credit.credits);
  }
  
  bool get hasUnlimitedCredits => totalCredits == -1;
  
  List<CreditModel> get activeCredits => 
      _userCredits.where((credit) => credit.isActive).toList();
  
  List<CreditModel> get expiredCredits => 
      _userCredits.where((credit) => credit.isExpired).toList();
  
  // Methods
  Future<void> fetchUserCredits(String userId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      _userCredits = await _firebaseService.getUserCredits(userId);
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> fetchAvailablePackages() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      _availablePackages = await _firebaseService.getCreditPackages();
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  bool hasSufficientCredits(int requiredCredits) {
    if (hasUnlimitedCredits) {
      return true;
    }
    
    return totalCredits >= requiredCredits;
  }
  
  int remainingAfterBooking(int requiredCredits) {
    if (hasUnlimitedCredits) {
      return -1; // Unlimited
    }
    
    return totalCredits - requiredCredits;
  }
  
  Future<bool> deductCredits(String userId, int amount, String description, {String? reference}) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      // Check if user has sufficient credits
      if (!hasSufficientCredits(amount)) {
        _error = 'Insufficient credits';
        _loading = false;
        notifyListeners();
        return false;
      }
      
      // If user has unlimited credits, don't actually deduct anything
      if (!hasUnlimitedCredits) {
        await _firebaseService.deductCredits(userId, amount, description, reference);
      }
      
      // Refresh user credits
      await fetchUserCredits(userId);
      
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  String getCreditStatusText() {
    if (hasUnlimitedCredits) {
      return 'Unlimited Credits';
    }
    
    return '$totalCredits Credits';
  }
  
  Color getCreditStatusColor() {
    if (hasUnlimitedCredits) {
      return AppTheme.creditUnlimitedColor;
    }
    
    if (totalCredits <= 0) {
      return AppTheme.creditEmptyColor;
    } else if (totalCredits < 5) {
      return AppTheme.creditLowColor;
    } else if (totalCredits < 10) {
      return AppTheme.creditMediumColor;
    } else {
      return AppTheme.creditFullColor;
    }
  }
  
  Future<String> _getCurrentUserId() async {
    // This should be implemented to get the current user ID
    // For now, returning a placeholder
    return 'user123';
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}