import 'package:flutter_example/domain/entities/operation/operation.dart';

/// Контейнер для передачи операции и связанных с ней данных.
/// Зона ответственности: упаковка операции и данных для передачи между слоями.
class OperationContainer<T> {
  final Operation operation;
  final T data;

  const OperationContainer({required this.operation, required this.data});
}
