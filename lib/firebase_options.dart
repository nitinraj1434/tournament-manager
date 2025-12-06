import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Central place to keep every Firebase option so swapping projects/environments
/// only requires editing this single file.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return desktop;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not set up for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGRYTz1dYcf5Z0ye0g0m6jhzQNLW01eS8',
    appId: '1:663248295112:android:09e721d4735ea4a72741fd',
    messagingSenderId: '663248295112',
    projectId: 'harsh-b7193',
    storageBucket: 'harsh-b7193.firebasestorage.app',
    databaseURL: 'https://harsh-b7193-default-rtdb.firebaseio.com/',
  );

  // Placeholder configs for other platforms so the app keeps compiling even if
  // only Android is currently wired up. Update these before enabling those
  // targets.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '663248295112',
    projectId: 'harsh-b7193',
    storageBucket: 'harsh-b7193.firebasestorage.app',
    iosBundleId: 'com.example.turnament',
    databaseURL: 'https://harsh-b7193-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions desktop = FirebaseOptions(
    apiKey: 'REPLACE_WITH_DESKTOP_KEY',
    appId: 'REPLACE_WITH_DESKTOP_APP_ID',
    messagingSenderId: '663248295112',
    projectId: 'harsh-b7193',
    storageBucket: 'harsh-b7193.firebasestorage.app',
    databaseURL: 'https://harsh-b7193-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WEB_KEY',
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '663248295112',
    projectId: 'harsh-b7193',
    authDomain: 'harsh-b7193.firebaseapp.com',
    storageBucket: 'harsh-b7193.firebasestorage.app',
    measurementId: 'REPLACE_WITH_MEASUREMENT_ID',
    databaseURL: 'https://harsh-b7193-default-rtdb.firebaseio.com/',
  );
}
