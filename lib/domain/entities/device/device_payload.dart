import 'package:flutter_example/domain/entities/device/device.dart';

/// Базовый класс для данных устройств.
/// Зона ответственности: объединение различных типов payload для устройств.
sealed class DevicePayload {
  const DevicePayload();
}

/// Список устройств.
class DeviceList extends DevicePayload {
  final List<Device> devices;
  const DeviceList(this.devices);
}

/// Список ID устройств.
class DeviceIds extends DevicePayload {
  final List<String> deviceIds;
  const DeviceIds(this.deviceIds);
}
