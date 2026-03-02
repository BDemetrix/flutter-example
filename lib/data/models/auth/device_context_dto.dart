import 'dart:convert';

/// DTO контекста устройства.
/// Зона ответственности: передача данных контекста устройства от сервера.
class DeviceContextDto {
  final String messageId;
  final int videoResolution;
  final int pingTimeout;
  final String networkName;
  final String networkGlobalId;
  final String networkInstanceId;

  DeviceContextDto({
    required this.messageId,
    required this.videoResolution,
    required this.pingTimeout,
    required this.networkName,
    required this.networkGlobalId,
    required this.networkInstanceId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DeviceContextKeys.messageId.key: messageId,
      DeviceContextKeys.videoResolution.key: videoResolution,
      DeviceContextKeys.pingTimeout.key: pingTimeout,
      DeviceContextKeys.networkName.key: networkName,
      DeviceContextKeys.networkGlobalId.key: networkGlobalId,
      DeviceContextKeys.networkInstanceId.key: networkInstanceId,
    };
  }

  factory DeviceContextDto.fromMap(Map<String, dynamic> map) {
    return DeviceContextDto(
      messageId: map[DeviceContextKeys.messageId.key] as String,
      videoResolution: map[DeviceContextKeys.videoResolution.key] as int,
      pingTimeout: map[DeviceContextKeys.pingTimeout.key] as int,
      networkName: map[DeviceContextKeys.networkName.key] as String,
      networkGlobalId: map[DeviceContextKeys.networkGlobalId.key] as String,
      networkInstanceId: map[DeviceContextKeys.networkInstanceId.key] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceContextDto.fromJson(String source) =>
      DeviceContextDto.fromMap(json.decode(source) as Map<String, dynamic>);
}

/// Ключи API для DeviceContextDto.
enum DeviceContextKeys {
  messageId('MessageID'),
  videoResolution('VideoResolution'),
  pingTimeout('PingTimeout'),
  networkName('NetworkName'),
  networkGlobalId('NetworkGlobalID'),
  networkInstanceId('NetworkInstanceID');

  final String key;
  const DeviceContextKeys(this.key);

  static DeviceContextKeys parse(String key) {
    switch (key) {
      case 'MessageID':
        return DeviceContextKeys.messageId;
      case 'VideoResolution':
        return DeviceContextKeys.videoResolution;
      case 'PingTimeout':
        return DeviceContextKeys.pingTimeout;
      case 'NetworkName':
        return DeviceContextKeys.networkName;
      case 'NetworkGlobalID':
        return DeviceContextKeys.networkGlobalId;
      case 'NetworkInstanceID':
        return DeviceContextKeys.networkInstanceId;
      default:
        throw ArgumentError('Invalid DeviceContextKeys: $key');
    }
  }
}
