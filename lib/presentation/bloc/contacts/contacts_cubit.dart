import 'dart:async';

import 'package:flutter_example/domain/aggregates/contacts/contacts_aggregate.dart';
import 'package:flutter_example/domain/aggregates/contacts/search_contacts_usecase.dart';
import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter_example/domain/entities/group/group.dart';
import 'package:flutter_example/presentation/bloc/contacts/contacts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Кубит управления контактами (абоненты и группы).
/// Зона ответственности: загрузка контактов, поиск/фильтрация,
/// управление состоянием отображения списка контактов.
class ContactsCubit extends Cubit<ContactsState> {
  final ContactsAggregate _getContactsUseCase;
  final SearchContactsUseCase _searchContactsUseCase;
  StreamSubscription? _contactsSubscription;

  // Храним оригинальные ОТСОРТИРОВАННЫЕ данные из UseCase
  List<Abonent> _sortedAbonents = [];
  List<Group> _sortedGroups = [];
  String? _currentSearchQuery;

  ContactsCubit({
    required ContactsAggregate getContactsUseCase,
    required SearchContactsUseCase searchContactsUseCase,
  }) : _getContactsUseCase = getContactsUseCase,
       _searchContactsUseCase = searchContactsUseCase,
       super(ContactsInitial()) {
    loadContacts();
  }

  void loadContacts() {
    emit(ContactsLoading());

    _contactsSubscription?.cancel();

    _contactsSubscription = _getContactsUseCase.stream.listen(
      (result) {
        result.fold((failure) => emit(ContactsError(failure.toString())), (
          contactsData,
        ) {
          // Сохраняем ОТСОРТИРОВАННЫЕ данные из UseCase
          _sortedAbonents =
              contactsData.abonents; // Уже отсортированы в UseCase
          _sortedGroups = contactsData.groups; // Уже отсортированы в UseCase

          // Применяем текущий поисковый запрос если есть
          if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
            _applySearch(_currentSearchQuery!);
          } else {
            // Показываем оригинальные отсортированные данные
            emit(
              ContactsLoaded(abonents: _sortedAbonents, groups: _sortedGroups),
            );
          }
        });
      },
      onError: (error) {
        emit(ContactsError(error.toString()));
      },
    );
  }

  void searchContacts(String query) {
    _currentSearchQuery = query.isNotEmpty ? query : null;

    if (_currentSearchQuery == null) {
      emit(ContactsLoaded(abonents: _sortedAbonents, groups: _sortedGroups));
    } else {
      _applySearch(_currentSearchQuery!);
    }
  }

  void _applySearch(String query) {
    // Всегда фильтруем оригинальные отсортированные данные
    final filteredContacts = _searchContactsUseCase.searchContacts(
      _sortedAbonents,
      _sortedGroups,
      query,
    );

    emit(
      ContactsLoaded(
        abonents: filteredContacts.abonents,
        groups: filteredContacts.groups,
        searchQuery: query,
      ),
    );
  }

  void clearSearch() {
    searchContacts('');
  }

  void refreshContacts() {
    loadContacts();
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}
