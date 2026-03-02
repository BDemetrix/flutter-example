import 'package:equatable/equatable.dart';

/// Сущность группы.
/// Зона ответственности: представление данных группы (ID, название, приоритет, флаги вызовов).
class Group extends Equatable {
  final String id;
  final String name;
  final int priority;
  final int emergency;
  final int allCall;
  final int broadcast;

  const Group({
    required this.id,
    required this.name,
    required this.priority,
    required this.emergency,
    required this.allCall,
    required this.broadcast,
  });

  Group copyWith({
    String? id,
    String? name,
    int? priority,
    int? emergency,
    int? allCall,
    int? broadcast,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      emergency: emergency ?? this.emergency,
      allCall: allCall ?? this.allCall,
      broadcast: broadcast ?? this.broadcast,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    priority,
    emergency,
    allCall,
    broadcast,
  ];
}
