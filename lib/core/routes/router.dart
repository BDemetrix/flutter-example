import 'package:flutter_example/presentation/pages/add_profile_page.dart';
import 'package:flutter_example/presentation/pages/contacts/contacts_page.dart';
import 'package:flutter_example/presentation/pages/login_page.dart';
import 'package:go_router/go_router.dart';

/// Имена маршрутов приложения.
abstract class AppRouterNames {
  static const login = "login";
  static const addProfile = "add_profile";
  static const main = "main";
}

/// Маршрутизатор приложения.
/// Зона ответственности: определение маршрутов и навигация между экранами.
class AppRouter {
  static final GoRouter authRouter = GoRouter(
    initialLocation: "/login",
    routes: [
      GoRoute(
        path: '/login',
        name: AppRouterNames.login,
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/add-profile',
        name: AppRouterNames.addProfile,
        builder: (context, state) => AddProfilePage(),
      ),
    ],
  );

  static final GoRouter mainRouter = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: '/',
        name: AppRouterNames.main,
        builder: (context, state) => ContactsPage(),
      ),
    ],
  );
}
