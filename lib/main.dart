import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/navigation/app_navigation.dart';
import 'package:fitsaga/navigation/navigation_service.dart';
import 'package:fitsaga/navigation/app_router.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/app_state_provider.dart';
import 'package:fitsaga/services/booking_service.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/utils/error_handler.dart';
import 'package:fitsaga/utils/connection_status_notifier.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/network_error_handler.dart';
import 'package:fitsaga/widgets/common/animated_logo.dart';
import 'package:fitsaga/firebase_options.dart';

/// Global navigation service for app-wide access
final NavigationService navigationService = NavigationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Continue with app anyway (will use demo mode)
    debugPrint('Error initializing Firebase: $e');
  }
  
  // Run the app inside an error boundary
  runApp(const AppErrorBoundary(child: MyApp()));
}

/// Error boundary widget to catch and handle errors at the app level
class AppErrorBoundary extends StatefulWidget {
  final Widget child;
  
  const AppErrorBoundary({Key? key, required this.child}) : super(key: key);
  
  @override
  _AppErrorBoundaryState createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  bool _hasError = false;
  dynamic _error;
  
  @override
  void initState() {
    super.initState();
    
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _hasError = true;
        _error = details.exception;
      });
      
      // Log error
      FlutterError.dumpErrorToConsole(details);
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: CustomErrorWidget(
            message: 'Something went wrong with the app. Please restart the app and try again.\n\nError: ${_error.toString()}',
            fullScreen: true,
            onRetry: () {
              setState(() {
                _hasError = false;
                _error = null;
              });
            },
          ),
        ),
      );
    }
    
    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // App state
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        
        // Network connectivity
        ChangeNotifierProvider(create: (_) => ConnectionStatusNotifier()),
        
        // Authentication
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Services
        Provider(create: (_) => BookingService()),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final themeMode = appState.themeMode;
          
          return MaterialApp(
            title: 'FitSAGA',
            debugShowCheckedModeBanner: false,
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme, // Replace with dark theme later
            themeMode: themeMode,
            
            // Navigation
            navigatorKey: navigationService.navigatorKey,
            initialRoute: '/',
            onGenerateRoute: AppRouter.generateRoute,
            onUnknownRoute: AppRouter.unknownRoute,
            
            // Home
            home: const AppStartupHandler(),
          );
        },
      ),
    );
  }
}

class AppStartupHandler extends StatefulWidget {
  const AppStartupHandler({Key? key}) : super(key: key);

  @override
  _AppStartupHandlerState createState() => _AppStartupHandlerState();
}

class _AppStartupHandlerState extends State<AppStartupHandler> {
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check network connectivity
      final connectionStatus = Provider.of<ConnectionStatusNotifier>(context, listen: false);
      await connectionStatus.checkConnectivity();
      
      // Initialize app state
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      
      // Simulate loading resources
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, set a demo user
      // In a real app, this would happen automatically via Firebase auth state changes
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // You can change this to test different user roles:
      // authProvider.setDemoUser(); // Regular user
      // authProvider.setDemoUser(isInstructor: true); // Instructor
      authProvider.setDemoUser(isAdmin: true); // Admin
      
    } catch (e) {
      setState(() {
        _error = ErrorHandler.handleError(e);
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check network connection
    final connectionStatus = Provider.of<ConnectionStatusNotifier>(context);
    final bool isConnected = connectionStatus.isConnected;
    
    // Show initialization states
    if (_isInitializing) {
      return const LoadingScreen();
    }
    
    if (!isConnected) {
      return const NetworkErrorScreen();
    }
    
    if (_error != null) {
      return ErrorScreen(message: _error!);
    }
    
    // Check authentication
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAuthenticated = authProvider.isAuthenticated;
    
    // Navigate based on authentication status
    if (!isAuthenticated) {
      return const WelcomeScreen();
    }
    
    // Show main app navigation for authenticated users
    return const AppNavigation();
  }
}

class NetworkErrorScreen extends StatelessWidget {
  const NetworkErrorScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NetworkErrorWidget(
        fullScreen: true,
        onRetry: () {
          // Refresh connection status and restart app initialization
          final connectionStatus = Provider.of<ConnectionStatusNotifier>(context, listen: false);
          connectionStatus.checkConnectivity();
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AppStartupHandler()),
          );
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use custom animated logo
            const AnimatedLogo(
              size: 180,
              animate: true,
              showText: false,
            ),
            const SizedBox(height: 32),
            const Text(
              'FitSAGA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Fitness Journey Starts Here',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;
  
  const ErrorScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomErrorWidget(
        message: message,
        fullScreen: true,
        onRetry: () {
          // Restart the app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AppStartupHandler()),
          );
        },
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // App logo (replace with actual logo)
              const Icon(
                Icons.fitness_center,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: 32),
              
              // App name
              const Text(
                'FitSAGA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              const Text(
                'Your Fitness Journey Starts Here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Introduction text
              const Text(
                'Get access to professional fitness sessions, personalized tutorials, and track your progress all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              
              const Spacer(),
              
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Register button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.register);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Continue as guest button
              TextButton(
                onPressed: () {
                  // Use demo mode with a demo user
                  Provider.of<AuthProvider>(context, listen: false).setDemoUser();
                },
                child: const Text('Continue as Guest'),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}