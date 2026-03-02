import 'dart:async';

import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter_example/domain/entities/abonent/abonent_payload.dart';
import 'package:flutter_example/domain/entities/contacts/contacts_data.dart';
import 'package:flutter_example/domain/entities/device/device.dart';
import 'package:flutter_example/domain/entities/device/device_payload.dart';
import 'package:flutter_example/domain/entities/group/group.dart';
import 'package:flutter_example/domain/entities/group/group_payload.dart';
import 'package:flutter_example/domain/entities/operation/operation.dart';
import 'package:flutter_example/domain/entities/operation/operation_container.dart';
import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/repositories/i_abonent_repository.dart';
import 'package:flutter_example/domain/repositories/i_device_repository.dart';
import 'package:flutter_example/domain/repositories/i_group_repository.dart';
import 'package:flutter_example/domain/repositories/i_profile_repository.dart';
import 'package:fpdart/fpdart.dart' hide Group;
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

enum _RepositorySource { abonent, group, device }

/// Агрегат контактов.
/// Зона ответственности: объединение данных от репозиториев абонентов, групп и устройств,
/// синхронизация онлайн-статусов, фильтрация и сортировка контактов.
@injectable
class ContactsAggregate {
  final IProfileRepository _profileRepository;
  final IAbonentRepository _abonentRepository;
  final IGroupRepository _groupRepository;
  final IDeviceRepository _deviceRepository;
  final Talker _talker;

  late final StreamController<Either<DomainError, ContactsData>> _controller;
  late final StreamSubscription<
    Either<DomainError, OperationContainer<AbonentPayload>>
  >
  _abonentRepositoryListener;
  late final StreamSubscription<
    Either<DomainError, OperationContainer<GroupPayload>>
  >
  _groupRepositoryListener;
  late final StreamSubscription<
    Either<DomainError, OperationContainer<DevicePayload>>
  >
  _deviceRepositoryListener;

  Profile? _profile;
  final Map<String, Abonent> _abonentsMap = {};
  final Map<String, Device> _deviceMap = {};
  final Map<String, Group> _groupMap = {};

  bool _abonentDone = false;
  bool _groupDone = false;
  bool _deviceDone = false;

  ContactsAggregate({
    required IProfileRepository profileRepository,
    required IAbonentRepository abonentRepository,
    required IGroupRepository groupRepository,
    required IDeviceRepository deviceRepository,
    required Talker talker,
  }) : _profileRepository = profileRepository,
       _abonentRepository = abonentRepository,
       _groupRepository = groupRepository,
       _deviceRepository = deviceRepository,
       _talker = talker {
    _controller = StreamController<Either<DomainError, ContactsData>>.broadcast();

    _abonentRepositoryListener = _abonentRepository.stream.listen(
      _onAbonentData,
      onError: (Object err, StackTrace st) =>
          _onRepositoryError(err, st, source: _RepositorySource.abonent),
      onDone: () => _onRepositoryDone(source: _RepositorySource.abonent),
      cancelOnError: false,
    );

    _groupRepositoryListener = _groupRepository.stream.listen(
      _onGroupData,
      onError: (Object err, StackTrace st) =>
          _onRepositoryError(err, st, source: _RepositorySource.group),
      onDone: () => _onRepositoryDone(source: _RepositorySource.group),
      cancelOnError: false,
    );

    _deviceRepositoryListener = _deviceRepository.stream.listen(
      _onDeviceData,
      onError: (Object err, StackTrace st) =>
          _onRepositoryError(err, st, source: _RepositorySource.device),
      onDone: () => _onRepositoryDone(source: _RepositorySource.device),
      cancelOnError: false,
    );
  }

  Stream<Either<DomainError, ContactsData>> get stream => _controller.stream;

