import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'firebase_options.dart';

// Web entry point — does NOT initialize Isar (dart:ffi incompatível com web).
// ProductRepository detecta kIsWeb e usa Firestore real-time streams.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6LeWud4sAAAAAEzyrtnulPxqqnv3iqPLfwipZDct'),
  );

  runApp(const SoyYoApp());
}
