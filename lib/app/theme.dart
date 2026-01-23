import 'package:flutter/material.dart';

class AppTheme {
  // Calendar Style Palette
  // Light
  static const Color _lightBg = Color(0xFFF5F5F7); // Off-white
  static const Color _lightSurface = Color(0xFFFFFFFF); // White
  static const Color _lightText = Color(0xFF1D1B20); // Nearly Black
  
  // Dark
  static const Color _darkBg = Color(0xFF1C1C1E); // Dark Grey
  static const Color _darkSurface = Color(0xFF2C2C2E); // Lighter Grey
  static const Color _darkText = Color(0xFFF2F2F7); // Off-white

  // Accent
  static const Color _accent = Color(0xFFFF6B6B); // Coral/Orange from Calendar

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _accent,
        surface: _lightSurface,
        onSurface: _lightText,
        surfaceContainerHighest: Color(0xFFE5E5EA), // For inputs/banners
      ),
      scaffoldBackgroundColor: _lightBg,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: _lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _lightText),
      ),
      
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0, // Flat look with border or soft shadow via decoration usually
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34, 
          fontWeight: FontWeight.w700, 
          color: _lightText,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w700, 
          color: _lightText,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 17, 
          fontWeight: FontWeight.w400, 
          color: _lightText,
        ),
        bodyMedium: TextStyle(
          fontSize: 15, 
          fontWeight: FontWeight.w400, 
          color: Color(0xFF8E8E93), // Secondary text
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _accent,
        surface: _darkSurface,
        onSurface: _darkText,
        surfaceContainerHighest: Color(0xFF3A3A3C),
      ),
      scaffoldBackgroundColor: _darkBg,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: _darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _darkText),
      ),

      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34, 
          fontWeight: FontWeight.w700, 
          color: _darkText,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.w700, 
          color: _darkText,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 17, 
          fontWeight: FontWeight.w400, 
          color: _darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 15, 
          fontWeight: FontWeight.w400, 
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }
}
