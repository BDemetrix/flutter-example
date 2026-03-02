import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class IProfileProvider {
  Future<Either<DomainError, Profile>> getProfile();
  Future<Either<DomainError, void>> saveProfile(Profile profile);
  Future<Either<DomainError, void>> clearProfile();
  Future<Either<DomainError, bool>> hasProfile();
}