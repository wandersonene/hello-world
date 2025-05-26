import 'package:equatable/equatable.dart';

class SyncLog extends Equatable {
  final int? id; // Auto-incremented ID for the log entry itself
  final int projectId;
  final DateTime lastSyncTimestamp;
  final String status; // "Success", "Error", "In Progress"
  final String? message; // Optional: error message or success details

  const SyncLog({
    this.id,
    required this.projectId,
    required this.lastSyncTimestamp,
    required this.status,
    this.message,
  });

  @override
  List<Object?> get props => [id, projectId, lastSyncTimestamp, status, message];

  factory SyncLog.fromMap(Map<String, dynamic> map) {
    return SyncLog(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      lastSyncTimestamp: DateTime.parse(map['last_sync_timestamp'] as String),
      status: map['status'] as String,
      message: map['message'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'last_sync_timestamp': lastSyncTimestamp.toIso8601String(),
      'status': status,
      'message': message,
    };
  }

  SyncLog copyWith({
    int? id,
    int? projectId,
    DateTime? lastSyncTimestamp,
    String? status,
    String? message,
    bool setMessageNull = false,
  }) {
    return SyncLog(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      status: status ?? this.status,
      message: setMessageNull ? null : (message ?? this.message),
    );
  }
}

class SyncStatus {
  static const String success = 'Success';
  static const String error = 'Error';
  static const String inProgress = 'In Progress';
  static const String neverSynced = 'Never Synced'; // For UI display before first sync
}
