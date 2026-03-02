import 'dart:convert';
import 'dart:math';

/// Утилиты для генерации UUID и случайных значений.
/// Зона ответственности: генерация Base64 ID и случайных чисел для RTP.
class Uuid {
  /// Генерация Base64 ID с паддингом.
  static String generateBase64WithPadding() {
    final uuid = List<int>.generate(16, (i) => Random().nextInt(256));
    return base64.encode(uuid);
  }

  /// Случайное число, необходимое для передачи данных по протоколу RTP.
  /// Должно быть уникальным для каждого
  static int generateRTPRandom() {
    final random = Random.secure();
    // Генерируем 32-битное число (от 0 до 4294967295)
    return (random.nextInt(1 << 16) << 16) | random.nextInt(1 << 16);
  }
}
