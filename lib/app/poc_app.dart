import 'package:flutter_example/app/cubit/failure/failure_bloc_listener.dart';
import 'package:flutter_example/app/cubit/failure/failure_cubit.dart';
import 'package:flutter_example/app/theme/app_theme.dart';
import 'package:flutter_example/app/theme/theme_cubit.dart';
import 'package:flutter_example/core/di/injection.dart';
import 'package:flutter_example/core/routes/router.dart';
import 'package:flutter_example/domain/aggregates/auth_aggregate.dart';
import 'package:flutter_example/domain/aggregates/failure_aggregate.dart';
import 'package:flutter_example/domain/aggregates/profile_aggregate.dart';
import 'package:flutter_example/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_example/presentation/bloc/profile/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Главный виджет приложения.
/// Зона ответственности: инициализация кубитов, настройка тем и маршрутизации.
class PocApp extends StatelessWidget {
  const PocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthCubit(getIt<AuthAggregate>())),
        BlocProvider(create: (_) => ProfileCubit(getIt<ProfileAggregate>())),
        BlocProvider(create: (_) => FailureCubit(getIt<FailureAggregate>())),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return _AppContent(isDark: isDark);
        },
      ),
    );
  }
}

class _AppContent extends StatefulWidget {
  final bool isDark;

  const _AppContent({required this.isDark});

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthCubit>().state;
    _updateRouter(
      isLoggedIn: authState is AuthLoaded && authState.isLoggedIn,
      withSetState: false,
    );
  }

  void _updateRouter({required bool isLoggedIn, bool withSetState = true}) {
    _router = isLoggedIn ? AppRouter.mainRouter : AppRouter.authRouter;

    if (withSetState) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current is AuthLoaded,
      listener: (context, authState) {
        final isLoggedIn = (authState as AuthLoaded).isLoggedIn;
        _updateRouter(isLoggedIn: isLoggedIn);
      },
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        routerConfig: _router,
        title: 'CleanArch Demo',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.isDark ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return FailureBlocListener(child: child ?? const SizedBox());
        },
      ),
    );
  }
}
