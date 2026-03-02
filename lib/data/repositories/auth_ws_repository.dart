import 'dart:async';
import 'dart:convert';

import 'package:flutter_example/core/utils/uuid.dart';
import 'package:flutter_example/data/mappers/device_config_mapper.dart';
import 'package:flutter_example/data/models/auth/device_context_dto.dart';
import 'package:flutter_example/data/models/auth/server_config_dto.dart';
import 'package:flutter_example/data/models/auth/login_api_msg_id.dart';
import 'package:flutter_example/data/models/auth/login_response.dart';
import 'package:flutter_example/data/models/auth/nack_response_code.dart';
import 'package:flutter_example/data/providers/local_config/i_local_config_provider.dart';
import 'package:flutter_example/data/providers/profile/i_profile_provider.dart';
import 'package:flutter_example/data/providers/websocket/i_websocket_provider.dart';
import 'package:flutter_example/data/repositories/base_classes/ws_repository.dart';
import 'package:flutter_example/domain/entities/auth_data.dart';
import 'package:flutter_example/domain/entities/device/device_config.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/repositories/i_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Репозиторий аутентификации через WebSocket.
/// Зона ответственности: логин/логаут, генерация и сохранение конфигураций устройства и сервера.
@LazySingleton(as: IAuthRepository)
class AuthWsRepository extends WsRepository<bool> implements IAuthRepository {
  AuthWsRepository({
    required ILocalConfigProvider localConfigProvider,
    required IProfileProvider profileProvider,
    required IWebSocketProvider<String> super.webSocketProvider,
    required super.talker,
  }) : _localConfigProvider = localConfigProvider,
       _profileProvider = profileProvider;

  final ILocalConfigProvider _localConfigProvider;
  final IProfileProvider _profileProvider;
  AuthData? _authData;
  bool _wasReplaySendDeviceConfig = false;

  @override
  /// Метод интерфейса IAuthRepository
  void login(AuthData authData) {
    _authData = authData;
    (webSocketProvider as IWebSocketProvider<String>).login(authData.serverUri);
  }

  @override
  /// Метод интерфейса IAuthRepository
  void logout() async {
    await webSocketProvider.logout();
    controller.sink.add(Right(false));
  }

  @override
  /// Реализация интерфейса IAuthRepository
  Stream<Either<DomainError, bool>> get stream => controller.stream;

  @override
  @protected
  /// Метод родителя WsRepository
  void onMessage(Either<DomainError, Map<String, dynamic>> either) {
    // talker.debug('AuthWsRepository - Received msg: $either');
    either.fold(
      (failure) => _handleFailure(failure),
      (data) => _handleSuccessData(data),
    );
  }

  // TODO продумать имплементацию
  void _handleFailure(DomainError failure) {
    controller.sink.add(Left(failure));
  }

  void _handleSuccessData(Map<String, dynamic> data) {
    if (data['MessageID'] == null) return;

    LoginApiMsgId messageId;
    try {
      messageId = LoginApiMsgId.parse(data['MessageID'].toString());
    } catch (_) {
      return;
    }

    // talker.debug('AuthWsRepository - Received success data: $data');

    switch (messageId) {
      case LoginApiMsgId.serverConfig:
        _serverConfigHandler(data);
        break;
      case LoginApiMsgId.deviceConfig:
        return;
      case LoginApiMsgId.configServerResponseAck:
        _serverResponseAckHandler(data);
        break;
      case LoginApiMsgId.configServerResponseNack:
        _serverResponseNackHandler(data);
        break;
      case LoginApiMsgId.login:
        return;
      case LoginApiMsgId.loginResponse:
        _loginResponseHandler(data);
        break;
      case LoginApiMsgId.deviceContext:
        _deviceContextHandler(data);
        break;
      case LoginApiMsgId.ping:
        return;
    }
  }

  /// Обработчик сообщения от сервера, которое приходит в ответ на соединение с сервером по WebSocket
  void _serverConfigHandler(Map<String, dynamic> data) async {
    talker.debug('Получена конфигурация сервера: ', data);
    ServerConfigDto config;
    try {
      config = ServerConfigDto.fromMap(data);
    } catch (e, st) {
      final failure = ParsingFailure(
        message: 'Ошибка в данных конфигурации сервера.',
        stackTrace: st,
      );
      talker.error(failure.message, e, st);
      controller.sink.add(Left(failure));
      return;
    }
    final saveRes = await _localConfigProvider.saveServerConfig(config);

    // Pattern matching (современный способ) для примера
    // if (saveRes case Left(value: final failure)) {
    //   controller.sink.add(Left(failure));
    // }

    // Традиционный способ
    if (saveRes.isLeft()) {
      final failure = (saveRes as Left).value;
      controller.sink.add(Left(failure));
      return;
    }

    _sendDeviceConfig();
  }

  /// Отправляется в ответ на пришедший serverConfig (MessageID == "DEVICE_CONFIG")
  /// Получает DeviceConfig из локальной БД
  /// Если в локальной БД нет DeviceConfig, создает его и сохраняет в локальную БД
  /// Отправляет DeviceConfig на сервер
  Future<void> _sendDeviceConfig([String? versionName]) async {
    DeviceConfig deviceConfig;
    final deviceConfigRes = await _localConfigProvider.getDeviceConfig();

    deviceConfig = await deviceConfigRes.fold(
      (failure) async {
        // Конфигурации нет в БД - создаем новую
        final config = _generateDeviceConfig();
        await _saveDeviceConfigSafely(config);
        return config;
      },
      (config) async {
        if (config != null) {
          return config.copyWith(
            sessionId: Uuid.generateBase64WithPadding(),
            login: _authData?.username,
            password: _authData?.password,
          );
        }
        final newConfig = _generateDeviceConfig();
        await _saveDeviceConfigSafely(newConfig);
        return newConfig;
      },
    );

    // Обработка отказа во входе в следствии неверной версии
    if (versionName != null &&
        deviceConfig.versionName.compareTo(versionName) < 0) {
      deviceConfig = deviceConfig.copyWith(versionName: versionName);
      await _saveDeviceConfigSafely(deviceConfig);
    }

    webSocketProvider.send('[${DeviceConfigMapper.toJson(deviceConfig)}]');
  }

