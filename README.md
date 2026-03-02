# Flutter Clean Architecture Demo

Демонстрационное приложение на Flutter, реализующее чистую архитектуру (Clean Architecture)
с эмуляцией WebSocket-взаимодействия.

> **Вход в приложение:** можно вводить **любой логин и пароль** — авторизация всегда успешна (эмуляция).

---

## 📁 Структура проекта

```
lib/
├── data/                          # Слой данных
│   ├── mappers/                   # Мапперы для конвертации DTO → Entity
│   │   ├── abonent_mapper.dart
│   │   ├── device_mapper.dart
│   │   ├── group_mapper.dart
│   │   └── ...
│   ├── models/                    # DTO-модели (объекты для передачи данных)
│   │   ├── contacts/
│   │   │   ├── abonent_field_key.dart
│   │   │   └── group_field_key.dart
│   │   └── device/
│   │       └── device_api_key.dart
│   ├── providers/                 # Провайдеры данных
│   │   └── websocket/
│   │       ├── app_ws_provider.dart      # Mock WebSocket провайдер
│   │       └── i_websocket_provider.dart # Интерфейс провайдера
│   └── repositories/              # Реализации репозиториев
│       ├── abonent_ws_repository.dart
│       ├── device_ws_repository.dart
│       ├── group_ws_repository.dart
│       └── base_classes/
│           └── ws_repository.dart  # Базовый класс для WS репозиториев
│
├── domain/                        # Доменный слой (бизнес-логика)
│   ├── aggregates/                # Агрегаты (координация нескольких репозиториев)
│   │   ├── auth/
│   │   │   └── auth_aggregate.dart
│   │   ├── contacts/
│   │   │   └── contacts_aggregate.dart
│   │   └── profile/
│   │       └── profile_aggregate.dart
│   ├── entities/                  # Доменные сущности
│   │   ├── abonent/
│   │   │   ├── abonent.dart
│   │   │   └── abonent_payload.dart
│   │   ├── device/
│   │   │   ├── device.dart
│   │   │   └── device_payload.dart
│   │   ├── group/
│   │   │   ├── group.dart
│   │   │   └── group_payload.dart
│   │   └── operation/
│   │       ├── operation.dart
│   │       └── operation_container.dart
│   ├── errors/                    # Ошибки доменного слоя
│   │   └── domain_error.dart
│   └── repositories/              # Интерфейсы репозиториев
│       ├── i_abonent_repository.dart
│       ├── i_device_repository.dart
│       ├── i_group_repository.dart
│       └── ...
│
├── presentation/                  # Слой представления (UI)
│   ├── bloc/                      # BLoC/Cubit для управления состоянием
│   │   ├── auth/
│   │   │   ├── auth_cubit.dart
│   │   │   └── auth_state.dart
│   │   ├── contacts/
│   │   │   ├── contacts_cubit.dart
│   │   │   └── contacts_state.dart
│   │   └── profile/
│   │       ├── profile_cubit.dart
│   │       └── profile_state.dart
│   ├── pages/                     # Экраны приложения
│   │   ├── login/
│   │   ├── profile/
│   │   └── contacts/
│   └── widgets/                   # Переиспользуемые виджеты
│
├── app/                           # Инфраструктура приложения
│   ├── theme/                     # Темы оформления
│   │   ├── app_theme.dart
│   │   └── ...
│   └── cubit/                     # Глобальные кубиты
│       └── failure/
│           └── failure_cubit.dart
│
├── core/                          # Общие утилиты
│   ├── di/                        # Dependency Injection
│   │   └── injection.dart
│   ├── routes/                    # Маршрутизация
│   │   └── app_router.dart
│   └── constants/                 # Константы
│       └── asset_constants.dart
│
└── main.dart                      # Точка входа

test/                              # Тесты
```

---

## 🏗 Архитектурные слои

### Domain Layer (Доменный слой)

**Назначение:** Чистая бизнес-логика без зависимостей от фреймворков и внешних библиотек.

