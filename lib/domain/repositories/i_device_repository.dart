import 'package:flutter_example/domain/entities/device/device_payload.dart';
import 'package:flutter_example/domain/entities/operation/operation_container.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart' show Either;

/// Интерфейс репозитория устройств.
/// Зона ответственности: предоставление потока данных об устройствах.
abstract class IDeviceRepository {
  Stream<Either<DomainError, OperationContainer<DevicePayload>>> get stream;
}
