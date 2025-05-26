import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // For File operations
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/inspection_module_model.dart';
import '../models/checklist_item_model.dart';
import '../models/photo_model.dart';
import '../models/sync_log_model.dart'; // Import SyncLog model

class DatabaseService {
  static const String _databaseName = 'field_app.db';
  static const int _databaseVersion = 1;

  // User table
  static const String tableUsers = 'users';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnUsername = 'username'; // CPF or Email
  static const String columnPasswordHash = 'password_hash';
  static const String columnSalt = 'salt';

  // Project table
  static const String tableProjects = 'projects';
  // static const String columnId = 'id'; // Already defined for users, can be reused if careful or aliased
  static const String columnProjectId = 'id'; // Explicit for projects
  static const String columnProjectTitle = 'title';
  static const String columnProjectClient = 'client';
  static const String columnProjectType = 'project_type';
  static const String columnProjectStatus = 'status';
  static const String columnProjectCreatedAt = 'created_at';
  static const String columnProjectUpdatedAt = 'updated_at';

  // InspectionModule table
  static const String tableInspectionModules = 'inspection_modules';
  static const String columnModuleId = 'id';
  static const String columnModuleProjectId = 'project_id';
  static const String columnModuleName = 'name';
  static const String columnModuleStatus = 'status';
  static const String columnModuleCreatedAt = 'created_at';
  static const String columnModuleUpdatedAt = 'updated_at';

  // ChecklistItem table
  static const String tableChecklistItems = 'checklist_items';
  static const String columnItemId = 'id';
  static const String columnItemInspectionModuleId = 'inspection_module_id';
  static const String columnItemOrder = 'item_order'; // Renamed to avoid SQL keyword 'order'
  static const String columnItemDescription = 'description';
  static const String columnItemItemType = 'item_type';
  static const String columnItemResponseOkNotConform = 'response_ok_not_conform';
  static const String columnItemResponseText = 'response_text';
  static const String columnItemResponseNumber = 'response_number';
  static const String columnItemIsMandatory = 'is_mandatory';
  static const String columnItemNotes = 'notes';
  static const String columnItemCreatedAt = 'created_at';
  static const String columnItemUpdatedAt = 'updated_at';

  // Photo table
  static const String tablePhotos = 'photos';
  static const String columnPhotoId = 'id';
  static const String columnPhotoProjectId = 'project_id';
  static const String columnPhotoInspectionModuleId = 'inspection_module_id';
  static const String columnPhotoChecklistItemId = 'checklist_item_id';
  static const String columnPhotoFilePath = 'file_path';
  static const String columnPhotoCaption = 'caption';
  static const String columnPhotoCreatedAt = 'created_at';
  static const String columnPhotoLatitude = 'latitude';
  static const String columnPhotoLongitude = 'longitude';

  // SyncLog table
  static const String tableSyncLogs = 'sync_logs';
  static const String columnSyncLogId = 'id';
  static const String columnSyncLogProjectId = 'project_id';
  static const String columnSyncLogLastSyncTimestamp = 'last_sync_timestamp';
  static const String columnSyncLogStatus = 'status';
  static const String columnSyncLogMessage = 'message';

