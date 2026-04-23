// lib/validators/app_validators.dart

class AppValidators {
  AppValidators._(); // Private constructor — utility class

  /// Validates that a field is not empty.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates full name — only letters and spaces, minimum 2 chars.
  static String? fullName(String? value) {
    final req = required(value, fieldName: 'Full Name');
    if (req != null) return req;

    final trimmed = value!.trim();
    if (trimmed.length < 2) {
      return 'Full Name must be at least 2 characters.';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Full Name can only contain letters, spaces, hyphens, or apostrophes.';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    final req = required(value, fieldName: 'Email');
    if (req != null) return req;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates password strength:
  /// - Min 6 characters
  /// - At least 1 uppercase letter
  /// - At least 1 special character
  static String? password(String? value) {
    final req = required(value, fieldName: 'Password');
    if (req != null) return req;

    final pass = value!;

    if (pass.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(pass)) {
      return 'Password must contain at least 1 uppercase letter.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;]').hasMatch(pass)) {
      return 'Password must contain at least 1 special character.';
    }
    return null;
  }

  /// Validates that confirm password matches the original.
  static String? confirmPassword(String? value, String original) {
    final req = required(value, fieldName: 'Confirm Password');
    if (req != null) return req;

    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Validates gender selection.
  static String? gender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a gender.';
    }
    return null;
  }

  /// Simple login email — same as email validator.
  static String? loginEmail(String? value) => email(value);

  /// Simple login password — just required, no strength check.
  static String? loginPassword(String? value) {
    return required(value, fieldName: 'Password');
  }
}
