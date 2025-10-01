import 'package:customer/themes/app_them_data.dart';
import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: isDarkTheme ? AppThemeData.surfaceDark : AppThemeData.surface,
      primaryColor: isDarkTheme ? AppThemeData.primary300 : AppThemeData.primary300,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      fontFamily: 'Outfit',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Outfit'),
        displayMedium: TextStyle(fontFamily: 'Outfit'),
        displaySmall: TextStyle(fontFamily: 'Outfit'),
        headlineLarge: TextStyle(fontFamily: 'Outfit'),
        headlineMedium: TextStyle(fontFamily: 'Outfit'),
        headlineSmall: TextStyle(fontFamily: 'Outfit'),
        titleLarge: TextStyle(fontFamily: 'Outfit'),
        titleMedium: TextStyle(fontFamily: 'Outfit'),
        titleSmall: TextStyle(fontFamily: 'Outfit'),
        bodyLarge: TextStyle(fontFamily: 'Outfit'),
        bodyMedium: TextStyle(fontFamily: 'Outfit'),
        bodySmall: TextStyle(fontFamily: 'Outfit'),
        labelLarge: TextStyle(fontFamily: 'Outfit'),
        labelMedium: TextStyle(fontFamily: 'Outfit'),
        labelSmall: TextStyle(fontFamily: 'Outfit'),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: isDarkTheme ? AppThemeData.grey700 : AppThemeData.grey300,
        dialTextStyle: TextStyle(fontWeight: FontWeight.bold, color: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800),
        dialTextColor: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800,
        hourMinuteTextColor: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800,
        dayPeriodTextColor: isDarkTheme ? AppThemeData.grey800 : AppThemeData.grey800,
      ),
    );
  }
}
