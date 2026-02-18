import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching the website theme
  static const Color primaryColor = Color(0xFFCBFE1C); // Theme color (lime green)
  static const Color backgroundColor = Color(0xFF0B0E13); // Dark background
  static const Color secondaryBackground = Color(0xFF1C1D20); // Secondary bg
  static const Color textColor = Color(0xFFABABAB); // Text color
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color borderColor = Color(0x33FFFFFF); // Border with opacity

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: secondaryBackground,
        background: backgroundColor,
        error: Colors.red,
        onPrimary: black,
        onSecondary: black,
        onSurface: white,
        onBackground: white,
        onError: white,
      ),
      fontFamily: 'ChakraPetch',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: 140,
          fontWeight: FontWeight.w400,
          color: white,
          letterSpacing: -3.2,
        ),
        displayMedium: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: 52,
          fontWeight: FontWeight.w400,
          color: white,
          letterSpacing: -1.04,
        ),
        displaySmall: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'ChakraPetch',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.75,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'ChakraPetch',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          fontFamily: 'DaysOne',
          fontSize: 20,
          color: white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: black,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'ChakraPetch',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}

