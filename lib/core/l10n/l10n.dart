import 'package:flutter/widgets.dart';

import 'ar.dart';

/// Lightweight localization: English text is the key, Arabic comes from [arStrings].
/// Placeholders use {name} and are filled from `args`.
class L10n {
  L10n._();

  static const supported = [Locale('en'), Locale('ar')];

  /// Current language for code without a BuildContext (cubits, services).
  static String lang = 'en';

  static bool get isArabic => lang == 'ar';

  static String translate(String lang, String key, [Map<String, Object?> args = const {}]) {
    var text = lang == 'ar' ? (arStrings[key] ?? key) : key;
    args.forEach((k, v) => text = text.replaceAll('{$k}', '$v'));
    return text;
  }
}

/// Translate without context (uses [L10n.lang]).
String tr(String key, [Map<String, Object?> args = const {}]) => L10n.translate(L10n.lang, key, args);

extension L10nContext on BuildContext {
  /// Translate and rebuild automatically when the app locale changes.
  String tr(String key, [Map<String, Object?> args = const {}]) =>
      L10n.translate(Localizations.localeOf(this).languageCode, key, args);

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}

/// Drop-in replacement for `Text('literal')` that translates itself.
class Tr extends StatelessWidget {
  const Tr(
    this.text, {
    super.key,
    this.args = const {},
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Map<String, Object?> args;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => Text(
        context.tr(text, args),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
}
