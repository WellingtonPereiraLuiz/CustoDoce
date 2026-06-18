import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCLvavDQjfYQIGpMDj-Vh8brdI6nOWEmZ0',
    appId: '1:842901176561:web:8cb708c8c0f5305f646950',
    messagingSenderId: '842901176561',
    projectId: 'custodoce-b07ce',
    authDomain: 'custodoce-b07ce.firebaseapp.com',
    storageBucket: 'custodoce-b07ce.firebasestorage.app',
    measurementId: 'G-JTLSYK3DP4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLvavDQjfYQIGpMDj-Vh8brdI6nOWEmZ0',
    appId: '1:842901176561:android:e2fc4b41d75fbb83646950',
    messagingSenderId: '842901176561',
    projectId: 'custodoce-b07ce',
    storageBucket: 'custodoce-b07ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLvavDQjfYQIGpMDj-Vh8brdI6nOWEmZ0',
    appId: String.fromEnvironment('FIREBASE_APP_ID_IOS', defaultValue: ''),
    messagingSenderId: '842901176561',
    projectId: 'custodoce-b07ce',
    storageBucket: 'custodoce-b07ce.firebasestorage.app',
    iosBundleId: 'com.custodoce.app',
  );
}
