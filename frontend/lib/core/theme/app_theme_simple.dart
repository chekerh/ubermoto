import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32); // Uber Green
  static const Color secondaryColor = Color(0xFF000000); // Black
  static const Color accentColor = Color(0xFF00C853); // Green

  static ThemeData lightTheme(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.ltr;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // Text Theme with Arabic/English fonts
      textTheme: TextTheme(
        displayLarge: isRTL 
            ? GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold)
            : GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: isRTL 
            ? GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold)
            : GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
        headlineLarge: isRTL 
            ? GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600)
            : GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge: isRTL 
            ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500)
            : GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: isRTL 
            ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.normal)
            : GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: isRTL 
            ? GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.normal)
            : GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
        labelLarge: isRTL 
            ? GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500)
            : GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: isRTL 
            ? GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)
            : GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: isRTL 
              ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500)
              : GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
