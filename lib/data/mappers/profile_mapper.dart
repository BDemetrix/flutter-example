import 'package:flutter_example/domain/entities/profile.dart';

/// Маппер для преобразования [Profile] в Map и обратно.
/// Зона ответственности: сериализация/десериализация данных профиля.
class ProfileMapper {
  static Profile fromMap(Map<String, dynamic> map) {
    return Profile(
      userId: map['userId'] ?? '',
      imageResId: map['imageResId'] ?? 0,
      username: map['username'] ?? '',
      description: map['position'] ?? '',
      password: map['password'] ?? '',
      imageUri: map['imageUri'],
      serverUri: map['serverUri'] ?? '',
    );
  }

  static Map<String, dynamic> toMap(Profile profile) {
    return {
      'userId': profile.userId,
      'imageResId': profile.imageResId,
      'username': profile.username,
      'position': profile.description,
      'password': profile.password,
      'imageUri': profile.imageUri,
      'serverUri': profile.serverUri,
    };
  }
}
