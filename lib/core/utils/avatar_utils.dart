import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_example/core/di/injection.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Утилиты для работы с аватарами.
/// Зона ответственности: генерация аватаров с градиентным фоном и первой буквой имени.
class AvatarUtils {
  /// Генерация изображения с первой буквой имени и постоянным градиентным фоном.
  static Future<ImageProvider?> generateAvatar(String name) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = 200.0;

      final gradientColorPairs = [
        [const Color(0xFF2193b0), const Color(0xFF6dd5ed)], // синий-голубой
        [
          const Color(0xFFcc2b5e),
          const Color(0xFF753a88),
        ], // малиново-фиолетовый
        [const Color(0xFFee9ca7), const Color(0xFFffdde1)], // розовый-персик
        [const Color(0xFF4568dc), const Color(0xFFb06ab3)], // синий-фиолетовый
        [const Color(0xFFbdc3c7), const Color(0xFF2c3e50)], // серый
        [const Color(0xFF0f2027), const Color(0xFF2c5364)], // глубокий морской
        [const Color(0xFF1f4037), const Color(0xFF99f2c8)], // тёмно-зелёный
      ];

      // Хэш логина -> индекс градиента
      final hash = md5.convert(utf8.encode(name)).bytes;
      final index = hash[0] % gradientColorPairs.length;
      final bgColor = gradientColorPairs[index];

      // Градиентная заливка (LinearGradient как в Android)
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(size, size),
          bgColor,
        );

      // Рисуем фон
      canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);

      // Буква
      final textPainter = TextPainter(
        text: TextSpan(
          text: name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size);

      textPainter.paint(
        canvas,
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

      if (bytes == null) return null;
      return MemoryImage(bytes.buffer.asUint8List());
    } catch (e, st) {
      getIt<Talker>().error('Ошибка генерации аватара по имени', e, st);
      return null;
    }
  }

  /// Генерирует и сохраняет аватар в файл
  static Future<String?> generateAndSaveAvatarToFile(String name) async {
    try {
      // Генерируем аватар
      final imageProvider = await generateAvatar(name);
      if (imageProvider == null) return null;

      // Получаем данные изображения из MemoryImage
      final MemoryImage memoryImage = imageProvider as MemoryImage;
      final Uint8List imageBytes = memoryImage.bytes;

      // Получаем директорию приложения
      final appDir = await getApplicationDocumentsDirectory();

      // Создаем уникальное имя файла на основе имени и хэша
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final hash = md5.convert(utf8.encode(name)).bytes.sublist(0, 4).join('');
      final fileName = 'avatar_${name}_$hash$timestamp.png';
      final filePath = '${appDir.path}/$fileName';

      // Сохраняем файл
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e, st) {
      getIt<Talker>().error(
        'Ошибка сохранения сгенерированного аватара',
        e,
        st,
      );
      return null;
    }
  }
}
