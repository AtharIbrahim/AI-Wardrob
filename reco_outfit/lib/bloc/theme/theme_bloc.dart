import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

// Theme Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class LoadThemeEvent extends ThemeEvent {}

class SetThemeEvent extends ThemeEvent {
  final bool isDark;
  SetThemeEvent(this.isDark);
}

// Theme State
class ThemeState {
  final ThemeData themeData;
  final bool isDark;

  const ThemeState({
    required this.themeData,
    required this.isDark,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    bool? isDark,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      isDark: isDark ?? this.isDark,
    );
  }
}

// Theme BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  
  ThemeBloc() : super(ThemeState(
    themeData: AppTheme.lightTheme,
    isDark: false,
  )) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      
      emit(ThemeState(
        themeData: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        isDark: isDark,
      ));
    } catch (e) {
      // If loading fails, keep the default light theme
      emit(ThemeState(
        themeData: AppTheme.lightTheme,
        isDark: false,
      ));
    }
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final newIsDark = !state.isDark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, newIsDark);
      
      emit(ThemeState(
        themeData: newIsDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        isDark: newIsDark,
      ));
    } catch (e) {
      // If saving fails, still emit the new theme but log the error
      print('Failed to save theme preference: $e');
      emit(ThemeState(
        themeData: newIsDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        isDark: newIsDark,
      ));
    }
  }

  Future<void> _onSetTheme(SetThemeEvent event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, event.isDark);
      
      emit(ThemeState(
        themeData: event.isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        isDark: event.isDark,
      ));
    } catch (e) {
      print('Failed to save theme preference: $e');
      emit(ThemeState(
        themeData: event.isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        isDark: event.isDark,
      ));
    }
  }
}