  // Обработка данных от репозитория абонентов
  void _onAbonentData(
    Either<DomainError, OperationContainer<AbonentPayload>> result,
  ) {
    result.fold(
      (failure) {
        _controller.add(Left(failure));
      },
      (abonentsMsg) async {
        switch (abonentsMsg.operation) {
          case Operation.initialize:
            // Полная замена словаря абонентов
            if (abonentsMsg.data is! AbonentList) break;
            _abonentsMap.clear();
            final abonents = (abonentsMsg.data as AbonentList).abonents;
            for (var abonent in abonents) {
              _abonentsMap[abonent.id] = abonent;
            }
            // Синхронизация: обновляем isOnline и deviceId для всех абонентов
            _synchronizeAbonentsWithDevices();
            break;
          case Operation.add:
          case Operation.change:
            if (abonentsMsg.data is! AbonentList) break;
            final abonents = (abonentsMsg.data as AbonentList).abonents;
            for (var abonent in abonents) {
              _abonentsMap[abonent.id] = abonent;
            }
            // Синхронизация для измененных абонентов
            _synchronizeAbonentsWithDevices();
            break;
          case Operation.remove:
            if (abonentsMsg.data is! AbonentIds) break;
            for (var id in (abonentsMsg.data as AbonentIds).abonentIds) {
              _abonentsMap.remove(id);
            }
            // После удаления абонента нужно обновить синхронизацию
            _synchronizeAbonentsWithDevices();
            break;
        }

        await _removeProfileFromAbonsMap();
        _emitContactsIfReady();
      },
    );
  }

  /// Синхронизирует абонентов с устройствами: обновляет isOnline и deviceId
  void _synchronizeAbonentsWithDevices() {
    // Сначала сбрасываем все isOnline в false
    for (var entry in _abonentsMap.entries) {
      _abonentsMap[entry.key] = entry.value.copyWith(
        isOnline: false,
        deviceId: '',
      );
    }

    // Затем помечаем абонентов с устройствами как online и устанавливаем deviceId
    for (var device in _deviceMap.values) {
      // Пропускаем устройства без userId
      if (device.userId.isEmpty) {
        continue;
      }

      final abon = _abonentsMap[device.userId];
      if (abon == null) {
        _talker.info(
          "В списке устройств существует устройство для которого не нашелся абонент! device.userId = ${device.userId}",
        );
        continue;
      }
      _abonentsMap[device.userId] = abon.copyWith(
        isOnline: true,
        deviceId: device.id,
      );
    }
  }

  /// Удаляет текущий профиль из массива абонентов
  Future<void> _removeProfileFromAbonsMap() async {
    if (_profile == null) {
      final eitherProfile = await _profileRepository.getProfile();
      eitherProfile.fold(
        (failure) => _talker.error(
          'GetContactsUseCase - не удалось получить даныне профиля из ProfileRepository',
          failure,
          StackTrace.current,
        ),
        (profile) => _profile = profile,
      );
    }
    _abonentsMap.remove(_profile?.userId);
  }

  // Обработка данных от репозитория групп
  void _onGroupData(Either<DomainError, OperationContainer<GroupPayload>> result) {
    result.fold(
      (failure) {
        _controller.add(Left(failure));
      },
      (groupsMsg) {
        switch (groupsMsg.operation) {
          case Operation.initialize:
            // Полная замена словаря групп
            if (groupsMsg.data is! GroupList) break;
            _groupMap.clear();
            for (var g in (groupsMsg.data as GroupList).groups) {
              _groupMap[g.id] = g;
            }
            break;
          case Operation.add:
          case Operation.change:
            if (groupsMsg.data is! GroupList) break;
            for (var g in (groupsMsg.data as GroupList).groups) {
              _groupMap[g.id] = g;
            }
            break;
          case Operation.remove:
            if (groupsMsg.data is! GroupIds) break;
            for (var id in (groupsMsg.data as GroupIds).groupId) {
              _groupMap.remove(id);
            }
            break;
        }

        _emitContactsIfReady();
      },
    );
  }

