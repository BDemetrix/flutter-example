import 'package:flutter/material.dart';

/// Цвета приложения.
/// Зона ответственности: централизованное хранение цветовых констант.
class AppColors {
  // static const MaterialColor primary = Colors.deepPurple;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const MaterialColor primary = MaterialColor(
    0xFF467480, // Основной цвет
    <int, Color>{
      50: Color(0xFFE8F0F2),
      100: Color(0xFFC5DCE2),
      200: Color(0xFF9FC7D0),
      300: Color(0xFF79B1BE),
      400: Color(0xFF5CA0B1),
      500: Color(0xFF467480), // Ваш основной цвет
      600: Color(0xFF3F6978),
      700: Color(0xFF375E6D),
      800: Color(0xFF2F5463),
      900: Color(0xFF204250),
    },
  );
}
