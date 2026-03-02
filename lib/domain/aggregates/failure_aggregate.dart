import 'dart:async';

import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Агрегат ошибок.
/// Зона ответственности: централизованная обработка и распространение ошибок приложения.
@lazySingleton
class FailureAggregate {
  final Talker _talker;

  FailureAggregate(this._talker) {
    _controller = StreamController<DomainError>.broadcast();
  }

  late final StreamController<DomainError> _controller;

  /// Глобальный поток ошибок, на который подписывается FailureCubit
  Stream<DomainError> get stream => _controller.stream;

  void addError(DomainError error) {
    _talker.error(error.message, error, error.stackTrace);
    if (!_controller.isClosed) {
      _controller.sink.add(error);
    }
  }

  void dispose() {
    _controller.close();
  }
}
