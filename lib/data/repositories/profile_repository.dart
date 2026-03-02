import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/data/providers/profile/i_profile_provider.dart';
import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/domain/repositories/i_profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Репозиторий профиля.
/// Зона ответственности: получение данных от провайдеров, стратегия кеширования,
/// работа с данными одного типа (профиль).
@LazySingleton(as: IProfileRepository)
class ProfileRepository implements IProfileRepository {
  final IProfileProvider _localProvider;

  ProfileRepository({required IProfileProvider localProvider})
    : _localProvider = localProvider;

  @override
  Future<Either<DomainError, Profile>> getProfile() {
    return _localProvider.getProfile();
  }

  @override
  Future<Either<DomainError, void>> updateProfile(Profile profile) {
    return _localProvider.saveProfile(profile);
  }

  @override
  Future<Either<DomainError, void>> clearProfile() {
    return _localProvider.clearProfile();
  }

  @override
  Future<Either<DomainError, bool>> hasProfile() {
    return _localProvider.hasProfile();
  }
}
