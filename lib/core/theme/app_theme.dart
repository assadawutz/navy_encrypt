import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF003049),
        secondary: const Color(0xFF669BBC),
      ),
      textTheme: GoogleFonts.promptTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        backgroundColor: const Color(0xFFEAE2B7),
        foregroundColor: const Color(0xFF003049),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF669BBC),
        secondary: const Color(0xFFFFB703),
      ),
      textTheme: GoogleFonts.promptTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xFF101828),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
      ),
    );
  }
}
