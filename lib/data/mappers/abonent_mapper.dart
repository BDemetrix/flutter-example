
import 'package:flutter_example/data/models/contacts/abonent_field_key.dart';
import 'package:flutter_example/domain/entities/abonent/abonent.dart';

/// Маппер для преобразования [Abonent] в Map и обратно.
class AbonentMapper {
  static Map<String, dynamic> toMap(Abonent abonent) {
    return {
      AbonentFieldKey.id.key: abonent.id,
      AbonentFieldKey.name.key: abonent.name,
      AbonentFieldKey.login.key: abonent.login,
      AbonentFieldKey.isOnline.key: abonent.isOnline,
    };
  }

  static Abonent fromMap(Map<String, dynamic> map) {
    return Abonent(
      id: map[AbonentFieldKey.id.key] as String,
      name: map[AbonentFieldKey.name.key] as String,
      login: map[AbonentFieldKey.login.key] as String,
      isOnline: (map[AbonentFieldKey.isOnline.key] as bool?) ?? false,
    );
  }
}
