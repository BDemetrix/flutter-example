import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter_example/domain/entities/group/group.dart';
import 'package:equatable/equatable.dart';

/// Данные контактов (абоненты и группы).
/// Зона ответственности: объединение списков абонентов и групп для отображения.
class ContactsData extends Equatable {
  final List<Abonent> abonents;
  final List<Group> groups;

  const ContactsData({required this.abonents, required this.groups});

  ContactsData copyWith({List<Abonent>? abonents, List<Group>? groups}) {
    return ContactsData(
      abonents: abonents ?? this.abonents,
      groups: groups ?? this.groups,
    );
  }

  @override
  String toString() {
    return 'ContactsData(abonents: ${abonents.length}, groups: ${groups.length})';
  }

  @override
  List<Object?> get props => [abonents, groups];
}
