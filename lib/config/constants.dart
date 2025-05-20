/// Class containing application-wide constants
class AppConstants {
  /// Application name as displayed in the UI
  static const String appName = 'FitSAGA';
  
  /// Application version number
  static const String appVersion = '1.0.0';
  
  /// Copyright text
  static const String copyright = '© 2023 FitSAGA. All rights reserved.';
  
  /// Contact email address
  static const String contactEmail = 'support@fitsaga.com';
  
  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://fitsaga.com/privacy';
  
  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://fitsaga.com/terms';
  
  /// Help and support URL
  static const String helpUrl = 'https://fitsaga.com/help';
  
  /// Base cost of one credit (for in-app purchases)
  static const double creditCost = 5.99;
  
  /// Default profile image URL
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  
  /// Rate limiting constants
  static const int maxLoginAttempts = 5;
  static const int loginLockoutMinutes = 15;
  
  /// Session booking constants
  static const int maxDaysInAdvance = 14; // Maximum days in advance for booking
  static const int minCancellationHours = 24; // Minimum hours for cancellation with refund
  
  /// Animation durations
  static const int shortAnimationDuration = 200; // milliseconds
  static const int mediumAnimationDuration = 350; // milliseconds
  static const int longAnimationDuration = 500; // milliseconds
}