import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

final localizationServiceProvider = Provider((ref) => LocalizationService());

class LocalizationService {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  static const Locale fallbackLocale = Locale('en', 'US');

  static const Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
  };

  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'ar': '🇸🇦',
  };

  static bool isRTL(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  static bool getTextDirection(BuildContext context) {
    return isRTL(context);
  }

  static AlignmentGeometry getAlignment(BuildContext context) {
    return isRTL(context) 
        ? Alignment.centerRight 
        : Alignment.centerLeft;
  }

  static EdgeInsetsDirectional getPadding(BuildContext context) {
    return isRTL(context)
        ? const EdgeInsetsDirectional.only(start: 16.0, end: 8.0)
        : const EdgeInsetsDirectional.only(start: 8.0, end: 16.0);
  }

  static TextStyle getArabicTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle getEnglishTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle getLocalizedTextStyle(BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final isArabic = context.locale.languageCode == 'ar';
    
    if (isArabic) {
      return getArabicTextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } else {
      return getEnglishTextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }

  static String formatNumber(BuildContext context, int number) {
    final locale = context.locale;
    if (locale.languageCode == 'ar') {
      // Convert to Arabic-Indic digits
      final arabicDigits = '٠١٢٣٤٥٦٧٨٩';
      return number.toString().split('').map((digit) {
        if (digit.contains(RegExp(r'[0-9]'))) {
          return arabicDigits[int.parse(digit)];
        }
        return digit;
      }).join('');
    }
    return number.toString();
  }

  static String formatCurrency(BuildContext context, double amount) {
    final locale = context.locale;
    final formattedAmount = amount.toStringAsFixed(2);
    
    if (locale.languageCode == 'ar') {
      // Arabic currency format
      return '$formattedAmount ر.س';
    } else {
      // English currency format
      return '\$$formattedAmount';
    }
  }

  static String formatDate(BuildContext context, DateTime date) {
    final locale = context.locale;
    
    if (locale.languageCode == 'ar') {
      // Arabic date format
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } else {
      // English date format
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  static Future<void> changeLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
  }

  static Locale getCurrentLocale(BuildContext context) {
    return context.locale;
  }

  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  static String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🏳️';
  }
}
