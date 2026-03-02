import 'package:flutter_example/app/theme/theme_cubit.dart';
import 'package:flutter_example/core/di/injection.dart';
import 'package:flutter_example/domain/aggregates/contacts/contacts_aggregate.dart';
import 'package:flutter_example/domain/aggregates/contacts/search_contacts_usecase.dart';
import 'package:flutter_example/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_example/presentation/bloc/contacts/contacts_cubit.dart';
import 'package:flutter_example/presentation/pages/contacts/contacts_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Страница контактов.
/// Зона ответственности: отображение списка контактов (группы и абоненты),
/// поиск по контактам, навигация по настройкам (профиль, тема).
class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  late ContactsCubit _contactsCubit;

  @override
  void initState() {
    super.initState();
    _contactsCubit = ContactsCubit(
      getContactsUseCase: getIt<ContactsAggregate>(),
      searchContactsUseCase: getIt<SearchContactsUseCase>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _contactsCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                _showSettingsMenu(context);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                onChanged: (value) {
                  _contactsCubit.searchContacts(value);
                },
              ),
            ),
          ),
        ),
        body: const ContactsView(),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthCubit>().logout();
              },
            ),
            BlocBuilder<ThemeCubit, bool>(
              builder: (context, isDark) {
                return ListTile(
                  leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  title: Text(isDark ? 'Light Theme' : 'Dark Theme'),
                  onTap: () {
                    context.read<ThemeCubit>().toggleTheme();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _contactsCubit.close();
    super.dispose();
  }
}
