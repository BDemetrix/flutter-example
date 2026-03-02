import 'package:flutter_example/domain/errors/domain_error.dart';
import 'package:flutter_example/data/models/auth/device_context_dto.dart';
import 'package:flutter_example/data/models/auth/server_config_dto.dart';
import 'package:flutter_example/domain/entities/device/device_config.dart';
import 'package:fpdart/fpdart.dart';

abstract class ILocalConfigProvider {
  Future<Either<DomainError, void>> saveServerConfig(ServerConfigDto config);
  Future<Either<DomainError, ServerConfigDto?>> getServerConfig();
  Future<Either<DomainError, void>> saveDeviceConfig(DeviceConfig config);
  Future<Either<DomainError, DeviceConfig?>> getDeviceConfig();
  Future<Either<DomainError, void>> saveDeviceContext(DeviceContextDto context);
  Future<Either<DomainError, DeviceContextDto?>> getDeviceContext();
  Future<Either<DomainError, void>> clearAllConfigs();
}
