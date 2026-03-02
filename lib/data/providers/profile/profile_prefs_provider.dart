import 'dart:convert';

import 'package:flutter_example/data/mappers/profile_mapper.dart';
import 'package:flutter_example/data/providers/profile/i_profile_provider.dart';
import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

@LazySingleton(as: IProfileProvider)
class ProfilePrefsProvider implements IProfileProvider {
  final SharedPreferences _prefs;
  final Talker _talker;
  static const String _profileKey = 'profile';

  ProfilePrefsProvider({
    required SharedPreferences prefs,
    required Talker talker,
  }) : _prefs = prefs,
       _talker = talker;

  @override
  Future<Either<DomainError, void>> saveProfile(Profile profile) async {
    try {
      final json = ProfileMapper.toMap(profile);
      final success = await _prefs.setString(_profileKey, jsonEncode(json));

      if (!success) {
        throw Exception('SharedPreferences failed to save profile');
      }

      return const Right(null);
    } catch (e, st) {
      const failure = ProfileSavingFailure();
      _talker.handle(
        e,
        st,
        "ProfilePrefsProvider()..saveProfile() -  ${failure.message}",
      );
      return Left(failure);
    }
  }

  @override
  Future<Either<DomainError, Profile>> getProfile() async {
    try {
      final data = _prefs.getString(_profileKey);

      if (data == null) {
        // Если произошла эта ошибка (в этом методе), значит нарушена логика обращения к профилю в юзкейсе или выше
        return Left(ProfileNotFoundFailure());
      }

      // Валидация наличия данных
      final profile = ProfileMapper.fromMap(jsonDecode(data));
      return Right(profile);
    } on ProfileNotFoundFailure {
      rethrow;
    } catch (e, st) {
      const failure = ProfileDecodingFailure();
      _talker.handle(
        e,
        st,
        "ProfilePrefsProvider()..getProfile() -  ${failure.message}",
      );
      return Left(failure);
    }
  }

  @override
  Future<Either<DomainError, void>> clearProfile() async {
    try {
      final success = await _prefs.remove(_profileKey);

      if (!success) {
        throw Exception('SharedPreferences failed to remove profile');
      }

      return const Right(null);
    } catch (e, st) {
      const failure = DatabaseFailure(
        "Ошибка удаления профиля из локального хранилища",
      );
      _talker.handle(
        e,
        st,
        "ProfilePrefsProvider()..clearProfile() -  ${failure.message}",
      );
      return Left(failure);
    }
  }

  @override
  Future<Either<DomainError, bool>> hasProfile() async {
    try {
      return Right(_prefs.containsKey(_profileKey));
    } catch (e, st) {
      const failure = DatabaseFailure(
        "Ошибка проверки существования профиля в локальном хранилище",
      );
      _talker.handle(
        e,
        st,
        "ProfilePrefsProvider()..hasProfile() -  ${failure.message}",
      );
      return Left(failure);
    }
  }
}
