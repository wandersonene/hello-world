import 'package:equatable/equatable.dart';

class Norma extends Equatable {
  final String id; // e.g., "ABNT NBR 16280" - Primary Key
  final String description; // User-provided or official short title
  final DateTime createdAt; // When this norma was first added to the local DB

  const Norma({
    required this.id,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, description, createdAt];

  factory Norma.fromMap(Map<String, dynamic> map) {
    return Norma(
      id: map['id'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Norma copyWith({
    String? id,
    String? description,
    DateTime? createdAt,
  }) {
    return Norma(
      id: id ?? this.id,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
