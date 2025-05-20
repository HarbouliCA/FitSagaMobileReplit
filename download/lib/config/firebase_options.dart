import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for FitSAGA app
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD3MAuIYZ2dGq5hspUvxK4KeNIbVzw6EaQ',
    appId: '1:360667066098:web:93bef4a0c957968c67aa6b',
    messagingSenderId: '360667066098',
    projectId: 'saga-fitness',
    authDomain: 'saga-fitness.firebaseapp.com',
    storageBucket: 'saga-fitness.appspot.com',
    measurementId: 'G-GCZRZ22EYL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvfH-loyKanakWeQhHCIBfeAIVF-aFW5o',
    appId: '1:360667066098:android:971b0615ac5882d267aa6b',
    messagingSenderId: '360667066098',
    projectId: 'saga-fitness',
    storageBucket: 'saga-fitness.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD3MAuIYZ2dGq5hspUvxK4KeNIbVzw6EaQ',
    appId: '1:360667066098:ios:971b0615ac5882d267aa6b',
    messagingSenderId: '360667066098',
    projectId: 'saga-fitness',
    storageBucket: 'saga-fitness.firebasestorage.app',
    iosClientId: '360667066098-ios-client-id',
    iosBundleId: 'com.fitsaga.fitsagaFlutter',
  );
}
