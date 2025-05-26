import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class SignatureScreen extends StatefulWidget {
  static const String routeName = '/signature';
  final int projectId; // To associate signature with a project
  final String? existingSignaturePath;

  const SignatureScreen({
    Key? key,
    required this.projectId,
    this.existingSignaturePath,
  }) : super(key: key);

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? _signatureBytes; // To display existing signature if any

  @override
  void initState() {
    super.initState();
    if (widget.existingSignaturePath != null) {
      _loadExistingSignature();
    }
  }

  Future<void> _loadExistingSignature() async {
    try {
      final file = File(widget.existingSignaturePath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        setState(() {
          _signatureBytes = bytes;
          // Note: SignatureController doesn't directly support loading points from an image.
          // We display the image above the pad if it exists. The user can re-sign.
        });
      }
    } catch (e) {
      print("Error loading existing signature: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar assinatura existente: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> _saveSignature() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, desenhe sua assinatura primeiro.')),
      );
      return null;
    }

    final Uint8List? data = await _controller.toPngBytes();
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível capturar a assinatura.')),
      );
      return null;
    }

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String signaturesDir = p.join(appDocDir.path, 'project_signatures');
      await Directory(signaturesDir).create(recursive: true);
      
      // Using project ID in filename to make it specific, overwrites old one for this project
      final String fileName = 'signature_project_${widget.projectId}.png';
      final String filePath = p.join(signaturesDir, fileName);
      
      final File file = File(filePath);
      await file.writeAsBytes(data);
      return filePath;
    } catch (e) {
      print("Error saving signature: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar assinatura: $e'), backgroundColor: Colors.red),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinatura Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar Assinatura',
            onPressed: () {
              _controller.clear();
              setState(() { _signatureBytes = null; }); // Clear displayed existing signature too
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_signatureBytes != null && _controller.isEmpty) // Show existing only if pad is empty
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text("Assinatura Atual:", style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Image.memory(_signatureBytes!, height: 100),
                  const SizedBox(height: 8),
                  Text("Desenhe abaixo para substituir.", style: Theme.of(context).textTheme.bodySmall),
                  const Divider(),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[50],
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.transparent, // Handled by container
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('Salvar Assinatura'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final savedPath = await _saveSignature();
                if (savedPath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Assinatura salva em: $savedPath'), backgroundColor: Colors.green),
                  );
                  Navigator.of(context).pop(savedPath); // Return path to previous screen
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
