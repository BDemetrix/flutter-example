import 'dart:async';

import 'package:flutter_example/data/mappers/abonent_mapper.dart';
import 'package:flutter_example/data/mappers/operation_mapper.dart';
import 'package:flutter_example/data/models/contacts/abonent_field_key.dart';
import 'package:flutter_example/data/providers/websocket/i_websocket_provider.dart';
import 'package:flutter_example/data/repositories/base_classes/ws_repository.dart';
import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter_example/domain/entities/abonent/abonent_payload.dart';
import 'package:flutter_example/domain/entities/operation/operation.dart';
import 'package:flutter_example/domain/entities/operation/operation_container.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/repositories/i_abonent_repository.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IAbonentRepository)
class AbonentWsRepository
    extends WsRepository<OperationContainer<AbonentPayload>>
    implements IAbonentRepository {
  AbonentWsRepository({
    required IWebSocketProvider<String> super.webSocketProvider,
    required super.talker,
  });

  @override
  /// Метод родителя WsRepository и интерфейса IAbonentRepository
  Stream<Either<DomainError, OperationContainer<AbonentPayload>>> get stream =>
      controller.stream;

  @override
  @protected
  /// Метод родителя WsRepository
  void onMessage(Either<DomainError, Map<String, dynamic>> either) {
    // talker.debug('AbonentWsRepository - Received msg: $either');
    either.fold(
      (failure) => _handleFailure(failure),
      (data) => _handleSuccessData(data),
    );
  }

  // TODO продумать реализацию
  void _handleFailure(DomainError failure) {
    controller.sink.add(Left(failure));
  }

  // TODO следует реализовать обработку Operation [MsgOperation] не только для значения 0
  void _handleSuccessData(Map<String, dynamic> data) {
    if (data['MessageID'] != 'DATAEX') {
      return;
    }
    if (data['DataType'] != 11) return;

    Operation operation;
    try {
      operation = OperationMapper.fromCode(
        int.parse(data['Operation'].toString()),
      );
    } catch (e, st) {
      talker.error(
        'AbonentWsRepository - получена некорректная операция над массивом абонентов: ${data['Operation']}',
        e,
        st,
      );
      return;
    }

    talker.debug('AbonentWsRepository - Received success data: $data');

    final dataObjects = data['DataObjects'];
    if (dataObjects == null || dataObjects is! List) {
      if (dataObjects is! List) {
        talker.error(
          'AbonentWsRepository - некорректный массив абонентов в JSON: $dataObjects',
        );
      }
      controller.add(
        Right(
          OperationContainer(
            operation: Operation.add,
            data: AbonentList([]),
          ),
        ),
      );
      return;
    }

    try {
      switch (operation) {
        case Operation.initialize:
        case Operation.add:
        case Operation.change:
          final abonents = <Abonent>[];
          for (var e in dataObjects) {
            try {
              final abonent = AbonentMapper.fromMap(e);
              abonents.add(abonent);
            } catch (err, st) {
              talker.error(
                'AbonentWsRepository - ошибка парсинга абонента: $e',
                err,
                st,
              );
              continue;
            }
          }
          controller.add(
            Right(
              OperationContainer(
                data: AbonentList(abonents),
                operation: operation,
              ),
            ),
          );
          break;
        case Operation.remove:
          final List<String> abonentIds = [];
          for (var e in dataObjects) {
            if (e is Map<String, dynamic>) {
              final id = e[AbonentFieldKey.id.key] as String?;
              if (id != null && id.isNotEmpty) abonentIds.add(id);
            } else if (e is String && e.isNotEmpty) {
              abonentIds.add(e);
            }
          }
          controller.add(
            Right(
              OperationContainer(
                data: AbonentIds(abonentIds),
                operation: operation,
              ),
            ),
          );
      }
    } catch (e, st) {
      final errText = 'Ошибка парсинга списка абонентов или Id абонентов';
      talker.error(errText, e, st);
      controller.add(Left(ParsingFailure(message: errText)));
    }
  }
}
