/// API ключи вложенного в DeviceConfig словаря DeviceData.
/// Зона ответственности: определение ключей для сериализации DeviceData.
enum DeviceDataKeys {
  sessionId('SessionID'),
  id('ID'),
  statusId('StatusID'),
  login('Login'),
  avatarHash('AvatarHash'),
  deviceDescription('DeviceDescription');

  final String key;
  const DeviceDataKeys(this.key);

  static DeviceDataKeys parse(String key) {
    switch (key) {
      case 'SessionID':
        return DeviceDataKeys.sessionId;
      case 'ID':
        return DeviceDataKeys.id;
      case 'StatusID':
        return DeviceDataKeys.statusId;
      case 'Login':
        return DeviceDataKeys.login;
      case 'AvatarHash':
        return DeviceDataKeys.avatarHash;
      case 'DeviceDescription':
        return DeviceDataKeys.deviceDescription;
      default:
        throw ArgumentError('Invalid DeviceDataKeys: $key');
    }
  }
}
