import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import '../services/google_auth_service_web.dart';
import '../services/drive_service_web.dart';
import '../models/drive_project_model.dart';

class AdminProvider with ChangeNotifier {
  final GoogleAuthServiceWeb _authService;
  DriveServiceWeb? _driveService;

  List<DriveProjectModel> _driveProjects = [];
  List<DriveProjectModel> get driveProjects => _driveProjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AdminProvider(this._authService) {
    _authService.addListener(_onAuthChanged);
    _onAuthChanged(); // Initialize based on current auth state
  }

  void _onAuthChanged() {
    if (_authService.isSignedIn && _authService.currentUser != null) {
      _driveService = DriveServiceWeb(_authService); // Pass the auth service instance directly
      fetchProjectsFromDrive();
    } else {
      _driveService = null;
      _driveProjects = [];
      _errorMessage = "Usuário não está logado.";
      notifyListeners();
    }
  }

  Future<void> fetchProjectsFromDrive() async {
    if (_driveService == null || !_authService.isSignedIn) {
      _errorMessage = "Login com Google necessário para carregar projetos.";
      _driveProjects = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const String appRootFolderName = "AplicativoDeComissionamento";
      final appRootFolder = await _driveService!.findFolder(appRootFolderName);

      if (appRootFolder == null || appRootFolder.id == null) {
        _errorMessage = "Pasta raiz do aplicativo ('$appRootFolderName') não encontrada no Drive.";
        _driveProjects = [];
      } else {
        final projectFolders = await _driveService!.listProjectFolders(appRootFolder.id!);
        List<DriveProjectModel> projects = [];
        for (var folder in projectFolders) {
          if (folder.id == null) continue;

          // Fetch the main PDF report for this project
          final reports = await _driveService!.listReportPdfsInFolder(folder.id!);
          gdrive.File? mainReport = reports.isNotEmpty ? reports.first : null;
          
          // Fetch photos and count them
          final photos = await _driveService!.listPhotosInSubfolder(folder.id!, "Fotos");
          
          projects.add(
            DriveProjectModel.fromDriveFolder(folder).copyWith(
              reportPdf: mainReport,
              photoCount: photos.length,
              // photos: photos, // Could store all photo gdrive.File objects if needed for detail view
            )
          );
        }
        _driveProjects = projects;
      }
    } catch (e) {
      print("Error fetching projects from Drive: $e");
      _errorMessage = "Erro ao buscar projetos do Drive: ${e.toString()}";
      _driveProjects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _driveService?.dispose(); // If DriveServiceWeb implements a dispose method
    super.dispose();
  }
}
