import 'package:equatable/equatable.dart';

/// Сущность устройства.
/// Зона ответственности: представление данных устройства (ID, тип, пользователь, статус).
class Device extends Equatable {
  final String id;
  final int type;
  final String userId;
  final String statusId;
  final String login;
  final String userName;
  final String deviceDescription;
  final String avatarHash;
  final String versionName;

  const Device({
    required this.id,
    required this.type,
    required this.userId,
    required this.statusId,
    required this.login,
    required this.userName,
    required this.deviceDescription,
    required this.avatarHash,
    required this.versionName,
  });

  Device copyWith({
    String? id,
    int? type,
    String? userId,
    String? statusId,
    String? login,
    String? userName,
    String? deviceDescription,
    String? avatarHash,
    String? versionName,
  }) {
    return Device(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      statusId: statusId ?? this.statusId,
      login: login ?? this.login,
      userName: userName ?? this.userName,
      deviceDescription: deviceDescription ?? this.deviceDescription,
      avatarHash: avatarHash ?? this.avatarHash,
      versionName: versionName ?? this.versionName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    userId,
    statusId,
    login,
    userName,
    deviceDescription,
    avatarHash,
    versionName,
  ];
}
