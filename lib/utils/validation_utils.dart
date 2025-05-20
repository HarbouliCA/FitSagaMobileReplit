/// A utility class for form validation functions.
class ValidationUtils {
  /// Validates an email address.
  /// Returns null if valid, or an error message if invalid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Simple regex for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates a password.
  /// Returns null if valid, or an error message if invalid.
  /// 
  /// [minLength] specifies the minimum length required (defaults to 6).
  /// If [requireSpecialChar] is true, the password must contain at least one special character.
  /// If [requireUppercase] is true, the password must contain at least one uppercase letter.
  /// If [requireNumber] is true, the password must contain at least one number.
  static String? validatePassword(
    String? value, {
    int minLength = 6,
    bool requireSpecialChar = false,
    bool requireUppercase = false,
    bool requireNumber = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    
    if (requireSpecialChar && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (requireNumber && !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  /// Validates that two passwords match.
  /// Returns null if they match, or an error message if they don't.
  static String? validatePasswordsMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validates a name field.
  /// Returns null if valid, or an error message if invalid.
  /// 
  /// [minLength] specifies the minimum length required (defaults to 2).
  /// [maxLength] specifies the maximum length allowed (defaults to 50).
  static String? validateName(
    String? value, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < minLength) {
      return 'Name must be at least $minLength characters long';
    }
    
    if (value.length > maxLength) {
      return 'Name cannot exceed $maxLength characters';
    }
    
    // Check if name contains numbers or special characters
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Name should only contain letters';
    }
    
    return null;
  }
  
  /// Validates a phone number.
  /// Returns null if valid, or an error message if invalid.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    // Strip any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Check length
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Phone number must be between 10 and 15 digits';
    }
    
    return null;
  }
  
  /// Validates a required field.
  /// Returns null if valid, or an error message if invalid.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Validates a numeric field.
  /// Returns null if valid, or an error message if invalid.
  /// 
  /// [min] specifies the minimum value allowed.
  /// [max] specifies the maximum value allowed.
  static String? validateNumber(
    String? value, {
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'This field is required' : null;
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Value cannot exceed $max';
    }
    
    return null;
  }
  
  /// Validates a credit card number using the Luhn algorithm.
  /// Returns null if valid, or an error message if invalid.
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }
    
    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 13 || digitsOnly.length > 19) {
      return 'Credit card number must be between 13 and 19 digits';
    }
    
    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      int n = int.parse(digitsOnly.substring(i, i + 1));
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'Invalid credit card number';
    }
    
    return null;
  }
  
  /// Validates a date field.
  /// Returns null if valid, or an error message if invalid.
  /// 
  /// [minDate] specifies the minimum date allowed.
  /// [maxDate] specifies the maximum date allowed.
  static String? validateDate(
    DateTime? value, {
    DateTime? minDate,
    DateTime? maxDate,
    bool required = true,
  }) {
    if (value == null) {
      return required ? 'Date is required' : null;
    }
    
    if (minDate != null && value.isBefore(minDate)) {
      return 'Date must be after ${minDate.toIso8601String().split('T')[0]}';
    }
    
    if (maxDate != null && value.isAfter(maxDate)) {
      return 'Date must be before ${maxDate.toIso8601String().split('T')[0]}';
    }
    
    return null;
  }
  
  /// Validates a URL.
  /// Returns null if valid, or an error message if invalid.
  static String? validateUrl(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL is required' : null;
    }
    
    // Simple regex for URL validation
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
}