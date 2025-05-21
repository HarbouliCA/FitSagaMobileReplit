import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/config/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Allow splash screen to display for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Navigate based on authentication status
    if (authProvider.isAuthenticated) {
      _navigateToHome();
    } else {
      _navigateToLogin();
    }
  }
  
  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }
  
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(color: Colors.black, opacity: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // App Tagline
            Text(
              'Fitness Made Simple',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(color: Colors.white, opacity: 0.8),
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}