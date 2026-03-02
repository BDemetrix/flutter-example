part of 'profile_cubit.dart';

/// Базовый класс состояний профиля.
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

/// Начальное состояние профиля.
class ProfileInitial extends ProfileState {}

/// Состояние загрузки профиля.
class ProfileLoading extends ProfileState {
  @override
  List<Object> get props => [];
}

/// Состояние с загруженным профилем.
class ProfileLoaded extends ProfileState {
  final Profile profile;
  final bool afterUpdated;

  const ProfileLoaded({required this.profile, this.afterUpdated = false});

  @override
  List<Object> get props => [profile, afterUpdated];
}

/// Состояние ошибки при работе с профилем.
class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure({required this.message});

  @override
  List<Object> get props => [message];
}
