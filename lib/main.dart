import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitsaga/app.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/user_provider.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDSlxOUyJ-OM1TTpYcxAZijlSdKxZZ76Xo",
      authDomain: "fitsaga-gym.firebaseapp.com",
      projectId: "fitsaga-gym",
      storageBucket: "fitsaga-gym.appspot.com",
      messagingSenderId: "709232933888",
      appId: "1:709232933888:web:4f67e8fa8b23e5c0573d55",
      measurementId: "G-NB1C8Z6ZC1"
    ),
  );
  
  // Initialize services
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => UserProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => SessionProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => TutorialProvider(firebaseService)),
        ChangeNotifierProvider(create: (_) => CreditProvider(firebaseService)),
      ],
      child: const FitSagaApp(),
    ),
  );
}