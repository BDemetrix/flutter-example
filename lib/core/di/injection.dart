import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
  // Модули автоматически обнаруживаются!
  // Ничего не нужно указывать вручную
)
Future<GetIt> configureDependencies() => getIt.init();

/// Иньекция всех сторонних библиотек, которые не имеют анотаций @Injectable
@module
abstract class CoreModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  Talker get talker => TalkerFlutter.init();
}
