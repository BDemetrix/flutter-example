import 'package:flutter_example/domain/entities/group/group_payload.dart';
import 'package:flutter_example/domain/entities/operation/operation_container.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:fpdart/fpdart.dart' show Either;

/// Интерфейс репозитория групп.
/// Зона ответственности: предоставление потока данных о группах, запрос списка групп.
abstract class IGroupRepository {
  void requestGroupList();
  Stream<Either<DomainError, OperationContainer<GroupPayload>>> get stream;
}
