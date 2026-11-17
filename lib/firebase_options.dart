import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQBqhSzPWqTWH3ZeFLZYV0OtxtQNTocgc',
    appId: '1:883435653412:web:40a4e596a9714a163b8bb1',
    messagingSenderId: '883435653412',
    projectId: 'emplake-e2d55',
    authDomain: 'emplake-e2d55.firebaseapp.com',
    storageBucket: 'emplake-e2d55.firebasestorage.app',
  );
}