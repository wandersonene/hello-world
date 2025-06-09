import 'package:equatable/equatable.dart';

class InspectionModule extends Equatable {
  final int? id;
  final int projectId;
  final String name;
  final String status; // e.g., "Pendente", "Em Andamento", "Concluído"
  final DateTime createdAt;
  final DateTime updatedAt;

  const InspectionModule({
    this.id,
    required this.projectId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, projectId, name, status, createdAt, updatedAt];

  factory InspectionModule.fromMap(Map<String, dynamic> map) {
    return InspectionModule(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InspectionModule copyWith({
    int? id,
    int? projectId,
    String? name,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionModule(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InspectionModuleStatus {
  static const String pending = 'Pendente';
  static const String inProgress = 'Em Andamento';
  static const String completed = 'Concluído';

  static List<String> get allStatuses => [pending, inProgress, completed];
}
