import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String name;
  final String username; // CPF or email
  final String passwordHash;
  final String salt;

  const User({
    this.id,
    required this.name,
    required this.username,
    required this.passwordHash,
    required this.salt,
  });

  // For Equatable
  @override
  List<Object?> get props => [id, name, username, passwordHash, salt];

  // Optional: For easier debugging
  @override
  String toString() {
    return 'User(id: $id, name: $name, username: $username, salt: $salt, passwordHash: $passwordHash)';
  }

  // Factory constructor to create a User from a map (e.g., from SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
    );
  }

  // Method to convert User object to a map (e.g., for SQLite insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id will be null for new users, handled by SQLite auto-increment
      'name': name,
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
    };
  }
}
