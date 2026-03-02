import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter_example/domain/entities/group/group.dart';

/// Базовый класс состояний контактов.
abstract class ContactsState {}

/// Начальное состояние контактов.
class ContactsInitial extends ContactsState {}

/// Состояние загрузки контактов.
class ContactsLoading extends ContactsState {}

/// Состояние с загруженными контактами.
class ContactsLoaded extends ContactsState {
  final List<Abonent> abonents;
  final List<Group> groups;
  final String? searchQuery;

  ContactsLoaded({
    required this.abonents,
    required this.groups,
    this.searchQuery,
  });

  ContactsLoaded copyWith({
    List<Abonent>? abonents,
    List<Group>? groups,
    String? searchQuery,
  }) {
    return ContactsLoaded(
      abonents: abonents ?? this.abonents,
      groups: groups ?? this.groups,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Состояние ошибки при загрузке контактов.
class ContactsError extends ContactsState {
  final String message;

  ContactsError(this.message);
}
