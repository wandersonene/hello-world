import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../models/sync_log_model.dart';
import '../services/google_auth_service.dart';
import '../services/drive_service.dart';
import '../services/report_service.dart'; // To get the report path
import '../services/database_service.dart'; // To get photos and sync logs
import '../service_locator.dart';
import 'new_edit_project_screen.dart';
import 'login_screen.dart'; // For logout
import 'settings_screen.dart'; // For settings navigation

class ProjectListScreen extends StatefulWidget {
  static const String routeName = '/project-list';
  final String userName; // Keep userName if needed for AppBar

  const ProjectListScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    _loadSyncLogs();
    // Listen to GoogleAuthService changes to update UI if login status changes
    Provider.of<GoogleAuthService>(context, listen: false).addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    Provider.of<GoogleAuthService>(context, listen: false).removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    // If auth status changes, refresh sync logs as they might depend on user
    _loadSyncLogs();
  }


  Map<int, SyncLog?> _syncLogs = {};
  bool _isLoadingSyncLogs = false;

  Future<void> _loadSyncLogs() async {
    setState(() { _isLoadingSyncLogs = true; });
    final projects = Provider.of<ProjectProvider>(context, listen: false).projects;
    Map<int, SyncLog?> newSyncLogs = {};
    final dbService = sl<DatabaseService>();
    for (var project in projects) {
      if (project.id != null) {
        newSyncLogs[project.id!] = await dbService.getSyncLogForProject(project.id!);
      }
    }
    if(mounted) {
      setState(() {
        _syncLogs = newSyncLogs;
        _isLoadingSyncLogs = false;
      });
    }
  }
  
  Future<void> _triggerSync(Project project) async {
    final authService = Provider.of<GoogleAuthService>(context, listen: false);
    if (!authService.isSignedIn || authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, faça login com o Google nas Configurações para sincronizar.')),
      );
      Navigator.of(context).pushNamed(SettingsScreen.routeName);
      return;
    }

    // Show loading indicator for this specific project sync
    setState(() {
      _syncLogs[project.id!] = SyncLog(
          projectId: project.id!,
          lastSyncTimestamp: _syncLogs[project.id!]?.lastSyncTimestamp ?? DateTime.now(), // keep old date until success
          status: SyncStatus.inProgress,
          message: 'Sincronizando...');
    });

    try {
      final driveService = DriveService(authService.currentUser!);
      final dbService = sl<DatabaseService>();
      final reportService = ReportService(); // Assuming it can generate/find report path

      // 1. Create root app folder
      const String appFolderName = "AplicativoDeComissionamento";
      String appFolderId = await driveService.createFolderIfNotExists(appFolderName);

      // 2. Create project folder
      final String projectFolderName = project.title.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
      String projectFolderId = await driveService.createFolderIfNotExists(projectFolderName, parentFolderId: appFolderId);
      
      // 3. Upload Report PDF
      //    Generate report first (or get path if already generated and current)
      //    For simplicity, let's assume ReportService.generateProjectReport creates/returns the latest PDF path
      String? reportPath = await reportService.generateProjectReport(project.id!);
      if (reportPath == null) throw Exception("Falha ao gerar o relatório PDF.");
      File reportFile = File(reportPath);
      if (!await reportFile.exists()) throw Exception("Arquivo PDF do relatório não encontrado em $reportPath");
      
      String? existingReportDriveId = await driveService.findFile(reportFile.path.split('/').last, projectFolderId);
      await driveService.uploadFile(reportFile, projectFolderId, existingFileId: existingReportDriveId);

      // 4. Upload Photos
      final String photosFolderName = "Fotos";
      String photosDriveFolderId = await driveService.createFolderIfNotExists(photosFolderName, parentFolderId: projectFolderId);
      
      // Fetch all photos related to the project (from all modules/items)
      // This might require a new method in DatabaseService or iterate through modules/items
      List<Photo> projectPhotos = [];
      final modules = await dbService.getInspectionModulesForProject(project.id!);
      for (var module in modules) {
        final items = await dbService.getChecklistItemsForModule(module.id!);
        for (var item in items) {
          projectPhotos.addAll(await dbService.getPhotosForChecklistItem(item.id!));
        }
      }
      // Add project-level photos if any (not implemented, but for future)
      // projectPhotos.addAll(await dbService.getPhotosForProject(project.id!));


      for (var photo in projectPhotos) {
        File photoFile = File(photo.filePath);
        if (await photoFile.exists()) {
          String? existingPhotoDriveId = await driveService.findFile(photoFile.path.split('/').last, photosDriveFolderId);
          await driveService.uploadFile(photoFile, photosDriveFolderId, existingFileId: existingPhotoDriveId);
        }
      }

      // 5. Update SyncLog
      final successLog = SyncLog(
        projectId: project.id!,
        lastSyncTimestamp: DateTime.now(),
        status: SyncStatus.success,
        message: 'Sincronizado com sucesso!',
      );
      await dbService.addOrUpdateSyncLog(successLog);
      if(mounted) {
        setState(() { _syncLogs[project.id!] = successLog; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Projeto "${project.title}" sincronizado com sucesso!'), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      print("Sync error for project ${project.id}: $e");
      final errorLog = SyncLog(
        projectId: project.id!,
        lastSyncTimestamp: _syncLogs[project.id!]?.lastSyncTimestamp ?? DateTime.now(), // Keep old date on error
        status: SyncStatus.error,
        message: e.toString(),
      );
      await sl<DatabaseService>().addOrUpdateSyncLog(errorLog);
      if(mounted) {
        setState(() { _syncLogs[project.id!] = errorLog; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sincronizar "${project.title}": $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Reload sync logs when projects change (e.g., after adding/deleting a project)
    // This is a bit of a workaround; a more robust solution might involve listening to ProjectProvider changes.
    final projectCount = Provider.of<ProjectProvider>(context).projects.length;
    if (_syncLogs.length != projectCount && !_isLoadingSyncLogs && projectCount > 0) {
       // Check projectCount > 0 to avoid initial load conflicts if projects load after sync logs
      _loadSyncLogs();
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Projetos - ${widget.userName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Provider.of<GoogleAuthService>(context, listen: false).signOut(); // Also sign out from Google
              // TODO: Clear local user session from local auth service if any
              Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          if (projectProvider.isLoading && projectProvider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (projectProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${projectProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => projectProvider.loadProjects(),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (projectProvider.projects.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum projeto encontrado. Clique em \'+\' para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            );
          }

          return ListView.builder(
            itemCount: projectProvider.projects.length,
            itemBuilder: (ctx, i) {
              final project = projectProvider.projects[i];
              final project = projectProvider.projects[i];
              final syncLog = _syncLogs[project.id!];
              bool isSyncing = syncLog?.status == SyncStatus.inProgress;

              return Dismissible(
                key: ValueKey(project.id),
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) { /* ... existing confirmDismiss ... */
                   return showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Tem certeza?'),
                      content: const Text('Deseja excluir este projeto? Esta ação não pode ser desfeita.'),
                      actions: <Widget>[
                        TextButton(child: const Text('Não'), onPressed: () => Navigator.of(ctx).pop(false)),
                        TextButton(child: const Text('Sim, Excluir'), onPressed: () => Navigator.of(ctx).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) { /* ... existing onDismissed ... */
                  Provider.of<ProjectProvider>(context, listen: false).deleteProject(project.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Projeto "${project.title}" excluído.')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.folder_special_outlined, color: Theme.of(context).primaryColor, size: 36),
                        title: Text(project.title, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('Status: ${project.status}\nCliente: ${project.client ?? "N/A"}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.grey),
                          tooltip: 'Editar Projeto',
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NewEditProjectScreen(projectToEdit: project),
                            )).then((_) => _loadSyncLogs()); // Refresh sync logs when returning
                          },
                        ),
                        onTap: () {
                           Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NewEditProjectScreen(projectToEdit: project),
                          )).then((_) => _loadSyncLogs());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                syncLog != null && syncLog.status != SyncStatus.neverSynced
                                  ? 'Última Sinc.: ${syncLog.lastSyncTimestamp.toLocal().toString().substring(0,16)}\nStatus: ${syncLog.status == SyncStatus.success ? "Sucesso" : (syncLog.status == SyncStatus.error ? "Erro" : syncLog.status)}'
                                  : 'Nunca sincronizado.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: syncLog?.status == SyncStatus.error ? Colors.redAccent : (syncLog?.status == SyncStatus.success ? Colors.green : Colors.grey),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            isSyncing
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.0))
                              : IconButton(
                                  icon: Icon(Icons.sync_outlined, color: Theme.of(context).colorScheme.secondary),
                                  tooltip: 'Sincronizar com Google Drive',
                                  onPressed: () => _triggerSync(project),
                                ),
                          ],
                        ),
                      )
                    ],
                  )
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const NewEditProjectScreen(),
          ));
        },
      ),
    );
  }
}
