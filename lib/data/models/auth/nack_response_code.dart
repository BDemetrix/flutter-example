/// Коды отказа сервера при аутентификации.
/// Зона ответственности: определение кодов и сообщений об отказе входа.
enum NackResponseCode {
  invalidClientVersion(1, 'Неверная версия клиента'),
  invalidUserNameOrPassword(2, 'Неверное имя пользователя или пароль'),
  exceededUserConnections(
    3,
    'Превышено количество доступных пользовательских подключений',
  ),
  multipleLoginsProhibited(
    4,
    'Множественные входы запрещены для этого пользователя, другое устройство уже подключено с этими учетными данными',
  );

  const NackResponseCode(this.code, this.text);
  final int code;
  final String text;

  static NackResponseCode parse(int code) {
    switch (code) {
      case 1:
        return NackResponseCode.invalidClientVersion;
      case 2:
        return NackResponseCode.invalidUserNameOrPassword;
      case 3:
        return NackResponseCode.exceededUserConnections;
      case 4:
        return NackResponseCode.multipleLoginsProhibited;
      default:
        throw ArgumentError('Invalid NackResponseCode code: $code');
    }
  }
}
