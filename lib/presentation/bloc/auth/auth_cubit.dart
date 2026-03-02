import 'dart:async';

import 'package:flutter_example/domain/aggregates/auth_aggregate.dart';
import 'package:flutter_example/domain/entities/auth_data.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'auth_state.dart';

/// Кубит управления аутентификацией.
/// Зона ответственности: управление состоянием входа/выхода пользователя,
/// взаимодействие с AuthAggregate для выполнения операций аутентификации.
class AuthCubit extends Cubit<AuthState> {
  final AuthAggregate _authUseCase;

  AuthCubit(AuthAggregate authUseCase)
    : _authUseCase = authUseCase,
      super(AuthInitial()) {
    _authUseCase.stream.listen(onData);
  }

  void login(AuthData authData) async {
    emit(AuthLoading());
    _authUseCase.login(authData);
  }

  void logout() async {
    emit(AuthLoading());
    _authUseCase.logout();
  }

  Stream<Either<DomainError, bool>> get connectionStatus => _authUseCase.stream;

  void onData(Either<DomainError, bool> data) {
    data.fold((failure) {
      emit(AuthFailure(message: failure.message));
    }, (isAuth) => emit(AuthLoaded(isLoggedIn: isAuth)));
  }
}
