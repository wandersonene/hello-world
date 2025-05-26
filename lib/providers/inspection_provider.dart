import 'package:flutter/material.dart';
import '../models/inspection_module_model.dart';
import '../models/checklist_item_model.dart';
import '../services/database_service.dart';
import '../service_locator.dart';

class InspectionProvider with ChangeNotifier {
  final DatabaseService _databaseService = sl<DatabaseService>();

  // State for modules list in Project Details Screen
  List<InspectionModule> _modulesForProject = [];
  List<InspectionModule> get modulesForProject => _modulesForProject;
  bool _isLoadingModules = false;
  bool get isLoadingModules => _isLoadingModules;
  String? _moduleErrorMessage;
  String? get moduleErrorMessage => _moduleErrorMessage;

  // State for a single inspection screen
  InspectionModule? _currentModule;
  InspectionModule? get currentModule => _currentModule;

  List<ChecklistItem> _checklistItems = [];
  List<ChecklistItem> get checklistItems => _checklistItems;

  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;
  ChecklistItem? get currentChecklistItem =>
      _checklistItems.isNotEmpty && _currentItemIndex < _checklistItems.length
          ? _checklistItems[_currentItemIndex]
          : null;

  bool _isLoadingItems = false;
  bool get isLoadingItems => _isLoadingItems;
  String? _itemsErrorMessage;
  String? get itemsErrorMessage => _itemsErrorMessage;

  // State for photos related to the current checklist item
  List<Photo> _photosForItem = [];
  List<Photo> get photosForItem => _photosForItem;
  bool _isLoadingPhotos = false;
  bool get isLoadingPhotos => _isLoadingPhotos;
  String? _photosErrorMessage;
  String? get photosErrorMessage => _photosErrorMessage;


  // --- Modules Management (for Project Details Screen) ---
  Future<void> loadModulesForProject(int projectId) async {
    _isLoadingModules = true;
    _moduleErrorMessage = null;
    notifyListeners();
    try {
      _modulesForProject = await _databaseService.getInspectionModulesForProject(projectId);
    } catch (e) {
      _moduleErrorMessage = "Error loading inspection modules: ${e.toString()}";
    } finally {
      _isLoadingModules = false;
      notifyListeners();
    }
  }

  Future<void> addInspectionModuleToProject(int projectId, String moduleName) async {
    // _isLoadingModules = true; // Handled by loadModulesForProject
    _moduleErrorMessage = null;
    // notifyListeners(); // Avoid multiple quick notifications if not necessary

    try {
      final newModule = InspectionModule(
        projectId: projectId,
        name: moduleName,
        status: InspectionModuleStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _databaseService.addInspectionModule(newModule); // This also adds predefined items
      await loadModulesForProject(projectId); // Refresh the list
    } catch (e) {
      _moduleErrorMessage = "Error adding inspection module: ${e.toString()}";
      // _isLoadingModules = false; // loadModulesForProject will handle this
      notifyListeners(); // Notify if error occurred before refresh
    }
  }

  Future<void> deleteInspectionModule(int moduleId, int projectId) async {
    _moduleErrorMessage = null;
    try {
      await _databaseService.deleteInspectionModule(moduleId);
      await loadModulesForProject(projectId); // Refresh list
    } catch (e) {
      _moduleErrorMessage = "Error deleting inspection module: ${e.toString()}";
      notifyListeners();
    }
  }

  // --- Checklist Items Management (for Inspection Screen) ---
  Future<void> loadChecklistForModule(int moduleId) async {
    _isLoadingItems = true;
    _itemsErrorMessage = null;
    _currentItemIndex = 0;
    _photosForItem = []; // Clear photos from previous item
    _photosErrorMessage = null;
    notifyListeners();

    try {
      _currentModule = await _databaseService.getInspectionModule(moduleId);
      if (_currentModule == null) {
        throw Exception("Module not found.");
      }
      _checklistItems = await _databaseService.getChecklistItemsForModule(moduleId);
      if (_currentModule!.status == InspectionModuleStatus.pending && _checklistItems.isNotEmpty) {
        await updateModuleStatus(moduleId, InspectionModuleStatus.inProgress, skipItemReload: true);
      }
      if (_checklistItems.isNotEmpty) {
        await loadPhotosForCurrentItem(); // Load photos for the first item
      }
    } catch (e) {
      _itemsErrorMessage = "Error loading checklist items: ${e.toString()}";
      _checklistItems = [];
    } finally {
      _isLoadingItems = false;
      notifyListeners();
    }
  }

  Future<void> _loadPhotosForCurrentItemInternal() async {
     if (currentChecklistItem != null && currentChecklistItem!.id != null) {
        _photosForItem = await _databaseService.getPhotosForChecklistItem(currentChecklistItem!.id!);
      } else {
        _photosForItem = [];
      }
  }

  Future<void> loadPhotosForCurrentItem() async {
    _isLoadingPhotos = true;
    _photosErrorMessage = null;
    notifyListeners();
    try {
      await _loadPhotosForCurrentItemInternal();
    } catch (e) {
      _photosErrorMessage = "Error loading photos: ${e.toString()}";
      _photosForItem = [];
    } finally {
      _isLoadingPhotos = false;
      notifyListeners();
    }
  }


  void navigateToItem(int index) {
    if (index >= 0 && index < _checklistItems.length) {
      _currentItemIndex = index;
      loadPhotosForCurrentItem(); // Load photos for the new current item
      // notifyListeners(); // loadPhotosForCurrentItem will notify
    }
  }

  void nextItem() {
    if (_currentItemIndex < _checklistItems.length - 1) {
      _currentItemIndex++;
      loadPhotosForCurrentItem();
      // notifyListeners();
    }
  }

  void previousItem() {
    if (_currentItemIndex > 0) {
      _currentItemIndex--;
      loadPhotosForCurrentItem();
      // notifyListeners();
    }
  }

  Future<void> updateChecklistItemResponse(ChecklistItem item) async {
    try {
      final itemToUpdate = item.copyWith(updatedAt: DateTime.now());
      await _databaseService.updateChecklistItem(itemToUpdate);
      // Update the local list to reflect changes immediately
      final index = _checklistItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _checklistItems[index] = itemToUpdate;
        notifyListeners();
      }
    } catch (e) {
      // Handle error - maybe set an error message on the specific item or provider
      _itemsErrorMessage = "Error saving item: ${e.toString()}";
      notifyListeners();
    }
  }
  
