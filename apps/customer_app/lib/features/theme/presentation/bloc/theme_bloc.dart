import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_event.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_state.dart';

@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final LocalStorageService _localStorage;

  ThemeBloc(this._localStorage) : super(const ThemeState()) {
    on<ThemeLoad>(_onLoad);
    on<ThemeToggle>(_onToggle);
    on<ThemeSet>(_onSet);
  }

  Future<void> _onLoad(ThemeLoad event, Emitter<ThemeState> emit) async {
    final index = await _localStorage.get<int>(StorageConstants.themeModeKey);
    final mode = AppThemeMode.values[index ?? 0];
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> _onToggle(ThemeToggle event, Emitter<ThemeState> emit) async {
    final nextIndex = (state.themeMode.index + 1) % AppThemeMode.values.length;
    final nextMode = AppThemeMode.values[nextIndex];
    emit(state.copyWith(themeMode: nextMode));
    await _localStorage.save(StorageConstants.themeModeKey, nextIndex);
  }

  Future<void> _onSet(ThemeSet event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(themeMode: event.mode));
    await _localStorage.save(StorageConstants.themeModeKey, event.mode.index);
  }
}
