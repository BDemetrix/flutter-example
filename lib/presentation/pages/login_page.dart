
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/app/theme/theme_cubit.dart';
import 'package:flutter_example/core/routes/router.dart';
import 'package:flutter_example/domain/entities/auth_data.dart';
import 'package:flutter_example/domain/entities/profile.dart';
import 'package:flutter_example/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_example/presentation/bloc/profile/profile_cubit.dart';
import 'package:flutter_example/presentation/widgets/profile_card.dart';
import 'package:go_router/go_router.dart';

/// Страница входа в приложение.
/// Зона ответственности: отображение профиля пользователя, инициация входа через AuthCubit,
/// управление навигацией на страницу добавления профиля.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final ProfileCubit profileCubit;
  late final AuthCubit authCubit;

  @override
  void initState() {
    super.initState();

    profileCubit = context.read<ProfileCubit>();
    authCubit = context.read<AuthCubit>();

    final profileCubitState = profileCubit.state;
    if (profileCubitState is ProfileInitial) {
      profileCubit.checkProfileExists();
    }
  }

  void onProfileClick() {
    context.pushNamed(AppRouterNames.addProfile);
  }

  void performLogin(Profile? profile) {
    if (profile == null) return;

    // Создаем AuthData из профиля
    final authData = AuthData(
      serverUri: profile.serverUri,
      username: profile.username,
      password: profile.password,
    );

    // Выполняем вход через AuthCubit
    authCubit.login(authData);
  }

  void onProfileLongClick(Profile? profile) async {
    if (profile == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить профиль?'),
        content: Text(
          'Вы уверены, что хотите удалить профиль "${profile.username}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await profileCubit.clearProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в приложение'),
        actions: [
          BlocBuilder<ThemeCubit, bool>(
            builder: (context, isDark) {
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is AuthLoaded && state.isLoggedIn) {
            // Successfully logged in
          }
        },
        builder: (context, authState) {
          return BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, profileState) {
              final profile = profileState is ProfileLoaded
                  ? profileState.profile
                  : null;

              return Column(
                children: [
                  const SizedBox(height: 32),
                  if (profileState is ProfileLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (profileState is! ProfileLoading)
                    Expanded(
                      child: Center(
                        child: ProfileCard(
                          profile: profile,
                          onTap: onProfileClick,
                          onLongPress: () => onProfileLongClick(profile),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final profile = profileState is ProfileLoaded
              ? profileState.profile
              : null;
          final isAuthLoading = context.watch<AuthCubit>().state is AuthLoading;

          if (profile == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                onPressed: isAuthLoading
                    ? null
                    : () {
                        performLogin(profile);
                      },
                backgroundColor: isAuthLoading ? Colors.grey : colors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                label: isAuthLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Войти', style: TextStyle(fontSize: 18)),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
