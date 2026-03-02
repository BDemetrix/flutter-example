import 'dart:async';
import 'dart:math';

import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/domain/entities/operation/operation.dart';
import 'package:flutter_example/data/mappers/operation_mapper.dart';
import 'package:flutter_example/data/providers/websocket/i_websocket_provider.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Mock WebSocket provider для CleanArch Demo.
/// Зона ответственности: эмуляция WebSocket соединения, генерация тестовых данных,
/// имитация handshake-последовательности и периодических обновлений.
@LazySingleton(as: IWebSocketProvider)
class AppWsProvider implements IWebSocketProvider<String> {
  final Talker _talker;
  late StreamController<Either<DomainError, Map<String, dynamic>>>
  _selfStreamController;

  // Creative names for mock users
  static const _firstNames = [
    'Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey',
    'Riley', 'Avery', 'Quinn', 'Skyler', 'Dakota',
    'Phoenix', 'River', 'Sage', 'Rowan', 'Emery',
    'Reese', 'Blake', 'Cameron', 'Hayden', 'Peyton',
  ];

  static const _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
    'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
  ];

  static const _nicknames = [
    'The Navigator', 'Night Owl', 'Speed Demon', 'Shadow', 'Phoenix',
    'Storm', 'Blaze', 'Frost', 'Echo', 'Viper',
    'Raven', 'Wolf', 'Hawk', 'Tiger', 'Bear',
  ];

  AppWsProvider({required Talker talker}) : _talker = talker {
    _selfStreamController =
        StreamController<Either<DomainError, Map<String, dynamic>>>.broadcast();
    _talker.info('Created AppWsProvider (mock)');
  }

  String? _serverUri;
  bool _loggedIn = false;
  Timer? _periodicTimer;

  // Mock data storage
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _devices = [];
  final List<Map<String, dynamic>> _groups = [];

  // Backup initial data for re-initialization
  final List<Map<String, dynamic>> _initialUsers = [];
  final List<Map<String, dynamic>> _initialDevices = [];
  final List<Map<String, dynamic>> _initialGroups = [];

  @override
  String? get serverUri => _serverUri;

  @override
  bool get loggedIn => _loggedIn;

  @override
  Stream<Either<DomainError, Map<String, dynamic>>> get stream =>
      _selfStreamController.stream;

  @override
  Future<Either<DomainError, void>> login(String serverUri) async {
    _talker.debug('Mock WS login to: $serverUri');
    _serverUri = serverUri;
    _loggedIn = true;

    // Initialize mock data
    _initMockData();

    // Emulate handshake sequence
    _emulateHandshake();

    return const Right(null);
  }

  @override
  Future<Either<DomainError, void>> logout() async {
    _talker.debug('Mock WS logout');
    _periodicTimer?.cancel();
    _loggedIn = false;
    _serverUri = null;
    return const Right(null);
  }

  @override
  void send(String message) {
    _talker.debug('Mock WS send (ignored): $message');
  }

  void _emit(Map<String, dynamic> data) {
    if (!_selfStreamController.isClosed) {
      _selfStreamController.sink.add(Right(data));
    }
  }

  void _initMockData() {
    // Initial users (DataType=11)
    _users.addAll([
      {"ID":"KXOduoLUMkKu3flYfmkmew==","Type":0,"Login":"1001","Name":"Alex \"The Navigator\" Smith","Locked":false},
      {"ID":"BrlZGFdwVr2aVzYmM5JI0A==","Type":0,"Login":"1002","Name":"Jordan Storm Garcia","Locked":false},
      {"ID":"rk5/SsxY8pRHTeVQEBMKNA==","Type":0,"Login":"1003","Name":"Taylor Phoenix Williams","Locked":false},
      {"ID":"eXj3tAb2CYxwynRx+4DZqA==","Type":0,"Login":"1004","Name":"Morgan \"Night Owl\" Johnson","Locked":false},
      {"ID":"S99UDAAm2erl1IL91MvhmA==","Type":0,"Login":"1005","Name":"Casey Blaze Miller","Locked":false},
      {"ID":"87CzZcp21UKKsZpF0P+/vA==","Type":0,"Login":"1006","Name":"Riley Shadow Davis","Locked":false},
      {"ID":"zbp6O07jWl6JxkIjdTL7wQ==","Type":0,"Login":"1007","Name":"Avery \"Speed Demon\" Brown","Locked":false},
      {"ID":"7qzWhQoDgPYOu1IehTfVFg==","Type":0,"Login":"1008","Name":"Quinn Frost Jones","Locked":false},
      {"ID":"hdtgyy8Vqk+A+EhUkGOS+Q==","Type":1,"Login":"dispatcher01","Name":"Skyler Raven Martinez","Locked":false},
      {"ID":"NZsD8s6F1kiD6u0G0RTJOA==","Type":1,"Login":"dispatcher02","Name":"Dakota \"Wolf\" Hernandez","Locked":false},
      {"ID":"EREREREREREREREREREREREQ==","Type":1,"Login":"admin","Name":"Phoenix \"The Chief\" Lopez","Locked":false},
    ]);
    _initialUsers.addAll(_users);

    // Initial devices (DataType=10) - UserID must exist in _users, Login/UserName must match user data
    _devices.addAll([
      {"ID":"XdSEY/dsDA43y+Wnw2+kjw==","Type":0,"UserID":"KXOduoLUMkKu3flYfmkmew==","StatusID":"AAAAAAAAAAAAAAAAAAAAAA==","Login":"1001","UserName":"Alex \"The Navigator\" Smith","DeviceDescription":"MANUFACTURER=TEST;MODEL=DEVICE_A;SERIAL=000001;OSVERSION=13","AvatarHash":"","VersionName":"1.0.0"},
      {"ID":"pu5BZyMPlrxs8amKw14rVQ==","Type":0,"UserID":"BrlZGFdwVr2aVzYmM5JI0A==","StatusID":"AAAAAAAAAAAAAAAAAAAAAA==","Login":"1002","UserName":"Jordan Storm Garcia","DeviceDescription":"MANUFACTURER=TEST;MODEL=DEVICE_B;SERIAL=000002;OSVERSION=14","AvatarHash":"","VersionName":"1.0.0"},
      {"ID":"LlPbPalS5u8LxqSqWqU9dA==","Type":0,"UserID":"rk5/SsxY8pRHTeVQEBMKNA==","StatusID":"BDT+fA5XEESnIxCTH6+8Tw==","Login":"1003","UserName":"Taylor Phoenix Williams","DeviceDescription":"MANUFACTURER=TEST;MODEL=DEVICE_C;SERIAL=000003;OSVERSION=15","AvatarHash":"","VersionName":"1.0.0"},
      {"ID":"lPbPa5u8LxqSыаыqWqU9dA==","Type":0,"UserID":"S99UDAAm2erl1IL91MvhmA==","StatusID":"BDT+fA5XEESnIxCTH+8Tw==","Login":"1004","UserName":"Morgan \"Night Owl\" Johnson","DeviceDescription":"MANUFACTURER=TEST;MODEL=DEVICE_C;SERIAL=000003;OSVERSION=15","AvatarHash":"","VersionName":"1.0.0"},
    ]);
    _initialDevices.addAll(_devices);

    // Initial groups (DataType=12)
    _groups.addAll([
      {"ID":"tOyXZRtmcR3xFoveR3dbTA==","Type":0,"Name":"Command Center","Priority":0,"Emergency":0,"AllCall":0,"Broadcast":0,"Echo":0},
      {"ID":"b6ypV6bOX0ipsYRcYjoVsQ==","Type":0,"Name":"Tactical Team","Priority":2,"Emergency":0,"AllCall":0,"Broadcast":0,"Echo":0},
      {"ID":"j7jX5NR0cDLWpLtiRHbBnQ==","Type":0,"Name":"Emergency Response","Priority":5,"Emergency":1,"AllCall":1,"Broadcast":1,"Echo":0},
      {"ID":"PQ6oDzsk2gVSm8vwSu3d4Q==","Type":0,"Name":"Security Patrol","Priority":0,"Emergency":0,"AllCall":0,"Broadcast":0,"Echo":0},
      {"ID":"QzM4UBPA2XWm7yImYVKTPA==","Type":1,"Name":"Rapid Response Unit","Priority":0,"Emergency":0,"AllCall":0,"Broadcast":0,"Echo":0},
      {"ID":"8dBU4zS3JALUPg0pfv30+A==","Type":1,"Name":"Night Shift Ops","Priority":0,"Emergency":0,"AllCall":0,"Broadcast":0,"Echo":0},
    ]);
    _initialGroups.addAll(_groups);
  }

  /// Re-initialize data by sending Operation.initialize with initial mock data
  void _reinitializeData() {
    _talker.debug('Mock WS: Re-initializing data (lists became empty)');
    
    // Reset current lists to initial state
    _users.clear();
    _users.addAll(_initialUsers);
    _devices.clear();
    _devices.addAll(_initialDevices);
    _groups.clear();
    _groups.addAll(_initialGroups);

    // Send initialize operations for all data types
    Future.delayed(Duration.zero, () {
      _emit({
        "MessageID": "DATAEX",
        "DataType": 11,
        "Operation": OperationMapper.toCode(Operation.initialize),
        "DataObjects": List<Map<String, dynamic>>.from(_initialUsers),
      });
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _emit({
        "MessageID": "DATAEX",
        "DataType": 10,
        "Operation": OperationMapper.toCode(Operation.initialize),
        "DataObjects": List<Map<String, dynamic>>.from(_initialDevices),
      });
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _emit({
        "MessageID": "DATAEX",
        "DataType": 12,
        "Operation": OperationMapper.toCode(Operation.initialize),
        "DataObjects": List<Map<String, dynamic>>.from(_initialGroups),
      });
    });
  }

  void _emulateHandshake() {
    // +300ms → SERVER_CONFIG
    Future.delayed(const Duration(milliseconds: 300), () {
      _emit({"MessageID": "SERVER_CONFIG", "VoipPort": 5060, "VideoPort": 8554, "AudioSampleRate": 8000, "AudioFrameSize": 160});
    });

    // +300ms → CONFIG_SERVER_RESPONSE_ACK
    Future.delayed(const Duration(milliseconds: 600), () {
      _emit({"MessageID": "CONFIG_SERVER_RESPONSE_ACK"});
    });

    // +300ms → LOGIN_RESPONSE
    Future.delayed(const Duration(milliseconds: 900), () {
      _emit({"MessageID": "LOGIN_RESPONSE", "Response": 0, "UserID": "EREREREREREREREREREREREQ=="});
    });

    // +300ms → DEVICE_CONTEXT
    Future.delayed(const Duration(milliseconds: 1200), () {
      _emit({
        "MessageID": "DEVICE_CONTEXT",
        "PingTimeout": 30000,
        "UserID": "EREREREREREREREREREREREREQ==",
        "VideoResolution": 0,
        "NetworkName": "",
        "NetworkGlobalID": "",
        "NetworkInstanceID": "",
      });
    });

    // +500ms → DATAEX DataType=11, Operation=initialize (users)
    Future.delayed(const Duration(milliseconds: 1700), () {
      _emit({
        "MessageID": "DATAEX",
        "DataType": 11,
        "Operation": OperationMapper.toCode(Operation.initialize),
        "DataObjects": _users,
      });
    });

    // +200ms → DATAEX DataType=10, Operation=initialize (devices)
    Future.delayed(const Duration(milliseconds: 1900), () {
      _emit({
        "MessageID": "DATAEX",
        "DataType": 10,
        "Operation": OperationMapper.toCode(Operation.initialize),
        "DataObjects": _devices,
      });
    });

    // +200ms → DATAEX DataType=12, Operation=initialize (groups)
    Future.delayed(const Duration(milliseconds: 2100), () {
      _emit({
        "MessageID": "DATAEX",
        "DataType": 12,
        "Operation": OperationMapper.toCode(Operation.initialize),
        "DataObjects": _groups,
      });
    });

    // Start periodic updates after initial data
    Future.delayed(const Duration(seconds: 3), () {
      _startPeriodicUpdates();
    });
  }

  void _startPeriodicUpdates() {
    _periodicTimer = Timer.periodic(Duration(milliseconds: 333), (_) {
      _emitRandomOperation();
    });
  }

  void _emitRandomOperation() {
    final random = Random();
    final dataType = [11, 10, 12][random.nextInt(3)]; // 11=users, 10=devices, 12=groups

    List<Map<String, dynamic>> targetList;
    String idField;

    switch (dataType) {
      case 11:
        targetList = _users;
        idField = 'ID';
        break;
      case 10:
        targetList = _devices;
        idField = 'ID';
        break;
      case 12:
        targetList = _groups;
        idField = 'ID';
        break;
      default:
        return;
    }

    // Check if target list is empty or too small - reinitialize if needed
    if (targetList.isEmpty) {
      _reinitializeData();
      return;
    }

    // Select random entities (no more than half) for operations
    final maxToRemoveOrChange = (targetList.length / 2).ceil();
    final countToRemoveOrChange = random.nextInt(maxToRemoveOrChange) + 1;
    final shuffled = List<Map<String, dynamic>>.from(targetList)..shuffle(random);
    final selectedForOperation = shuffled.take(countToRemoveOrChange).toList();

    Map<String, dynamic> data;

    // Operation codes must match OperationMapper:
    // 0 = initialize, 1 = add, 2 = remove, 3 = change
    final operationCodes = [
      OperationMapper.toCode(Operation.add),
      OperationMapper.toCode(Operation.remove),
      OperationMapper.toCode(Operation.change),
    ];
    final operation = operationCodes[random.nextInt(operationCodes.length)];

    switch (operation) {
      case 1: // add - add all entities from mocks
        final newItems = <Map<String, dynamic>>[];
        for (final _ in selectedForOperation) {
          final newId = _generateBase64Id();
          final newItem = _createMockItem(dataType, newId);
          if (newItem.isNotEmpty) {
            newItems.add(newItem);
            targetList.add(newItem);
          }
        }
        if (newItems.isEmpty) {
          _talker.debug('Mock WS: Skipping add operation - failed to create items for DataType=$dataType');
          return;
        }
        data = {
          "MessageID": "DATAEX",
          "DataType": dataType,
          "Operation": operation,
          "DataObjects": newItems,
        };
        _talker.debug('Mock WS: Added ${newItems.length} items to DataType=$dataType');
        break;

      case 2: // remove - remove selected entities by ID (OperationMapper: 2 = remove)
        final removedIds = <String>[];
        for (final item in selectedForOperation) {
          final removedId = item[idField] as String;
          targetList.removeWhere((e) => e[idField] == removedId);
          removedIds.add(removedId);
        }

        // For remove operation, send objects with only the ID field
        final removeData = removedIds.map((id) => <String, dynamic>{idField: id}).toList();

        data = {
          "MessageID": "DATAEX",
          "DataType": dataType,
          "Operation": operation,
          "DataObjects": removeData,
        };
        _talker.debug('Mock WS: Removed ${removedIds.length} items from DataType=$dataType');
        break;

      case 3: // change - modify names of selected entities randomly (OperationMapper: 3 = change)
        final changedItems = <Map<String, dynamic>>[];
        for (final item in selectedForOperation) {
          switch (dataType) {
            case 11: // user - change Name randomly
              final firstName = _firstNames[random.nextInt(_firstNames.length)];
              final lastName = _lastNames[random.nextInt(_lastNames.length)];
              final nickname = _nicknames[random.nextInt(_nicknames.length)];
              final nameStyle = random.nextInt(3);
              String displayName;
              switch (nameStyle) {
                case 0:
                  displayName = '$firstName $lastName';
                  break;
                case 1:
                  displayName = '$firstName "$nickname" $lastName';
                  break;
                default:
                  displayName = '$firstName $nickname';
              }
              item['Name'] = displayName;
              break;

            case 10: // device - change UserName/Login using mock data
              final firstName = _firstNames[random.nextInt(_firstNames.length)];
              final lastName = _lastNames[random.nextInt(_lastNames.length)];
              final nickname = _nicknames[random.nextInt(_nicknames.length)];
              final nameStyle = random.nextInt(3);
              String displayName;
              switch (nameStyle) {
                case 0:
                  displayName = '$firstName $lastName';
                  break;
                case 1:
                  displayName = '$firstName "$nickname" $lastName';
                  break;
                default:
                  displayName = '$firstName $nickname';
              }
              final loginNum = random.nextInt(1000);
              item['Login'] = '$loginNum';
              item['UserName'] = displayName;
              break;

            case 12: // group - change Name
              final num = random.nextInt(1000);
              item['Name'] = 'Group $num';
              break;
          }
          changedItems.add(item);
        }
        data = {
          "MessageID": "DATAEX",
          "DataType": dataType,
          "Operation": operation,
          "DataObjects": changedItems,
        };
        _talker.debug('Mock WS: Changed ${changedItems.length} items in DataType=$dataType');
        break;

      default:
        return;
    }

    _emit(data);
  }

  Map<String, dynamic> _createMockItem(int dataType, String id) {
    final random = Random();
    final num = random.nextInt(1000);

    switch (dataType) {
      case 11: // user
        final firstName = _firstNames[random.nextInt(_firstNames.length)];
        final lastName = _lastNames[random.nextInt(_lastNames.length)];
        final nickname = _nicknames[random.nextInt(_nicknames.length)];
        final nameStyle = random.nextInt(3);

        String displayName;
        switch (nameStyle) {
          case 0:
            displayName = '$firstName $lastName';
            break;
          case 1:
            displayName = '$firstName "$nickname" $lastName';
            break;
          default:
            displayName = '$firstName $nickname';
        }

        return {
          "ID": id,
          "Type": 0,
          "Login": "user$num",
          "Name": displayName,
          "Locked": false,
        };
      case 10: // device
        // Only use users with Type=0 (regular subscribers, not dispatchers/admins)
        final regularUsers = _users.where((u) => (u['Type'] as int) == 0).toList();
        if (regularUsers.isEmpty) {
          _talker.warning('Mock WS: Cannot create device - no regular users available');
          return {};
        }
        final user = regularUsers[random.nextInt(regularUsers.length)];
        final userId = user["ID"] as String;
        final userLogin = user["Login"] as String;
        final userName = user["Name"] as String;
        return {
          "ID": id,
          "Type": 0,
          "UserID": userId,
          "StatusID": "AAAAAAAAAAAAAAAAAAAAAA==",
          "Login": userLogin,
          "UserName": userName,
          "DeviceDescription": "MANUFACTURER=TEST;MODEL=DEVICE_X;SERIAL=${random.nextInt(999999)};OSVERSION=16",
          "AvatarHash": "",
          "VersionName": "1.0.0",
        };
      case 12: // group
        return {
          "ID": id,
          "Type": 0,
          "Name": "Group $num",
          "Priority": random.nextInt(5),
          "Emergency": 0,
          "AllCall": 0,
          "Broadcast": 0,
          "Echo": 0,
        };
      default:
        return {};
    }
  }

  String _generateBase64Id() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(24, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
