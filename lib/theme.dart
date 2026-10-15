import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color palette ported from the LIMS web design tokens.
class C {
  static const bg = Color(0xFFF2F7FE);
  static const card = Color(0xFFFFFFFF);
  static const blue = Color(0xFF1B6EF3);
  static const blue2 = Color(0xFF0B4FCE);
  static const soft = Color(0xFFE9F2FF);
  static const softer = Color(0xFFF4F9FF);
  static const ink = Color(0xFF0D1B34);
  static const muted = Color(0xFF68758C);
  static const pink = Color(0xFFF43F5E);
  static const pinksoft = Color(0xFFFFEDF1);
  static const green = Color(0xFF12B76A);
  static const greensoft = Color(0xFFE7F8F0);
  static const amber = Color(0xFFF79009);
  static const ambersoft = Color(0xFFFEF3E4);
  static const violet = Color(0xFF7C5CFC);
  static const violet2 = Color(0xFF4F36D9);
  static const violetsoft = Color(0xFFF0EBFF);
  static const faint = Color(0xFF9AA8BF);
  static const line = Color(0xFFF0F5FC);
  static const border = Color(0xFFE2EAF6);
  static const dark = Color(0xFF0D1B34);

  static const blueGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7BF5), blue2],
  );
  static const violetGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet, violet2],
  );
  static const camGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1B33), Color(0xFF14294F)],
  );
  static const barGrad = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3D8BFF), blue],
  );
  static const progGrad = LinearGradient(
    colors: [Color(0xFF3D8BFF), blue],
  );
}

/// Icon tint colors by semantic key.
Color colorFor(String key) => switch (key) {
      'blue' => C.blue,
      'green' => C.green,
      'pink' => C.pink,
      'amber' => C.amber,
      'violet' => C.violet,
      _ => C.muted,
    };

/// Icon container background colors by semantic key.
Color bgFor(String key) => switch (key) {
      'blue' => C.soft,
      'green' => C.greensoft,
      'pink' => C.pinksoft,
      'amber' => C.ambersoft,
      'violet' => C.violetsoft,
      _ => const Color(0xFFEEF2F8),
    };

Color badgeBg(String key) => switch (key) {
      'green' => C.greensoft,
      'pink' => C.pinksoft,
      'amber' => C.ambersoft,
      'blue' => C.soft,
      _ => const Color(0xFFEEF2F8),
    };

Color badgeFg(String key) => switch (key) {
      'green' => C.green,
      'pink' => C.pink,
      'amber' => C.amber,
      'blue' => C.blue,
      _ => const Color(0xFF8494AB),
    };

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.blue,
      primary: C.blue,
      surface: C.card,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: C.ink, displayColor: C.ink),
  );
}
