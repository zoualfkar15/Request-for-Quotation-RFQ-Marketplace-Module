class Validation {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required.';
    final exp = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
    if (!exp.hasMatch(v)) return 'Please enter a valid email.';
    return null;
  }

  /// Password rules (simple, assessment-friendly):
  /// - min 8 chars
  /// - at least 1 uppercase, 1 lowercase, 1 digit
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required.';
    if (v.length < 8) return 'Password must be at least 8 characters.';
    final exp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
    if (!exp.hasMatch(v)) {
      return 'Password must contain upper & lower case letters and a number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final v = value ?? '';
    if (v.isEmpty) return 'Confirm password is required.';
    if (v != password) return 'Passwords must match.';
    return null;
  }
}


