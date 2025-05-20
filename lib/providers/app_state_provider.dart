import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider class for managing global app state and preferences.
class AppStateProvider extends ChangeNotifier {
  bool _isFirstLaunch = true;
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  bool _isOfflineMode = false;
  bool _enableNotifications = true;
  bool _hasCompletedOnboarding = false;
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Shared preferences instance
  SharedPreferences? _prefs;
  
  // Error handling
  bool _hasError = false;
  String? _errorMessage;
  
  // Network connection
  bool _isConnected = true;
  
  // Getters
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get isOfflineMode => _isOfflineMode;
  bool get enableNotifications => _enableNotifications;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  ThemeMode get themeMode => _themeMode;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;
  
  /// Constructor that initializes the provider and loads preferences
  AppStateProvider() {
    _loadPreferences();
  }
  
  /// Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      _isFirstLaunch = _prefs?.getBool('isFirstLaunch') ?? true;
      _isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
      _selectedLanguage = _prefs?.getString('selectedLanguage') ?? 'en';
      _isOfflineMode = _prefs?.getBool('isOfflineMode') ?? false;
      _enableNotifications = _prefs?.getBool('enableNotifications') ?? true;
      _hasCompletedOnboarding = _prefs?.getBool('hasCompletedOnboarding') ?? false;
      
      final themeModeValue = _prefs?.getString('themeMode') ?? 'system';
      switch (themeModeValue) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load preferences: $e';
      notifyListeners();
    }
  }
  
  /// Set whether this is the first launch of the app
  Future<void> setFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    await _prefs?.setBool('isFirstLaunch', value);
    notifyListeners();
  }
  
  /// Set the dark mode preference
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs?.setBool('isDarkMode', value);
    notifyListeners();
  }
  
  /// Set the theme mode (system, light, or dark)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    String themeModeValue;
    switch (mode) {
      case ThemeMode.light:
        themeModeValue = 'light';
        break;
      case ThemeMode.dark:
        themeModeValue = 'dark';
        break;
      default:
        themeModeValue = 'system';
    }
    
    await _prefs?.setString('themeMode', themeModeValue);
    notifyListeners();
  }
  
  /// Set the selected language
  Future<void> setSelectedLanguage(String value) async {
    _selectedLanguage = value;
    await _prefs?.setString('selectedLanguage', value);
    notifyListeners();
  }
  
  /// Set the offline mode preference
  Future<void> setOfflineMode(bool value) async {
    _isOfflineMode = value;
    await _prefs?.setBool('isOfflineMode', value);
    notifyListeners();
  }
  
  /// Set the notifications preference
  Future<void> setEnableNotifications(bool value) async {
    _enableNotifications = value;
    await _prefs?.setBool('enableNotifications', value);
    notifyListeners();
  }
  
  /// Set whether the onboarding process has been completed
  Future<void> setHasCompletedOnboarding(bool value) async {
    _hasCompletedOnboarding = value;
    await _prefs?.setBool('hasCompletedOnboarding', value);
    notifyListeners();
  }
  
  /// Set the network connection status
  void setNetworkStatus(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }
  
  /// Update the error state
  void setError(bool hasError, {String? message}) {
    _hasError = hasError;
    _errorMessage = message;
    notifyListeners();
  }
  
  /// Clear the error state
  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Reset all preferences to default values
  Future<void> resetPreferences() async {
    _isFirstLaunch = true;
    _isDarkMode = false;
    _selectedLanguage = 'en';
    _isOfflineMode = false;
    _enableNotifications = true;
    _hasCompletedOnboarding = false;
    _themeMode = ThemeMode.system;
    
    await _prefs?.clear();
    notifyListeners();
  }
}