  /// Обработка данных от репозитория устройств
  void _onDeviceData(
    Either<DomainError, OperationContainer<DevicePayload>> result,
  ) {
    result.fold(
      (failure) {
        _controller.add(Left(failure));
      },
      (deviceMsg) {
        switch (deviceMsg.operation) {
          case Operation.initialize:
            // Полная замена словаря устройств
            if (deviceMsg.data is! DeviceList) break;
            _deviceMap.clear();
            final devices = (deviceMsg.data as DeviceList).devices;
            for (var d in devices) {
              _deviceMap[d.id] = d;
            }
            // Синхронизация: обновляем isOnline и deviceId для всех абонентов
            _synchronizeAbonentsWithDevices();
            break;
          case Operation.add:
          case Operation.change:
            if (deviceMsg.data is! DeviceList) break;
            final devices = (deviceMsg.data as DeviceList).devices;
            for (var d in devices) {
              _deviceMap[d.id] = d;
            }
            // Синхронизация для абонентов с измененными устройствами
            _synchronizeAbonentsWithDevices();
            break;
          case Operation.remove:
            if (deviceMsg.data is! DeviceIds) break;
            for (var id in (deviceMsg.data as DeviceIds).deviceIds) {
              _deviceMap.remove(id);
            }
            // Синхронизация после удаления устройств
            _synchronizeAbonentsWithDevices();
            break;
        }

        _emitContactsIfReady();
      },
    );
  }

  // Общая логика отправки объединённых данных
  void _emitContactsIfReady() {
    // Отправляем текущие данные, даже если одна из коллекций пока пустая.
    // Здесь надо будет подмешивать статус входящего вызова и фильтровать контакты
    final data = ContactsData(
      abonents: _sortAbonents(_filterAbonents(_abonentsMap.values.toList())),
      groups: _sortGroups(_filterGroups(_groupMap.values.toList())),
    );
    _controller.add(Right(data));
  }

  List<Abonent> _filterAbonents(List<Abonent> abonents) {
    return abonents
        .where((a) => a.id.isNotEmpty && a.name.isNotEmpty)
        .toList();
  }

  List<Group> _filterGroups(List<Group> groups) {
    return groups
        .where((g) => g.id.isNotEmpty && g.name.isNotEmpty)
        .toList();
  }

  List<Abonent> _sortAbonents(List<Abonent> abonents) {
    return List<Abonent>.from(abonents)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<Group> _sortGroups(List<Group> groups) {
    return List<Group>.from(groups)..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Обработка ошибок, которые пришли как исключение потока (onError)
  /// не отменяем подписку (cancelOnError: false) — можно продолжать получать данные
  void _onRepositoryError(
    Object e,
    StackTrace st, {
    required _RepositorySource source,
  }) {
    final sourceStr = source == _RepositorySource.group ? 'групп' : 'абонентов';
    final errText = 'Сбой потока получения данных $sourceStr в ядре приложения';
    _talker.error(errText, e, st);

    // Если поток уже выдал DomainError — прокидываем напрямую
    if (e is DomainError) {
      _controller.add(Left(e));
      return;
    }

    final failure = DataProcessingFailure(message: errText);
    _controller.add(Left(failure));
  }

  /// Помечает источник как завершённый; когда оба завершились — закрываем контроллер
  void _onRepositoryDone({required _RepositorySource source}) {
    String errText;
    switch (source) {
      case _RepositorySource.abonent:
        _abonentDone = true;
        errText =
            'Сбой - поток получения данных абонентов завершился по неизвестной причине';
        break;
      case _RepositorySource.group:
        _groupDone = true;
        errText =
            'Сбой - поток получения данных групп завершился по неизвестной причине';
        break;
      case _RepositorySource.device:
        _deviceDone = true;
        errText =
            'Сбой - поток получения данных устройств завершился по неизвестной причине';
        break;
    }

    final failure = DataProcessingFailure(message: errText);
    _controller.add(Left(failure));
    _talker.error(errText, failure, StackTrace.current);

    if (_abonentDone && _groupDone && _deviceDone) {
      if (!_controller.isClosed) _controller.close();
    }
  }

  // Освобождение ресурсов
  Future<void> dispose() async {
    await _abonentRepositoryListener.cancel();
    await _groupRepositoryListener.cancel();
    await _deviceRepositoryListener.cancel();
    if (!_controller.isClosed) await _controller.close();
  }
}
