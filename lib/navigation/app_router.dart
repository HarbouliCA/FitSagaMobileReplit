import 'package:flutter/material.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/screens/auth/login_screen.dart';
import 'package:fitsaga/screens/auth/register_screen.dart';
import 'package:fitsaga/screens/home/home_screen.dart';
import 'package:fitsaga/screens/profile/profile_screen.dart';
import 'package:fitsaga/screens/sessions/calendar_view_screen.dart';
import 'package:fitsaga/screens/sessions/booking_screen.dart';
import 'package:fitsaga/screens/sessions/session_detail_screen.dart';
import 'package:fitsaga/screens/sessions/user_bookings_screen.dart';
import 'package:fitsaga/screens/sessions/booking_confirmation_screen.dart';
import 'package:fitsaga/screens/credits/credit_management_screen.dart';
import 'package:fitsaga/screens/credits/credit_history_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorial_list_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorial_detail_screen.dart';

/// Class responsible for defining all app routes
class AppRouter {
  // Route names
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String sessions = '/sessions';
  static const String sessionDetail = '/sessions/detail';
  static const String bookings = '/bookings';
  static const String userBookings = '/user/bookings';
  static const String tutorials = '/tutorials';
  static const String tutorialDetail = '/tutorials/detail';
  static const String creditManagement = '/credits';
  static const String creditHistory = '/credits/history';
  static const String instructorDashboard = '/instructor/dashboard';
  static const String adminDashboard = '/admin/dashboard';

  /// Generate routes based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case sessions:
        return MaterialPageRoute(
          builder: (_) => const CalendarViewScreen(),
          settings: settings,
        );

      case sessionDetail:
        final SessionModel session = settings.arguments as SessionModel;
        return MaterialPageRoute(
          builder: (_) => SessionDetailScreen(session: session),
          settings: settings,
        );

      case bookings:
        return MaterialPageRoute(
          builder: (_) => const BookingScreen(),
          settings: settings,
        );
        
      case userBookings:
        return MaterialPageRoute(
          builder: (_) => const UserBookingsScreen(),
          settings: settings,
        );

      case tutorials:
        return MaterialPageRoute(
          builder: (_) => const TutorialListScreen(),
          settings: settings,
        );
        
      case creditManagement:
        return MaterialPageRoute(
          builder: (_) => const CreditManagementScreen(),
          settings: settings,
        );
        
      case creditHistory:
        return MaterialPageRoute(
          builder: (_) => const CreditHistoryScreen(),
          settings: settings,
        );

      case tutorialDetail:
        final Tutorial tutorial = settings.arguments as Tutorial;
        return MaterialPageRoute(
          builder: (_) => TutorialDetailScreen(tutorial: tutorial),
          settings: settings,
        );

      case instructorDashboard:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Instructor Dashboard - Coming Soon'),
            ),
          ),
          settings: settings,
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Admin Dashboard - Coming Soon'),
            ),
          ),
          settings: settings,
        );

      default:
        // If the route is not defined, return a 404 page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(
              child: Text('Page not found'),
            ),
          ),
          settings: settings,
        );
    }
  }
}