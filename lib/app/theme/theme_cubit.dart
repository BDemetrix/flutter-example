import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Кубит управления темой оформления.
/// Зона ответственности: сохранение и переключение светлой/тёмной темы.
class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(true) {
    _loadTheme();
  }

  bool _isDark = true;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    _isDark = isDark;
    emit(isDark);
  }

  Future<void> toggleTheme() async {
    final newValue = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', newValue);
    _isDark = newValue;
    emit(newValue);
  }

  bool get isDark => _isDark;

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    _isDark = isDark;
    emit(isDark);
  }
}
