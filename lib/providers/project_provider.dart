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
}
