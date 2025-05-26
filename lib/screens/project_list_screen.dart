import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:googleapis/drive/v3.dart' as gdrive; // For gdrive.File
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../models/sync_log_model.dart';
import '../services/google_auth_service.dart';
import '../services/drive_service.dart';
import '../services/report_service.dart'; 
import '../services/database_service.dart'; 
import '../service_locator.dart';
import 'new_edit_project_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'abnt_catalog_screen.dart';
import '../widgets/connectivity_indicator.dart'; // Added ConnectivityIndicator

class ProjectListScreen extends StatefulWidget {
  static const String routeName = '/project-list';
  final String userName;

  const ProjectListScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  Map<int, SyncLog?> _syncLogs = {};
  bool _isLoadingSyncLogs = false;
  int? _currentlySyncingProjectId; 

  @override
  void initState() {
    super.initState();
    _loadSyncLogs();
    Provider.of<GoogleAuthService>(context, listen: false).addListener(_onAuthChanged);
    Provider.of<ProjectProvider>(context, listen: false).addListener(_onProjectsChanged);
  }

  @override
  void dispose() {
    Provider.of<GoogleAuthService>(context, listen: false).removeListener(_onAuthChanged);
    Provider.of<ProjectProvider>(context, listen: false).removeListener(_onProjectsChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    _loadSyncLogs();
  }
  
  void _onProjectsChanged() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSyncLogs();
      }
    });
  }

  Future<void> _loadSyncLogs() async {
    if (!mounted) return;
    setState(() { _isLoadingSyncLogs = true; });
    final projects = Provider.of<ProjectProvider>(context, listen: false).projects;
    Map<int, SyncLog?> newSyncLogs = {};
    final dbService = sl<DatabaseService>();
    for (var project in projects) {
      if (project.id != null) {
        newSyncLogs[project.id!] = await dbService.getSyncLogForProject(project.id!);
      }
    }
    if (mounted) {
      setState(() {
        _syncLogs = newSyncLogs;
        _isLoadingSyncLogs = false;
      });
    }
  }
  
  void _updateSyncLogState(int projectId, String status, String message, {int? bytesTransferred, int? totalBytes, String? currentOperation, String? driveReportWebViewLink}) {
    final existingLog = _syncLogs[projectId];
    DateTime timestamp = DateTime.now();
    String? finalDriveLink = driveReportWebViewLink ?? existingLog?.driveReportWebViewLink;

    // Preserve timestamp if just updating progress of an ongoing operation
    if (status == SyncStatus.inProgress && existingLog?.status == SyncStatus.inProgress) {
      timestamp = existingLog?.lastSyncTimestamp ?? DateTime.now();
    }
    
    final newLog = SyncLog(
      id: existingLog?.id, 
      projectId: projectId,
      lastSyncTimestamp: timestamp,
      status: status,
      message: message,
      bytesTransferred: bytesTransferred ?? (status == SyncStatus.inProgress ? existingLog?.bytesTransferred : null), // Preserve or reset based on status
      totalBytes: totalBytes ?? (status == SyncStatus.inProgress ? existingLog?.totalBytes : null),
      currentOperation: currentOperation ?? (status == SyncStatus.inProgress ? existingLog?.currentOperation : null),
      driveReportWebViewLink: finalDriveLink,
    );
    
    sl<DatabaseService>().addOrUpdateSyncLog(newLog);
    if(mounted) {
      setState(() {
        _syncLogs[projectId] = newLog;
      });
    }
  }

  Future<bool?> _showConflictDialog(BuildContext context, String fileName) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Conflito de Arquivo'),
          content: Text('O arquivo "$fileName" no Google Drive foi modificado desde a última sincronização. Deseja sobrescrevê-lo com a versão local?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não (Manter Versão do Drive)'),
              onPressed: () { Navigator.of(dialogContext).pop(false); },
            ),
            TextButton(
              child: const Text('Sim (Sobrescrever)'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () { Navigator.of(dialogContext).pop(true); },
            ),
          ],
        );
      },
    );
  }

  Future<void> _triggerSync(BuildContext context, Project project) async {
    if (!mounted) return;
    final authService = Provider.of<GoogleAuthService>(context, listen: false);
    if (!authService.isSignedIn || authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, faça login com o Google nas Configurações para sincronizar.')),
      );
      Navigator.of(context).pushNamed(SettingsScreen.routeName);
      return;
    }

    setState(() { _currentlySyncingProjectId = project.id; });
    _updateSyncLogState(project.id!, SyncStatus.inProgress, "Iniciando sincronização...", currentOperation: "Conectando...");

    String? currentDriveReportLink = _syncLogs[project.id!]?.driveReportWebViewLink;

    try {
      final driveService = DriveService(authService.currentUser!);
      final dbService = sl<DatabaseService>();
      final reportService = ReportService();
      Project? latestProjectData = await dbService.getProject(project.id!); 
      if (latestProjectData == null) throw Exception("Projeto não encontrado localmente.");

      const String appFolderName = "AplicativoDeComissionamento";
      _updateSyncLogState(project.id!, SyncStatus.inProgress, "Verificando pasta do aplicativo...", currentOperation: "Pastas (1/3)", driveReportWebViewLink: currentDriveReportLink);
      String appFolderId = await driveService.createFolderIfNotExists(appFolderName);

      final String projectFolderName = project.title.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
      _updateSyncLogState(project.id!, SyncStatus.inProgress, "Verificando pasta do projeto...", currentOperation: "Pastas (2/3)", driveReportWebViewLink: currentDriveReportLink);
      String projectFolderId = await driveService.createFolderIfNotExists(projectFolderName, parentFolderId: appFolderId);
      
      _updateSyncLogState(project.id!, SyncStatus.inProgress, "Gerando relatório PDF...", currentOperation: "Relatório (1/2)", driveReportWebViewLink: currentDriveReportLink);
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String signaturesDir = p.join(appDocDir.path, 'project_signatures');
      final String signatureFileName = 'signature_project_${project.id}.png';
      final String signatureFilePath = p.join(signaturesDir, signatureFileName);
      String? currentSignaturePath = await File(signatureFilePath).exists() ? signatureFilePath : null;
      
      String? reportPath = await reportService.generateProjectReport(project.id!, signatureImagePath: currentSignaturePath);
      if (reportPath == null) throw Exception("Falha ao gerar o relatório PDF.");
      File reportFile = File(reportPath);
      if (!await reportFile.exists()) throw Exception("Arquivo PDF do relatório não encontrado em $reportPath");
      
      final reportFileName = reportFile.path.split('/').last;
      _updateSyncLogState(project.id!, SyncStatus.inProgress, "Verificando PDF no Drive...", currentOperation: "Relatório (2/2)", driveReportWebViewLink: currentDriveReportLink);
      gdrive.File? existingPdfDriveFile = await driveService.findFileByNameAndGetMetadata(reportFileName, projectFolderId);
      bool allowOverwritePdf = true;

      if (existingPdfDriveFile?.id != null && existingPdfDriveFile?.modifiedTime != null) {
        final driveModifiedTime = existingPdfDriveFile!.modifiedTime!;
        final localProjectUpdatedAt = latestProjectData.updatedAt; 

        if (driveModifiedTime.isAfter(localProjectUpdatedAt)) {
          _updateSyncLogState(project.id!, SyncStatus.conflict, "Conflito detectado para o PDF. Aguardando usuário.", currentOperation: "Conflito: PDF", driveReportWebViewLink: existingPdfDriveFile.webViewLink);
           if(mounted) allowOverwritePdf = await _showConflictDialog(context, reportFileName) ?? false;
          if (!allowOverwritePdf) {
            _updateSyncLogState(project.id!, SyncStatus.userCancelled, "Envio do PDF cancelado pelo usuário.", currentOperation: "PDF: Conflito não resolvido", driveReportWebViewLink: existingPdfDriveFile.webViewLink);
            currentDriveReportLink = existingPdfDriveFile.webViewLink; // Keep old link
          }
        }
      }
      
      if (allowOverwritePdf) {
        _updateSyncLogState(project.id!, SyncStatus.inProgress, "Enviando PDF...", currentOperation: "Enviando PDF: $reportFileName", driveReportWebViewLink: currentDriveReportLink);
        gdrive.File uploadedPdfFile = await driveService.uploadFile(reportFile, projectFolderId, existingFileId: existingPdfDriveFile?.id);
        currentDriveReportLink = uploadedPdfFile.webViewLink; 
      }

      _updateSyncLogState(project.id!, SyncStatus.inProgress, "Preparando fotos...", currentOperation: "Pastas (3/3)", driveReportWebViewLink: currentDriveReportLink);
      final String photosFolderName = "Fotos";
      String photosDriveFolderId = await driveService.createFolderIfNotExists(photosFolderName, parentFolderId: projectFolderId);
      
      List<Photo> projectPhotos = await dbService.getPhotosForProject(project.id!); // Get all photos for the project

      int totalPhotos = projectPhotos.length;
      _updateSyncLogState(project.id!, SyncStatus.inProgress, "Enviando fotos...", currentOperation: "Fotos (0 de $totalPhotos)", totalBytes: totalPhotos, bytesTransferred: 0, driveReportWebViewLink: currentDriveReportLink);
      for (int i = 0; i < totalPhotos; i++) {
        final photo = projectPhotos[i];
        _updateSyncLogState(project.id!, SyncStatus.inProgress, "Enviando fotos...", currentOperation: "Foto ${i+1} de $totalPhotos: ${photo.filePath.split('/').last}", totalBytes: totalPhotos, bytesTransferred: i + 1, driveReportWebViewLink: currentDriveReportLink);
        
        File photoFile = File(photo.filePath);
        if (await photoFile.exists()) {
          final photoFileName = photoFile.path.split('/').last;
          gdrive.File? existingPhotoDriveFile = await driveService.findFileByNameAndGetMetadata(photoFileName, photosDriveFolderId);
          await driveService.uploadFile(photoFile, photosDriveFolderId, existingFileId: existingPhotoDriveFile?.id);
        }
      }

      _updateSyncLogState(project.id!, SyncStatus.success, 'Sincronizado com sucesso!', currentOperation: "Concluído", totalBytes: totalPhotos, bytesTransferred: totalPhotos, driveReportWebViewLink: currentDriveReportLink);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Projeto "${project.title}" sincronizado com sucesso!'), backgroundColor: Colors.green),
      );

    } catch (e) {
      print("Sync error for project ${project.id}: $e");
      _updateSyncLogState(project.id!, SyncStatus.error, e.toString(), currentOperation: "Falha na sincronização", driveReportWebViewLink: currentDriveReportLink); 
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sincronizar "${project.title}": $e'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) setState(() { _currentlySyncingProjectId = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    if (_syncLogs.length != projects.length && !_isLoadingSyncLogs && projects.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) _loadSyncLogs();
        });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Projetos - ${widget.userName}'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ConnectivityIndicator(), // Added ConnectivityIndicator
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined), 
            tooltip: 'Catálogo ABNT',
            onPressed: () {
              Navigator.of(context).pushNamed(AbntCatalogScreen.routeName);
            },
          ),
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
              Provider.of<GoogleAuthService>(context, listen: false).signOut();
              Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: projectProvider.isLoading && projects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : projectProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erro: ${projectProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: () => projectProvider.loadProjects(), child: const Text('Tentar Novamente'))
                    ],
                  ),
                )
              : projects.isEmpty
                  ? const Center(
                      child: Text('Nenhum projeto encontrado. Clique em \'+\' para adicionar.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0)),
                    )
                  : ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (ctx, i) {
                        final project = projects[i];
                        final syncLog = _syncLogs[project.id];
                        bool isProjectCurrentlySyncing = _currentlySyncingProjectId == project.id;
                        bool isSyncInProgressOnLog = syncLog?.status == SyncStatus.inProgress;

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
                          confirmDismiss: (direction) {
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
                          onDismissed: (direction) {
                            projectProvider.deleteProject(project.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Projeto "${project.title}" excluído.')),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            elevation: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.folder_special_outlined, color: Theme.of(context).primaryColor, size: 40),
                                  title: Text(project.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Status: ${project.status}\nCliente: ${project.client ?? "N/A"}\nAtualizado: ${project.updatedAt.toLocal().toString().substring(0,16)}',
                                                 style: Theme.of(context).textTheme.bodyMedium),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit_note, color: Colors.grey, size: 28),
                                    tooltip: 'Editar Projeto',
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => NewEditProjectScreen(projectToEdit: project),
                                      )).then((_) => _loadSyncLogs());
                                    },
                                  ),
                                  onTap: () {
                                     Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => NewEditProjectScreen(projectToEdit: project),
                                    )).then((_) => _loadSyncLogs());
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       Divider(height: 1, color: Colors.grey[300]),
                                       const SizedBox(height: 8),
                                       Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  syncLog != null && syncLog.status != SyncStatus.neverSynced
                                                    ? 'Última Sinc.: ${syncLog.lastSyncTimestamp.toLocal().toString().substring(0,16)}'
                                                    : 'Nunca sincronizado.',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                                ),
                                                Text(
                                                  'Status Sinc.: ${syncLog?.status ?? SyncStatus.neverSynced}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: syncLog?.status == SyncStatus.error ? Colors.redAccent 
                                                           : (syncLog?.status == SyncStatus.success ? Colors.green 
                                                           : (syncLog?.status == SyncStatus.inProgress || isProjectCurrentlySyncing ? Theme.of(context).primaryColor : Colors.grey)),
                                                    fontWeight: (syncLog?.status == SyncStatus.inProgress || isProjectCurrentlySyncing) ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                                if ((isProjectCurrentlySyncing || isSyncInProgressOnLog) && syncLog?.currentOperation != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2.0),
                                                    child: Text(syncLog!.currentOperation!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColorDark), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                                  ),
                                                if ((isProjectCurrentlySyncing || isSyncInProgressOnLog) && syncLog?.bytesTransferred != null && syncLog?.totalBytes != null && syncLog!.totalBytes! > 0)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: LinearProgressIndicator(
                                                      value: syncLog.bytesTransferred! / syncLog.totalBytes!,
                                                      backgroundColor: Colors.grey[300],
                                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                                    ),
                                                  ),
                                                if (syncLog?.status == SyncStatus.error && syncLog?.message != null)
                                                   Padding(
                                                    padding: const EdgeInsets.only(top: 2.0),
                                                    child: Text("Detalhe: ${syncLog!.message!}", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent), maxLines: 2, overflow: TextOverflow.ellipsis,),
                                                  ),
                                              ],
                                            )
                                          ),
                                          (isProjectCurrentlySyncing || isSyncInProgressOnLog)
                                            ? const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                                              )
                                            : IconButton(
                                                icon: Icon(Icons.sync_outlined, color: Theme.of(context).colorScheme.secondary, size: 28),
                                                tooltip: 'Sincronizar com Google Drive',
                                                onPressed: () => _triggerSync(context, project),
                                              ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const NewEditProjectScreen(),
          )).then((_) => _loadSyncLogs());
        },
      ),
    );
  }
}