  // Make this a singleton class.
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  // Only have a single app-wide reference to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnUsername TEXT NOT NULL UNIQUE,
        $columnPasswordHash TEXT NOT NULL,
        $columnSalt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProjects (
        $columnProjectId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnProjectTitle TEXT NOT NULL,
        $columnProjectClient TEXT,
        $columnProjectType TEXT,
        $columnProjectStatus TEXT NOT NULL,
        $columnProjectCreatedAt TEXT NOT NULL,
        $columnProjectUpdatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableInspectionModules (
        $columnModuleId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnModuleProjectId INTEGER NOT NULL,
        $columnModuleName TEXT NOT NULL,
        $columnModuleStatus TEXT NOT NULL,
        $columnModuleCreatedAt TEXT NOT NULL,
        $columnModuleUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnModuleProjectId) REFERENCES $tableProjects ($columnProjectId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableChecklistItems (
        $columnItemId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnItemInspectionModuleId INTEGER NOT NULL,
        $columnItemOrder INTEGER NOT NULL,
        $columnItemDescription TEXT NOT NULL,
        $columnItemItemType TEXT NOT NULL,
        $columnItemResponseOkNotConform INTEGER,
        $columnItemResponseText TEXT,
        $columnItemResponseNumber REAL,
        $columnItemIsMandatory INTEGER NOT NULL DEFAULT 0,
        $columnItemNotes TEXT,
        $columnItemCreatedAt TEXT NOT NULL,
        $columnItemUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnItemInspectionModuleId) REFERENCES $tableInspectionModules ($columnModuleId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePhotos (
        $columnPhotoId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPhotoProjectId INTEGER NOT NULL,
        $columnPhotoInspectionModuleId INTEGER,
        $columnPhotoChecklistItemId INTEGER,
        $columnPhotoFilePath TEXT NOT NULL,
        $columnPhotoCaption TEXT,
        $columnPhotoCreatedAt TEXT NOT NULL,
        $columnPhotoLatitude REAL,
        $columnPhotoLongitude REAL,
        FOREIGN KEY ($columnPhotoProjectId) REFERENCES $tableProjects ($columnProjectId) ON DELETE CASCADE,
        FOREIGN KEY ($columnPhotoInspectionModuleId) REFERENCES $tableInspectionModules ($columnModuleId) ON DELETE SET NULL,
        FOREIGN KEY ($columnPhotoChecklistItemId) REFERENCES $tableChecklistItems ($columnItemId) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSyncLogs (
        $columnSyncLogId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSyncLogProjectId INTEGER NOT NULL UNIQUE, 
        $columnSyncLogLastSyncTimestamp TEXT NOT NULL,
        $columnSyncLogStatus TEXT NOT NULL,
        $columnSyncLogMessage TEXT,
        FOREIGN KEY ($columnSyncLogProjectId) REFERENCES $tableProjects ($columnProjectId) ON DELETE CASCADE
      )
    ''');
     await db.execute('PRAGMA foreign_keys = ON;'); // Ensure foreign keys are enabled
  }

  // --- User Management ---
  // Insert a user into the database
  Future<int> insertUser(User user) async {
    final db = await database;
    try {
      return await db.insert(tableUsers, user.toMap());
    } catch (e) {
      // Handle specific SQLite exception for UNIQUE constraint violation
      if (e.toString().contains('UNIQUE constraint failed: users.username')) {
        throw Exception('Username (CPF/Email) already exists.');
      }
      rethrow; // Re-throw other exceptions
    }
  }

  // Retrieve a user by username (CPF/Email)
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUsername = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Optional: Close the database (though often not explicitly needed in Flutter apps)
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  // --- Project Management ---

  // Add a new project
  Future<int> addProject(Project project) async {
    final db = await database;
    return await db.insert(tableProjects, project.toMap());
  }

  // Get a single project by ID
  Future<Project?> getProject(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableProjects,
      where: '$columnProjectId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Get all projects, sorted by updated_at descending
  Future<List<Project>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableProjects,
      orderBy: '$columnProjectUpdatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  // Update an existing project
  Future<int> updateProject(Project project) async {
    final db = await database;
    return await db.update(
      tableProjects,
      project.toMap(),
      where: '$columnProjectId = ?',
      whereArgs: [project.id],
    );
  }

  // Delete a project by ID
  Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(
      tableProjects,
      where: '$columnProjectId = ?',
      whereArgs: [id],
    );
  }

  // --- Inspection Module Management ---

  Future<int> addInspectionModule(InspectionModule module) async {
    final db = await database;
    int moduleId = await db.insert(tableInspectionModules, module.toMap());
    // After adding the module, add its predefined checklist items
    if (moduleId > 0 && PredefinedChecklists.isPredefined(module.name)) {
        await addPredefinedChecklistItems(moduleId, module.name);
    }
    return moduleId;
  }

  Future<List<InspectionModule>> getInspectionModulesForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableInspectionModules,
      where: '$columnModuleProjectId = ?',
      whereArgs: [projectId],
      orderBy: '$columnModuleCreatedAt ASC',
    );
    return List.generate(maps.length, (i) => InspectionModule.fromMap(maps[i]));
  }

  Future<int> updateInspectionModule(InspectionModule module) async {
    final db = await database;
    return await db.update(
      tableInspectionModules,
      module.toMap(),
      where: '$columnModuleId = ?',
      whereArgs: [module.id],
    );
  }

  Future<int> deleteInspectionModule(int moduleId) async {
    final db = await database;
    // ON DELETE CASCADE will handle checklist items
    return await db.delete(
      tableInspectionModules,
      where: '$columnModuleId = ?',
      whereArgs: [moduleId],
    );
  }

  // --- Checklist Item Management ---

  Future<int> addChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.insert(tableChecklistItems, item.toMap());
  }

  Future<List<ChecklistItem>> getChecklistItemsForModule(int moduleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableChecklistItems,
      where: '$columnItemInspectionModuleId = ?',
      whereArgs: [moduleId],
      orderBy: '$columnItemOrder ASC',
    );
    return List.generate(maps.length, (i) => ChecklistItem.fromMap(maps[i]));
  }

  Future<int> updateChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.update(
      tableChecklistItems,
      item.toMap(),
      where: '$columnItemId = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteChecklistItem(int itemId) async {
    final db = await database;
    return await db.delete(
      tableChecklistItems,
      where: '$columnItemId = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> addPredefinedChecklistItems(int moduleId, String moduleType) async {
    final items = PredefinedChecklists.getChecklistItems(moduleType, moduleId);
    final db = await database;
    Batch batch = db.batch();
    for (var item in items) {
      batch.insert(tableChecklistItems, item.toMap());
    }
    await batch.commit(noResult: true);
  }

  // --- Photo Management ---
  Future<int> addPhoto(Photo photo) async {
    final db = await database;
    return await db.insert(tablePhotos, photo.toMap());
  }

  Future<List<Photo>> getPhotosForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePhotos,
      where: '$columnPhotoProjectId = ? AND $columnPhotoInspectionModuleId IS NULL AND $columnPhotoChecklistItemId IS NULL',
      whereArgs: [projectId],
      orderBy: '$columnPhotoCreatedAt DESC',
    );
    return List.generate(maps.length, (i) => Photo.fromMap(maps[i]));
  }

  Future<List<Photo>> getPhotosForInspectionModule(int inspectionModuleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePhotos,
      where: '$columnPhotoInspectionModuleId = ? AND $columnPhotoChecklistItemId IS NULL',
      whereArgs: [inspectionModuleId],
      orderBy: '$columnPhotoCreatedAt DESC',
    );
    return List.generate(maps.length, (i) => Photo.fromMap(maps[i]));
  }

  Future<List<Photo>> getPhotosForChecklistItem(int checklistItemId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePhotos,
      where: '$columnPhotoChecklistItemId = ?',
      whereArgs: [checklistItemId],
      orderBy: '$columnPhotoCreatedAt DESC',
    );
    return List.generate(maps.length, (i) => Photo.fromMap(maps[i]));
  }
  
  Future<Photo?> getPhotoById(int photoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePhotos,
      where: '$columnPhotoId = ?',
      whereArgs: [photoId],
    );
    if (maps.isNotEmpty) {
      return Photo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePhoto(Photo photo) async {
    final db = await database;
    return await db.update(
      tablePhotos,
      photo.toMap(),
      where: '$columnPhotoId = ?',
      whereArgs: [photo.id],
    );
  }

  Future<int> deletePhoto(int photoId) async {
    final db = await database;
    // First, retrieve the photo to get its file path
    final photo = await getPhotoById(photoId);
    if (photo != null) {
      // Delete the file from local storage
      try {
        final file = File(photo.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Log error or handle as needed
        print('Error deleting file: ${photo.filePath}, Error: $e');
      }
    }
    // Then, delete the record from the database
    return await db.delete(
      tablePhotos,
      where: '$columnPhotoId = ?',
      whereArgs: [photoId],
    );
  }

  // --- SyncLog Management ---
  Future<int> addOrUpdateSyncLog(SyncLog syncLog) async {
    final db = await database;
    // Try to find an existing log for the project
    final existingLog = await getSyncLogForProject(syncLog.projectId);
    if (existingLog != null) {
      // Update existing log
      return await db.update(
        tableSyncLogs,
        syncLog.copyWith(id: existingLog.id).toMap(), // Ensure we use the existing ID
        where: '$columnSyncLogId = ?',
        whereArgs: [existingLog.id],
      );
    } else {
      // Insert new log
      return await db.insert(tableSyncLogs, syncLog.toMap());
    }
  }

  Future<SyncLog?> getSyncLogForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSyncLogs,
      where: '$columnSyncLogProjectId = ?',
      whereArgs: [projectId],
    );
    if (maps.isNotEmpty) {
      return SyncLog.fromMap(maps.first);
    }
    return null;
  }
}


// Helper class for Predefined Checklists
class PredefinedChecklists {
  static const String visualInspection = "Inspeção Visual";
  static const String simplePolarity = "Polaridade Simplificada";
  static const String basicInsulationResistance = "Resistência de Isolamento Básica";

  static List<String> get allPredefinedModuleTypes => [
    visualInspection,
    simplePolarity,
    basicInsulationResistance,
  ];

  static bool isPredefined(String moduleName) {
    return allPredefinedModuleTypes.contains(moduleName);
  }

  static List<ChecklistItem> getChecklistItems(String moduleType, int moduleId) {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> itemsData = [];

    switch (moduleType) {
      case visualInspection:
        itemsData = [
          {'order': 1, 'description': 'Limpeza geral do painel/equipamento', 'itemType': ChecklistItemType.okNotConform, 'isMandatory': true},
          {'order': 2, 'description': 'Fixação de componentes', 'itemType': ChecklistItemType.okNotConform, 'isMandatory': true},
          {'order': 3, 'description': 'Conexões e cablagem (aperto, organização)', 'itemType': ChecklistItemType.okNotConform, 'isMandatory': true},
          {'order': 4, 'description': 'Identificação de componentes e cabos (etiquetas)', 'itemType': ChecklistItemType.okNotConform},
          {'order': 5, 'description': 'Estado de conservação de invólucros e proteções', 'itemType': ChecklistItemType.okNotConform},
          {'order': 6, 'description': 'Sinais de superaquecimento ou danos em componentes', 'itemType': ChecklistItemType.okNotConform},
          {'order': 7, 'description': 'Observações adicionais da inspeção visual', 'itemType': ChecklistItemType.text},
        ];
        break;
      case simplePolarity:
        itemsData = [
          {'order': 1, 'description': 'Verificação de polaridade Fase (L) - Neutro (N)', 'itemType': ChecklistItemType.okNotConform, 'isMandatory': true},
          {'order': 2, 'description': 'Verificação de polaridade Fase (L) - Terra (PE)', 'itemType': ChecklistItemType.okNotConform, 'isMandatory': true},
          {'order': 3, 'description': 'Verificação de polaridade Neutro (N) - Terra (PE)', 'itemType': ChecklistItemType.okNotConform, 'isMandatory': true},
          {'order': 4, 'description': 'Observações sobre polaridade', 'itemType': ChecklistItemType.text},
        ];
        break;
      case basicInsulationResistance:
        itemsData = [
          {'order': 1, 'description': 'Medição L-N (valor em MOhms)', 'itemType': ChecklistItemType.number, 'isMandatory': true},
          {'order': 2, 'description': 'Medição L-PE (valor em MOhms)', 'itemType': ChecklistItemType.number, 'isMandatory': true},
          {'order': 3, 'description': 'Medição N-PE (valor em MOhms)', 'itemType': ChecklistItemType.number, 'isMandatory': true},
          {'order': 4, 'description': 'Tensão de teste utilizada (Volts)', 'itemType': ChecklistItemType.number},
          {'order': 5, 'description': 'Observações da resistência de isolamento', 'itemType': ChecklistItemType.text},
        ];
        break;
    }

    return itemsData.map((data) => ChecklistItem(
      inspectionModuleId: moduleId,
      order: data['order'] as int,
      description: data['description'] as String,
      itemType: data['itemType'] as String,
      isMandatory: data['isMandatory'] ?? false,
      createdAt: now,
      updatedAt: now,
    )).toList();
  }
}
