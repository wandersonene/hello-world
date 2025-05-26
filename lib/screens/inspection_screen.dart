import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // Alias for path package
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import '../models/checklist_item_model.dart';
import '../models/inspection_module_model.dart'; // For status constants
import '../models/photo_model.dart' as app_photo; // Alias to avoid conflict with PhotoView
import 'package:geolocator/geolocator.dart';


class InspectionScreen extends StatefulWidget {
  static const String routeName = '/inspection';

  final int inspectionModuleId;
  final String moduleName;
  final int projectId; // To refresh project modules list if status changes

  const InspectionScreen({
    Key? key,
    required this.inspectionModuleId,
    required this.moduleName,
    required this.projectId,
  }) : super(key: key);

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  late InspectionProvider _inspectionProvider;
  TextEditingController? _textEditingController;
  TextEditingController? _notesEditingController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _inspectionProvider = Provider.of<InspectionProvider>(context, listen: false);
    _textEditingController = TextEditingController();
    _notesEditingController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inspectionProvider.loadChecklistForModule(widget.inspectionModuleId).then((_) {
        _updateTextControllerWithCurrentItem();
        // Photos for the first item are loaded by loadChecklistForModule itself
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This might be called if the provider instance changes, good place to re-initialize listeners or controllers if needed
    // For this screen, primary loading is in initState and via Consumer updates.
  }
  
  void _updateTextControllerWithCurrentItem() {
    final item = _inspectionProvider.currentChecklistItem;
    if (item != null) {
      if (item.itemType == ChecklistItemType.text) {
        _textEditingController?.text = item.responseText ?? '';
      } else if (item.itemType == ChecklistItemType.number) {
        _textEditingController?.text = item.responseNumber?.toString() ?? '';
      } else {
         _textEditingController?.clear(); // Clear for non-text/number types initially
      }
      _notesEditingController?.text = item.notes ?? '';
    } else {
       _textEditingController?.clear();
       _notesEditingController?.clear();
    }
  }


  @override
  void dispose() {
    _textEditingController?.dispose();
    _notesEditingController?.dispose();
    // It's good practice to clear specific state in provider if it's tightly coupled to this screen's lifecycle
    // For example: _inspectionProvider.clearCurrentChecklistState();
    // However, do this only if that state isn't needed immediately after popping (e.g. for updating previous screen)
    // For now, we are not clearing it as the provider might be used by other widgets or for quick re-entry.
    // Consider calling `_inspectionProvider.clearInspectionState();` if appropriate.
    super.dispose();
  }

  Future<void> _saveResponse({
    bool? okNotConform,
    String? textResponse,
    double? numberResponse,
    String? notes,
    bool isLeavingItem = false, // true if called when navigating away
  }) async {
    final item = _inspectionProvider.currentChecklistItem;
    if (item == null) return;

    ChecklistItem updatedItem = item;
    if (okNotConform != null) {
      updatedItem = updatedItem.copyWith(responseOkNotConform: okNotConform, updatedAt: DateTime.now());
    }
    if (textResponse != null && item.itemType == ChecklistItemType.text) {
       updatedItem = updatedItem.copyWith(responseText: textResponse, updatedAt: DateTime.now());
    }
    if (numberResponse != null && item.itemType == ChecklistItemType.number) {
       updatedItem = updatedItem.copyWith(responseNumber: numberResponse, updatedAt: DateTime.now());
    }
     if (notes != null) { // Allow saving notes independently
      updatedItem = updatedItem.copyWith(notes: notes, updatedAt: DateTime.now());
    }
    
    // Only save if something actually changed or if explicitly saving (e.g. on text field blur/change)
    // For OK/Not Conform, they are explicit actions, so always save.
    // For text/number, save if isLeavingItem is true or if the value actually changed.
    bool hasChanged = item != updatedItem;

    if (hasChanged) {
        await _inspectionProvider.updateChecklistItemResponse(updatedItem);
    }
  }
  
  void _saveCurrentTextResponse() {
    final item = _inspectionProvider.currentChecklistItem;
    if (item == null) return;

    if (item.itemType == ChecklistItemType.text) {
      _saveResponse(textResponse: _textEditingController?.text);
    } else if (item.itemType == ChecklistItemType.number) {
      final val = double.tryParse(_textEditingController?.text ?? '');
      _saveResponse(numberResponse: val);
    }
  }
  
  void _saveNotesResponse() {
     final item = _inspectionProvider.currentChecklistItem;
    if (item == null) return;
    _saveResponse(notes: _notesEditingController?.text);
  }


  Widget _buildResponseInput(ChecklistItem item) {
    switch (item.itemType) {
      case ChecklistItemType.okNotConform:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: item.responseOkNotConform == true ? Colors.green : Colors.grey),
              onPressed: () => _saveResponse(okNotConform: true),
              child: const Text('OK'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: item.responseOkNotConform == false ? Colors.red : Colors.grey),
              onPressed: () => _saveResponse(okNotConform: false),
              child: const Text('Não Conforme'),
            ),
          ],
        );
      case ChecklistItemType.text:
      case ChecklistItemType.number: // Handled together for text input, validation differs
         // _textEditingController is already updated by _updateTextControllerWithCurrentItem
        return TextFormField(
          controller: _textEditingController,
          decoration: InputDecoration(
            labelText: item.itemType == ChecklistItemType.number ? 'Resposta Numérica' : 'Resposta Textual',
            border: const OutlineInputBorder(),
          ),
          keyboardType: item.itemType == ChecklistItemType.number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.multiline,
          maxLines: item.itemType == ChecklistItemType.text ? null : 1, // Allow multiple lines for text
          onChanged: (value) {
            // Debounced save or save on blur might be better for performance
            // For now, direct save on change for simplicity, or rely on navigation to save
            if (item.itemType == ChecklistItemType.text) {
                 _saveResponse(textResponse: value);
            } else if (item.itemType == ChecklistItemType.number) {
                 _saveResponse(numberResponse: double.tryParse(value));
            }
          },
        );
      case ChecklistItemType.photoReference:
        // This specific type might just be a flag to encourage photo taking,
        // but the photo section below is generic for any item.
        return Column(
          children: [
            Text('Este item requer referência fotográfica.', style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).hintColor)),
            const SizedBox(height: 8),
            // The actual photo adding UI will be in _buildPhotoSection
          ],
        );
      default:
        return const Text('Tipo de item desconhecido.');
    }
  }

   Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviços de localização desabilitados.')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão de localização negada.')));
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão de localização negada permanentemente. Não é possível obter coordenadas.')));
      return null;
    } 
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao obter localização: $e')));
      return null;
    }
  }


  Future<void> _pickImage(ImageSource source) async {
    final ChecklistItem? currentItem = _inspectionProvider.currentChecklistItem;
    if (currentItem == null || currentItem.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item de checklist não selecionado.')),
      );
      return;
    }

    // Request permissions first
    Map<Permission, PermissionStatus> statuses = await [
        source == ImageSource.camera ? Permission.camera : Permission.photos,
        Permission.locationWhenInUse, // Request location along with camera/gallery
    ].request();

    bool cameraGranted = statuses[Permission.camera] == PermissionStatus.granted || statuses[Permission.photos] == PermissionStatus.granted;
    bool locationGranted = statuses[Permission.locationWhenInUse] == PermissionStatus.granted || statuses[Permission.locationWhenInUse] == PermissionStatus.limited;


    if (!cameraGranted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${source == ImageSource.camera ? "Camera" : "Gallery"} permission not granted.'))
        );
        return;
    }
    
    Position? position;
    if(locationGranted) {
        position = await _getCurrentLocation();
    } else {
        print("Location permission not granted, proceeding without location.");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão de localização não concedida. A foto será salva sem coordenadas.'))
        );
    }


    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String projectPhotoDir = p.join(appDir.path, 'project_photos', widget.projectId.toString());
        await Directory(projectPhotoDir).create(recursive: true);
        
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
        final String savedImagePath = p.join(projectPhotoDir, fileName);

        final File localImage = await File(pickedFile.path).copy(savedImagePath);

        // Allow user to add a caption
        String? caption = await _showCaptionDialog(context);

        await _inspectionProvider.addPhotoToChecklistItem(
          projectId: widget.projectId,
          inspectionModuleId: widget.inspectionModuleId,
          checklistItemId: currentItem.id!,
          filePath: localImage.path,
          caption: caption,
          latitude: position?.latitude,
          longitude: position?.longitude,
        );
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<String?> _showCaptionDialog(BuildContext context, {String? initialCaption}) async {
    TextEditingController captionController = TextEditingController(text: initialCaption);
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(initialCaption == null ? 'Adicionar Legenda' : 'Editar Legenda'),
          content: TextField(
            controller: captionController,
            decoration: const InputDecoration(hintText: "Digite a legenda da foto"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(captionController.text);
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _completeInspection() async {
    bool allMandatoryAnswered = true;
    for (var item in _inspectionProvider.checklistItems) {
      if (item.isMandatory) {
        bool answered = false;
        if (item.itemType == ChecklistItemType.okNotConform && item.responseOkNotConform != null) answered = true;
        if (item.itemType == ChecklistItemType.text && item.responseText != null && item.responseText!.isNotEmpty) answered = true;
        if (item.itemType == ChecklistItemType.number && item.responseNumber != null) answered = true;
        // PHOTO_REFERENCE would need its own check when implemented

        if (!answered) {
          allMandatoryAnswered = false;
          break;
        }
      }
    }

    if (!allMandatoryAnswered) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, responda todos os itens obrigatórios antes de concluir.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Save any pending changes from text fields before completing
    _saveCurrentTextResponse();
    _saveNotesResponse();

    await _inspectionProvider.updateModuleStatus(widget.inspectionModuleId, InspectionModuleStatus.completed);
    // Refresh the modules list on the previous screen (Project Details)
    // This assumes ProjectDetailsScreen re-fetches or listens to ProjectProvider/InspectionProvider for module updates.
    // For a more direct update, we might pass a callback or use a shared provider that ProjectDetailsScreen listens to.
    // For now, InspectionProvider on ProjectDetails screen will reload when it next builds.
    Provider.of<InspectionProvider>(context, listen: false).loadModulesForProject(widget.projectId);


    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspeção concluída!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Concluir Inspeção',
            onPressed: _completeInspection,
          )
        ],
      ),
      body: Consumer<InspectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingItems || provider.currentChecklistItem == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.itemsErrorMessage != null) {
            return Center(
              child: Text('Erro: ${provider.itemsErrorMessage}', style: const TextStyle(color: Colors.red)),
            );
          }

          final item = provider.currentChecklistItem!;
          // Ensure controller text is updated when item changes via provider (e.g. next/prev)
          // This is crucial because the TextFormField uses a controller.
          WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) _updateTextControllerWithCurrentItem();
          });


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView( // Allows content to scroll if it overflows
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item ${provider.currentItemIndex + 1} de ${provider.checklistItems.length}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (provider.currentModule?.status != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom:8.0),
                      child: Text(
                        'Status do Módulo: ${provider.currentModule!.status}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  
                  // Main content card for item description and response
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (item.isMandatory)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '* Obrigatório',
                                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 20),
                          _buildResponseInput(item),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photo Section
                  _buildPhotoSection(item),
                  
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesEditingController,
                    decoration: const InputDecoration(
                        labelText: 'Notas Adicionais do Item (Opcional)',
                        border: OutlineInputBorder(),
                        hintText: 'Digite suas observações sobre este item aqui...'),
                    maxLines: 3,
                    onChanged: (value) {
                        _saveResponse(notes: value); // Save notes as they change
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                        onPressed: provider.currentItemIndex == 0 ? null : () {
                           _saveCurrentTextResponse(); _saveNotesResponse(); provider.previousItem();
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Próximo'),
                        onPressed: provider.currentItemIndex == provider.checklistItems.length - 1 ? null : () {
                           _saveCurrentTextResponse(); _saveNotesResponse(); provider.nextItem();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoSection(ChecklistItem item) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fotos do Item', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: Icon(Icons.add_a_photo_outlined, color: Theme.of(context).primaryColor),
                  tooltip: 'Adicionar Foto',
                  onPressed: () => _showPhotoSourceDialog(context),
                ),
              ],
            ),
            Consumer<InspectionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingPhotos) {
                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                }
                if (provider.photosErrorMessage != null) {
                  return Text('Erro: ${provider.photosErrorMessage}', style: const TextStyle(color: Colors.red));
                }
                if (provider.photosForItem.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Nenhuma foto adicionada para este item.'),
                  ));
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: provider.photosForItem.length,
                  itemBuilder: (context, index) {
                    final photo = provider.photosForItem[index];
                    return _buildPhotoThumbnail(photo);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(app_photo.Photo photo) {
    return GestureDetector(
      onTap: () => _viewPhoto(photo.filePath),
      onLongPress: () => _showPhotoOptionsDialog(photo),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: Image.file(
              File(photo.filePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
            ),
          ),
          if (photo.caption != null && photo.caption!.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Text(
                photo.caption!,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _viewPhoto(String filePath) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Visualizar Foto')),
        body: PhotoView(
          imageProvider: FileImage(File(filePath)),
          backgroundDecoration: BoxDecoration(color: Theme.of(context).canvasColor),
        ),
      ),
    ));
  }
  
  void _showPhotoSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeria'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoOptionsDialog(app_photo.Photo photo) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Opções da Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar Legenda'),
                onTap: () async {
                  Navigator.of(dialogContext).pop(); // Close this dialog
                  final newCaption = await _showCaptionDialog(context, initialCaption: photo.caption);
                  if (newCaption != null && photo.id != null) {
                    _inspectionProvider.updatePhotoCaption(photo.id!, newCaption);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Excluir Foto'),
                onTap: () {
                  Navigator.of(dialogContext).pop(); // Close this dialog
                  _confirmDeletePhoto(photo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeletePhoto(app_photo.Photo photo) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir esta foto${photo.caption != null && photo.caption!.isNotEmpty ? ' (${photo.caption})' : ''}? Esta ação não pode ser desfeita.'),
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
                if (photo.id != null) {
                  await _inspectionProvider.deletePhotoFromChecklistItem(photo.id!);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
