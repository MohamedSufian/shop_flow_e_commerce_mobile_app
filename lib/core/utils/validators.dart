class Validators {
  Validators._();

  static final _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!_emailRe.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'At least 6 characters';
    return null;
  }

  static String? name(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name is too short';
    return null;
  }

  static String? Function(String?) required(String label) =>
      (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null;

  /// 0..4 strength score.
  static int passwordStrength(String v) {
    var score = 0;
    if (v.length >= 6) score++;
    if (v.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v) && RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    return score;
  }
}
