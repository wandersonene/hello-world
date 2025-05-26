import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  final int? id;
  final int inspectionModuleId;
  final int order;
  final String description;
  final String itemType; // "OK_NOT_CONFORM", "TEXT", "NUMBER", "PHOTO_REFERENCE"
  final bool? responseOkNotConform;
  final String? responseText;
  final double? responseNumber;
  final bool isMandatory;
  final String? notes; // For user's notes on the item, not the response itself
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChecklistItem({
    this.id,
    required this.inspectionModuleId,
    required this.order,
    required this.description,
    required this.itemType,
    this.responseOkNotConform,
    this.responseText,
    this.responseNumber,
    this.isMandatory = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        inspectionModuleId,
        order,
        description,
        itemType,
        responseOkNotConform,
        responseText,
        responseNumber,
        isMandatory,
        notes,
        createdAt,
        updatedAt,
      ];

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as int?,
      inspectionModuleId: map['inspection_module_id'] as int,
      order: map['item_order'] as int, // Renamed column to avoid SQL keyword conflict
      description: map['description'] as String,
      itemType: map['item_type'] as String,
      responseOkNotConform: map['response_ok_not_conform'] == null ? null : (map['response_ok_not_conform'] == 1), // SQLite stores bool as 0 or 1
      responseText: map['response_text'] as String?,
      responseNumber: map['response_number'] as double?,
      isMandatory: map['is_mandatory'] == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inspection_module_id': inspectionModuleId,
      'item_order': order, // Renamed column
      'description': description,
      'item_type': itemType,
      'response_ok_not_conform': responseOkNotConform == null ? null : (responseOkNotConform! ? 1 : 0),
      'response_text': responseText,
      'response_number': responseNumber,
      'is_mandatory': isMandatory ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ChecklistItem copyWith({
    int? id,
    int? inspectionModuleId,
    int? order,
    String? description,
    String? itemType,
    bool? responseOkNotConform,
    String? responseText,
    double? responseNumber,
    bool? isMandatory,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool setResponseOkNotConformNull = false, // Special flags for explicit null setting
    bool setResponseTextNull = false,
    bool setResponseNumberNull = false,
    bool setNotesNull = false,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      inspectionModuleId: inspectionModuleId ?? this.inspectionModuleId,
      order: order ?? this.order,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      responseOkNotConform: setResponseOkNotConformNull ? null : (responseOkNotConform ?? this.responseOkNotConform),
      responseText: setResponseTextNull ? null : (responseText ?? this.responseText),
      responseNumber: setResponseNumberNull ? null : (responseNumber ?? this.responseNumber),
      isMandatory: isMandatory ?? this.isMandatory,
      notes: setNotesNull ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChecklistItemType {
  static const String okNotConform = 'OK_NOT_CONFORM';
  static const String text = 'TEXT';
  static const String number = 'NUMBER';
  static const String photoReference = 'PHOTO_REFERENCE'; // Placeholder for now

  static List<String> get allItemTypes => [okNotConform, text, number, photoReference];
}
