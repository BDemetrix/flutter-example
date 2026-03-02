import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter_example/domain/entities/group/group.dart';
import 'package:injectable/injectable.dart';

/// UseCase для поиска контактов.
/// Зона ответственности: фильтрация списков абонентов и групп по поисковому запросу.
@injectable
class SearchContactsUseCase {
  /// Поиск абонентов по имени или логину.
  List<Abonent> searchAbonents(List<Abonent> abonents, String query) {
    if (query.isEmpty) return abonents;
    return abonents.where((abonent) {
      return abonent.name.toLowerCase().contains(query.toLowerCase()) ||
          abonent.login.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Поиск групп по названию.
  List<Group> searchGroups(List<Group> groups, String query) {
    if (query.isEmpty) return groups;
    return groups.where((group) {
      return group.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Поиск по всем контактам (абоненты и группы).
  ({List<Abonent> abonents, List<Group> groups}) searchContacts(
    List<Abonent> abonents,
    List<Group> groups,
    String query,
  ) {
    if (query.isEmpty) {
      return (abonents: abonents, groups: groups);
    }

    final filteredAbonents = searchAbonents(abonents, query);
    final filteredGroups = searchGroups(groups, query);

    return (abonents: filteredAbonents, groups: filteredGroups);
  }
}
