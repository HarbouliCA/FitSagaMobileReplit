import 'package:flutter/material.dart';

/// A service that provides navigation methods throughout the app
/// This allows navigation from anywhere in the app without requiring a BuildContext
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Navigate to a named route
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }
  
  /// Replace the current route with a new one
  static Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }
  
  /// Navigate back
  static void goBack() {
    return navigatorKey.currentState!.pop();
  }
  
  /// Check if can go back
  static bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }
  
  /// Navigate back to a specific route
  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }
  
  /// Navigate to route and remove all previous routes
  static Future<dynamic> navigateToAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }
}