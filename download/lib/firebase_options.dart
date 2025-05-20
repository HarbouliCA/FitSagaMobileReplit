// File generated based on the Firebase configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the FitSAGA app
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // For mobile platforms
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Firebase configuration options for the Android platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvfH-loyKanakWeQhHCIBfeAIVF-aFW5o',
    appId: '1:360667066098:android:971b0615ac5882d267aa6b',
    messagingSenderId: '360667066098',
    projectId: 'saga-fitness',
    storageBucket: 'saga-fitness.firebasestorage.app',
  );

  /// Firebase configuration options for the iOS platform
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvfH-loyKanakWeQhHCIBfeAIVF-aFW5o', // Using the same API key as Android
    appId: '1:360667066098:ios:xxxxxxxxxxxxxxx', // Placeholder - need actual iOS appId
    messagingSenderId: '360667066098',
    projectId: 'saga-fitness',
    storageBucket: 'saga-fitness.firebasestorage.app',
    // iosClientId: 'iOS client ID from google-services.json',
    // iosBundleId: 'com.fitsaga.fitsaga_flutter',
  );

  /// Firebase configuration options for the Web platform
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvfH-loyKanakWeQhHCIBfeAIVF-aFW5o', // Using the same API key
    appId: '1:360667066098:web:xxxxxxxxxxxxxxx', // Placeholder - need actual Web appId
    messagingSenderId: '360667066098',
    projectId: 'saga-fitness',
    storageBucket: 'saga-fitness.firebasestorage.app',
    // authDomain: 'saga-fitness.firebaseapp.com',
  );
}