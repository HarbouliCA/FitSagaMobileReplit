class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }
  
  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }
  
  // Phone number validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone can be optional
    }
    
    final phoneRegExp = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }
  
  // Height validator (in cm)
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Height can be optional
    }
    
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Enter a valid number';
    }
    
    if (intValue < 50 || intValue > 250) {
      return 'Enter a valid height (50-250 cm)';
    }
    
    return null;
  }
  
  // Weight validator (in kg)
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Weight can be optional
    }
    
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Enter a valid number';
    }
    
    if (intValue < 20 || intValue > 300) {
      return 'Enter a valid weight (20-300 kg)';
    }
    
    return null;
  }
  
  // Required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  // Number validator
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    final numValue = int.tryParse(value);
    if (numValue == null) {
      return 'Enter a valid number';
    }
    
    if (min != null && numValue < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && numValue > max) {
      return 'Value must be at most $max';
    }
    
    return null;
  }
  
  // Credit validator
  static String? validateCredits(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credits value is required';
    }
    
    if (value.toLowerCase() == 'unlimited') {
      return null;
    }
    
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Enter a valid number or "unlimited"';
    }
    
    if (intValue < 0) {
      return 'Credits cannot be negative';
    }
    
    return null;
  }
  
  // Date validator
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    
    return null;
  }
  
  // Time validator
  static String? validateTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) {
      return 'Start time is required';
    }
    
    if (endTime == null) {
      return 'End time is required';
    }
    
    if (endTime.isBefore(startTime)) {
      return 'End time must be after start time';
    }
    
    return null;
  }
}
