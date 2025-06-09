import 'package:equatable/equatable.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;

class DriveProjectModel extends Equatable {
  final String id; // Drive folder ID
  final String name;
  final DateTime? modifiedTime;
  final String? webViewLink; // Link to the folder itself on Drive

  // Details typically fetched separately or after initial listing
  final gdrive.File? reportPdf; // The main PDF report file from Drive
  final int photoCount;
  final List<gdrive.File> photos; // List of photo files from Drive

  const DriveProjectModel({
    required this.id,
    required this.name,
    this.modifiedTime,
    this.webViewLink,
    this.reportPdf,
    this.photoCount = 0,
    this.photos = const [],
  });

  @override
  List<Object?> get props => [id, name, modifiedTime, webViewLink, reportPdf, photoCount, photos];

  factory DriveProjectModel.fromDriveFolder(gdrive.File folder) {
    return DriveProjectModel(
      id: folder.id!,
      name: folder.name ?? 'Projeto Sem Nome',
      modifiedTime: folder.modifiedTime,
      webViewLink: folder.webViewLink,
    );
  }

  DriveProjectModel copyWith({
    String? id,
    String? name,
    DateTime? modifiedTime,
    String? webViewLink,
    gdrive.File? reportPdf,
    bool setReportPdfNull = false,
    int? photoCount,
    List<gdrive.File>? photos,
  }) {
    return DriveProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      webViewLink: webViewLink ?? this.webViewLink,
      reportPdf: setReportPdfNull ? null : (reportPdf ?? this.reportPdf),
      photoCount: photoCount ?? this.photoCount,
      photos: photos ?? this.photos,
    );
  }
}
