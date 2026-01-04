import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFF06543),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFF06543),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    foregroundColor: Colors.black,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold, fontSize: 24.0),
    headlineMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w600, fontSize: 20.0),
    bodyLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 16.0),
    bodyMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 14.0),
    labelLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold, fontSize: 18.0),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 2,
  ),
  // Add more customizations as needed
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFF06543),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFF06543),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold, fontSize: 24.0, color: Colors.white),
    headlineMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w600, fontSize: 20.0, color: Colors.white),
    bodyLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 16.0, color: Colors.white70),
    bodyMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 14.0, color: Colors.white70),
    labelLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    color: const Color(0xFF1E1E1E),
  ),
);