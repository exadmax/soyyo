import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/splash/presentation/splash_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const _GarantirWeb());
}

class _GarantirWeb extends StatelessWidget {
  const _GarantirWeb();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garantir',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _WebAuthGate(),
    );
  }
}

class _WebAuthGate extends StatefulWidget {
  const _WebAuthGate();

  @override
  State<_WebAuthGate> createState() => _WebAuthGateState();
}

class _WebAuthGateState extends State<_WebAuthGate> {
  bool _splashDone = false;
  bool _authResolved = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
          _authResolved = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget page;

    if (!_splashDone || !_authResolved) {
      page = SplashPage(
        key: const ValueKey('splash'),
        onDone: () {
          if (mounted) setState(() => _splashDone = true);
        },
      );
    } else if (_user != null) {
      page = const _WebHome(key: ValueKey('home'));
    } else {
      page = const LoginPage(key: ValueKey('login'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: page,
    );
  }
}

class _WebHome extends StatelessWidget {
  const _WebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F6E8C),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android_rounded, size: 72, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Garantir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Baixe o app no Android para\ngerenciar suas garantias.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout, color: Colors.white54, size: 18),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