  /// Безопасное сохранение конфигурации с обработкой ошибок
  Future<void> _saveDeviceConfigSafely(DeviceConfig config) async {
    final saveResult = await _localConfigProvider.saveDeviceConfig(config);
    saveResult.fold((failure) {
      talker.error('Ошибка сохранения DeviceConfig: $failure');
      controller.sink.add(Left(failure));
    }, (_) => talker.debug('DeviceConfig успешно сохранен'));
  }

  /// ответ сервера на отправку deviceConfig, если сервер позволяет вход
  void _serverResponseAckHandler(Map<String, dynamic> data) {
    // TODO следует сохранять "AllowedOps": 33423826 или нет?
    talker.debug(
      'Сервер прислал ответ ${LoginApiMsgId.configServerResponseAck.key} = ',
      data,
    );
    _login();
  }

  /// Ответ серверу на serverResponseAck
  void _login() {
    webSocketProvider.send(
      jsonEncode([
        {'MessageID': LoginApiMsgId.login.key},
      ]),
    );
  }

  // Обработка отклоненного входа
  void _serverResponseNackHandler(Map<String, dynamic> data) {
    talker.debug(
      'Сервер отклонил вход ${LoginApiMsgId.configServerResponseNack.key} = ',
      data,
    );
    final minVersionName = data['MinVersionName'].toString();
    final responseCode = int.tryParse(data['ResponseCode'].toString()) ?? -1;

    NackResponseCode nackResponseCode;
    try {
      nackResponseCode = NackResponseCode.parse(responseCode);
    } catch (e, st) {
      final errText =
          'Сервер запретил вход. Причина неизвестна, код ошибки некорректен.';
      talker.error(errText, e, st);
      controller.sink.add(Left(ConnectionFailure(message: errText)));
      return;
    }

    // Попытка переподключиться с новой версией (одна попытка)
    if (nackResponseCode.code == 1 && !_wasReplaySendDeviceConfig) {
      _sendDeviceConfig(minVersionName);
      _wasReplaySendDeviceConfig = true;
      return;
    }
    controller.sink.add(Left(ConnectionFailure(message: nackResponseCode.text)));
  }

  /// Обрабатывает сообщение от сервера к клиенту в ответ на сообщение _login()
  void _loginResponseHandler(Map<String, dynamic> data) async {
    talker.debug('Получен ответ за запрос входа: ', data);
    final response = int.tryParse(data['Response'].toString()) ?? -1;

    LoginResponse loginResponse;
    try {
      loginResponse = LoginResponse.parse(response);
    } catch (e, st) {
      final errText =
          'Сервер отклонил вход. Причина неизвестна, код ошибки некорректен.';
      talker.error(errText, e, st);
      controller.sink.add(Left(ConnectionFailure(message: errText)));
      return;
    }

    if (loginResponse == LoginResponse.successfulLogin) {
      // TODO сохранить "UserID": "jHop3VeEH0OKJ9eLY5V2Pg==" - КУДА?
      _saveUserId(data);
      controller.sink.add(Right(true));
      return;
    }

    controller.sink.add(Left(ConnectionFailure(message: loginResponse.text)));
  }

  /// Обработчик сообщения от сервера в ответ на удачный вход
  void _deviceContextHandler(Map<String, dynamic> data) async {
    talker.debug('Получен контекст устройства: ', data);
    try {
      final context = DeviceContextDto.fromMap(data);
      (await _localConfigProvider.saveDeviceContext(
        context,
      )).mapLeft((e) => throw e);
    } catch (e, st) {
      final errText =
          'Не удалось сохранить контекст устройства. Ошибка локальной БД.';
      talker.error('$errText ${LoginApiMsgId.deviceContext.key}', e, st);
      controller.sink.add(Left(ConnectionFailure(message: errText)));
    }
  }

  /// Сохраняет UserID в локальную базу в объект Profile
  Future<void> _saveUserId(Map<String, dynamic> data) async {
    final profile = (await _profileProvider.getProfile()).fold(
      (_) => null,
      (p) => p,
    );
    if (profile == null) return;

    final userID = data['UserID'];
    if (userID == null) {
      // TODO определить, является ли это критической ошибкой для логики системы
      talker.error(
        'Сервер в ответе на вход не вернул "UserID"',
        data,
        StackTrace.current,
      );
      return;
    }

    _profileProvider.saveProfile(profile.copyWith(userId: userID.toString()));
  }

  /// Гененирует DeviceConfig
  DeviceConfig _generateDeviceConfig() {
    return DeviceConfig(
      messageId: LoginApiMsgId.deviceConfig.key,
      ssrc: Uuid.generateRTPRandom(),
      appName: "CleanArch Demo",
      versionCode: 1,
      versionName: "1.0.0",
      password: _authData?.password ?? '',
      audioCodec: 2,

      sessionId: Uuid.generateBase64WithPadding(),
      deviceId: Uuid.generateBase64WithPadding(),
      statusId: "AAAAAAAAAAAAAAAAAAAAAA==",
      login: _authData?.username ?? '',
      avatarHash: "",
      deviceDescription:
          "MANUFACTURER=MYCOMPANY;MODEL=MYDEVICE;SERIAL=123456789;OSVERSION=5.5",
    );
  }
}
