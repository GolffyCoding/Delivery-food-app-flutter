import 'package:opendelivery_core/opendelivery_core.dart';

sealed class ThemeEvent {
  const ThemeEvent();
}

class ThemeLoad extends ThemeEvent {
  const ThemeLoad();
}

class ThemeToggle extends ThemeEvent {
  const ThemeToggle();
}

class ThemeSet extends ThemeEvent {
  final AppThemeMode mode;
  const ThemeSet(this.mode);
}
