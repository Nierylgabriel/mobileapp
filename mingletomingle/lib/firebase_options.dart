import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
///dart
/// // ...
/// await Firebase.initializeApp(
///    options: DefaultFirebaseOptions.currentPlatform,
/// );
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
    apiKey: 'AIzaSyAO0M07CWO8dT52wnw0g5n796MCjClimJw',
    appId: '1:557404429223:web:9429ee01df9a4ec6cdb482',
    messagingSenderId: '557404429223',
    projectId: 'lootswap-3878b',
    authDomain: 'lootswap-3878b.firebaseapp.com',
    storageBucket: 'lootswap-3878b.firebasestorage.app',
    measurementId: 'G-C2GDJKX9W1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSahJBy8QJ99R5uqRNUa8NGU18NT0RLOI',
    appId: '1:557404429223:android:5f35ff87c632162acdb482',
    messagingSenderId: '557404429223',
    projectId: 'lootswap-3878b',
    storageBucket: 'lootswap-3878b.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAFOH96YowKMP7fyq-suGGSrlDDAKAk7cI',
    appId: '1:557404429223:ios:b0693c95f86f9e2bcdb482',
    messagingSenderId: '557404429223',
    projectId: 'lootswap-3878b',
    storageBucket: 'lootswap-3878b.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAFOH96YowKMP7fyq-suGGSrlDDAKAk7cI',
    appId: '1:557404429223:ios:b0693c95f86f9e2bcdb482',
    messagingSenderId: '557404429223',
    projectId: 'lootswap-3878b',
    storageBucket: 'lootswap-3878b.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAO0M07CWO8dT52wnw0g5n796MCjClimJw',
    appId: '1:557404429223:web:546feaa83325a15ecdb482',
    messagingSenderId: '557404429223',
    projectId: 'lootswap-3878b',
    authDomain: 'lootswap-3878b.firebaseapp.com',
    storageBucket: 'lootswap-3878b.firebasestorage.app',
    measurementId: 'G-1RMMSTQLJ3',
  );
}