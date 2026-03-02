/// Перечисление ключей для сериализации/десериализации сущности [Device].
/// Зона ответственности: определение ключей API для устройства.
enum DeviceApiKey {
  /// Идентификатор устройства
  id('ID'),

  /// Тип устройства
  type('Type'),

  /// Идентификатор пользователя
  userID('UserID'),

  /// Идентификатор статуса
  statusID('StatusID'),

  /// Логин
  login('Login'),

  /// Имя пользователя
  userName('UserName'),

  /// Описание устройства
  deviceDescription('DeviceDescription'),

  /// Хэш аватара
  avatarHash('AvatarHash'),

  /// Версия приложения
  versionName('VersionName');

  final String key;
  const DeviceApiKey(this.key);

  /// Преобразует строковый ключ в [DeviceApiKey]
  static DeviceApiKey parse(String key) {
    for (final value in DeviceApiKey.values) {
      if (value.key == key) return value;
    }
    throw FormatException('Unknown DeviceFieldKey: $key');
  }
}
