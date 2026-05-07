import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/products/presentation/products_page.dart';
import '../features/splash/presentation/splash_page.dart';

class SoyYoApp extends StatelessWidget {
  const SoyYoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garantir',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashPage();
          }
          if (snapshot.data != null) {
            return const ProductsPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
