import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/screens/auth/login_screen.dart';
import 'package:fitsaga/screens/auth/register_screen.dart';
import 'package:fitsaga/screens/home/home_screen.dart';
import 'package:fitsaga/screens/sessions/sessions_screen.dart';
import 'package:fitsaga/screens/sessions/session_details_screen.dart';
import 'package:fitsaga/screens/sessions/booking_confirmation_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorials_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorial_details_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorial_video_screen.dart';
import 'package:fitsaga/screens/profile/profile_screen.dart';
import 'package:fitsaga/screens/splash_screen.dart';
import 'package:fitsaga/theme/app_theme.dart';

class FitSagaApp extends StatelessWidget {
  const FitSagaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSAGA',
      theme: ThemeData(
        primarySwatch: AppTheme.createMaterialColor(AppTheme.primaryColor),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(color: AppTheme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/sessions': (context) => const SessionsScreen(),
        '/sessions/details': (context) => const SessionDetailsScreen(),
        '/sessions/booking-confirmation': (context) => const BookingConfirmationScreen(),
        '/tutorials': (context) => const TutorialsScreen(),
        '/tutorials/details': (context) => const TutorialDetailsScreen(),
        '/tutorials/video': (context) => const TutorialVideoScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      builder: (context, child) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Show loading screen if auth state is being determined
            if (authProvider.isLoading) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                debugShowCheckedModeBanner: false,
              );
            }
            
            return child!;
          },
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}