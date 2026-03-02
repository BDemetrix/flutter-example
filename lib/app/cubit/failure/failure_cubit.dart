import 'dart:async';

import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/aggregates/failure_aggregate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Состояния FailureCubit.
abstract class FailureState {}

/// Начальное состояние.
class FailureInitial extends FailureState {}

/// Состояние с полученной ошибкой.
class FailureReceived extends FailureState {
  final DomainError failure;
  FailureReceived(this.failure);
}

/// Кубит для управления глобальными ошибками приложения.
/// Зона ответственности: подписка на FailureAggregate и эмиссия ошибок для отображения.
class FailureCubit extends Cubit<FailureState> {
  final FailureAggregate _failureUseCase;
  late final StreamSubscription<DomainError> _subscription;

  FailureCubit(this._failureUseCase) : super(FailureInitial()) {
    // Подписываемся в конструкторе — cubit автоматически получает все ошибки.
    _subscription = _failureUseCase.stream.listen((failure) {
      emit(FailureReceived(failure));
    }, onError: (err, st) {});
  }

  void reset() {
    if (state is! FailureInitial) {
      emit(FailureInitial());
    }
  }

  @override
  Future<void> close() async {
    try {
      await _subscription.cancel();
    } catch (_) {}

    try {
      _failureUseCase.dispose();
    } catch (_) {}
    return super.close();
  }
}
