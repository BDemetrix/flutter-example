import 'package:flutter_example/domain/entities/auth_data.dart';

/// Маппер для преобразования [AuthData] в Map и обратно.
/// Зона ответственности: сериализация/десериализация данных аутентификации.
// TODO проверить и удалить
class AuthDataMapper {
  static Map<String, dynamic> toMap(AuthData authData) {
    return {
      'username': authData.username,
      'password': authData.password,
      'serverUri': authData.serverUri,
    };
  }

  static AuthData fromMap(Map<String, dynamic> map) {
    return AuthData(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      serverUri: map['serverUri'] ?? '',
    );
  }
}
