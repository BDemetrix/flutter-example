/// Перечисление ключей сущности [Abonent].
/// Зона ответственности: определение ключей для сериализации абонента.
enum AbonentFieldKey {
  id('ID'),
  name('Name'),
  login('Login'),
  type('Type'),
  locked('Locked'),
  isOnline('isOnline');

  final String key;
  const AbonentFieldKey(this.key);

  /// Преобразует строковый ключ в значение перечисления [AbonentFieldKey]
  static AbonentFieldKey parse(String key) {
    for (final value in AbonentFieldKey.values) {
      if (value.key == key) {
        return value;
      }
    }
    throw FormatException('Unknown AbonentFieldKey: $key');
  }
}
