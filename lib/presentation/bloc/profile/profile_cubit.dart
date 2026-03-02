import 'package:flutter_example/domain/aggregates/profile_aggregate.dart';
import 'package:flutter_example/domain/entities/profile.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

/// Кубит управления профилем пользователя.
/// Зона ответственности: загрузка, сохранение, обновление и очистка данных профиля
/// через взаимодействие с ProfileAggregate.
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileAggregate _profileUseCase;

  ProfileCubit(this._profileUseCase) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await _profileUseCase.getProfile();
    result.match((failure) {
      emit(ProfileFailure(message: failure.message));
    }, (profile) => emit(ProfileLoaded(profile: profile)));
  }

  Future<void> updateProfile(Profile profile) async {
    emit(ProfileLoading());
    final result = await _profileUseCase.updateProfile(profile);
    result.match((failure) {
      emit(ProfileFailure(message: failure.message));
    }, (_) => emit(ProfileLoaded(profile: profile, afterUpdated: true)));
  }

  Future<void> clearProfile() async {
    emit(ProfileLoading());
    final result = await _profileUseCase.clearProfile();
    result.match((failure) {
      emit(ProfileFailure(message: failure.message));
    }, (_) => emit(ProfileInitial()));
  }

  Future<void> checkProfileExists() async {
    final result = await _profileUseCase.hasProfile();
    result.match(
      (failure) {
        emit(ProfileFailure(message: failure.message));
      },
      (exists) {
        if (exists) {
          loadProfile();
        } else {
          emit(ProfileInitial());
        }
      },
    );
  }
}
