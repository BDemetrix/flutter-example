import 'dart:async';

import 'package:flutter_example/app/poc_app.dart';
import 'package:flutter_example/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Точка входа приложения.
/// Зона ответственности: инициализация зависимостей, обработка глобальных ошибок.
void main() async {
  // Установка глобального обработчика ошибок
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Инициализация get_it и зависимостей
      await configureDependencies();

      runApp(PocApp());
    },
    (error, stackTrace) {
      getIt<Talker>().error('Глобальная ошибка', error, stackTrace);
    },
  );
}
