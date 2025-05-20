import 'package:flutter/material.dart';

/// A service that manages app navigation through a centralized API.
///
/// This service allows navigation to be performed from anywhere in the app
/// without requiring a BuildContext, making it useful for services and providers.
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Gets the current navigator state
  NavigatorState? get navigator => navigatorKey.currentState;
  
  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }
  
  /// Replace the current route with a new named route
  Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }
  
  /// Navigate to a named route and remove all previous routes
  Future<dynamic> navigateToAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName, 
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }
  
  /// Pop the current route
  void goBack() {
    return navigator!.pop();
  }
  
  /// Pop to a specific route
  void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }
  
  /// Navigate to a new page using MaterialPageRoute
  Future<dynamic> navigateToPage(Widget page) {
    return navigator!.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  /// Replace the current route with a new page
  Future<dynamic> replaceWithPage(Widget page) {
    return navigator!.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  /// Navigate to a new page and remove all previous routes
  Future<dynamic> navigateToPageAndRemoveUntil(Widget page) {
    return navigator!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (Route<dynamic> route) => false,
    );
  }

  /// Check if we can go back from the current route
  bool canGoBack() {
    return navigator!.canPop();
  }
}