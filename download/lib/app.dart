import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/screens/auth/login_screen.dart';
import 'package:fitsaga/screens/auth/register_screen.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';

class FitSagaApp extends StatefulWidget {
  const FitSagaApp({Key? key}) : super(key: key);

  @override
  State<FitSagaApp> createState() => _FitSagaAppState();
}

class _FitSagaAppState extends State<FitSagaApp> {
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    
    if (mounted) {
      setState(() {
        _initializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.getTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: ThemeMode.light, // Default to light theme
      debugShowCheckedModeBanner: false,
      home: _initializing
          ? _buildLoadingScreen()
          : _buildHomeScreen(),
      routes: _buildRoutes(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: LoadingIndicator(
        message: 'Starting FitSAGA...',
      ),
    );
  }

  Widget _buildHomeScreen() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is authenticated
    if (authProvider.isAuthenticated) {
      // User is logged in, redirect to dashboard/home based on role
      return _buildAuthenticatedScreen(authProvider);
    } else {
      // User is not logged in, show login screen
      return const LoginScreen();
    }
  }

  Widget _buildAuthenticatedScreen(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const LoginScreen();
    }
    
    // For now, redirect to a placeholder HomeScreen
    // Later, we'll implement role-based routing to different home screens
    return const Scaffold(
      body: Center(
        child: Text('Welcome to FitSAGA! Home screen coming soon.'),
      ),
    );
    
    // TODO: Implement role-based routing
    /*
    // Based on user role, redirect to the appropriate home screen
    if (user.isAdmin) {
      return const AdminHomeScreen();
    } else if (user.isInstructor) {
      return const InstructorHomeScreen();
    } else {
      return const ClientHomeScreen();
    }
    */
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      // TODO: Add more routes as screens are implemented
      /*
      '/forgot-password': (context) => const ForgotPasswordScreen(),
      '/home': (context) => const HomeScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/sessions': (context) => const SessionsScreen(),
      '/tutorial': (context) => const TutorialsScreen(),
      '/credits': (context) => const CreditsScreen(),
      '/admin/users': (context) => const AdminUsersScreen(),
      '/admin/sessions': (context) => const AdminSessionsScreen(),
      '/instructor/sessions': (context) => const InstructorSessionsScreen(),
      '/instructor/tutorials': (context) => const InstructorTutorialsScreen(),
      */
    };
  }
}