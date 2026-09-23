import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../core/storage/local_storage.dart';

/// App language (English / Arabic). Persisted; defaults to the device language.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage) : super(_initial(_storage)) {
    L10n.lang = state.languageCode;
  }

  final LocalStorage _storage;
  static const _key = 'app_locale';

  static Locale _initial(LocalStorage storage) {
    final saved = storage.getString(_key);
    if (saved == 'ar' || saved == 'en') return Locale(saved!);
    final device = PlatformDispatcher.instance.locale.languageCode;
    return Locale(device == 'ar' ? 'ar' : 'en');
  }

  bool get isArabic => state.languageCode == 'ar';

  void setLanguage(String code) {
    if (code == state.languageCode) return;
    _storage.setString(_key, code);
    L10n.lang = code;
    emit(Locale(code));
  }

  void toggle() => setLanguage(isArabic ? 'en' : 'ar');
}
