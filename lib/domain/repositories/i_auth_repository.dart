import 'dart:async';

import 'package:flutter_example/domain/entities/auth_data.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart';

/// Интерфейс репозитория аутентификации.
/// Зона ответственности: управление сессией входа/выхода пользователя.
abstract class IAuthRepository {
  void login(AuthData authData);
  void logout();
  Stream<Either<DomainError, bool>> get stream;
}
