import 'dart:async';

import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/data/providers/websocket/i_websocket_provider.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Базовый класс для WebSocket репозиториев.
/// Зона ответственности: подписка на WebSocket поток, обработка ошибок соединения,
/// предоставление общего интерфейса для наследников.
abstract class WsRepository<StreamData> {
  final IWebSocketProvider _webSocketProvider;
  final Talker _talker;
  late StreamController<Either<DomainError, StreamData>> _controller;
  StreamSubscription? _webSocketSubscription;

  WsRepository({
    required IWebSocketProvider webSocketProvider,
    required Talker talker,
  }) : _webSocketProvider = webSocketProvider,
       _talker = talker {
    _controller = StreamController<Either<DomainError, StreamData>>.broadcast();
    _webSocketSubscription = _webSocketProvider.stream.listen(
      onMessage,
      onError: _onWebSocketError,
      onDone: _onWebSocketDone,
    );
  }

  // Защищенные геттеры для наследников
  @protected
  IWebSocketProvider get webSocketProvider => _webSocketProvider;

  @protected
  StreamController<Either<DomainError, StreamData>> get controller => _controller;

  @protected
  Talker get talker => _talker;

  // Абстрактный метод, который должны реализовать наследники
  @protected
  void onMessage(Either<DomainError, Map<String, dynamic>> message);

  // остальные методы без изменений...
  void _onWebSocketError(dynamic error) {
    _talker.error(
      'Стрим экземпляра WebSocketProvider вернул ошибку',
      error,
      StackTrace.current,
    );
  }

  void _onWebSocketDone() {
    _talker.debug("WebSocket closed by server");
    _talker.error(
      'Стрим экземпляра WebSocketProvider был закрыт! Прием сообщений от сервера в $runtimeType невозможен',
    );
    _cleanUp();
  }

  void _cleanUp() {
    _webSocketSubscription?.cancel();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

  void dispose() {
    _cleanUp();
  }
}
