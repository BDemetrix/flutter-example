import 'package:flutter_example/domain/entities/abonent/abonent_payload.dart';
import 'package:flutter_example/domain/entities/operation/operation_container.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart' show Either;

/// Интерфейс репозитория абонентов.
/// Зона ответственности: предоставление потока данных об абонентах.
abstract class IAbonentRepository {
  Stream<Either<DomainError, OperationContainer<AbonentPayload>>> get stream;
}
