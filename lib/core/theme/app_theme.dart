import 'package:flutter/material.dart';

class AppTheme {
  // Palette inspirée de Binance
  static const _binanceYellow = Color(0xFFF0B90B);
  static const _binanceBackground = Color(0xFF0B0E11);
  static const _binanceSurface = Color(0xFF181A20);
  static const _binanceGrey = Color(0xFFB7BDC6);

  // Thème clair (optionnel) mais gardant les couleurs Binance
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _binanceYellow,
      onPrimary: Colors.black,
      secondary: _binanceGrey,
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: _binanceYellow,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 22),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _binanceYellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _binanceYellow,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _binanceYellow),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black,
      ),
    );
  }

  // Thème sombre proche du style Binance
  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _binanceYellow,
      onPrimary: _binanceBackground,
      secondary: _binanceGrey,
      onSecondary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: _binanceSurface,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _binanceBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _binanceSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: _binanceYellow,
        unselectedItemColor: _binanceGrey,
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 22),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _binanceYellow,
          foregroundColor: _binanceBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _binanceYellow,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _binanceSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: _binanceYellow),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: _binanceGrey,
      ),
      iconTheme: const IconThemeData(color: _binanceGrey),
    );
  }
}
