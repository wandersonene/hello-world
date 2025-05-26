import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // For checking signature file
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For signature path
import 'package:path/path.dart' as p; // For path joining
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../models/inspection_module_model.dart';
import '../providers/project_provider.dart';
import '../providers/inspection_provider.dart';
import '../services/database_service.dart'; // For PredefinedChecklists
import '../services/report_service.dart'; // Added for ReportService
import 'inspection_screen.dart';
import 'signature_screen.dart'; // Added for SignatureScreen

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
    if (_isEditing && widget.projectToEdit?.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _inspectionProvider.loadModulesForProject(widget.projectToEdit!.id!);
        _loadSignaturePath(); // Load existing signature path
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
                 Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Gerar Relatório PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[700],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => _generateAndOpenReport(context, widget.projectToEdit!.id!, _signaturePath),
                  ),
                ),
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
}
