/// Конфигурация устройства.
/// Зона ответственности: хранение параметров устройства для аутентификации на сервере.
class DeviceConfig {
  final String messageId;
  final int ssrc;
  final String appName;
  final int versionCode;
  final String versionName;
  final String password;
  final int audioCodec;
  // static const idKeyToDBMap = 'deviceId';
  // deviceData - превращаем в плоскую структуру
  final String sessionId;
  final String deviceId;
  final String statusId;
  final String login;
  final String avatarHash;
  final String deviceDescription;

  static const idKeyToDBMap = 'deviceId';

  DeviceConfig({
    required this.messageId,
    required this.ssrc,
    required this.appName,
    required this.versionCode,
    required this.versionName,
    required this.password,
    required this.audioCodec,
    required this.sessionId,
    required this.deviceId,
    required this.statusId,
    required this.login,
    required this.avatarHash,
    required this.deviceDescription,
  });

  DeviceConfig copyWith({
    String? messageId,
    int? ssrc,
    String? appName,
    int? versionCode,
    String? versionName,
    String? password,
    int? audioCodec,
    String? sessionId,
    String? deviceId,
    String? statusId,
    String? login,
    String? avatarHash,
    String? deviceDescription,
  }) {
    return DeviceConfig(
      messageId: messageId ?? this.messageId,
      ssrc: ssrc ?? this.ssrc,
      appName: appName ?? this.appName,
      versionCode: versionCode ?? this.versionCode,
      versionName: versionName ?? this.versionName,
      password: password ?? this.password,
      audioCodec: audioCodec ?? this.audioCodec,
      sessionId: sessionId ?? this.sessionId,
      deviceId: deviceId ?? this.deviceId,
      statusId: statusId ?? this.statusId,
      login: login ?? this.login,
      avatarHash: avatarHash ?? this.avatarHash,
      deviceDescription: deviceDescription ?? this.deviceDescription,
    );
  }
}
