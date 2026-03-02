
import 'package:flutter_example/data/models/device/device_api_key.dart';
import 'package:flutter_example/domain/entities/device/device.dart';

/// Маппер для преобразования [Device] в Map/JSON и обратно
class DeviceMapper {
  /// Преобразует объект [Device] в Map
  static Map<String, dynamic> toMap(Device device) {
    return {
      DeviceApiKey.id.key: device.id,
      DeviceApiKey.type.key: device.type,
      DeviceApiKey.userID.key: device.userId,
      DeviceApiKey.statusID.key: device.statusId,
      DeviceApiKey.login.key: device.login,
      DeviceApiKey.userName.key: device.userName,
      DeviceApiKey.deviceDescription.key: device.deviceDescription,
      DeviceApiKey.avatarHash.key: device.avatarHash,
      DeviceApiKey.versionName.key: device.versionName,
    };
  }

  /// Создаёт объект [Device] из Map
  static Device fromMap(Map<String, dynamic> map) {
    return Device(
      id: map[DeviceApiKey.id.key] as String,
      type: map[DeviceApiKey.type.key] as int,
      userId: map[DeviceApiKey.userID.key] as String,
      statusId: map[DeviceApiKey.statusID.key] as String,
      login: map[DeviceApiKey.login.key] as String,
      userName: map[DeviceApiKey.userName.key] as String,
      deviceDescription: map[DeviceApiKey.deviceDescription.key] as String,
      avatarHash: map[DeviceApiKey.avatarHash.key] as String,
      versionName: map[DeviceApiKey.versionName.key] as String,
    );
  }
}
