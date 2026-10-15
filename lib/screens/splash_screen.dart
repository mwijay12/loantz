import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;

  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..repeat();
  late final AnimationController _bar = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..repeat();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, .45, 1],
            colors: [Color(0xFF2E7BF5), C.blue, Color(0xFF0A3FA8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -110,
              child: _circle(340, .07),
            ),
            Positioned(
              bottom: -70,
              left: -90,
              child: _circle(260, .07),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) {
                          final t = _pulse.value;
                          return Transform.scale(
                            scale: 1 + .7 * t,
                            child: Opacity(
                              opacity: (1 - t) * .8,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.view_in_ar_rounded,
                            size: 46, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('LIMS',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.5)),
                  const SizedBox(height: 6),
                  const Text('Loan & Inventory Management System',
                      style: TextStyle(
                          color: Color(0xD9FFFFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 34),
                  // Loading bar
                  SizedBox(
                    width: 170,
                    height: 5,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.25),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _bar,
                          builder: (context, _) => Positioned(
                            top: 0,
                            bottom: 0,
                            left: -68 + 238 * _bar.value,
                            child: Container(
                              width: 68,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Version 2.4 · Mbezi Branch',
                      style: TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}
