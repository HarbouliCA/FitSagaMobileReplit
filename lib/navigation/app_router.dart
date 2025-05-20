import 'package:flutter/material.dart';
import 'package:fitsaga/navigation/app_navigation.dart';
import 'package:fitsaga/screens/auth/login_screen.dart';
import 'package:fitsaga/screens/auth/register_screen.dart';
import 'package:fitsaga/screens/profile/profile_screen.dart';
import 'package:fitsaga/screens/sessions/calendar_view_screen.dart';
import 'package:fitsaga/screens/bookings/my_bookings_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorial_list_screen.dart';
import 'package:fitsaga/screens/admin/admin_dashboard_screen.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

/// A class that manages app routes and navigation.
class AppRouter {
  /// Named routes for the app
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String sessions = '/sessions';
  static const String bookings = '/bookings';
  static const String tutorials = '/tutorials';
  static const String adminDashboard = '/admin/dashboard';

  /// Route generation function to be used with onGenerateRoute
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const AppNavigation());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case sessions:
        return MaterialPageRoute(builder: (_) => const CalendarViewScreen());
      
      case bookings:
        return MaterialPageRoute(builder: (_) => const MyBookingsScreen());
      
      case tutorials:
        return MaterialPageRoute(builder: (_) => const TutorialListScreen());
      
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
        
      default:
        // If route doesn't exist, show a not found error
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: CustomErrorWidget(
              message: 'The page "${settings.name}" was not found.',
              fullScreen: true,
              icon: Icons.error_outline,
            ),
          ),
        );
    }
  }

  /// Default route if no route is found
  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: CustomErrorWidget(
          message: 'The page "${settings.name}" was not found.',
          fullScreen: true,
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}