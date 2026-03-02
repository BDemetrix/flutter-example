import 'package:flutter_example/domain/entities/abonent/abonent.dart';

/// Базовый класс для данных абонентов.
/// Зона ответственности: объединение различных типов payload для абонентов.
sealed class AbonentPayload {
  const AbonentPayload();
}

/// Список абонентов.
class AbonentList extends AbonentPayload {
  final List<Abonent> abonents;
  const AbonentList(this.abonents);
}

/// Список ID абонентов.
class AbonentIds extends AbonentPayload {
  final List<String> abonentIds;
  const AbonentIds(this.abonentIds);
}
