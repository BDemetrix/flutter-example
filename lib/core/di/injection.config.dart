// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:talker_flutter/talker_flutter.dart' as _i207;

import '../../data/providers/local_config/i_local_config_provider.dart'
    as _i135;
import '../../data/providers/local_config/local_config_provider.dart' as _i550;
import '../../data/providers/profile/i_profile_provider.dart' as _i250;
import '../../data/providers/profile/profile_prefs_provider.dart' as _i977;
import '../../data/providers/websocket/app_ws_provider.dart' as _i493;
import '../../data/providers/websocket/i_websocket_provider.dart' as _i311;
import '../../data/repositories/abonent_ws_repository.dart' as _i656;
import '../../data/repositories/auth_ws_repository.dart' as _i390;
import '../../data/repositories/device_ws_repository.dart' as _i327;
import '../../data/repositories/group_ws_repository.dart' as _i426;
import '../../data/repositories/profile_repository.dart' as _i971;
import '../../domain/aggregates/auth_aggregate.dart' as _i1068;
import '../../domain/aggregates/contacts/contacts_aggregate.dart' as _i541;
import '../../domain/aggregates/contacts/search_contacts_usecase.dart' as _i715;
import '../../domain/aggregates/failure_aggregate.dart' as _i246;
import '../../domain/aggregates/profile_aggregate.dart' as _i815;
import '../../domain/repositories/i_abonent_repository.dart' as _i98;
import '../../domain/repositories/i_auth_repository.dart' as _i841;
import '../../domain/repositories/i_device_repository.dart' as _i664;
import '../../domain/repositories/i_group_repository.dart' as _i66;
import '../../domain/repositories/i_profile_repository.dart' as _i1067;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.prefs,
      preResolve: true,
    );
    gh.factory<_i715.SearchContactsUseCase>(
      () => _i715.SearchContactsUseCase(),
    );
    gh.lazySingleton<_i207.Talker>(() => coreModule.talker);
    gh.lazySingleton<_i246.FailureAggregate>(
      () => _i246.FailureAggregate(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i135.ILocalConfigProvider>(
      () => _i550.LocalConfigProvider(talker: gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i250.IProfileProvider>(
      () => _i977.ProfilePrefsProvider(
        prefs: gh<_i460.SharedPreferences>(),
        talker: gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i311.IWebSocketProvider<String>>(
      () => _i493.AppWsProvider(talker: gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i66.IGroupRepository>(
      () => _i426.GroupWsRepository(
        webSocketProvider: gh<_i311.IWebSocketProvider<String>>(),
        talker: gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i841.IAuthRepository>(
      () => _i390.AuthWsRepository(
        localConfigProvider: gh<_i135.ILocalConfigProvider>(),
        profileProvider: gh<_i250.IProfileProvider>(),
        webSocketProvider: gh<_i311.IWebSocketProvider<String>>(),
        talker: gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i1067.IProfileRepository>(
      () =>
          _i971.ProfileRepository(localProvider: gh<_i250.IProfileProvider>()),
    );
    gh.lazySingleton<_i664.IDeviceRepository>(
      () => _i327.DeviceWsRepository(
        webSocketProvider: gh<_i311.IWebSocketProvider<String>>(),
        talker: gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i98.IAbonentRepository>(
      () => _i656.AbonentWsRepository(
        webSocketProvider: gh<_i311.IWebSocketProvider<String>>(),
        talker: gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i1068.AuthAggregate>(
      () => _i1068.AuthAggregate(gh<_i841.IAuthRepository>()),
    );
    gh.factory<_i541.ContactsAggregate>(
      () => _i541.ContactsAggregate(
        profileRepository: gh<_i1067.IProfileRepository>(),
        abonentRepository: gh<_i98.IAbonentRepository>(),
        groupRepository: gh<_i66.IGroupRepository>(),
        deviceRepository: gh<_i664.IDeviceRepository>(),
        talker: gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i815.ProfileAggregate>(
      () => _i815.ProfileAggregate(repository: gh<_i1067.IProfileRepository>()),
    );
    return this;
  }
}

class _$CoreModule extends _i464.CoreModule {}
