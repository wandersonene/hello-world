import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  final int? id;
  final int projectId;
  final int? inspectionModuleId;
  final int? checklistItemId;
  final String filePath;
  final String? caption;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  const Photo({
    this.id,
    required this.projectId,
    this.inspectionModuleId,
    this.checklistItemId,
    required this.filePath,
    this.caption,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        inspectionModuleId,
        checklistItemId,
        filePath,
        caption,
        createdAt,
        latitude,
        longitude,
      ];

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      inspectionModuleId: map['inspection_module_id'] as int?,
      checklistItemId: map['checklist_item_id'] as int?,
      filePath: map['file_path'] as String,
      caption: map['caption'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'inspection_module_id': inspectionModuleId,
      'checklist_item_id': checklistItemId,
      'file_path': filePath,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Photo copyWith({
    int? id,
    int? projectId,
    int? inspectionModuleId,
    int? checklistItemId,
    String? filePath,
    String? caption,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    bool setInspectionModuleIdNull = false,
    bool setChecklistItemIdNull = false,
    bool setCaptionNull = false,
    bool setLatitudeNull = false,
    bool setLongitudeNull = false,
  }) {
    return Photo(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      inspectionModuleId: setInspectionModuleIdNull ? null : (inspectionModuleId ?? this.inspectionModuleId),
      checklistItemId: setChecklistItemIdNull ? null : (checklistItemId ?? this.checklistItemId),
      filePath: filePath ?? this.filePath,
      caption: setCaptionNull ? null : (caption ?? this.caption),
      createdAt: createdAt ?? this.createdAt,
      latitude: setLatitudeNull ? null : (latitude ?? this.latitude),
      longitude: setLongitudeNull ? null : (longitude ?? this.longitude),
    );
  }
}
