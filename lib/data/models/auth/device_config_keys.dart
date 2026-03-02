/// Ключи API конфигурации устройства.
/// Зона ответственности: определение ключей для сериализации DeviceConfig.
enum DeviceConfigKeys {
  messageId('MessageID'),
  ssrc('Ssrc'),
  appName('AppName'),
  versionCode('VersionCode'),
  versionName('VersionName'),
  password('Password'),
  audioCodec('AudioCodec'),
  deviceData('DeviceData');

  final String key;
  const DeviceConfigKeys(this.key);

  static DeviceConfigKeys parse(String key) {
    switch (key) {
      case 'MessageID':
        return DeviceConfigKeys.messageId;
      case 'Ssrc':
        return DeviceConfigKeys.ssrc;
      case 'AppName':
        return DeviceConfigKeys.appName;
      case 'VersionCode':
        return DeviceConfigKeys.versionCode;
      case 'VersionName':
        return DeviceConfigKeys.versionName;
      case 'Password':
        return DeviceConfigKeys.password;
      case 'AudioCodec':
        return DeviceConfigKeys.audioCodec;
      case 'DeviceData':
        return DeviceConfigKeys.deviceData;
      default:
        throw ArgumentError('Invalid DeviceConfigKeys: $key');
    }
  }
}