**Компоненты:**
- **Entities** — бизнес-сущности (`Abonent`, `Group`, `Device`, `Profile`)
- **Repositories** — интерфейсы для работы с данными (`IAbonentRepository`, `IGroupRepository`)
- **Aggregates** — координируют работу нескольких репозиториев, объединяют данные
- **Errors** — иерархия доменных ошибок (`DomainError`)

**Принципы:**
- Никаких импортов из `data`, `presentation`, внешних библиотек (кроме `equatable`, `fpdart`)
- Только чистая бизнес-логика

---

### Data Layer (Слой данных)

**Назначение:** Реализация интерфейсов репозиториев, работа с источниками данных.

**Компоненты:**
- **Repositories** — реализации через WebSocket (`AbonentWsRepository`, `GroupWsRepository`)
- **Providers** — источники данных:
  - `AppWsProvider` — эмуляция WebSocket (mock)
  - `LocalConfigProvider` — локальная конфигурация устройства
  - `ProfileProvider` — хранение профиля в SharedPreferences
- **Mappers** — преобразование DTO → Entity и обратно
- **Models** — DTO-модели с ключами API (`AbonentFieldKey`, `DeviceApiKey`)

**Принципы:**
- Зависит от Domain (реализует интерфейсы)
- Инкапсулирует всю работу с внешними источниками
- Обрабатывает ошибки парсинга, логирует их, но не прерывает поток

---

### Presentation Layer (Слой представления)

**Назначение:** UI и управление состоянием.

**Компоненты:**
- **Pages** — экраны приложения (`LoginPage`, `ProfilePage`, `ContactsPage`)
- **BLoC/Cubit** — управление состоянием (`AuthCubit`, `ContactsCubit`)
- **Widgets** — переиспользуемые компоненты

**Принципы:**
- Зависит от Domain (использует агрегаты и сущности)
- Никакой прямой работы с репозиториями
- Реагирует на изменения состояния агрегатов

---

### App & Core (Инфраструктура)

**Назначение:** Настройка приложения, DI, навигация, темы.

**Компоненты:**
- **DI** — `get_it` + `injectable` для внедрения зависимостей
- **Routes** — `go_router` для навигации
- **Theme** — светлая и тёмная темы
- **Constants** — константы и пути к ресурсам

---

## 🔄 Потоки данных

### 1. Авторизация

```
LoginPage → AuthCubit → AuthAggregate → AuthWsRepository → AppWsProvider
```

1. Пользователь вводит логин/пароль
2. `AuthCubit` вызывает `AuthAggregate.login()`
3. `AuthAggregate` координирует `IAuthRepository`
4. `AuthWsRepository` отправляет запрос через `AppWsProvider`
5. Ответ проходит обратно по цепочке

---

### 2. Получение контактов (абоненты + группы + устройства)

```
AppWsProvider (мок)
  → AuthWsRepository (авторизация)
  → AbonentWsRepository (абоненты, DATAEX DataType=11)
  → GroupWsRepository (группы, DATAEX DataType=12)
  → DeviceWsRepository (устройства, DATAEX DataType=10)
  → ContactsAggregate (объединение данных и синхронизация)
  → ContactsCubit → ContactsPage (UI)
```

**ContactsAggregate:**
- Слушает потоки от трёх репозиториев
- Объединяет данные в `ContactsData`
- Синхронизирует абонентов с устройствами:
  - При получении устройств обновляет `isOnline` и `deviceId` у абонентов
  - При удалении абонента обновляет статус устройств
- Фильтрует сущности с пустыми ID/именами
- Отправляет объединённые данные в поток

---

### 3. Обработка операций (add/change/remove)

Каждый репозиторий получает данные в формате:
```json
{
  "MessageID": "DATAEX",
  "DataType": 11,  // 10=devices, 11=abonents, 12=groups
  "Operation": 0   // 0=initialize, 1=add, 2=change, 3=remove
  "DataObjects": [...]
}
```

**Обработка в репозитории:**
1. Парсинг операции через `OperationMapper`
2. Маппинг каждого элемента через `fromMap()`
3. При ошибке парсинга — логирование и `continue` (пропуск элемента)
4. Отправка результата в поток через `OperationContainer`

