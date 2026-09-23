import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_storage.themeMode);

  final LocalStorage _storage;

  void setMode(ThemeMode mode) {
    _storage.setThemeMode(mode);
    emit(mode);
  }

  /// Toggle between light & dark, resolving "system" against the platform.
  void toggle(Brightness current) =>
      setMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
