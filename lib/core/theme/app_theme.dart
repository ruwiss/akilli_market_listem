import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'app_theme_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.lightColorScheme,
      appBarTheme: AppThemeConstants.appBarTheme,
      cardTheme: AppThemeConstants.cardTheme,
      checkboxTheme: AppThemeConstants.checkboxTheme,
      elevatedButtonTheme: AppThemeConstants.elevatedButtonTheme,
      bottomNavigationBarTheme: AppThemeConstants.bottomNavigationBarTheme,
    );
  }
}
