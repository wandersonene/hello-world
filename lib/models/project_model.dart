import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final int? id;
  final String title;
  final String? client;
  final String? projectType; // "tipo"
  final String status; // "Em Andamento", "Concluído", "Pendente"
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    this.id,
    required this.title,
    this.client,
    this.projectType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, client, projectType, status, createdAt, updatedAt];

  // For easier debugging
  @override
  String toString() {
    return 'Project(id: $id, title: $title, client: $client, projectType: $projectType, status: $status, createdAt: ${createdAt.toIso8601String()}, updatedAt: ${updatedAt.toIso8601String()})';
  }

  // Factory constructor to create a Project from a map (e.g., from SQLite)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      title: map['title'] as String,
      client: map['client'] as String?,
      projectType: map['project_type'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Method to convert Project object to a map (e.g., for SQLite insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id will be null for new projects, handled by SQLite auto-increment
      'title': title,
      'client': client,
      'project_type': projectType,
      'status': status,
      'created_at': createdAt.toIso8601String(), // Store as ISO8601 string
      'updated_at': updatedAt.toIso8601String(), // Store as ISO8601 string
    };
  }

  Project copyWith({
    int? id,
    String? title,
    String? client,
    String? projectType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      client: client ?? this.client,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Predefined project statuses
class ProjectStatus {
  static const String inProgress = 'Em Andamento';
  static const String completed = 'Concluído';
  static const String pending = 'Pendente';

  static List<String> get allStatuses => [inProgress, pending, completed];
}
