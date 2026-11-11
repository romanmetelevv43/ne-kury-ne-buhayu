import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF101511);
  static const panel = Color(0xFF202923);
  static const panelAlt = Color(0xFF1D2920);
  static const green = Color(0xFF7FE69C);
  static const muted = Color(0xFFA8B9AA);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.dark)
        .copyWith(primary: green, secondary: green, surface: panel),
    appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: Colors.white),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF182019),
      indicatorColor: Color(0xFF31563A),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: panel,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}
