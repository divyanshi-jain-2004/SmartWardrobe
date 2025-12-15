import 'package:flutter/material.dart';

// आपके दिए गए AppColors का उपयोग
class AppColors {
  static const Color accentTeal = Color(0xFF00ADB5);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF8D8D8D);
  static const Color lightGrayBackground = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
}

class AppThemes {
  // ☀️ लाइट थीम
  static final ThemeData lightTheme = ThemeData(
      primaryColor: AppColors.accentTeal,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightGrayBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentTeal,
        secondary: AppColors.accentTeal,
        surface: AppColors.backgroundWhite, // Card/Container background
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundWhite,
        iconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.primaryText),
        bodyMedium: TextStyle(color: AppColors.primaryText),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) => AppColors.accentTeal),
        trackColor: MaterialStateProperty.resolveWith((states) => AppColors.accentTeal.withOpacity(0.5)),
      )
  );

  // 🌙 डार्क थीम
  static final ThemeData darkTheme = ThemeData(
      primaryColor: AppColors.accentTeal,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentTeal,
        secondary: AppColors.accentTeal,
        surface: AppColors.darkCard, // Card/Container background
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        iconTheme: IconThemeData(color: AppColors.backgroundWhite),
        titleTextStyle: TextStyle(color: AppColors.backgroundWhite, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.backgroundWhite),
        bodyMedium: TextStyle(color: AppColors.backgroundWhite),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) => AppColors.accentTeal),
        trackColor: MaterialStateProperty.resolveWith((states) => AppColors.accentTeal.withOpacity(0.5)),
      )
  );
}