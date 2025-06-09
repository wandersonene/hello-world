import 'package:equatable/equatable.dart';

class ProjectNorma extends Equatable {
  final int? id; // Optional: if the join table needs its own primary key
  final int projectId;
  final String normaId; // Foreign key to Norma.id
  final DateTime linkedAt;

  const ProjectNorma({
    this.id,
    required this.projectId,
    required this.normaId,
    required this.linkedAt,
  });

  @override
  List<Object?> get props => [id, projectId, normaId, linkedAt];

  factory ProjectNorma.fromMap(Map<String, dynamic> map) {
    return ProjectNorma(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      normaId: map['norma_id'] as String,
      linkedAt: DateTime.parse(map['linked_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'norma_id': normaId,
      'linked_at': linkedAt.toIso8601String(),
    };
  }
}