**Обработка в агрегате:**
- `Operation.initialize` — полная замена словаря (`.clear()` + добавление)
- `Operation.add/change` — обновление/добавление элементов
- `Operation.remove` — удаление по ID
- После каждого изменения — синхронизация связанных сущностей

---

## 🎭 Эмуляция WebSocket

`AppWsProvider` — mock-провайдер, эмулирующий реальное WebSocket-соединение.

### Handshake последовательность:

| Время | Сообщение | Описание |
|-------|-----------|----------|
| +300ms | `SERVER_CONFIG` | Конфигурация сервера (VoipPort, VideoPort) |
| +600ms | `CONFIG_SERVER_RESPONSE_ACK` | Подтверждение конфигурации |
| +900ms | `LOGIN_RESPONSE` | Ответ на авторизацию |
| +1200ms | `DEVICE_CONTEXT` | Контекст устройства |
| +1700ms | `DATAEX (DataType=11, Op=0)` | Список абонентов |
| +1900ms | `DATAEX (DataType=10, Op=0)` | Список устройств |
| +2100ms | `DATAEX (DataType=12, Op=0)` | Список групп |
| +3000ms | Периодические обновления | Каждые 3 сек: случайная операция |

### Периодические обновления:

Каждые 3 секунды эмитируется случайная операция:
- **Operation.add** — добавление нового элемента
- **Operation.change** — изменение существующего
- **Operation.remove** — удаление элемента

**Важно:** При операции `remove` отправляются все обязательные поля (не только ID), чтобы мапперы не выбрасывали ошибок.

---

## 🛠 Обработка ошибок

### В мапперах:
```dart
static Abonent fromMap(Map<String, dynamic> map) {
  return Abonent(
    id: map[AbonentFieldKey.id.key] as String,  // Обязательно
    name: map[AbonentFieldKey.name.key] as String,
    login: map[AbonentFieldKey.login.key] as String,
    isOnline: (map[AbonentFieldKey.isOnline.key] as bool?) ?? false,
  );
}
```
- Поля обязательные (не nullable)
- Ошибка выбрасывается естественно при приведении типа

### В репозиториях:
```dart
for (var e in dataObjects) {
  try {
    final abonent = AbonentMapper.fromMap(e);
    abonents.add(abonent);
  } catch (err, st) {
    talker.error('AbonentWsRepository - ошибка парсинга абонента: $e', err, st);
    continue;  // Пропуск проблемного элемента
  }
}
```
- Каждый элемент обрабатывается в отдельном try-catch
- Ошибка логируется через `talker`
- Обработка продолжается для остальных элементов

### В агрегатах:
```dart
void _synchronizeAbonentsWithDevices() {
  for (var device in _deviceMap.values) {
    if (device.userId.isEmpty) continue;  // Пропуск устройств без userId
    
    final abon = _abonentsMap[device.userId];
    if (abon == null) {
      _talker.info("Не нашёлся абонент для device.userId = ${device.userId}");
      continue;
    }
    // Синхронизация...
  }
}
```
- Защита от null и пустых значений
- Логирование предупреждений
- Данные не портятся при отсутствии соответствий

---

## 📦 Технологии

| Технология | Назначение |
|------------|------------|
| **Flutter BLoC / Cubit** | Управление состоянием |
| **get_it + injectable** | Dependency Injection |
| **go_router** | Навигация между экранами |
| **fpdart** | Functional programming (`Either` для обработки ошибок) |
| **shared_preferences** | Локальное хранение профиля |
| **talker** | Логирование с красивым выводом |
| **equatable** | Сравнение сущностей по значениям |

---

## 🚀 Запуск

```bash
# Установка зависимостей
flutter pub get

# Запуск приложения
flutter run
```

---

## 📝 Ключевые принципы Clean Architecture в этом проекте

1. **Зависимости направлены внутрь** — Domain не зависит ни от чего
2. **Разделение ответственности** — каждый слой решает свои задачи
3. **Агрегаты координируют** — объединяют данные из нескольких репозиториев
4. **Мапперы инкапсулируют** — преобразование DTO → Entity в одном месте
5. **Ошибки обрабатываются локально** — не прерывают поток, а логируются
6. **Синхронизация в агрегатах** — связанные сущности обновляются согласованно
