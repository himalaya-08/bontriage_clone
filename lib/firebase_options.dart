// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
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
          'DefaultFirebaseOptions have not been configured for macos - '
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwZfC0Ns5u86McGtXXEurKmFAoS_drpgI',
    appId: '1:564280065480:web:c501fac65979462a5014fd',
    messagingSenderId: '564280065480',
    projectId: 'bontriage-71c9d',
    authDomain: 'bontriage-71c9d.firebaseapp.com',
    storageBucket: 'bontriage-71c9d.appspot.com',
    measurementId: 'G-4R63TGWRX5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDyXnSvqbDlk80aHDIo-XOlS3X3Y_Cs33g',
    appId: '1:564280065480:android:191f50f2aec95cdb5014fd',
    messagingSenderId: '564280065480',
    projectId: 'bontriage-71c9d',
    storageBucket: 'bontriage-71c9d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJo8b78hZxTWX1-OK5cNVG5FGEXB7XAYE',
    appId: '1:564280065480:ios:ee3554fe39d0e6205014fd',
    messagingSenderId: '564280065480',
    projectId: 'bontriage-71c9d',
    storageBucket: 'bontriage-71c9d.appspot.com',
    androidClientId: '564280065480-20ag1s2a7kkkspbacjtk1aegs21uc409.apps.googleusercontent.com',
    iosClientId: '564280065480-7vaee4f90add5cr8ulabp9d7l3mjq0kj.apps.googleusercontent.com',
    iosBundleId: 'com.bontriage.mobile',
  );
}
