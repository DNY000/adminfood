// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyACFZSy-6T7Y7Fq2YvIT8J-kJNSr7MXFdU',
    appId: '1:44206956684:web:2e75f3fa3b36cf5e8f9ba9',
    messagingSenderId: '44206956684',
    projectId: 'foodapp-daade',
    authDomain: 'foodapp-daade.firebaseapp.com',
    storageBucket: 'foodapp-daade.appspot.com',
    measurementId: 'G-TW60RW22ZH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMkUV4BSvwKL2NP6mwo_0-b-BEtiXYgFs',
    appId: '1:44206956684:android:1ebde9c85df6ac678f9ba9',
    messagingSenderId: '44206956684',
    projectId: 'foodapp-daade',
    storageBucket: 'foodapp-daade.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2ma-Oq1ktQWSyrW6Fj49yCqUPMQki0ng',
    appId: '1:44206956684:ios:5b3ed87a39d8fdb88f9ba9',
    messagingSenderId: '44206956684',
    projectId: 'foodapp-daade',
    storageBucket: 'foodapp-daade.appspot.com',
    androidClientId: '44206956684-l7ve5tnlk78vfg8h63v3cai4i41rvv4p.apps.googleusercontent.com',
    iosClientId: '44206956684-p80p3jh54nl86ccmpkgell56atq34k3t.apps.googleusercontent.com',
    iosBundleId: 'com.example.admin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA2ma-Oq1ktQWSyrW6Fj49yCqUPMQki0ng',
    appId: '1:44206956684:ios:5b3ed87a39d8fdb88f9ba9',
    messagingSenderId: '44206956684',
    projectId: 'foodapp-daade',
    storageBucket: 'foodapp-daade.appspot.com',
    androidClientId: '44206956684-l7ve5tnlk78vfg8h63v3cai4i41rvv4p.apps.googleusercontent.com',
    iosClientId: '44206956684-p80p3jh54nl86ccmpkgell56atq34k3t.apps.googleusercontent.com',
    iosBundleId: 'com.example.admin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0gQKzlutBuGgTNk74u_me6snkCLMuB8g',
    appId: '1:44206956684:web:b7c909eeebe4eec08f9ba9',
    messagingSenderId: '44206956684',
    projectId: 'foodapp-daade',
    authDomain: 'foodapp-daade.firebaseapp.com',
    storageBucket: 'foodapp-daade.appspot.com',
    measurementId: 'G-BQQF4P0MBP',
  );
}
