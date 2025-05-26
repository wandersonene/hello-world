import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

// Custom class to use with googleapis
// Based on: https://github.com/google/googleapis.dart/blob/master/generated/googleapis/lib/src/common/http_client.dart
// And: https://github.com/dart-lang/sdk/issues/42945
class AuthenticatedHttpClient extends http.BaseClient {
  final GoogleSignInAccount _account;
  final http.Client _client;

  AuthenticatedHttpClient(this._account) : _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final headers = await _account.authHeaders;
    // Ensure 'Authorization' header is set, and potentially other required headers.
    // The googleapis package might handle some of this internally if it expects an AuthClient.
    // For direct HTTP client usage, setting the Authorization header is key.
    if (headers['Authorization'] != null) {
      request.headers['Authorization'] = headers['Authorization']!;
    }
    // It's also common to need to set 'X-Goog-AuthUser' if you're managing multiple accounts,
    // but for a single signed-in user, the Authorization token usually suffices.
    // request.headers['X-Goog-AuthUser'] = '0'; // Example if needed
    
    // If running on web, CORS might be an issue for some Drive API interactions.
    // This might require specific setup in GCP console or handling by the googleapis library itself.
    // if (kIsWeb) {
    //   // request.headers['Access-Control-Allow-Origin'] = '*'; // This is NOT for client-side
    // }

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
    // The DriveApi constructor expects an authenticated client.
    // We create one using the GoogleSignInAccount's authHeaders.
    _driveApi = gdrive.DriveApi(AuthenticatedHttpClient(_googleUser));
  }

  // Helper to get the Drive API instance
  // gdrive.DriveApi get driveApi => _driveApi;

  Future<String?> findFolder(String folderName, {String? parentFolderId}) async {
    String query = "mimeType='application/vnd.google-apps.folder' and trashed=false and name='$folderName'";
    if (parentFolderId != null) {
      query += " and '$parentFolderId' in parents";
    } else {
      query += " and 'root' in parents"; // Search in root if no parent specified
    }

    try {
      final gdrive.FileList result = await _driveApi.files.list(
        q: query,
        $fields: "files(id, name)", // Request only necessary fields
      );
      if (result.files != null && result.files!.isNotEmpty) {
        return result.files!.first.id; // Return the ID of the first folder found
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

  Future<String?> findFile(String fileName, String driveFolderId) async {
    final query = "mimeType!='application/vnd.google-apps.folder' and trashed=false and name='$fileName' and '$driveFolderId' in parents";
    try {
      final gdrive.FileList result = await _driveApi.files.list(
        q: query,
        $fields: "files(id, name)",
      );
      if (result.files != null && result.files!.isNotEmpty) {
        return result.files!.first.id; // Return existing file ID
      }
      return null;
    } catch (e) {
      print('Error finding file $fileName: $e');
      throw Exception('Error finding file: $e');
    }
  }


  Future<gdrive.File> uploadFile(File localFile, String driveFolderId, {String? existingFileId}) async {
    final gdrive.File fileMetadata = gdrive.File()..name = localFile.path.split('/').last;
    
    // If existingFileId is provided, parents don't need to be set for update.
    // For new files, set the parent folder.
    if (existingFileId == null) {
       fileMetadata.parents = [driveFolderId];
    }

    final gdrive.Media media = gdrive.Media(localFile.openRead(), localFile.lengthSync());

    try {
      gdrive.File uploadedFile;
      if (existingFileId != null) {
        // Update existing file
        uploadedFile = await _driveApi.files.update(
          fileMetadata, // Only name can be updated this way, and other metadata. Content is via media.
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new file
        uploadedFile = await _driveApi.files.create(
          fileMetadata,
          uploadMedia: media,
        );
      }
      return uploadedFile;
    } catch (e) {
      print('Error uploading file ${localFile.path}: $e');
      // Consider specific error types, e.g., if it's an http.ClientException
      throw Exception('Error uploading file: $e');
    }
  }
}
