import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashPage(),
    ),
  );
}
