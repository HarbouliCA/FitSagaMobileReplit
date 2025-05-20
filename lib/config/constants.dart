class AppConstants {
  // App Info
  static const String appName = 'FitSAGA';
  static const String appVersion = '1.0.0';
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection. Please check your network.';
  static const String errorInvalidCredentials = 'Invalid email or password. Please try again.';
  static const String errorInsufficientCredits = 'You don\'t have enough credits to book this session.';
  static const String errorSessionFull = 'This session is already fully booked.';
  static const String errorSessionCancelled = 'This session has been cancelled.';
  static const String errorSessionExpired = 'This session has already expired.';
  static const String errorAlreadyBooked = 'You have already booked this session.';
  
  // Success Messages
  static const String successBooking = 'Session booked successfully!';
  static const String successCancellation = 'Booking cancelled successfully.';
  static const String successPurchase = 'Credits purchased successfully!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successPasswordReset = 'Password reset email sent successfully!';
  
  // Session Types
  static const String sessionTypePersonalTraining = 'ENTREMIENTO_PERSONAL';
  static const String sessionTypeKickBoxing = 'KICK_BOXING';
  static const String sessionTypeFitness = 'SALE_FITNESS';
  static const String sessionTypeGroupClass = 'CLASES_DERIGIDAS';
  
  // Session Status
  static const String sessionStatusActive = 'active';
  static const String sessionStatusCancelled = 'cancelled';
  static const String sessionStatusCompleted = 'completed';
  
  // Booking Status
  static const String bookingStatusActive = 'active';
  static const String bookingStatusCancelled = 'cancelled';
  
  // Tutorial Categories
  static const String tutorialCategoryExercise = 'exercise';
  static const String tutorialCategoryNutrition = 'nutrition';
  
  // Tutorial Difficulty Levels
  static const String difficultyBeginner = 'beginner';
  static const String difficultyIntermediate = 'intermediate';
  static const String difficultyAdvanced = 'advanced';
  
  // Credit Transaction Types
  static const String creditTransactionPurchase = 'purchase';
  static const String creditTransactionUsed = 'used';
  static const String creditTransactionRefund = 'refund';
  static const String creditTransactionExpiry = 'expiry';
  static const String creditTransactionAdjustment = 'adjustment';
  
  // Miscellaneous
  static const int defaultPageSize = 10;
  static const Duration sessionBookingTimeLimit = Duration(minutes: 30);
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
}