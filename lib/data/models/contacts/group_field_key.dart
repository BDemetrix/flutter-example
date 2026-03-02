/// Перечисление ключей для сериализации/десериализации сущности [Group]
/// Должен находиться на слое данных
enum GroupFieldKey {
  /// Идентификатор группы
  id('ID'),

  /// Название группы
  name('Name'),

  /// Приоритет группы
  priority('Priority'),

  /// Признак аварийного вызова
  emergency('Emergency'),

  /// Признак общего вызова
  allCall('AllCall'),

  /// Признак трансляции
  broadcast('Broadcast');

  final String key;
  const GroupFieldKey(this.key);

  /// Преобразует строковый ключ в [GroupFieldKey]
  static GroupFieldKey parse(String key) {
    for (final value in GroupFieldKey.values) {
      if (value.key == key) return value;
    }
    throw FormatException('Unknown GroupFieldKey: $key');
  }
}
