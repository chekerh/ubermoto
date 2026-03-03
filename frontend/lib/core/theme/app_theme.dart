import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32); // Uber Green
  static const Color secondaryColor = Color(0xFF000000); // Black
  static const Color accentColor = Color(0xFF00C853); // Green

  static const Color successColor = Color(0xFF00C853); // Green
  static const Color errorColor = Color(0xFFE53935); // Red
  static const Color dangerColor = Color(0xFFE53935); // Red
  static const Color warningColor = Color(0xFFFFA000); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue-500
  
  // Driver status colors
  static const Color driverOnlineColor = Color(0xFF00C853); // Green
  static const Color driverBusyColor = Color(0xFFFFA000); // Amber
  static const Color driverOfflineColor = Color(0xFF9E9E9E); // Grey

  static ThemeData lightTheme({required bool isArabic}) {
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Text Theme with Arabic/English fonts
      textTheme: TextTheme(
        displayLarge: isArabic
            ? GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold)
            : GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: isArabic
            ? GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold)
            : GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
        headlineLarge: isArabic
            ? GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600)
            : GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge: isArabic
            ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500)
            : GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: isArabic
            ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.normal)
            : GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: isArabic
            ? GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.normal)
            : GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
        labelLarge: isArabic
            ? GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500)
            : GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        background: Color(0xFFF8FAFC),
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: isArabic
            ? GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)
            : GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        iconTheme: const IconThemeData(color: Colors.black87),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        surfaceTintColor: primaryColor,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: isArabic
              ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500)
              : GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1E293B),
      background: Color(0xFF0F172A),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
  );
}
