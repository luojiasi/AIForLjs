import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF4A90D9),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF4A90D9),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      );
}
