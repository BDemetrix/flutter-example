import 'package:flutter_example/domain/entities/operation/operation.dart';

/// Маппер для преобразования [Operation] в int и обратно.
///
/// Используется на границе с транспортным / API слоем.
class OperationMapper {
  static const Map<int, Operation> _fromCode = {
    0: Operation.initialize,
    1: Operation.add,
    2: Operation.remove,
    3: Operation.change,
  };

  static const Map<Operation, int> _toCode = {
    Operation.initialize: 0,
    Operation.add: 1,
    Operation.remove: 2,
    Operation.change: 3,
  };

  static Operation fromCode(int code, {Operation? orElse}) {
    final operation = _fromCode[code];
    if (operation != null) return operation;
    if (orElse != null) return orElse;
    throw ArgumentError('Unknown Operation code: $code');
  }

  static int toCode(Operation operation) {
    return _toCode[operation]!;
  }
}
