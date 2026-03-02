/// Перечисление ключей Walkiefleet API для подключения к серверу (Login Routine).
/// Зона ответственности: определение типов сообщений протокола аутентификации.
enum LoginApiMsgId {
  serverConfig('SERVER_CONFIG'),
  deviceConfig('DEVICE_CONFIG'),
  configServerResponseAck('CONFIG_SERVER_RESPONSE_ACK'),
  configServerResponseNack('CONFIG_SERVER_RESPONSE_NACK'),
  login('LOGIN'),
  loginResponse('LOGIN_RESPONSE'),
  deviceContext('DEVICE_CONTEXT'),
  ping('PING');

  const LoginApiMsgId(this.key);
  final String key;

  static LoginApiMsgId parse(String messageId) {
    switch (messageId) {
      case 'SERVER_CONFIG':
        return LoginApiMsgId.serverConfig;
      case 'DEVICE_CONFIG':
        return LoginApiMsgId.deviceConfig;
      case 'CONFIG_SERVER_RESPONSE_ACK':
        return LoginApiMsgId.configServerResponseAck;
      case 'CONFIG_SERVER_RESPONSE_NACK':
        return LoginApiMsgId.configServerResponseNack;
      case 'LOGIN':
        return LoginApiMsgId.login;
      case 'LOGIN_RESPONSE':
        return LoginApiMsgId.loginResponse;
      case 'DEVICE_CONTEXT':
        return LoginApiMsgId.deviceContext;
      case 'PING':
        return LoginApiMsgId.ping;
      default:
        throw ArgumentError('Invalid LoginApiMsgId messageId: $messageId');
    }
  }
}
