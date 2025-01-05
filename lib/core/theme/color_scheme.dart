import 'package:flutter/material.dart';

class AppColorScheme {
  // Ana renkler
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color secondaryColor = Color(0xFF50C878);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color surfaceColor = Colors.white;

  // Metin renkleri
  static const Color primaryTextColor = Color(0xFF2C3E50);
  static const Color secondaryTextColor = Color(0xFF95A5A6);

  // Gölge renkleri
  static Color shadowColor = Colors.black.withOpacity(0.05);

  // Durum renkleri
  static const Color successColor = Color(0xFF50C878);
  static const Color warningColor = Color(0xFFF1C40F);
  static const Color infoColor = Color(0xFF3498DB);

  static ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryTextColor,
      onBackground: primaryTextColor,
      onError: Colors.white,
    );
  }
}
