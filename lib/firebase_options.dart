import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase configuration options loaded from .env file.
///
/// Usage:
/// ```dart
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by adding macOS credentials to the .env file.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can reconfigure this by adding Windows credentials to the .env file.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by adding Linux credentials to the .env file.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['ANDROID_API_KEY'] ?? '',
        appId: dotenv.env['ANDROID_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['ANDROID_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['ANDROID_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['ANDROID_STORAGE_BUCKET'] ?? '',
      );

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['WEB_API_KEY'] ?? '',
        appId: dotenv.env['WEB_APP_ID'] ?? '',
        authDomain: dotenv.env['WEB_AUTH_DOMAIN'] ?? '',
        messagingSenderId: dotenv.env['WEB_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['WEB_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['WEB_STORAGE_BUCKET'] ?? '',
        measurementId: dotenv.env['WEB_MEASUREMENT_ID'] ?? '',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.env['IOS_API_KEY'] ?? '',
        appId: dotenv.env['IOS_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['IOS_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['IOS_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['IOS_STORAGE_BUCKET'] ?? '',
        iosBundleId: dotenv.env['IOS_BUNDLE_ID'] ?? '',
      );
}
