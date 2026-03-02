import 'package:equatable/equatable.dart';

/// Базовый класс для ошибок доменного слоя.
/// Зона ответственности: представление ошибок бизнес-логики.
abstract class DomainError extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const DomainError(this.message, [this.stackTrace]);

  @override
  String toString() => 'DomainError: $message \n ${stackTrace ?? ""}';

  @override
  List<Object?> get props => [message, stackTrace];
}

/// Ошибка базы данных.
class DatabaseFailure extends DomainError {
  const DatabaseFailure(super.message, [super.stackTrace]);
}

/// Ошибка сервера.
class ServerFailure extends DomainError {
  const ServerFailure([super.message = 'Server error', super.stackTrace]);
}

/// Ошибка WebSocket соединения.
class WebSocketFailure extends DomainError {
  const WebSocketFailure({
    String message = 'WebSocket error',
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Ошибка сети.
class NetworkFailure extends DomainError {
  const NetworkFailure({
    String message = 'Network error',
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Ошибка обработки данных.
class DataProcessingFailure extends DomainError {
  const DataProcessingFailure({
    String message = 'Data processing error',
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Ошибка парсинга данных.
class ParsingFailure extends DomainError {
  const ParsingFailure({
    String message = 'Data parsing error',
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Ошибка невалидного аргумента.
class InvalidArgumentFailure extends DomainError {
  const InvalidArgumentFailure({
    String message = 'Invalid argument error',
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Ошибка таймаута операции.
class TimeoutFailure extends DomainError {
  const TimeoutFailure({
    String message = 'Operation timeout',
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Ошибка: профиль не найден.
class ProfileNotFoundFailure extends DomainError {
  const ProfileNotFoundFailure() : super('Profile not found');
}

/// Ошибка парсинга профиля.
class ProfileDecodingFailure extends DomainError {
  const ProfileDecodingFailure() : super('Profile parsing error');
}

/// Ошибка сохранения профиля.
class ProfileSavingFailure extends DomainError {
  const ProfileSavingFailure() : super('Profile saving error');
}

/// Неизвестная ошибка.
class UnknownFailure extends DomainError {
  const UnknownFailure(String message, [StackTrace? stackTrace])
      : super('Unknown error: $message', stackTrace);
}

/// Ошибка соединения/авторизации.
class ConnectionFailure extends DomainError {
  final int responseCode;

  const ConnectionFailure({
    this.responseCode = -1,
    String message = 'Connection or authorization error.',
    StackTrace? stackTrace,
  }) : super(message, stackTrace);

  @override
  List<Object?> get props => [responseCode, ...super.props];
}
