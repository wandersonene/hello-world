import 'dart:math';
import 'dart:convert'; // For utf8 encoding
import 'package:crypt/crypt.dart'; // For PBKDF2
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _databaseService;

  AuthService(this._databaseService);

  // Helper to generate a random salt
  String _generateSalt([int length = 16]) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes); // Using base64Url for safe string representation
  }

  // Helper to hash password with salt using PBKDF2
  String _hashPassword(String password, String salt) {
    // The crypt package expects the salt to be part of the hash string format
    // or used in specific ways depending on the algorithm.
    // For PBKDF2, Crypt.sha256(password, salt: salt) is a common pattern.
    // Let's use a standard PBKDF2 implementation.
    // Crypt.fromConcatenatedSalt(hash, salt)
    // Crypt c = Crypt.sha256(password, salt: salt);
    // c.toString()
    //
    // According to `crypt` package documentation for PBKDF2:
    // final c1 = Crypt.sha256(password, salt: salt);
    // final c2 = Crypt.sha256(password, salt: salt);
    // c1 == c2 // true
    // c1.toString() == c2.toString() // true
    //
    // A common way to store PBKDF2 is just the derived key, as the salt, iteration count,
    // and algorithm are stored separately or are fixed.
    // However, some libraries output a string that includes all parameters.
    // The `crypt` package's `toString()` method for SHA256/SHA512 based hashes
    // produces a string like "$algorithm$rounds$salt$hash".
    // Let's use PBKDF2 directly for more control if available, or use its SHA256 helper.
    // The `crypt` package's `Crypt.sha256` is a password hashing scheme,
    // not just a raw PBKDF2. It includes the salt within its generated hash string.
    // This is good as we only need to store the output of `c.toString()`.

    final c = Crypt.sha256(utf8.encode(password), salt: salt); // Ensure password bytes are UTF-8
    return c.toString(); // This string contains the algo, salt, and hash
  }

  Future<User> registerUser({
    required String name,
    required String username,
    required String password,
  }) async {
    // Check if user already exists
    final existingUser = await _databaseService.getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('Username (CPF/Email) already exists. Please try logging in or use a different username.');
    }

    final salt = _generateSalt();
    // For `crypt`'s SHA256 scheme, the salt we provide is used internally.
    // The output of `_hashPassword` will contain this salt.
    // So, the `User` model's `salt` field will store the salt we generated,
    // and `passwordHash` will store the full hash string from `crypt` which also embeds the salt.
    final passwordHash = _hashPassword(password, salt);

    final newUser = User(
      name: name,
      username: username,
      passwordHash: passwordHash, // This contains the salt
      salt: salt, // Store the generated salt separately for clarity/potential direct use if needed
    );

    final userId = await _databaseService.insertUser(newUser);
    return newUser.copyWith(id: userId); // Return user with ID
  }

  Future<User> loginUser({
    required String username,
    required String password,
  }) async {
    final user = await _databaseService.getUserByUsername(username);

    if (user == null) {
      throw Exception('User not found. Please check your CPF/Email or register.');
    }

    // To verify with `crypt` package:
    // Create a Crypt object from the stored hash string.
    // Then use its `match` method.
    final storedCrypt = Crypt(user.passwordHash);
    if (storedCrypt.match(utf8.encode(password))) { // Ensure password bytes are UTF-8
      return user;
    } else {
      throw Exception('Invalid password. Please try again.');
    }
  }
}

// Extension to add copyWith to User model if not already present
extension UserCopyWith on User {
  User copyWith({
    int? id,
    String? name,
    String? username,
    String? passwordHash,
    String? salt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
    );
  }
}
