/// Данные для аутентификации.
/// Зона ответственности: хранение учетных данных для входа (имя, пароль, URI сервера).
class AuthData {
  final String username;
  final String password;
  final String serverUri;

  AuthData({
    required this.username,
    required this.password,
    required this.serverUri,
  });
}
