import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/repositories/i_profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Агрегат профиля.
/// Зона ответственности: координация операций с профилем через IProfileRepository.
@lazySingleton
class ProfileAggregate {
  final IProfileRepository _repository;

  ProfileAggregate({required IProfileRepository repository})
    : _repository = repository;

  Future<Either<DomainError, Profile>> getProfile() => _repository.getProfile();
  Future<Either<DomainError, void>> updateProfile(Profile profile) =>
      _repository.updateProfile(profile);
  Future<Either<DomainError, void>> clearProfile() => _repository.clearProfile();
  Future<Either<DomainError, bool>> hasProfile() => _repository.hasProfile();
}
