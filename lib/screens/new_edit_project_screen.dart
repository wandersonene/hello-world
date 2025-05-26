import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // For checking signature file
import 'package:flutter/material.dart';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'dart:io'; 
import 'dart:typed_data'; // For QR code image
import 'dart:ui' as ui; // For QR code image rendering
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:path/path.dart' as p; 
import 'package:provider/provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/project_model.dart';
import '../models/inspection_module_model.dart';
import '../models/norma_model.dart'; 
import '../models/sync_log_model.dart'; // Added for SyncLog
import '../providers/project_provider.dart';
import '../providers/inspection_provider.dart';
import '../services/database_service.dart'; 
import '../services/report_service.dart'; 
import '../service_locator.dart'; // Added for DatabaseService direct access
import 'inspection_screen.dart';
import 'signature_screen.dart'; 

class NewEditProjectScreen extends StatefulWidget {
  static const String routeNameAdd = '/add-project';
  static const String routeNameEdit = '/edit-project';

  final Project? projectToEdit;

  const NewEditProjectScreen({Key? key, this.projectToEdit}) : super(key: key);

  @override
  State<NewEditProjectScreen> createState() => _NewEditProjectScreenState();
}

class _NewEditProjectScreenState extends State<NewEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _clientController;
  late TextEditingController _projectTypeController;
  String? _selectedStatus;

  bool get _isEditing => widget.projectToEdit != null;
  late InspectionProvider _inspectionProvider;
  String? _signaturePath; // To store the path of the saved signature

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.projectToEdit?.title ?? '');
    _clientController = TextEditingController(text: widget.projectToEdit?.client ?? '');
    _projectTypeController = TextEditingController(text: widget.projectToEdit?.projectType ?? '');
    _selectedStatus = widget.projectToEdit?.status ?? ProjectStatus.pending;

    _inspectionProvider = Provider.of<InspectionProvider>(context, listen: false);
    // Load project-specific data after the first frame
    if (_isEditing && widget.projectToEdit?.id != null) {
      final projectId = widget.projectToEdit!.id!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _inspectionProvider.loadModulesForProject(projectId);
        Provider.of<ProjectProvider>(context, listen: false).loadNormasForProject(projectId); // Load Normas
        _loadSignaturePath(); 
      });
    }
  }
  
  Future<void> _loadSignaturePath() async {
    if (widget.projectToEdit?.id == null) return;
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String signaturesDir = p.join(appDocDir.path, 'project_signatures');
      final String fileName = 'signature_project_${widget.projectToEdit!.id}.png';
      final String filePath = p.join(signaturesDir, fileName);
      
      if (await File(filePath).exists()) {
        setState(() {
          _signaturePath = filePath;
        });
      }
    } catch (e) {
      print("Error loading signature path: $e");
      // Handle error if necessary, but don't block UI
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _projectTypeController.dispose();
    // Clear norms for the specific project when leaving the screen,
    // if ProjectProvider is scoped more broadly or needs cleanup.
    // Provider.of<ProjectProvider>(context, listen: false).clearCurrentProjectNormas(); 
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final projectData = Project(
        id: widget.projectToEdit?.id,
        title: _titleController.text.trim(),
        client: _clientController.text.trim().isEmpty ? null : _clientController.text.trim(),
        projectType: _projectTypeController.text.trim().isEmpty ? null : _projectTypeController.text.trim(),
        status: _selectedStatus!,
        createdAt: widget.projectToEdit?.createdAt ?? now,
        updatedAt: now,
      );

      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      String message = '';
      bool error = false;

      try {
        if (_isEditing) {
          await projectProvider.updateProject(projectData);
          message = 'Project updated successfully!';
        } else {
          await projectProvider.addProject(projectData);
          message = 'Project added successfully!';
        }
        // After successful save, if it was a new project, pop.
        // If it was an edit, stay on the screen and show SnackBar.
        if (!mounted) return;
        if (!_isEditing) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        message = 'Error saving project: ${e.toString()}';
        error = true;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: error ? Theme.of(context).colorScheme.error : Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the title based on whether we are editing or adding a new project
    String screenTitle = _isEditing ? 'Detalhes do Projeto' : 'Add New Project';
    if (_isEditing && (_titleController.text.isNotEmpty || _clientController.text.isNotEmpty)) {
      // If editing, it's more of a details/edit screen
      screenTitle = 'Detalhes/Editar Projeto';
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Project Details Section Title
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Dados Gerais do Projeto',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título do Projeto*'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título não pode estar vazio.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(labelText: 'Cliente'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _projectTypeController,
                decoration: const InputDecoration(labelText: 'Tipo de Projeto (ex: Instalação, Manutenção)'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status*'),
                items: ProjectStatus.allStatuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um status.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProject,
                child: const Text('Salvar Alterações do Projeto'),
              ),

              // Inspection Modules Section
              if (_isEditing && widget.projectToEdit?.id != null) ...[
                const SizedBox(height: 24),
                Divider(thickness: 1, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Módulos de Inspeção',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                      tooltip: 'Adicionar Módulo de Inspeção',
                      onPressed: () => _showAddInspectionModuleDialog(context, widget.projectToEdit!.id!),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInspectionModulesList(),
              ],
              
              // PDF Report Generation Button
              if (_isEditing && widget.projectToEdit?.id != null) ...[
                const SizedBox(height: 24),
                Divider(thickness: 1, color: Colors.grey[400]),
                const SizedBox(height: 16),
                _buildSignatureSection(context, widget.projectToEdit!.id!),
                const SizedBox(height: 16),
                 Wrap( // Use Wrap for button layout on smaller screens
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Gerar/Abrir Relatório PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => _generateAndOpenReport(context, widget.projectToEdit!.id!, _signaturePath),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Enviar por E-mail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => _sendReportByEmail(context, widget.projectToEdit!, _signaturePath),
                    ),
                     ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_2_outlined),
                      label: const Text('QR Code (Drive)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[700],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => _showQrCodeDialog(context, widget.projectToEdit!.id!),
                    ),
                  ],
                ),
                const SizedBox(height: 16), 
              ],

              // ABNT Normas Section
              if (_isEditing && widget.projectToEdit?.id != null) ...[
                const SizedBox(height: 24),
                Divider(thickness: 1, color: Colors.grey[400]),
                const SizedBox(height: 16),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Normas ABNT Associadas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                      tooltip: 'Adicionar Norma ABNT',
                      onPressed: () => _showAddNormaDialog(context, widget.projectToEdit!.id!),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildNormasList(widget.projectToEdit!.id!),
                const SizedBox(height: 16), // Spacing at the bottom
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionModulesList() {
    return Consumer<InspectionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingModules) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.moduleErrorMessage != null) {
          return Center(child: Text('Erro: ${provider.moduleErrorMessage}', style: const TextStyle(color: Colors.red)));
        }
        if (provider.modulesForProject.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Column(
              children: [
                Icon(Icons.list_alt_outlined, size: 40, color: Colors.grey[600]),
                const SizedBox(height: 8),
                const Text(
                  'Nenhum módulo de inspeção adicionado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique no botão "+" acima para adicionar um novo módulo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Since it's inside another ListView
          itemCount: provider.modulesForProject.length,
          itemBuilder: (ctx, index) {
            final module = provider.modulesForProject[index];
            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(_getModuleIcon(module.name), color: Theme.of(context).primaryColor),
                title: Text(module.name),
                subtitle: Text('Status: ${module.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Excluir Módulo',
                      onPressed: () => _confirmDeleteModule(context, module),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => InspectionScreen(
                      inspectionModuleId: module.id!,
                      moduleName: module.name,
                      projectId: module.projectId, // Pass projectId
                    ),
                  ));
                },
              ),
            );
          },
        );
      },
    );
  }

  IconData _getModuleIcon(String moduleName) {
    if (moduleName.toLowerCase().contains('visual')) {
      return Icons.visibility_outlined;
    } else if (moduleName.toLowerCase().contains('polaridade')) {
      return Icons.electrical_services_outlined;
    } else if (moduleName.toLowerCase().contains('resistência') || moduleName.toLowerCase().contains('isolamento')) {
      return Icons.thermostat_outlined;
    }
    return Icons.assignment_outlined;
  }

  void _showAddInspectionModuleDialog(BuildContext context, int projectId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedModuleType; // To hold the selected value from dropdown

        return StatefulBuilder( // Use StatefulBuilder for dialog internal state
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar Novo Módulo de Inspeção'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Selecione o tipo de módulo',
                  border: OutlineInputBorder(),
                ),
                value: selectedModuleType,
                hint: const Text('Escolha um tipo'),
                isExpanded: true,
                items: PredefinedChecklists.allPredefinedModuleTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() { // Use setDialogState to update dialog's UI
                    selectedModuleType = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione um tipo de módulo' : null,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Adicionar'),
                  onPressed: selectedModuleType == null ? null : () async { // Disable if no type selected
                    if (selectedModuleType != null) {
                      try {
                        await _inspectionProvider.addInspectionModuleToProject(
                          projectId,
                          selectedModuleType!,
                        );
                        if (mounted) Navigator.of(dialogContext).pop(); // Close dialog
                        if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Módulo "$selectedModuleType" adicionado!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                         if (mounted) Navigator.of(dialogContext).pop();
                         if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao adicionar módulo: $e'), backgroundColor: Colors.red),
                            );
                         }
                      }
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDeleteModule(BuildContext context, InspectionModule module) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o módulo "${module.name}" e todos os seus itens de checklist? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () async {
                try {
                  await _inspectionProvider.deleteInspectionModule(module.id!, module.projectId);
                   if (mounted) Navigator.of(dialogContext).pop(); // Close dialog
                   if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Módulo "${module.name}" excluído.'), backgroundColor: Colors.orange),
                      );
                   }
                } catch (e) {
                  if (mounted) Navigator.of(dialogContext).pop();
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao excluir módulo: $e'), backgroundColor: Colors.red),
                      );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndOpenReport(BuildContext context, int projectId, String? signaturePath) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final reportService = ReportService(); // Consider injecting via provider/sl if it grows
      final String? filePath = await reportService.generateProjectReport(projectId, signatureImagePath: signaturePath);
      
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading indicator

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Relatório PDF/A salvo em: $filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'ABRIR',
              onPressed: () {
                reportService.openPdf(filePath);
              },
            ),
          ),
        );
      } else {
        throw Exception('Falha ao gerar o caminho do relatório.');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading indicator on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar relatório: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildSignatureSection(BuildContext context, int projectId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assinatura do Relatório',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_signaturePath != null && File(_signaturePath!).existsSync())
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assinatura atual:', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Image.file(File(_signaturePath!), height: 80, fit: BoxFit.contain),
              const SizedBox(height: 8),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Nenhuma assinatura salva para este projeto.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        OutlinedButton.icon(
          icon: Icon(_signaturePath != null ? Icons.edit_outlined : Icons.draw_outlined),
          label: Text(_signaturePath != null ? 'Alterar Assinatura' : 'Adicionar Assinatura'),
          onPressed: () async {
            final result = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignatureScreen(
                projectId: projectId,
                existingSignaturePath: _signaturePath,
              ),
            ));
            if (result is String) {
              setState(() {
                _signaturePath = result;
              });
            }
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor),
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNormasList(int projectId) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        if (projectProvider.isLoadingNormas) {
          return const Center(child: CircularProgressIndicator());
        }
        if (projectProvider.normaErrorMessage != null) {
          return Center(child: Text('Erro: ${projectProvider.normaErrorMessage}', style: const TextStyle(color: Colors.red)));
        }
        if (projectProvider.currentProjectNormas.isEmpty) {
          return const Center(child: Text('Nenhuma norma associada a este projeto.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projectProvider.currentProjectNormas.length,
          itemBuilder: (ctx, index) {
            final norma = projectProvider.currentProjectNormas[index];
            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.article_outlined, color: Colors.orangeAccent),
                title: Text(norma.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(norma.description),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  tooltip: 'Remover Norma',
                  onPressed: () => _confirmRemoveNorma(context, projectId, norma),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddNormaDialog(BuildContext context, int projectId) {
    final normaIdController = TextEditingController();
    final normaDescController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar Norma ABNT'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: normaIdController,
                  decoration: const InputDecoration(labelText: 'ID da Norma (ex: ABNT NBR 16280)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ID da Norma é obrigatório.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: normaDescController,
                  decoration: const InputDecoration(labelText: 'Descrição da Norma (opcional)'),
                  // No validator, description is optional
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
                  await projectProvider.addNormaToProject(
                    projectId,
                    normaIdController.text.trim(),
                    normaDescController.text.trim(), // Empty string if not filled
                  );
                  Navigator.of(dialogContext).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Norma "${normaIdController.text.trim()}" adicionada!'), backgroundColor: Colors.green),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmRemoveNorma(BuildContext context, int projectId, Norma norma) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remover Norma'),
          content: Text('Tem certeza que deseja remover a norma "${norma.id}" deste projeto?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remover'),
              onPressed: () async {
                final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
                await projectProvider.removeNormaFromProject(projectId, norma.id);
                Navigator.of(dialogContext).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Norma "${norma.id}" removida.'), backgroundColor: Colors.orange),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _ensureReportGenerated(BuildContext context, int projectId, String? signaturePath) async {
    // Simple check: if a report path exists, assume it's current. 
    // For a real app, you might check timestamps or always regenerate.
    final reportService = ReportService();
    final String safeProjectTitle = (widget.projectToEdit?.title ?? "Projeto_Sem_Titulo").replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String reportDir = p.join(appDocDir.path, 'project_reports', projectId.toString());
    // Try to find a report that might have been generated today (common case)
    // This logic might need to be more robust to find the *latest* generated report.
    final String expectedFileName = 'Relatorio_${safeProjectTitle}_${DateTime.now().toIso8601String().split('T').first}.pdf';
    String filePath = p.join(reportDir, expectedFileName);

    if (!await File(filePath).exists()) {
       // Attempt to find any PDF in the directory if today's doesn't exist (e.g. generated on a previous day)
        final dir = Directory(reportDir);
        if (await dir.exists()) {
            final files = await dir.list().where((item) => item.path.endsWith(".pdf")).toList();
            if (files.isNotEmpty) {
                // Sort by modified time to get the latest, or just take the first one found for simplicity
                files.sort((a, b) => (b as FileSystemEntity).statSync().modified.compareTo((a as FileSystemEntity).statSync().modified));
                filePath = files.first.path;
            } else {
                 filePath = ""; // No PDF found
            }
        } else {
            filePath = ""; // Directory doesn't exist
        }
    }
    
    if (!await File(filePath).exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gerando relatório PDF primeiro...')),
        );
        filePath = await reportService.generateProjectReport(projectId, signatureImagePath: signaturePath);
        if (filePath == null) {
          throw Exception('Falha ao gerar o relatório PDF para o e-mail.');
        }
    }
    return filePath;
  }

  Future<void> _sendReportByEmail(BuildContext context, Project project, String? signaturePath) async {
    if (project.id == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final String? reportFilePath = await _ensureReportGenerated(context, project.id!, signaturePath);
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading indicator

      if (reportFilePath == null || reportFilePath.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Não foi possível encontrar ou gerar o relatório PDF.'), backgroundColor: Colors.red),
         );
         return;
      }

      final Email email = Email(
        body: 'Segue em anexo o relatório do projeto "${project.title}".\n\nGerado por: Field Engineer App',
        subject: 'Relatório de Comissionamento: ${project.title}',
        recipients: [], // User will fill this in their email client
        attachmentPaths: [reportFilePath],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading indicator on error
      print("Error sending email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar e-mail: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _showQrCodeDialog(BuildContext context, int projectId) async {
    final dbService = sl<DatabaseService>();
    final syncLog = await dbService.getSyncLogForProject(projectId);

    if (syncLog == null || syncLog.status != SyncStatus.success || syncLog.driveReportWebViewLink == null || syncLog.driveReportWebViewLink!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório não sincronizado com Google Drive ou link indisponível. Sincronize primeiro.')),
      );
      return;
    }

    final qrLink = syncLog.driveReportWebViewLink!;
    final GlobalKey qrKey = GlobalKey();


    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('QR Code do Relatório (Google Drive)'),
          content: SingleChildScrollView( // In case content overflows
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  key: qrKey,
                  child: Container( // Container helps RepaintBoundary capture background
                    color: Colors.white, // Ensure QR code has a white background for saving
                    child: QrImageView(
                      data: qrLink,
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false, // Default is true, false adds small gap around modules
                      errorCorrectionLevel: QrErrorCorrectLevel.M, // Medium
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(qrLink, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Link'),
                      onPressed: () {
                        Share.share('Link para o relatório no Google Drive: $qrLink');
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.save_alt),
                      label: const Text('QR Code'),
                      onPressed: () async {
                        try {
                           // Request storage permission
                          var status = await Permission.storage.status;
                          if (!status.isGranted) {
                            status = await Permission.storage.request();
                          }

                          if (status.isGranted) {
                            final RenderRepaintBoundary boundary = qrKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
                            final ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Higher pixelRatio for better quality
                            final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                            final Uint8List pngBytes = byteData!.buffer.asUint8List();

                            final result = await ImageGallerySaver.saveImage(pngBytes, name: "relatorio_qr_projeto_${widget.projectToEdit?.id ?? 'geral'}");
                            if (result['isSuccess']) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('QR Code salvo na galeria!'), backgroundColor: Colors.green),
                              );
                            } else {
                              throw Exception(result['errorMessage'] ?? 'Falha ao salvar QR Code.');
                            }
                          } else {
                             ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('Permissão de armazenamento negada.')),
                              );
                          }
                        } catch (e) {
                          print("Error saving QR code: $e");
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('Erro ao salvar QR Code: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
