import 'package:opendelivery_core/opendelivery_core.dart';

class ThemeState {
  final AppThemeMode themeMode;
  const ThemeState({this.themeMode = AppThemeMode.system});

  ThemeState copyWith({AppThemeMode? themeMode}) => ThemeState(themeMode: themeMode ?? this.themeMode);
}
