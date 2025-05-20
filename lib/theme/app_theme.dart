import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF4A5568);
  static const Color primaryLightColor = Color(0xFF718096);
  static const Color primaryDarkColor = Color(0xFF2D3748);
  
  // Accent Colors
  static const Color accentColor = Color(0xFF48BB78);
  static const Color accentLightColor = Color(0xFF68D391);
  static const Color accentDarkColor = Color(0xFF2F855A);
  
  // Semantic Colors
  static const Color successColor = Color(0xFF48BB78);
  static const Color warningColor = Color(0xFFECC94B);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color infoColor = Color(0xFF4299E1);
  
  // Text Colors
  static const Color textColor = Color(0xFF1A202C);
  static const Color textLightColor = Color(0xFF718096);
  static const Color textMutedColor = Color(0xFFA0AEC0);
  
  // Background Colors
  static const Color backgroundColor = Colors.white;
  static const Color backgroundLightColor = Color(0xFFF7FAFC);
  static const Color backgroundDarkColor = Color(0xFFEDF2F7);
  
  // Credits System Colors
  static const Color creditFullColor = Color(0xFF48BB78);
  static const Color creditMediumColor = Color(0xFFECC94B);
  static const Color creditLowColor = Color(0xFFED8936);
  static const Color creditEmptyColor = Color(0xFFE53E3E);
  static const Color creditUnlimitedColor = Color(0xFF4299E1);
  
  // Tutorial Category Colors
  static const Color exerciseColor = Color(0xFF4299E1);
  static const Color nutritionColor = Color(0xFF48BB78);
  
  // Spacing
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingRegular = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
  
  // Padding
  static const double paddingExtraSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingRegular = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusRegular = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;
  static const double borderRadiusRound = 100.0;
  
  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationRegular = 4.0;
  static const double elevationLarge = 8.0;
  
  // Font Size
  static const double fontSizeExtraSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeHeading = 22.0;
  static const double fontSizeTitle = 24.0;
  
  // Helper method to create MaterialColor from Color
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}