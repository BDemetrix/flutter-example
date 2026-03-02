import 'dart:async';

import 'package:flutter_example/data/mappers/device_mapper.dart';
import 'package:flutter_example/data/mappers/operation_mapper.dart';
import 'package:flutter_example/data/models/device/device_api_key.dart';
import 'package:flutter_example/data/providers/websocket/i_websocket_provider.dart';
import 'package:flutter_example/data/repositories/base_classes/ws_repository.dart';
import 'package:flutter_example/domain/entities/device/device.dart';
import 'package:flutter_example/domain/entities/device/device_payload.dart';
import 'package:flutter_example/domain/entities/operation/operation.dart';
import 'package:flutter_example/domain/entities/operation/operation_container.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/repositories/i_device_repository.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IDeviceRepository)
class DeviceWsRepository
    extends WsRepository<OperationContainer<DevicePayload>>
    implements IDeviceRepository {
  DeviceWsRepository({
    required IWebSocketProvider<String> super.webSocketProvider,
    required super.talker,
  });

  /// Метод родителя WsRepository и интерфейса IDeviceRepository
  @override
  Stream<Either<DomainError, OperationContainer<DevicePayload>>> get stream =>
      controller.stream;

  @override
  @protected
  /// Метод родителя WsRepository
  void onMessage(Either<DomainError, Map<String, dynamic>> either) {
    // talker.debug('DeviceWsRepository - Received msg: $either');
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
    if (data['DataType'] != 10) return;

    Operation operation;
    try {
      operation = OperationMapper.fromCode(
        int.parse(data['Operation'].toString()),
      );
    } catch (e, st) {
      talker.error(
        'DeviceWsRepository - получена некорректная операция над массивом устройств: ${data['Operation']}',
        e,
        st,
      );
      return;
    }

    talker.debug('DeviceWsRepository - Received success data: $data');

    final dataObjects = data['DataObjects'];
    if (dataObjects == null || dataObjects is! List) {
      if (dataObjects is! List) {
        talker.error(
          'DeviceWsRepository - некорректный массив устройств в JSON: $dataObjects',
        );
      }
      controller.add(
        Right(
          OperationContainer(
            operation: Operation.add,
            data: DeviceList([]),
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
          final devices = <Device>[];
          for (var e in dataObjects) {
            try {
              final device = DeviceMapper.fromMap(e);
              devices.add(device);
            } catch (err, st) {
              talker.error(
                'DeviceWsRepository - ошибка парсинга устройства: $e',
                err,
                st,
              );
              continue;
            }
          }
          controller.add(
            Right(
              OperationContainer(
                data: DeviceList(devices),
                operation: operation,
              ),
            ),
          );
          break;
        case Operation.remove:
          final List<String> deviceIds = [];
          for (var e in dataObjects) {
            if (e is Map<String, dynamic>) {
              final id = e[DeviceApiKey.id.key] as String?;
              if (id != null && id.isNotEmpty) deviceIds.add(id);
            }
          }
          controller.add(
            Right(
              OperationContainer(
                data: DeviceIds(deviceIds),
                operation: operation,
              ),
            ),
          );
      }
    } catch (e, st) {
      final errText = 'Ошибка парсинга списка устройств или Id устройств';
      talker.error(errText, e, st);
      controller.add(Left(ParsingFailure(message: errText)));
    }
  }
}
