import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitsaga/services/firebase_service.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/screens/sessions/calendar_view_screen.dart';
import 'package:fitsaga/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(firebaseService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => TutorialProvider(firebaseService),
        ),
      ],
      child: const FitSagaApp(),
    ),
  );
}

class FitSagaApp extends StatelessWidget {
  const FitSagaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSAGA',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const CalendarViewScreen(),
    const Placeholder(child: Center(child: Text('Tutorials'))),
    const Placeholder(child: Center(child: Text('Profile'))),
    const Placeholder(child: Center(child: Text('Admin'))),
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Load session data when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      sessionProvider.loadSessions();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sessions',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Tutorials',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          if (authProvider.isAuthenticated && 
              authProvider.currentUser?.isAdmin == true)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}