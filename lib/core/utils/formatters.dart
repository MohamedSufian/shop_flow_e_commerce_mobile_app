import '../l10n/l10n.dart';

extension PriceFormat on num {
  String get asPrice => '\$${toStringAsFixed(2)}';
}

extension StringX on String {
  String get capitalized => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', //
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

extension DateFormatX on DateTime {
  /// e.g. "Mar 12, 2025" / "12 مارس 2025"
  String get short => L10n.isArabic ? '$day ${_monthsAr[month - 1]} $year' : '${_months[month - 1]} $day, $year';
}

extension DateTimeFormatX on DateTime {
  /// e.g. "Mar 12, 2025 • 14:05"
  String get withTime =>
      '$short  •  ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
