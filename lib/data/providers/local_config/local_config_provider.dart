import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/data/mappers/device_config_mapper.dart';
import 'package:flutter_example/data/models/auth/device_config_keys.dart';
import 'package:flutter_example/data/models/auth/device_context_dto.dart';
import 'package:flutter_example/data/models/auth/device_data_keys.dart';
import 'package:flutter_example/data/models/auth/server_config_dto.dart';
import 'package:flutter_example/domain/entities/device/device_config.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'i_local_config_provider.dart';

@LazySingleton(as: ILocalConfigProvider)
class LocalConfigProvider implements ILocalConfigProvider {
  static const String _dbName = 'config_cache.db';
  static const int _dbVersion = 2; // Увеличено для миграции

  static const String _tableServerConfig = 'server_config';
  static const String _tableDeviceConfig = 'device_config';
  static const String _tableDeviceContext = 'device_context';

  final Talker _talker;
  Database? _database;

  LocalConfigProvider({required Talker talker}) : _talker = talker;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      _dbName,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _migrateDatabase(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableServerConfig (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ServerConfigKeys.messageId.key} TEXT,
        ${ServerConfigKeys.voipPort.key} INTEGER,
        ${ServerConfigKeys.videoPort.key} INTEGER,
        ${ServerConfigKeys.audioSampleRate.key} INTEGER,
        ${ServerConfigKeys.audioFrameSize.key} INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableDeviceConfig (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DeviceConfigKeys.messageId.key} TEXT,
        ${DeviceConfigKeys.ssrc.key} INTEGER,
        ${DeviceConfigKeys.appName.key} TEXT,
        ${DeviceConfigKeys.versionCode.key} INTEGER,
        ${DeviceConfigKeys.versionName.key} TEXT,
        ${DeviceConfigKeys.password.key} TEXT,
        ${DeviceConfigKeys.audioCodec.key} INTEGER,
        ${DeviceDataKeys.sessionId.key} TEXT,
        ${DeviceConfigMapper.idKeyToDBMap} TEXT,
        ${DeviceDataKeys.statusId.key} TEXT,
        ${DeviceDataKeys.login.key} TEXT,
        ${DeviceDataKeys.avatarHash.key} TEXT,
        ${DeviceDataKeys.deviceDescription.key} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableDeviceContext (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DeviceContextKeys.messageId.key} TEXT,
        ${DeviceContextKeys.videoResolution.key} INTEGER,
        ${DeviceContextKeys.pingTimeout.key} INTEGER,
        ${DeviceContextKeys.networkName.key} TEXT,
        ${DeviceContextKeys.networkGlobalId.key} TEXT,
        ${DeviceContextKeys.networkInstanceId.key} TEXT
      )
    ''');
  }

  Future<void> _migrateDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    _talker.info('Миграция БД с версии $oldVersion на $newVersion');

    for (var version = oldVersion + 1; version <= newVersion; version++) {
      switch (version) {
        case 2:
          await _migrateToV2(db);
          break;
        // case 3:
        //   await _migrateToV3(db);
        //   break;
        // Добавляйте новые версии по мере необходимости
      }
    }
  }

  /// Миграция до версии 2 (упрощенная, без сохранения данных)
  Future<void> _migrateToV2(Database db) async {
    try {
      // 1. Удаляем старую таблицу device_config
      await db.execute('DROP TABLE IF EXISTS $_tableDeviceConfig');

      // 2. Создаем новую таблицу device_config с правильной структурой
      await db.execute('''
        CREATE TABLE $_tableDeviceConfig (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ${DeviceConfigKeys.messageId.key} TEXT,
          ${DeviceConfigKeys.ssrc.key} INTEGER,
          ${DeviceConfigKeys.appName.key} TEXT,
          ${DeviceConfigKeys.versionCode.key} INTEGER,
          ${DeviceConfigKeys.versionName.key} TEXT,
          ${DeviceConfigKeys.password.key} TEXT,
          ${DeviceConfigKeys.audioCodec.key} INTEGER,
          ${DeviceDataKeys.sessionId.key} TEXT,
          ${DeviceConfigMapper.idKeyToDBMap} TEXT,
          ${DeviceDataKeys.statusId.key} TEXT,
          ${DeviceDataKeys.login.key} TEXT,
          ${DeviceDataKeys.avatarHash.key} TEXT,
          ${DeviceDataKeys.deviceDescription.key} TEXT
        )
      ''');

      // 3. Создаем новую таблицу для DeviceContextDto
      await db.execute('''
      CREATE TABLE $_tableDeviceContext (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DeviceContextKeys.messageId.key} TEXT,
        ${DeviceContextKeys.videoResolution.key} INTEGER,
        ${DeviceContextKeys.pingTimeout.key} INTEGER,
        ${DeviceContextKeys.networkName.key} TEXT,
        ${DeviceContextKeys.networkGlobalId.key} TEXT,
        ${DeviceContextKeys.networkInstanceId.key} TEXT
      )
    ''');

      _talker.info(
        'Миграция до v2 успешно завершена: '
        'пересоздана таблица $_tableDeviceConfig и '
        'создана таблица $_tableDeviceContext',
      );
    } catch (e, st) {
      _talker.error('Ошибка миграции до v2', e, st);
      rethrow;
    }
  }

  /// ЗАГОТОВКА ДЛЯ СЛЕДУЮЩЕЙ МИГРАЦИИ
  // Future<void> _migrateToV3(Database db) async {
  //   try {
  //     // Пример: добавляем новое поле в server_config
  //     // await db.execute(
  //     //   'ALTER TABLE $_tableServerConfig ADD COLUMN new_field TEXT'
  //     // );
  //
  //     // Пример: создаем новую таблицу
  //     // await db.execute('''
  //     //   CREATE TABLE new_table (
  //     //     id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     //     name TEXT,
  //     //     value INTEGER
  //     //   )
  //     // ''');
  //
  //     _talker.info('Миграция до v3 успешно завершена');
  //   } catch (e, st) {
  //     _talker.error('Ошибка миграции до v3', e, st);
  //     rethrow;
  //   }
  // }

  @override
  Future<Either<DomainError, void>> saveServerConfig(ServerConfigDto config) async {
    try {
      final db = await database;
      await db.delete(_tableServerConfig);
      await db.insert(_tableServerConfig, config.toMap());
      return const Right(null);
    } catch (e, st) {
      final errText = 'Ошибка сохранения конфикурации сервера в локальную БД';
      _talker.error(errText, e, st);
      return Left(DatabaseFailure(errText));
    }
  }

  @override
  Future<Either<DomainError, ServerConfigDto?>> getServerConfig() async {
    try {
      final db = await database;
      final maps = await db.query(_tableServerConfig);

      if (maps.isEmpty) return const Right(null);

      return Right(ServerConfigDto.fromMap(maps.first));
    } catch (e, st) {
      final errText = 'Ошибка получения конфикурации сервера из локальной БД';
      _talker.error(errText, e, st);
      return Left(DatabaseFailure(errText));
    }
  }

  @override
  Future<Either<DomainError, void>> saveDeviceConfig(DeviceConfig config) async {
    try {
      final db = await database;
      // // Отладочный вывод структуры таблицы
      // final tableInfo = await db.rawQuery(
      //   'PRAGMA table_info($_tableDeviceConfig)',
      // );
      // _talker.debug('Структура таблицы device_config: $tableInfo');

      // // Отладочный вывод данных для вставки
      // final dbMap = config.toDBMap();
      // _talker.debug('Данные для вставки: $dbMap');

      await db.delete(_tableDeviceConfig);
      await db.insert(_tableDeviceConfig, DeviceConfigMapper.toDBMap(config));
      return const Right(null);
    } catch (e, st) {
      final errText =
          'Ошибка сохранения конфикурации устройства в локальную БД';
      _talker.error(errText, e, st);
      return Left(DatabaseFailure(errText));
    }
  }

  @override
  Future<Either<DomainError, DeviceConfig?>> getDeviceConfig() async {
    try {
      final db = await database;
      final maps = await db.query(_tableDeviceConfig);

      if (maps.isEmpty) return const Right(null);

      final map = maps.first;
      return Right(DeviceConfigMapper.fromDBMap(map));
    } catch (e, st) {
      final errText =
          'Ошибка получения конфикурации устройства из локальной БД';
      _talker.error(errText, e, st);
      return Left(DatabaseFailure(errText));
    }
  }

  @override
  Future<Either<DomainError, void>> saveDeviceContext(
    DeviceContextDto context,
  ) async {
    try {
      final db = await database;
      await db.delete(_tableDeviceContext);
      await db.insert(_tableDeviceContext, context.toMap());
      return const Right(null);
    } catch (e, st) {
      final errText = 'Ошибка сохранения контекста устройства в локальную БД';
      _talker.error(errText, e, st);
      return Left(DatabaseFailure(errText));
    }
  }

  @override
  Future<Either<DomainError, DeviceContextDto?>> getDeviceContext() async {
    try {
      final db = await database;
      final maps = await db.query(_tableDeviceContext);

      if (maps.isEmpty) return const Right(null);

      return Right(DeviceContextDto.fromMap(maps.first));
    } catch (e, st) {
      final errText = 'Ошибка получения контекста устройства из локальной БД';
      _talker.error(errText, e, st);
      return Left(DatabaseFailure(errText));
    }
  }

  @override
  Future<Either<DomainError, void>> clearAllConfigs() async {
    try {
      final db = await database;
      await db.delete(_tableServerConfig);
      await db.delete(_tableDeviceConfig);
      await db.delete(_tableDeviceContext);
      return const Right(null);
    } catch (e, st) {
      final errText =
          'Ошибка очистки локальной БД от данных конфигураций сервера, устройства и контекста устройства';
      _talker.error(errText, e, st);
      return Left(DatabaseFailure(errText));
    }
  }
}
