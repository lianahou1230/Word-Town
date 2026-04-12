import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundStart,
      fontFamily: 'Courier',
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.badgeText,
          fontFamily: 'Courier',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.choiceButtonText,
          fontFamily: 'Courier',
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: AppColors.choiceButtonText,
          fontFamily: 'Courier',
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.choiceButtonText,
          fontFamily: 'Courier',
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.choiceButtonText,
          fontFamily: 'Courier',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.choiceButtonText,
          fontFamily: 'Courier',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.choiceButtonBg,
          foregroundColor: AppColors.choiceButtonText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: AppColors.choiceButtonBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.inputFieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.inputFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.inputFieldFocusBorder, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontFamily: 'Courier',
        ),
      ),
    );
  }
}
