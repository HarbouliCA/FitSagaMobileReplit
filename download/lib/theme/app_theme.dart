import 'package:flutter/material.dart';

/// AppTheme class for managing the application's visual styles
class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF3F51B5); // Indigo
  static const Color primaryLightColor = Color(0xFF757DE8);
  static const Color primaryDarkColor = Color(0xFF002984);
  
  // Secondary Colors
  static const Color accentColor = Color(0xFFFF5722); // Deep Orange
  static const Color accentLightColor = Color(0xFFFF8A50);
  static const Color accentDarkColor = Color(0xFFC41C00);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Color(0xFF9E9E9E);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Status Light Colors (for backgrounds)
  static const Color successLightColor = Color(0xFFE8F5E9);
  static const Color warningLightColor = Color(0xFFFFF8E1);
  static const Color errorLightColor = Color(0xFFFFEBEE);
  static const Color infoLightColor = Color(0xFFE3F2FD);
  
  // Font Sizes
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeader = 30.0;
  
  // Paddings
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingRegular = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingRegular = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusRegular = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusCircular = 50.0;
  
  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationXSmall = 1.0;
  static const double elevationSmall = 2.0;
  static const double elevationRegular = 4.0;
  static const double elevationMedium = 6.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeRegular = 24.0;
  static const double iconSizeMedium = 32.0;
  static const double iconSizeLarge = 40.0;
  
  // Button Heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightRegular = 40.0;
  static const double buttonHeightLarge = 48.0;
  
  // Form Field Heights
  static const double fieldHeightSmall = 40.0;
  static const double fieldHeightRegular = 48.0;
  static const double fieldHeightLarge = 56.0;
  
  /// Generate the main theme data for the application
  static ThemeData getTheme() {
    return ThemeData(
      // Base Colors
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      
      // Scaffold and Background
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: surfaceColor,
      cardColor: cardColor,
      
      // Text Themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeHeader,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeMedium,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeRegular,
          color: textPrimaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeSmall,
          color: textSecondaryColor,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingMedium,
            vertical: paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusRegular),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingSmall,
            vertical: paddingXSmall,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingMedium,
            vertical: paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusRegular),
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingRegular,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
          borderSide: const BorderSide(color: textLightColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
          borderSide: const BorderSide(color: textLightColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textLightColor),
        errorStyle: const TextStyle(color: errorColor, fontSize: fontSizeSmall),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
        margin: const EdgeInsets.all(paddingSmall),
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: elevationSmall,
        centerTitle: false,
        toolbarHeight: 56.0,
      ),
      
      // TabBar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondaryColor,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: primaryColor, width: 2.0),
          ),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        elevation: elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: textLightColor,
        thickness: 1.0,
        space: spacingMedium,
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: primaryLightColor,
        linearTrackColor: primaryLightColor,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLightColor,
        type: BottomNavigationBarType.fixed,
        elevation: elevationSmall,
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textLightColor;
          }
          return primaryColor;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textLightColor;
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textLightColor.withOpacity(0.5);
          }
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return textLightColor;
        }),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: elevationRegular,
        highlightElevation: elevationMedium,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: elevationMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadiusMedium),
            topRight: Radius.circular(borderRadiusMedium),
          ),
        ),
      ),
    );
  }
  
  /// Generate a dark theme for the application
  static ThemeData getDarkTheme() {
    return ThemeData.dark().copyWith(
      // Base Colors
      primaryColor: primaryDarkColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryDarkColor,
        secondary: accentDarkColor,
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
        error: errorColor,
      ),
      
      // Text Theme adjustments for dark mode
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      
      // Card Theme for dark mode
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
        margin: const EdgeInsets.all(paddingSmall),
      ),
    );
  }
}