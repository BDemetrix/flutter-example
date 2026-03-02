
import 'package:flutter_example/data/models/contacts/group_field_key.dart';
import 'package:flutter_example/domain/entities/group/group.dart';

/// Маппер для преобразования [Group] в Map/JSON и обратно
class GroupMapper {
  /// Преобразует объект [Group] в Map
  static Map<String, dynamic> toMap(Group group) {
    return {
      GroupFieldKey.id.key: group.id,
      GroupFieldKey.name.key: group.name,
      GroupFieldKey.priority.key: group.priority,
      GroupFieldKey.emergency.key: group.emergency,
      GroupFieldKey.allCall.key: group.allCall,
      GroupFieldKey.broadcast.key: group.broadcast,
    };
  }

  /// Создаёт объект [Group] из Map
  static Group fromMap(Map<String, dynamic> map) {
    return Group(
      id: map[GroupFieldKey.id.key] as String,
      name: map[GroupFieldKey.name.key] as String,
      priority: map[GroupFieldKey.priority.key] as int,
      emergency: map[GroupFieldKey.emergency.key] as int,
      allCall: map[GroupFieldKey.allCall.key] as int,
      broadcast: map[GroupFieldKey.broadcast.key] as int,
    );
  }
}
