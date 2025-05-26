import 'dart:async';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'google_auth_service_web.dart'; // Assuming this provides DriveApi

class DriveServiceWeb {
  final GoogleAuthServiceWeb _authService;
  gdrive.DriveApi? _driveApi;

  DriveServiceWeb(this._authService) {
    _driveApi = _authService.driveApi; // Get it from auth service
    _authService.addListener(_onAuthChanged); // Listen for auth changes
  }

  void _onAuthChanged() {
    _driveApi = _authService.driveApi; // Update DriveApi if auth changes
  }

  gdrive.DriveApi get driveApi {
    if (_driveApi == null) {
      throw Exception("Drive API not initialized. User might not be signed in.");
    }
    return _driveApi!;
  }
  
  // Method to find a folder by name, optionally within a parent folder.
  Future<gdrive.File?> findFolder(String folderName, {String? parentFolderId}) async {
    String query = "mimeType='application/vnd.google-apps.folder' and trashed=false and name='$folderName'";
    if (parentFolderId != null) {
      query += " and '$parentFolderId' in parents";
    } else {
      // If no parentFolderId is specified, it defaults to searching in 'root' or user's "My Drive".
      // For listing folders in the app's root, we might need a different strategy if not directly in 'root'.
      // Let's assume for now, the main app folder is expected to be findable without specifying 'root' if it's shared or owned.
      // Or, if it's always in root: query += " and 'root' in parents";
    }

    try {
      final result = await driveApi.files.list(
        q: query,
        $fields: "files(id, name, modifiedTime, webViewLink)", 
        // spaces: 'drive', // Search all of user's Drive if needed
      );
      if (result.files != null && result.files!.isNotEmpty) {
        return result.files!.first;
      }
      return null;
    } catch (e) {
      print('Error finding folder "$folderName": $e');
      throw Exception('Error finding folder "$folderName": $e');
    }
  }

  // List folders within a given parent folder ID.
  Future<List<gdrive.File>> listProjectFolders(String appRootFolderId) async {
    final String query = "mimeType='application/vnd.google-apps.folder' and trashed=false and '$appRootFolderId' in parents";
    try {
      final result = await driveApi.files.list(
        q: query,
        $fields: "files(id, name, modifiedTime, webViewLink, createdTime)", // Add createdTime if useful
        orderBy: "name", // Sort by name
      );
      return result.files ?? [];
    } catch (e) {
      print('Error listing project folders: $e');
      throw Exception('Error listing project folders: $e');
    }
  }

  // List files (specifically PDFs for reports) within a project folder.
  Future<List<gdrive.File>> listReportPdfsInFolder(String projectFolderId) async {
    final String query = "mimeType='application/pdf' and trashed=false and '$projectFolderId' in parents";
    try {
      final result = await driveApi.files.list(
        q: query,
        $fields: "files(id, name, modifiedTime, webViewLink, webContentLink, iconLink, thumbnailLink, size)",
        orderBy: "modifiedTime desc", // Get the latest report first
      );
      return result.files ?? [];
    } catch (e) {
      print('Error listing report PDFs: $e');
      throw Exception('Error listing report PDFs: $e');
    }
  }
  
  // List files in a specific subfolder (e.g., "Fotos") within a project folder.
  Future<List<gdrive.File>> listPhotosInSubfolder(String projectFolderId, String subfolderName) async {
     // First, find the subfolder (e.g., "Fotos")
    final photoSubfolder = await findFolder(subfolderName, parentFolderId: projectFolderId);
    if (photoSubfolder == null || photoSubfolder.id == null) {
      print('Photos subfolder "$subfolderName" not found in project $projectFolderId.');
      return []; // No subfolder, so no photos
    }

    final String query = "mimeType contains 'image/' and trashed=false and '${photoSubfolder.id}' in parents";
    try {
      final result = await driveApi.files.list(
        q: query,
        $fields: "files(id, name, modifiedTime, webViewLink, webContentLink, iconLink, thumbnailLink, size)",
      );
      return result.files ?? [];
    } catch (e) {
      print('Error listing photos in subfolder "$subfolderName": $e');
      throw Exception('Error listing photos in subfolder "$subfolderName": $e');
    }
  }

  // Get a specific file's metadata (useful if you have the ID)
  Future<gdrive.File?> getFileMetadata(String fileId) async {
    try {
      final file = await driveApi.files.get(
        fileId,
        $fields: "id, name, modifiedTime, webViewLink, webContentLink, iconLink, thumbnailLink, size",
      ) as gdrive.File?; // Cast needed as get returns dynamic
      return file;
    } catch (e) {
      print('Error getting file metadata for $fileId: $e');
      // Handle not found or other errors gracefully
      if (e is gdrive.DetailedApiRequestError && e.statusCode == 404) {
        return null;
      }
      throw Exception('Error getting file metadata: $e');
    }
  }
  
  void dispose() {
    _authService.removeListener(_onAuthChanged);
  }
}
