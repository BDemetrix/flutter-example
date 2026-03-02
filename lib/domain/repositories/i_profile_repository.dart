import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart';

/// Интерфейс репозитория профиля.
/// Зона ответственности: операции с профилем пользователя (получение, обновление, очистка).
abstract class IProfileRepository {
  Future<Either<DomainError, Profile>> getProfile();
  Future<Either<DomainError, void>> updateProfile(Profile profile);
  Future<Either<DomainError, void>> clearProfile();
  Future<Either<DomainError, bool>>  hasProfile();
}