import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color darkBgStart = Color(0xFF0A0F1D);
  static const Color darkBgEnd = Color(0xFF16132D);
  
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color moneyGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  
  // Card colors
  static const Color glassCardBg = Color(0x12FFFFFF);
  static const Color glassCardBorder = Color(0x24FFFFFF);
  static const Color glassCardShadow = Color(0x1F000000);

  // Gradient definitions
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), moneyGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkBackgroundGradient = LinearGradient(
    colors: [darkBgStart, darkBgEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Main Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Colors.transparent, // Handled by background gradient wrapper
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentIndigo,
        surface: Color(0xFF151929),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE2E8F0),
        error: errorRed,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF64748B),
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0x1FFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.glassCardBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F1222),
        selectedItemColor: primaryBlue,
        unselectedItemColor: Color(0xFF64748B),
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryBlue,
        inactiveTrackColor: const Color(0x33FFFFFF),
        thumbColor: Colors.white,
        overlayColor: primaryBlue.withOpacity(0.2),
        valueIndicatorColor: Color(0xFF151929),
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
