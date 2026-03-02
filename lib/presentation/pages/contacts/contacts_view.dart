import 'package:flutter_example/domain/entities/abonent/abonent.dart';
import 'package:flutter_example/domain/entities/group/group.dart';
import 'package:flutter_example/presentation/bloc/contacts/contacts_cubit.dart';
import 'package:flutter_example/presentation/bloc/contacts/contacts_state.dart';
import 'package:flutter_example/presentation/widgets/contacts/abonent_item.dart';
import 'package:flutter_example/presentation/widgets/contacts/group_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Виджет отображения списка контактов.
/// Зона ответственности: отображение списков групп и абонентов с табами,
/// разделение абонентов на онлайн/оффлайн, обработка нажатий на элементы.
class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Группы', 'Абоненты'];
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        if (state is ContactsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ContactsError) {
          return Center(child: Text('Ошибка: ${state.message}'));
        }

        if (state is ContactsLoaded) {
          final abonents = state.abonents;
          final groups = state.groups;

          // Сортировка: онлайн-контакты вверху, оффлайн - внизу
          final onlineAbonents = abonents.where((a) => a.isOnline).toList();
          final offlineAbonents = abonents.where((a) => !a.isOnline).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ContactsCubit>().refreshContacts();
            },
            child: DefaultTabController(
              // TODO табы не должны исчезать если массивы пустые, надо показывать что группы или абоненты не найдены
              length: tabs.length,
              child: Column(
                children: [
                  // Табы
                  _ContactsTabBar(tabs: tabs),

                  // Контент табов
                  Expanded(
                    child: TabBarView(
                      children: [
                        GroupsSection(
                          groups: groups,
                          onGroupTap: (group) => _onGroupTap(context, group),
                        ),
                        AbonentsSection(
                          onlineAbonents: onlineAbonents,
                          offlineAbonents: offlineAbonents,
                          onContactTap: (contact) =>
                              _onContactTap(context, contact),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('Нет данных'));
      },
    );
  }

  void _onGroupTap(BuildContext context, Group group) {
    // TODO: Реализовать навигацию к чату группы
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Выбрана группа: ${group.name}')));
  }

  void _onContactTap(BuildContext context, Abonent contact) {
    // TODO: Реализовать навигацию к чату с абонентом
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Выбран абонент: ${contact.name}')));
  }
}

/// Секция отображения списка групп.
class GroupsSection extends StatelessWidget {
  final List<Group> groups;
  final Function(Group) onGroupTap;

  const GroupsSection({
    super.key,
    required this.groups,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardTheme.color,
      // margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: groups.isEmpty
            ? Center(
                child: Text(
                  'Группы не найдены.\nПопробуйте изменть параметры поиска.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: TextTheme.of(context).titleMedium?.fontSize,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        return GroupItem(
                          group: groups[index],
                          onTap: () => onGroupTap(groups[index]),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Секция отображения списка абонентов.
class AbonentsSection extends StatelessWidget {
  final List<Abonent> onlineAbonents;
  final List<Abonent> offlineAbonents;
  final Function(Abonent) onContactTap;

  const AbonentsSection({
    super.key,
    required this.onlineAbonents,
    required this.offlineAbonents,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      color: theme.cardTheme.color,
      // margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: onlineAbonents.isEmpty && offlineAbonents.isEmpty
            ? Center(
                child: Text(
                  'Абоненты не найдены.\nПопробуйте изменть параметры поиска.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: TextTheme.of(context).titleMedium?.fontSize,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Онлайн-абоненты
                          if (onlineAbonents.isNotEmpty) ...[
                            Text('Онлайн', style: textTheme.labelLarge),
                            const SizedBox(height: 8),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: onlineAbonents.length,
                              itemBuilder: (context, index) {
                                final contact = onlineAbonents[index];
                                return AbonentItem(
                                  contact: contact,
                                  onTap: () => onContactTap(contact),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Оффлайн-абоненты
                          if (offlineAbonents.isNotEmpty) ...[
                            Text('Оффлайн', style: textTheme.labelLarge),
                            const SizedBox(height: 8),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: offlineAbonents.length,
                              itemBuilder: (context, index) {
                                final contact = offlineAbonents[index];
                                return AbonentItem(
                                  contact: contact,
                                  onTap: () => onContactTap(contact),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Виджет табов для переключения между группами и абонентами.
class _ContactsTabBar extends StatelessWidget {
  final List<String> tabs;

  const _ContactsTabBar({required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      child: TabBar(
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        unselectedLabelStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : Colors.white70,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
      ),
    );
  }
}
