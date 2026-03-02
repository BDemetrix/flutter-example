import 'dart:async';
import 'dart:convert';

import 'package:flutter_example/data/mappers/group_mapper.dart';
import 'package:flutter_example/data/mappers/operation_mapper.dart';
import 'package:flutter_example/data/models/contacts/group_field_key.dart';
import 'package:flutter_example/data/providers/websocket/i_websocket_provider.dart';
import 'package:flutter_example/data/repositories/base_classes/ws_repository.dart';
import 'package:flutter_example/domain/entities/group/group.dart';
import 'package:flutter_example/domain/entities/group/group_payload.dart';
import 'package:flutter_example/domain/entities/operation/operation.dart';
import 'package:flutter_example/domain/entities/operation/operation_container.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/repositories/i_group_repository.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide Group;
import 'package:injectable/injectable.dart';

@LazySingleton(as: IGroupRepository)
class GroupWsRepository extends WsRepository<OperationContainer<GroupPayload>>
    implements IGroupRepository {
  GroupWsRepository({
    required IWebSocketProvider<String> super.webSocketProvider,
    required super.talker,
  });

  @override
  /// Метод интерфейса IGroupRepository
  void requestGroupList() {
    final request = {"MessageID": "DATAEX", "DataType": 12, "Operation": 0};
    webSocketProvider.send(jsonEncode(request));
  }

  /// Метод родителя WsRepository и интерфейса IGroupRepository
  @override
  Stream<Either<DomainError, OperationContainer<GroupPayload>>> get stream =>
      controller.stream;

  @override
  @protected
  /// Метод родителя WsRepository
  void onMessage(Either<DomainError, Map<String, dynamic>> either) {
    // talker.debug('GroupWsRepository - Received msg: $either');
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
    if (data['DataType'] != 12) return;

    Operation operation;
    try {
      operation = OperationMapper.fromCode(
        int.parse(data['Operation'].toString()),
      );
    } catch (e, st) {
      talker.error(
        'GroupWsRepository - получена некорректная операция над массивом групп: ${data['Operation']}',
        e,
        st,
      );
      return;
    }

    talker.debug('GroupWsRepository - Received success data: $data');

    final dataObjects = data['DataObjects'];
    if (dataObjects == null || dataObjects is! List) {
      if (dataObjects is! List) {
        talker.error(
          'GroupWsRepository - некорректный массив групп в JSON: $dataObjects',
        );
      }
      controller.add(
        Right(
          OperationContainer(
            operation: Operation.add,
            data: GroupList([]),
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
          final groups = <Group>[];
          for (var e in dataObjects) {
            try {
              final group = GroupMapper.fromMap(e);
              groups.add(group);
            } catch (err, st) {
              talker.error(
                'GroupWsRepository - ошибка парсинга группы: $e',
                err,
                st,
              );
              continue;
            }
          }
          controller.add(
            Right(
              OperationContainer(
                data: GroupList(groups),
                operation: operation,
              ),
            ),
          );
          break;
        case Operation.remove:
          final List<String> groupIds = [];
          for (var e in dataObjects) {
            if (e is Map<String, dynamic>) {
              final id = e[GroupFieldKey.id.key] as String?;
              if (id != null && id.isNotEmpty) groupIds.add(id);
            } else if (e is String && e.isNotEmpty) {
              groupIds.add(e);
            }
          }
          controller.add(
            Right(
              OperationContainer(
                data: GroupIds(groupIds),
                operation: operation,
              ),
            ),
          );
      }
    } catch (e, st) {
      final errText = 'Ошибка парсинга списка групп или Id групп';
      talker.error(errText, e, st);
      controller.add(Left(ParsingFailure(message: errText)));
    }
  }
}
