import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  // Configuration for web platform - for demo purposes
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForWebPlatform12345',
    appId: '1:1234567890:web:demo1234567890',
    messagingSenderId: '1234567890',
    projectId: 'fitsaga-demo',
    authDomain: 'fitsaga-demo.firebaseapp.com',
    storageBucket: 'fitsaga-demo.appspot.com',
    measurementId: 'G-DEMO12345',
  );

  // Configuration for Android platform - for demo purposes
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForAndroidPlatform12345',
    appId: '1:1234567890:android:demo1234567890',
    messagingSenderId: '1234567890',
    projectId: 'fitsaga-demo',
    storageBucket: 'fitsaga-demo.appspot.com',
  );

  // Configuration for iOS platform - for demo purposes
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForIOSPlatform12345',
    appId: '1:1234567890:ios:demo1234567890',
    messagingSenderId: '1234567890',
    projectId: 'fitsaga-demo',
    storageBucket: 'fitsaga-demo.appspot.com',
    iosClientId: 'demo.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitsaga',
  );

  // Configuration for macOS platform - for demo purposes
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForMacOSPlatform12345',
    appId: '1:1234567890:ios:demo1234567890',
    messagingSenderId: '1234567890',
    projectId: 'fitsaga-demo',
    storageBucket: 'fitsaga-demo.appspot.com',
    iosClientId: 'demo.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitsaga',
  );
}