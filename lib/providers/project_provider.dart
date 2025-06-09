import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/database_service.dart';
import '../service_locator.dart';

class ProjectProvider with ChangeNotifier {
  final DatabaseService _databaseService = sl<DatabaseService>();

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProjectProvider() {
    loadProjects();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _databaseService.getAllProjects();
    } catch (e) {
      _errorMessage = "Error loading projects: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject(Project project) async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners(); // Optional: notify for immediate UI feedback if needed

    try {
      await _databaseService.addProject(project);
      await loadProjects(); // Refresh the list from DB
    } catch (e) {
      _errorMessage = "Error adding project: ${e.toString()}";
      // _isLoading = false; // Already handled by loadProjects in finally
      // notifyListeners(); // loadProjects will notify
    }
    // No finally block here as loadProjects() has its own.
  }

  Future<void> updateProject(Project project) async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();

    try {
      await _databaseService.updateProject(project);
      await loadProjects();
    } catch (e) {
      _errorMessage = "Error updating project: ${e.toString()}";
    }
  }

  Future<void> deleteProject(int projectId) async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();

    try {
      await _databaseService.deleteProject(projectId);
      await loadProjects();
    } catch (e) {
      _errorMessage = "Error deleting project: ${e.toString()}";
    }
  }

  Project? getProjectById(int id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null; // Not found
    }
  }

  // --- Norma Management for a specific project ---
  // Note: For a more complex app, a dedicated NormaProvider might be better.
  // For simplicity, adding to ProjectProvider as it's project-specific.

  List<Norma> _currentProjectNormas = [];
  List<Norma> get currentProjectNormas => _currentProjectNormas;
  bool _isLoadingNormas = false;
  bool get isLoadingNormas => _isLoadingNormas;
  String? _normaErrorMessage;
  String? get normaErrorMessage => _normaErrorMessage;

  Future<void> loadNormasForProject(int projectId) async {
    _isLoadingNormas = true;
    _normaErrorMessage = null;
    notifyListeners();
    try {
      _currentProjectNormas = await _databaseService.getNormasForProject(projectId);
    } catch (e) {
      _normaErrorMessage = "Error loading normas: ${e.toString()}";
      _currentProjectNormas = []; // Ensure it's empty on error
    } finally {
      _isLoadingNormas = false;
      notifyListeners();
    }
  }

  Future<void> addNormaToProject(int projectId, String normaId, String normaDescription) async {
    _normaErrorMessage = null;
    // No need to set isLoadingNormas to true here, as it's a quick operation
    // and the UI update will be handled by loadNormasForProject.
    try {
      // Add/get the norma itself to ensure it exists in the 'normas' table
      await _databaseService.addOrGetNorma(normaId, normaDescription);
      // Link it to the project
      await _databaseService.linkNormaToProject(projectId, normaId);
      await loadNormasForProject(projectId); // Refresh the list
    } catch (e) {
      _normaErrorMessage = "Error adding norma: ${e.toString()}";
      notifyListeners(); // Notify if error occurred
    }
  }

  Future<void> removeNormaFromProject(int projectId, String normaId) async {
    _normaErrorMessage = null;
    try {
      await _databaseService.removeNormaFromProject(projectId, normaId);
      await loadNormasForProject(projectId); // Refresh the list
    } catch (e) {
      _normaErrorMessage = "Error removing norma: ${e.toString()}";
      notifyListeners(); // Notify if error occurred
    }
  }

  // Call this when a project is no longer being viewed to clear its norms
  void clearCurrentProjectNormas() {
    _currentProjectNormas = [];
    _normaErrorMessage = null;
    // Optionally notify listeners if UI should react to this clearing immediately
    // For now, assume it's part of a screen disposal or project change logic
  }
}
