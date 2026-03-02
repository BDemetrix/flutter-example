/// Ответы сервера на запрос входа.
/// Зона ответственности: определение кодов и сообщений ответов аутентификации.
enum LoginResponse {
  successfulLogin(0, 'Успешный вход в систему'),
  invalidClientVersion(1, 'Неверная версия клиента'),
  invalidUserNameOrPassword(2, 'Неверное имя пользователя или пароль'),
  licenseExpired(3, 'Лицензия истекла'),
  exceededUserConnections(
    4,
    'Превышено количество доступных пользовательских подключений',
  ),
  serverInDemoMode(
    5,
    'Сервер работает в демо-режиме и должен быть перезапущен',
  ),
  multipleLoginsProhibited(
    6,
    'Множественные входы запрещены для этого пользователя, другое устройство уже подключено с этими учетными данными',
  );

  const LoginResponse(this.code, this.text);
  final int code;
  final String text;

  static LoginResponse parse(int code) {
    switch (code) {
      case 0:
        return LoginResponse.successfulLogin;
      case 1:
        return LoginResponse.invalidClientVersion;
      case 2:
        return LoginResponse.invalidUserNameOrPassword;
      case 3:
        return LoginResponse.licenseExpired;
      case 4:
        return LoginResponse.exceededUserConnections;
      case 5:
        return LoginResponse.serverInDemoMode;
      case 6:
        return LoginResponse.multipleLoginsProhibited;

      default:
        throw ArgumentError('Invalid LoginResponse code: $code');
    }
  }
}
