import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeNotifier extends Notifier<ThemeData> {
  @override
  ThemeData build() {
    _loadTheme();
    return lightTheme; // Default
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    state = isDark ? darkTheme : lightTheme;
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    state = isDark ? darkTheme : lightTheme;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(() => ThemeNotifier());