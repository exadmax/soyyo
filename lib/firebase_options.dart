import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
          'Plataforma nao configurada. Rode flutterfire configure para gerar este arquivo.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'WEB_API_KEY',
    appId: 'WEB_APP_ID',
    messagingSenderId: 'WEB_MESSAGING_SENDER_ID',
    projectId: 'WEB_PROJECT_ID',
    authDomain: 'WEB_AUTH_DOMAIN',
    storageBucket: 'WEB_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ANDROID_API_KEY',
    appId: 'ANDROID_APP_ID',
    messagingSenderId: 'ANDROID_MESSAGING_SENDER_ID',
    projectId: 'ANDROID_PROJECT_ID',
    storageBucket: 'ANDROID_STORAGE_BUCKET',
  );
}
