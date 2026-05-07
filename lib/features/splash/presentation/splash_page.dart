import 'dart:math';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _cycleController;
  late final AnimationController _fadeController;
  late final Animation<double> _arcSweep;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Outer arc rotates clockwise — the "lock dial"
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Arc closes (270° → 360°), pauses as full circle (logo), then opens again
    _cycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _arcSweep = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.75)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_cycleController);

    _cycleController.repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _cycleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F6E8C),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_spinController, _cycleController]),
                  builder: (context, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating arc — closes into a full circle
                        Transform.rotate(
                          angle: _spinController.value * 2 * pi,
                          child: CustomPaint(
                            size: const Size(100, 100),
                            painter: _ArcPainter(
                              sweepFraction: _arcSweep.value,
                            ),
                          ),
                        ),
                        // G counter-rotates at 1/3 speed — inner lock cylinder
                        Transform.rotate(
                          angle: -_spinController.value * (2 * pi / 3),
                          child: const Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w300,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Garantir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double sweepFraction;

  const _ArcPainter({required this.sweepFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // starts at the top
      sweepFraction * 2 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.sweepFraction != sweepFraction;
}
