import 'package:equatable/equatable.dart';

class SyncLog extends Equatable {
  final int? id;
  final int projectId;
  final DateTime lastSyncTimestamp;
  final String status; // "Success", "Error", "In Progress", "Conflict"
  final String? message;
  final int? bytesTransferred; // Optional: for progress tracking
  final int? totalBytes;       // Optional: for progress tracking
  final String? currentOperation; // Optional: e.g., "UPLOADING_PDF", "PHOTO_3_OF_10"

  const SyncLog({
    this.id,
    required this.projectId,
    required this.lastSyncTimestamp,
    required this.status,
    this.message,
    this.bytesTransferred,
    this.totalBytes,
    this.currentOperation,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        lastSyncTimestamp,
        status,
        message,
        bytesTransferred,
        totalBytes,
        currentOperation,
      ];

  factory SyncLog.fromMap(Map<String, dynamic> map) {
    return SyncLog(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      lastSyncTimestamp: DateTime.parse(map['last_sync_timestamp'] as String),
      status: map['status'] as String,
      message: map['message'] as String?,
      bytesTransferred: map['bytes_transferred'] as int?,
      totalBytes: map['total_bytes'] as int?,
      currentOperation: map['current_operation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'last_sync_timestamp': lastSyncTimestamp.toIso8601String(),
      'status': status,
      'message': message,
      'bytes_transferred': bytesTransferred,
      'total_bytes': totalBytes,
      'current_operation': currentOperation,
    };
  }

  SyncLog copyWith({
    int? id,
    int? projectId,
    DateTime? lastSyncTimestamp,
    String? status,
    String? message,
    int? bytesTransferred,
    int? totalBytes,
    String? currentOperation,
    bool setMessageNull = false,
    bool setBytesTransferredNull = false,
    bool setTotalBytesNull = false,
    bool setCurrentOperationNull = false,
  }) {
    return SyncLog(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      status: status ?? this.status,
      message: setMessageNull ? null : (message ?? this.message),
      bytesTransferred: setBytesTransferredNull ? null : (bytesTransferred ?? this.bytesTransferred),
      totalBytes: setTotalBytesNull ? null : (totalBytes ?? this.totalBytes),
      currentOperation: setCurrentOperationNull ? null : (currentOperation ?? this.currentOperation),
    );
  }
}

class SyncStatus {
  static const String success = 'Success';
  static const String error = 'Error';
  static const String inProgress = 'In Progress';
  static const String conflict = 'Conflict';
  static const String neverSynced = 'Never Synced';
  static const String userCancelled = 'User Cancelled';
  final String? driveReportWebViewLink; // Link to the report PDF on Google Drive


  const SyncLog({
    this.id,
    required this.projectId,
    required this.lastSyncTimestamp,
    required this.status,
    this.message,
    this.bytesTransferred,
    this.totalBytes,
    this.currentOperation,
    this.driveReportWebViewLink,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        lastSyncTimestamp,
        status,
        message,
        bytesTransferred,
        totalBytes,
        currentOperation,
        driveReportWebViewLink,
      ];

  factory SyncLog.fromMap(Map<String, dynamic> map) {
    return SyncLog(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      lastSyncTimestamp: DateTime.parse(map['last_sync_timestamp'] as String),
      status: map['status'] as String,
      message: map['message'] as String?,
      bytesTransferred: map['bytes_transferred'] as int?,
      totalBytes: map['total_bytes'] as int?,
      currentOperation: map['current_operation'] as String?,
      driveReportWebViewLink: map['drive_report_web_view_link'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'last_sync_timestamp': lastSyncTimestamp.toIso8601String(),
      'status': status,
      'message': message,
      'bytes_transferred': bytesTransferred,
      'total_bytes': totalBytes,
      'current_operation': currentOperation,
      'drive_report_web_view_link': driveReportWebViewLink,
    };
  }

  SyncLog copyWith({
    int? id,
    int? projectId,
    DateTime? lastSyncTimestamp,
    String? status,
    String? message,
    int? bytesTransferred,
    int? totalBytes,
    String? currentOperation,
    String? driveReportWebViewLink,
    bool setMessageNull = false,
    bool setBytesTransferredNull = false,
    bool setTotalBytesNull = false,
    bool setCurrentOperationNull = false,
    bool setDriveReportWebViewLinkNull = false,
  }) {
    return SyncLog(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      status: status ?? this.status,
      message: setMessageNull ? null : (message ?? this.message),
      bytesTransferred: setBytesTransferredNull ? null : (bytesTransferred ?? this.bytesTransferred),
      totalBytes: setTotalBytesNull ? null : (totalBytes ?? this.totalBytes),
      currentOperation: setCurrentOperationNull ? null : (currentOperation ?? this.currentOperation),
      driveReportWebViewLink: setDriveReportWebViewLinkNull ? null : (driveReportWebViewLink ?? this.driveReportWebViewLink),
    );
  }
}

class SyncStatus {
  static const String success = 'Success';
  static const String error = 'Error';
  static const String inProgress = 'In Progress';
  static const String conflict = 'Conflict';
  static const String neverSynced = 'Never Synced';
  static const String userCancelled = 'User Cancelled';
  final String? driveReportWebViewLink; // Link to the report PDF on Google Drive


  const SyncLog({
    this.id,
    required this.projectId,
    required this.lastSyncTimestamp,
    required this.status,
    this.message,
    this.bytesTransferred,
    this.totalBytes,
    this.currentOperation,
    this.driveReportWebViewLink,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        lastSyncTimestamp,
        status,
        message,
        bytesTransferred,
        totalBytes,
        currentOperation,
        driveReportWebViewLink,
      ];

  factory SyncLog.fromMap(Map<String, dynamic> map) {
    return SyncLog(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      lastSyncTimestamp: DateTime.parse(map['last_sync_timestamp'] as String),
      status: map['status'] as String,
      message: map['message'] as String?,
      bytesTransferred: map['bytes_transferred'] as int?,
      totalBytes: map['total_bytes'] as int?,
      currentOperation: map['current_operation'] as String?,
      driveReportWebViewLink: map['drive_report_web_view_link'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'last_sync_timestamp': lastSyncTimestamp.toIso8601String(),
      'status': status,
      'message': message,
      'bytes_transferred': bytesTransferred,
      'total_bytes': totalBytes,
      'current_operation': currentOperation,
      'drive_report_web_view_link': driveReportWebViewLink,
    };
  }

  SyncLog copyWith({
    int? id,
    int? projectId,
    DateTime? lastSyncTimestamp,
    String? status,
    String? message,
    int? bytesTransferred,
    int? totalBytes,
    String? currentOperation,
    String? driveReportWebViewLink,
    bool setMessageNull = false,
    bool setBytesTransferredNull = false,
    bool setTotalBytesNull = false,
    bool setCurrentOperationNull = false,
    bool setDriveReportWebViewLinkNull = false,
  }) {
    return SyncLog(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      status: status ?? this.status,
      message: setMessageNull ? null : (message ?? this.message),
      bytesTransferred: setBytesTransferredNull ? null : (bytesTransferred ?? this.bytesTransferred),
      totalBytes: setTotalBytesNull ? null : (totalBytes ?? this.totalBytes),
      currentOperation: setCurrentOperationNull ? null : (currentOperation ?? this.currentOperation),
      driveReportWebViewLink: setDriveReportWebViewLinkNull ? null : (driveReportWebViewLink ?? this.driveReportWebViewLink),
    );
  }
}

class SyncStatus {
  static const String success = 'Success';
  static const String error = 'Error';
  static const String inProgress = 'In Progress';
  static const String conflict = 'Conflict';
  static const String neverSynced = 'Never Synced';
  static const String userCancelled = 'User Cancelled';
  final String? driveReportWebViewLink; // Link to the report PDF on Google Drive


  const SyncLog({
    this.id,
    required this.projectId,
    required this.lastSyncTimestamp,
    required this.status,
    this.message,
    this.bytesTransferred,
    this.totalBytes,
    this.currentOperation,
    this.driveReportWebViewLink,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        lastSyncTimestamp,
        status,
        message,
        bytesTransferred,
        totalBytes,
        currentOperation,
        driveReportWebViewLink,
      ];

  factory SyncLog.fromMap(Map<String, dynamic> map) {
    return SyncLog(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      lastSyncTimestamp: DateTime.parse(map['last_sync_timestamp'] as String),
      status: map['status'] as String,
      message: map['message'] as String?,
      bytesTransferred: map['bytes_transferred'] as int?,
      totalBytes: map['total_bytes'] as int?,
      currentOperation: map['current_operation'] as String?,
      driveReportWebViewLink: map['drive_report_web_view_link'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'last_sync_timestamp': lastSyncTimestamp.toIso8601String(),
      'status': status,
      'message': message,
      'bytes_transferred': bytesTransferred,
      'total_bytes': totalBytes,
      'current_operation': currentOperation,
      'drive_report_web_view_link': driveReportWebViewLink,
    };
  }

  SyncLog copyWith({
    int? id,
    int? projectId,
    DateTime? lastSyncTimestamp,
    String? status,
    String? message,
    int? bytesTransferred,
    int? totalBytes,
    String? currentOperation,
    String? driveReportWebViewLink,
    bool setMessageNull = false,
    bool setBytesTransferredNull = false,
    bool setTotalBytesNull = false,
    bool setCurrentOperationNull = false,
    bool setDriveReportWebViewLinkNull = false,
  }) {
    return SyncLog(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      status: status ?? this.status,
      message: setMessageNull ? null : (message ?? this.message),
      bytesTransferred: setBytesTransferredNull ? null : (bytesTransferred ?? this.bytesTransferred),
      totalBytes: setTotalBytesNull ? null : (totalBytes ?? this.totalBytes),
      currentOperation: setCurrentOperationNull ? null : (currentOperation ?? this.currentOperation),
      driveReportWebViewLink: setDriveReportWebViewLinkNull ? null : (driveReportWebViewLink ?? this.driveReportWebViewLink),
    );
  }
}

class SyncStatus {
  static const String success = 'Success';
  static const String error = 'Error';
  static const String inProgress = 'In Progress';
  static const String conflict = 'Conflict';
  static const String neverSynced = 'Never Synced';
  static const String userCancelled = 'User Cancelled';
}
