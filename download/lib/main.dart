import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitsaga/app.dart';
import 'package:fitsaga/firebase_options.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with configuration options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  
  // Initialize Firebase service
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => TutorialProvider()),
        ChangeNotifierProvider(create: (_) => CreditProvider()),
      ],
      child: const FitSagaApp(),
    ),
  );
}