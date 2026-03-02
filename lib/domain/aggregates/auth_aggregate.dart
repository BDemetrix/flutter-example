import 'dart:async';

import 'package:flutter_example/domain/entities/auth_data.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/repositories/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Агрегат аутентификации.
/// Зона ответственности: координация операций входа/выхода через IAuthRepository.
@lazySingleton
class AuthAggregate {
  final IAuthRepository _authRepository;

  AuthAggregate(IAuthRepository authRepository)
    : _authRepository = authRepository;

  void login(AuthData authData) {
    return _authRepository.login(authData);
  }

  void logout() {
    return _authRepository.logout();
  }

  Stream<Either<DomainError, bool>> get stream => _authRepository.stream;
}
