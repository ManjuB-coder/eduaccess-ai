import 'package:firebase_core/firebase_core.dart';
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

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "",
    appId: "",
    messagingSenderId: "68827941974",
    projectId: "eduaccessai",
    authDomain: "eduaccessai.firebaseapp.com",
    storageBucket: "eduaccessai.firebasestorage.app",
    measurementId: "G-D2HBF12EFP",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "",
    appId: "",
    messagingSenderId: "68827941974",
    projectId: "eduaccessai",
    storageBucket: "eduaccessai.firebasestorage.app",
  );
}
