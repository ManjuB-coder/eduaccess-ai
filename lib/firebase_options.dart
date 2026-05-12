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
    apiKey: "AIzaSyDX7FJwaOFoWseuPyBpI7_9ZRXemlLFIQM",
    appId: "1:68827941974:web:57c994577611641025bff7",
    messagingSenderId: "68827941974",
    projectId: "eduaccessai",
    authDomain: "eduaccessai.firebaseapp.com",
    storageBucket: "eduaccessai.firebasestorage.app",
    measurementId: "G-D2HBF12EFP",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDX7FJwaOFoWseuPyBpI7_9ZRXemlLFIQM",
    appId: "1:68827941974:android:57c994577611641025bff7",
    messagingSenderId: "68827941974",
    projectId: "eduaccessai",
    storageBucket: "eduaccessai.firebasestorage.app",
  );
}