  Future<void> updateModuleStatus(int moduleId, String status, {bool skipItemReload = false}) async {
    InspectionModule? module = _currentModule?.id == moduleId ? _currentModule : await _databaseService.getInspectionModule(moduleId);
    if (module != null) {
      final updatedModule = module.copyWith(status: status, updatedAt: DateTime.now());
      await _databaseService.updateInspectionModule(updatedModule);
      _currentModule = updatedModule; // Update current module if it's the one being modified

      // If this provider is also managing the list of modules for the project details screen,
      // we might need to refresh that list or update the specific module in it.
      // For now, focus on the current module's status.
      // If on inspection screen and finishing, reload items to reflect status on module.
      if (!skipItemReload) {
        await loadChecklistForModule(moduleId); // Reload to refresh module state
      } else {
         notifyListeners(); // Just notify for current module update
      }
    }
  }

  // Helper to clear inspection state when leaving the inspection screen
  void clearInspectionState() {
    _currentModule = null;
    _checklistItems = [];
    _currentItemIndex = 0;
    _isLoadingItems = false;
    _itemsErrorMessage = null;
    _photosForItem = [];
    _isLoadingPhotos = false;
    _photosErrorMessage = null;
    // notifyListeners(); // Consider if needed
  }

  // --- Photo Management for Checklist Items ---
  Future<void> addPhotoToChecklistItem({
    required int projectId,
    required int inspectionModuleId,
    required int checklistItemId,
    required String filePath,
    String? caption,
    double? latitude,
    double? longitude,
  }) async {
    _isLoadingPhotos = true; // Or a specific flag like _isAddingPhoto
    _photosErrorMessage = null;
    notifyListeners();

    try {
      final newPhoto = Photo(
        projectId: projectId,
        inspectionModuleId: inspectionModuleId,
        checklistItemId: checklistItemId,
        filePath: filePath,
        caption: caption,
        createdAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
      );
      await _databaseService.addPhoto(newPhoto);
      // Refresh photo list for the current item
      await _loadPhotosForCurrentItemInternal();
    } catch (e) {
      _photosErrorMessage = "Error adding photo: ${e.toString()}";
    } finally {
      _isLoadingPhotos = false;
      notifyListeners();
    }
  }

  Future<void> deletePhotoFromChecklistItem(int photoId) async {
    _isLoadingPhotos = true; // Or a specific flag like _isDeletingPhoto
    _photosErrorMessage = null;
    notifyListeners();
    try {
      await _databaseService.deletePhoto(photoId);
      // Refresh photo list for the current item
      await _loadPhotosForCurrentItemInternal();
    } catch (e) {
      _photosErrorMessage = "Error deleting photo: ${e.toString()}";
    } finally {
      _isLoadingPhotos = false;
      notifyListeners();
    }
  }
  
  Future<void> updatePhotoCaption(int photoId, String newCaption) async {
    _isLoadingPhotos = true;
    _photosErrorMessage = null;
    notifyListeners();
    try {
      Photo? photo = await _databaseService.getPhotoById(photoId);
      if (photo != null) {
        await _databaseService.updatePhoto(photo.copyWith(caption: newCaption));
        await _loadPhotosForCurrentItemInternal();
      } else {
        throw Exception("Photo not found for update.");
      }
    } catch (e) {
      _photosErrorMessage = "Error updating photo caption: ${e.toString()}";
    } finally {
      _isLoadingPhotos = false;
      notifyListeners();
    }
  }

}
