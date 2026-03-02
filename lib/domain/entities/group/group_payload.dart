import 'package:flutter_example/domain/entities/group/group.dart';

/// Базовый класс для данных групп.
/// Зона ответственности: объединение различных типов payload для групп.
sealed class GroupPayload {
  const GroupPayload();
}

/// Список групп.
class GroupList extends GroupPayload {
  final List<Group> groups;
  const GroupList(this.groups);
}

/// Список ID групп.
class GroupIds extends GroupPayload {
  final List<String> groupId;
  const GroupIds(this.groupId);
}
