import 'dart:convert';

import 'package:flutter_example/data/models/auth/device_config_keys.dart';
import 'package:flutter_example/data/models/auth/device_data_keys.dart';
import 'package:flutter_example/domain/entities/device/device_config.dart';

class DeviceConfigMapper {
  /// Ключ для БД
  static const idKeyToDBMap = 'deviceId';

  static DeviceConfig fromMap(Map<String, dynamic> map) {
    final deviceDataMap =
        map[DeviceConfigKeys.deviceData.key] as Map<String, dynamic>;
    return DeviceConfig(
      messageId: map[DeviceConfigKeys.messageId.key] as String,
      ssrc: map[DeviceConfigKeys.ssrc.key] as int,
      appName: map[DeviceConfigKeys.appName.key] as String,
      versionCode: map[DeviceConfigKeys.versionCode.key] as int,
      versionName: map[DeviceConfigKeys.versionName.key] as String,
      password: map[DeviceConfigKeys.password.key] as String,
      audioCodec: map[DeviceConfigKeys.audioCodec.key] as int,
      // Дальше ключи устройства DeviceData
      sessionId: deviceDataMap[DeviceDataKeys.sessionId.key] as String,
      deviceId: deviceDataMap[DeviceDataKeys.id.key] as String,
      statusId: deviceDataMap[DeviceDataKeys.statusId.key] as String,
      login: deviceDataMap[DeviceDataKeys.login.key] as String,
      avatarHash: deviceDataMap[DeviceDataKeys.avatarHash.key] as String,
      deviceDescription:
          deviceDataMap[DeviceDataKeys.deviceDescription.key] as String,
    );
  }

  /// Создает объект из словаря БД с ключем deviceId отличным от API
  static DeviceConfig fromDBMap(Map<String, dynamic> map) {
    return DeviceConfig(
      messageId: map[DeviceConfigKeys.messageId.key] as String,
      ssrc: map[DeviceConfigKeys.ssrc.key] as int,
      appName: map[DeviceConfigKeys.appName.key] as String,
      versionCode: map[DeviceConfigKeys.versionCode.key] as int,
      versionName: map[DeviceConfigKeys.versionName.key] as String,
      password: map[DeviceConfigKeys.password.key] as String,
      audioCodec: map[DeviceConfigKeys.audioCodec.key] as int,
      // Дальше ключи устройства DeviceData
      sessionId: map[DeviceDataKeys.sessionId.key] as String,
      deviceId: map[idKeyToDBMap] as String,
      statusId: map[DeviceDataKeys.statusId.key] as String,
      login: map[DeviceDataKeys.login.key] as String,
      avatarHash: map[DeviceDataKeys.avatarHash.key] as String,
      deviceDescription: map[DeviceDataKeys.deviceDescription.key] as String,
    );
  }

  static Map<String, dynamic> toMap(DeviceConfig data) {
    final deviceData = {
      DeviceDataKeys.sessionId.key: data.sessionId,
      DeviceDataKeys.id.key: data.deviceId,
      DeviceDataKeys.statusId.key: data.statusId,
      DeviceDataKeys.login.key: data.login,
      DeviceDataKeys.avatarHash.key: data.avatarHash,
      DeviceDataKeys.deviceDescription.key: data.deviceDescription,
    };
    return <String, dynamic>{
      DeviceConfigKeys.messageId.key: data.messageId,
      DeviceConfigKeys.ssrc.key: data.ssrc,
      DeviceConfigKeys.appName.key: data.appName,
      DeviceConfigKeys.versionCode.key: data.versionCode,
      DeviceConfigKeys.versionName.key: data.versionName,
      DeviceConfigKeys.password.key: data.password,
      DeviceConfigKeys.audioCodec.key: data.audioCodec,
      // Дальше ключи устройства DeviceData
      DeviceConfigKeys.deviceData.key: deviceData,
    };
  }

  /// Создает из объекта словарь БД с ключем deviceId отличным от API
  static Map<String, dynamic> toDBMap(DeviceConfig data) {
    return <String, dynamic>{
      DeviceConfigKeys.messageId.key: data.messageId,
      DeviceConfigKeys.ssrc.key: data.ssrc,
      DeviceConfigKeys.appName.key: data.appName,
      DeviceConfigKeys.versionCode.key: data.versionCode,
      DeviceConfigKeys.versionName.key: data.versionName,
      DeviceConfigKeys.password.key: data.password,
      DeviceConfigKeys.audioCodec.key: data.audioCodec,
      // Дальше ключи устройства DeviceData
      DeviceDataKeys.sessionId.key: data.sessionId,
      idKeyToDBMap: data.deviceId,
      DeviceDataKeys.statusId.key: data.statusId,
      DeviceDataKeys.login.key: data.login,
      DeviceDataKeys.avatarHash.key: data.avatarHash,
      DeviceDataKeys.deviceDescription.key: data.deviceDescription,
    };
  }

  static String toJson(DeviceConfig data) => json.encode(toMap(data));

  static DeviceConfig fromJson(String source) =>
      fromMap(json.decode(source) as Map<String, dynamic>);
}
