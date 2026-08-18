import 'package:email_validator/email_validator.dart';

/// Reusable form-field validators returning null on success or an
/// error string on failure, matching Flutter's `FormField validator` signature.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!EmailValidator.validate(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final parsed = num.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Enter a valid $field';
    return null;
  }

  static String? seatCount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Seat count is required';
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1 || parsed > 8) {
      return 'Enter a number between 1 and 8';
    }
    return null;
  }
}
