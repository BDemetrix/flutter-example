import 'package:flutter_example/domain/entities/status.dart';

/// Маппер для преобразования [Status] в Map и обратно.
/// Зона ответственности: сериализация/десериализация данных статуса.
// TODO проверить актуальность этого класса
class StatusMapper {
  static Status fromMap(Map<String, dynamic> map) {
    return Status(
      id: map['ID'] as String,
      name: map['Name'] as String,
      color: map['Color'] as String,
    );
  }

  static Map<String, dynamic> toMap(Status status) {
    return {'ID': status.id, 'Name': status.name, 'Color': status.color};
  }
}
