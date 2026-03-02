part of 'auth_cubit.dart';

/// Базовый класс состояний аутентификации.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Начальное состояние аутентификации.
final class AuthInitial extends AuthState {}

/// Состояние загрузки (процесс аутентификации).
class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

/// Состояние успешной аутентификации.
class AuthLoaded extends AuthState {
  final bool isLoggedIn;

  const AuthLoaded({this.isLoggedIn = false});

  @override
  List<Object> get props => [isLoggedIn];
}

/// Состояние ошибки аутентификации.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}
