import 'dart:async';

import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class IWebSocketProvider<TLoginData> {
  Future<Either<DomainError, void>> login(TLoginData data);

  /// Для всех подписчиков возможность (после проверки) залогиниться если соединение было разорвано  вынести метод в интерфейс (который будут поддерживать все кроме репозитория входа)
  /// подумать как сделать его на уровне IWebSocketProvider, чтобы сообщение не отправлялось до тех пор, пока не будет retryLogin
  // Future<Either<DomainError, void>> retryLogin();
  Future<Either<DomainError, void>> logout();
  void send(String message);

  Stream<Either<DomainError, Map<String, dynamic>>> get stream;
  String? get serverUri;
  bool get loggedIn;
}
