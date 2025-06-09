import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

// Custom class to use with googleapis
class AuthenticatedHttpClient extends http.BaseClient {
  final GoogleSignInAccount _account;
  final http.Client _client;

  AuthenticatedHttpClient(this._account) : _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final headers = await _account.authHeaders;
    if (headers['Authorization'] != null) {
      request.headers['Authorization'] = headers['Authorization']!;
    }
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}

class DriveService {
  final GoogleSignInAccount _googleUser;
  late final gdrive.DriveApi _driveApi;

  DriveService(this._googleUser) {
    _driveApi = gdrive.DriveApi(AuthenticatedHttpClient(_googleUser));
  }

  Future<String?> findFolder(String folderName, {String? parentFolderId}) async {
    String query = "mimeType='application/vnd.google-apps.folder' and trashed=false and name='$folderName'";
    if (parentFolderId != null) {
      query += " and '$parentFolderId' in parents";
    } else {
      query += " and 'root' in parents";
    }

    try {
      final gdrive.FileList result = await _driveApi.files.list(
        q: query,
        $fields: "files(id, name)",
      );
      if (result.files != null && result.files!.isNotEmpty) {
        return result.files!.first.id;
      }
      return null;
    } catch (e) {
      print('Error finding folder $folderName: $e');
      throw Exception('Error finding folder: $e');
    }
  }

  Future<String> createFolderIfNotExists(String folderName, {String? parentFolderId}) async {
    String? existingFolderId = await findFolder(folderName, parentFolderId: parentFolderId);
    if (existingFolderId != null) {
      return existingFolderId;
    }

    final gdrive.File folderToCreate = gdrive.File()
      ..name = folderName
      ..mimeType = "application/vnd.google-apps.folder";

    if (parentFolderId != null) {
      folderToCreate.parents = [parentFolderId];
    }

    try {
      final gdrive.File createdFolder = await _driveApi.files.create(folderToCreate);
      if (createdFolder.id == null) {
        throw Exception('Failed to create folder: ID was null.');
      }
      return createdFolder.id!;
    } catch (e) {
      print('Error creating folder $folderName: $e');
      throw Exception('Error creating folder: $e');
    }
  }

  Future<gdrive.File?> findFileByNameAndGetMetadata(String fileName, String driveFolderId) async {
    final query = "mimeType!='application/vnd.google-apps.folder' and trashed=false and name='$fileName' and '$driveFolderId' in parents";
    try {
      final gdrive.FileList result = await _driveApi.files.list(
        q: query,
        // Request all necessary fields, including webViewLink for sharing/QR codes
        $fields: "files(id, name, modifiedTime, size, version, webViewLink, webContentLink)",
      );
      if (result.files != null && result.files!.isNotEmpty) {
        return result.files!.first;
      }
      return null;
    } catch (e) {
      print('Error finding file $fileName with metadata: $e');
      throw Exception('Error finding file with metadata: $e');
    }
  }

  Future<String?> findFile(String fileName, String driveFolderId) async {
    final file = await findFileByNameAndGetMetadata(fileName, driveFolderId);
    return file?.id;
  }

  Future<gdrive.File> uploadFile(File localFile, String driveFolderId, {String? existingFileId}) async {
    final gdrive.File fileMetadata = gdrive.File()..name = localFile.path.split('/').last;

    if (existingFileId == null) {
       fileMetadata.parents = [driveFolderId];
    }

    final gdrive.Media media = gdrive.Media(localFile.openRead(), localFile.lengthSync());

    try {
      gdrive.File uploadedFile;
      if (existingFileId != null) {
        uploadedFile = await _driveApi.files.update(
          fileMetadata,
          existingFileId,
          uploadMedia: media,
          $fields: "id, name, webViewLink, webContentLink, modifiedTime", // Ensure webViewLink is returned on update
        );
      } else {
        uploadedFile = await _driveApi.files.create(
          fileMetadata,
          uploadMedia: media,
          $fields: "id, name, webViewLink, webContentLink, modifiedTime", // Ensure webViewLink is returned on create
        );
      }
      return uploadedFile;
    } catch (e) {
      print('Error uploading file ${localFile.path}: $e');
      throw Exception('Error uploading file: $e');
    }
  }
}
