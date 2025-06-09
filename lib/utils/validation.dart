import 'package:email_validator/email_validator.dart';

class InputValidators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty.';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF/Email cannot be empty.';
    }
    // Basic check: if it contains '@', validate as email, otherwise treat as potential CPF
    // For a real CPF validation, a specific algorithm/package would be needed.
    // For this MVP, we'll just check for non-emptiness and basic email format if applicable.
    if (value.contains('@')) {
      if (!EmailValidator.validate(value)) {
        return 'Invalid email format.';
      }
    } else {
      // Basic CPF-like check (e.g. length, only numbers - adapt if needed)
      // This is a placeholder, real CPF validation is more complex.
      final cpfRegex = RegExp(r'^\d{11}$'); // Example: 11 digits for CPF
      // if (!cpfRegex.hasMatch(value.replaceAll(RegExp(r'[.-]'), ''))) {
      //   return 'Invalid CPF format (should be 11 digits).';
      // }
      // For MVP, we'll keep it simple and not enforce strict CPF, just that it's not an invalid email
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    // Add more complexity rules if needed (e.g., uppercase, number, special character)
    // bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    // bool hasDigits = value.contains(RegExp(r'[0-9]'));
    // bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    // bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    // if (!hasUppercase || !hasDigits || !hasLowercase /*|| !hasSpecialCharacters*/) {
    //   return 'Password must include uppercase, lowercase, and digits.';
    // }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password cannot be empty.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
