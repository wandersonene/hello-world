import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file_plus/open_file_plus.dart';

import '../models/project_model.dart';
import '../models/inspection_module_model.dart';
import '../models/checklist_item_model.dart';
import '../models/photo_model.dart';
import 'database_service.dart';
import '../service_locator.dart'; // To access DatabaseService instance

class ReportService {
  final DatabaseService _dbService = sl<DatabaseService>();

  Future<String?> generateProjectReport(int projectId, {String? signatureImagePath}) async {
    final project = await _dbService.getProject(projectId);
    if (project == null) {
      throw Exception('Project not found');
    }

    final modules = await _dbService.getInspectionModulesForProject(projectId);

    // PDF/A Compliance: Initialize document with PDF/A version and XMP metadata
    final pdf = pw.Document(
      version: PdfVersion.pdf_1_7, // Common base for PDF/A (PDF/A-2 needs 1.7)
      deflate: zlibCall, // Recommended for PDF/A
      // producer: 'Field Engineer App v1.0', // Will be set in XMP
      // title: 'Relatório de Comissionamento - ${project.title}', // Will be set in XMP
      // author: 'Field Engineer App User', // Will be set in XMP
      // creator: 'Field Engineer App', // Will be set in XMP
      // keywords: 'comissionamento, relatório, ${project.projectType ?? ''}', // Will be set in XMP
    );

    // Load TTF fonts - these must be valid TTF files in assets/fonts/
    pw.Font notoRegular;
    pw.Font notoBold;
    try {
      final fontDataRegular = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      notoRegular = pw.Font.ttf(fontDataRegular);
      final fontDataBold = await rootBundle.load("assets/fonts/NotoSans-Bold.ttf");
      notoBold = pw.Font.ttf(fontDataBold);
    } catch (e) {
      print("Error loading Noto fonts: $e. Falling back to Helvetica.");
      // Fallback to Helvetica if Noto fonts fail (though this compromises full PDF/A char support)
      notoRegular = pw.Font.helvetica();
      notoBold = pw.Font.helveticaBold();
    }

    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: notoRegular,
      bold: notoBold,
      // icons: await PdfGoogleFonts.materialIcons(), // PDF/A typically disallows some icon fonts if not embedded properly
    );

    // PDF/A XMP Metadata
    pdf.document.catalog.xmpMetadata = pw.XmpMetadata(
      creatorTool: 'Field Engineer App v1.0.0',
      createDate: DateTime.now().toUtc(),
      modifyDate: DateTime.now().toUtc(),
      keywords: 'comissionamento, inspeção, relatório, ${project.projectType ?? ''}, ${project.title}',
      title: 'Relatório de Comissionamento: ${project.title}',
      dc: pw.XmpDublinCore(
        title: 'Relatório de Comissionamento: ${project.title}',
        creator: 'Field Engineer App', // Application Name
        subject: 'Relatório de inspeção e comissionamento do projeto ${project.title}',
        description: 'Este documento contém os detalhes das inspeções realizadas para o projeto ${project.title}, cliente ${project.client ?? "N/A"}.',
        date: [DateTime.now().toUtc()],
        format: 'application/pdf',
        language: 'pt-BR', // Example language
      ),
      pdfaSchema: pw.XmpPdfASchema(
        part: 2, // PDF/A-2
        conformance: 'B', // Level B conformance (Basic)
        // For PDF/A-1b: part: 1, conformance: 'B'
      ),
    );

    // PDF/A OutputIntent (sRGB) - This is a simplified placeholder.
    // True ICC profile embedding is more complex with the `pdf` package.
    // The package generally works in sRGB by default for PdfColor.
    // pdf.document.catalog.outputIntents = [
    //   pw.PdfOutputIntent(
    //     subtype: '/GTS_PDFA1', // Or other appropriate subtype for PDF/A-2
    //     outputConditionIdentifier: 'sRGB IEC61966-2.1',
    //     info: 'sRGB IEC61966-2.1',
    //     // destOutputProfile: PdfStream(pdf.document, iccProfileData), // Requires actual ICC profile bytes
    //   )
    // ];


    // Load signature image if path is provided
    pw.ImageProvider? signatureImageProvider;
    if (signatureImagePath != null) {
      try {
        final signatureFile = File(signatureImagePath);
        if (await signatureFile.exists()) {
          signatureImageProvider = pw.MemoryImage(signatureFile.readAsBytesSync());
        }
      } catch (e) {
        print("Error loading signature image for PDF: $e");
      }
    }


    // Page 1: Project Header & Summary
    // final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    // final ttf = pw.Font.ttf(fontData);
    // final boldFontData = await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");
    // final boldTtf = pw.Font.ttf(boldFontData);

    // Using default font (Helvetica) as it's built-in and avoids asset issues for now.
    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return _buildHeader(project.title, theme);
        },
        footer: _buildFooter,
        build: (pw.Context context) => [
          _buildProjectHeader(project, theme),
          pw.SizedBox(height: 20),
          _buildModulesSummary(modules, theme),
          pw.SizedBox(height: 10),
          pw.Text('Detalhes das Inspeções:', style: pw.TextStyle(font: theme.bold, fontSize: 14)),
        ],
      ),
    );

    // Subsequent content: Inspection Details
    // Pre-fetch all checklist items and their photos
    Map<int, List<ChecklistItem>> moduleChecklistItems = {};
    Map<int, List<pw.ImageProvider?>> itemImageProviders = {}; // Store pw.ImageProvider or null
    Map<int, List<Photo>> itemPhotoObjects = {}; // Store Photo objects for captions

    for (final module in modules) {
      if (module.id == null) continue;
      final items = await _dbService.getChecklistItemsForModule(module.id!);
      moduleChecklistItems[module.id!] = items;
      for (final item in items) {
        if (item.id == null) continue;
        final photos = await _dbService.getPhotosForChecklistItem(item.id!);
        itemPhotoObjects[item.id!] = photos; // Store Photo objects
        List<pw.ImageProvider?> currentItemImageProviders = [];
        for (final photo in photos) {
          try {
            final file = File(photo.filePath);
            if (await file.exists()) {
              currentItemImageProviders.add(pw.MemoryImage(file.readAsBytesSync()));
            } else {
              currentItemImageProviders.add(null); // Placeholder for missing image
            }
          } catch (e) {
            print("Error loading image for PDF: ${photo.filePath}, Error: $e");
            currentItemImageProviders.add(null); // Placeholder on error
          }
        }
        itemImageProviders[item.id!] = currentItemImageProviders;
      }
    }

    for (final module in modules) {
      if (module.id == null) continue;
      final itemsForCurrentModule = moduleChecklistItems[module.id!] ?? [];

      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          header: (pw.Context context) {
            return _buildHeader('${project.title} - ${module.name}', theme);
          },
          footer: _buildFooter,
          build: (pw.Context context) => [
            _buildModuleDetailSection(module, itemsForCurrentModule, itemImageProviders, itemPhotoObjects, theme),
          ],
        ),
      );
    }

    // Add Signature Page/Section if signature is provided
    if (signatureImageProvider != null) {
      pdf.addPage(
        pw.Page(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Assinatura do Responsável', style: pw.TextStyle(font: theme.bold, fontSize: 18)),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: 200, // Adjust size as needed
                  height: 100,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                  child: pw.Image(signatureImageProvider, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Assinado em: ${DateTime.now().toLocal().toString().substring(0,16)}', style: pw.TextStyle(font: theme.base, fontSize: 10)),
                // You might want to add a line for the printed name of the signer if available
              ]
            );
          }
        )
      );
    }


    // Save the PDF
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String reportDir = '${appDocDir.path}/project_reports/${project.id}';
    await Directory(reportDir).create(recursive: true);

    final String safeProjectTitle = project.title.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
    final String fileName = 'Relatorio_${safeProjectTitle}_${DateTime.now().toIso8601String().split('T').first}.pdf';
    final String filePath = '$reportDir/$fileName';

    final File file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  pw.Widget _buildHeader(String title, pw.ThemeData theme) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      margin: const pw.EdgeInsets.only(bottom: 10.0),
      padding: const pw.EdgeInsets.only(bottom: 5.0),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
      ),
      child: pw.Text(title, style: pw.TextStyle(font: theme.bold, fontSize: 16)),
    );
  }

  pw.Widget _buildFooter(pw.Context context) { // Theme is implicitly available via context
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10.0),
      padding: const pw.EdgeInsets.only(top: 5.0),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
      ),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
      ),
    );
  }

  pw.Widget _buildProjectHeader(Project project, pw.ThemeData theme) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Relatório do Projeto', style: pw.TextStyle(font: theme.bold, fontSize: 20)),
        pw.SizedBox(height: 10),
        _buildInfoRow('Título do Projeto:', project.title, theme),
        _buildInfoRow('Cliente:', project.client ?? 'N/A', theme),
        _buildInfoRow('Tipo de Projeto:', project.projectType ?? 'N/A', theme),
        _buildInfoRow('Data de Geração:', DateTime.now().toLocal().toString().split(' ')[0], theme),
        _buildInfoRow('Status do Projeto:', project.status, theme),
      ],
    );
  }

  pw.Widget _buildModulesSummary(List<InspectionModule> modules, pw.ThemeData theme) {
    if (modules.isEmpty) {
      return pw.Text('Nenhum módulo de inspeção encontrado para este projeto.', style: pw.TextStyle(font: theme.base, fontStyle: pw.FontStyle.italic));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Resumo dos Módulos de Inspeção:', style: pw.TextStyle(font: theme.bold, fontSize: 14)),
        pw.SizedBox(height: 5),
        pw.Table.fromTextArray(
          headers: ['Nome do Módulo', 'Status'],
          data: modules.map((module) => [module.name, module.status]).toList(),
          headerStyle: pw.TextStyle(font: theme.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellStyle: pw.TextStyle(font: theme.base),
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
        ),
      ],
    );
  }

  pw.Widget _buildModuleDetailSection(
    InspectionModule module,
    List<ChecklistItem> items,
    Map<int, List<pw.ImageProvider?>> itemImageProviders, // Changed name
    Map<int, List<Photo>> itemPhotoObjects, // Added to pass Photo objects for captions
    pw.ThemeData theme,
  ) {
     return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Status do Módulo:', module.status, theme),
        pw.SizedBox(height: 10),
        if (items.isEmpty)
            pw.Text('Nenhum item de checklist para este módulo.', style: pw.TextStyle(font: theme.base, fontStyle: pw.FontStyle.italic))
        else
            ...items.map((item) {
                final imageProviders = item.id != null ? itemImageProviders[item.id!] : null;
                final photoObjects = item.id != null ? itemPhotoObjects[item.id!] : null;
                return _buildChecklistItemDetail(item, imageProviders, photoObjects, theme);
            }).expand((widgets) => widgets),
      ],
    );
  }

  List<pw.Widget> _buildChecklistItemDetail(
    ChecklistItem item,
    List<pw.ImageProvider?>? imageProviders, // Changed name
    List<Photo>? photoObjects, // Added
    pw.ThemeData theme,
  ) {
    List<pw.Widget> widgets = [
      pw.SizedBox(height: 8),
      pw.Text(
        '${item.order}. ${item.description}',
        style: pw.TextStyle(font: theme.bold),
      ),
      _buildInfoRow('Resposta:', _formatChecklistItemResponse(item), theme),
      if (item.notes != null && item.notes!.isNotEmpty)
        _buildInfoRow('Notas:', item.notes!, theme),
      pw.SizedBox(height: 4),
    ];

    if (imageProviders != null && imageProviders.isNotEmpty) {
      widgets.add(pw.Text('Fotos:', style: pw.TextStyle(font: theme.bold, fontSize: 11)));
      widgets.add(pw.SizedBox(height: 4));

      List<pw.Widget> photoWidgets = [];
      for (int i = 0; i < imageProviders.length; i++) {
        final imgProvider = imageProviders[i];
        final photoCaption = (photoObjects != null && i < photoObjects.length && photoObjects[i].caption != null && photoObjects[i].caption!.isNotEmpty)
                             ? photoObjects[i].caption
                             : null;

        if (imgProvider != null) {
          photoWidgets.add(
            pw.Column( // Column to hold image and caption
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 120, // Adjust size as needed
                  height: 120,
                  child: pw.Image(imgProvider, fit: pw.BoxFit.contain),
                  decoration: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                if (photoCaption != null)
                  pw.Container(
                    width: 120,
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: pw.Text(photoCaption, style: pw.TextStyle(font: theme.base, fontSize: 8, color: PdfColors.grey700)),
                  ),
                pw.SizedBox(height: 5), // Spacing between photos
              ]
            )
          );
        } else {
          photoWidgets.add(
            pw.Container(
              width: 120, height: 120,
              child: pw.Center(child: pw.Text('Foto não encontrada', style: pw.TextStyle(font: theme.base, fontSize: 9, color: PdfColors.grey))),
              decoration: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            )
          );
        }
      }
      widgets.add(pw.Wrap(spacing: 5, runSpacing: 5, children: photoWidgets));
      widgets.add(pw.SizedBox(height: 6));
    } else {
       widgets.add(pw.Text('Fotos: Nenhuma foto para este item.', style: pw.TextStyle(font: theme.base, fontStyle: pw.FontStyle.italic, color: PdfColors.grey)));
    }

    widgets.add(pw.Divider(height: 10, thickness: 0.5, color: PdfColors.grey400));

    return widgets;
  }


  String _formatChecklistItemResponse(ChecklistItem item) { // Theme not needed here, it's just string formatting
    switch (item.itemType) {
      case ChecklistItemType.okNotConform:
        if (item.responseOkNotConform == true) return 'OK';
        if (item.responseOkNotConform == false) return 'Não Conforme';
        return 'Não respondido';
      case ChecklistItemType.text:
        return item.responseText ?? 'Não respondido';
      case ChecklistItemType.number:
        return item.responseNumber?.toString() ?? 'Não respondido';
      case ChecklistItemType.photoReference:
        return 'Ver fotos associadas';
      default:
        return 'Tipo de item desconhecido';
    }
  }

  pw.Widget _buildInfoRow(String label, String value, pw.ThemeData theme) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120, // Adjust width as needed
            child: pw.Text(label, style: pw.TextStyle(font: theme.bold)),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: theme.base))),
        ],
      ),
    );
  }

  // Helper to open the PDF
  Future<void> openPdf(String filePath) async {
    final OpenResult result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print('Error opening file: ${result.message}');
      // Consider showing a message to the user
      throw Exception('Could not open PDF file: ${result.message}');
    }
  }
}

// Helper for Google Fonts in PDF (requires internet during PDF generation if not cached)
// For offline, you must bundle TTF fonts.
// For now, this class is not used as we default to Helvetica.
// class PdfGoogleFonts {
//   static Future<pw.Font> openSansRegular() async {
//     final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
//     return pw.Font.ttf(fontData);
//   }

//   static Future<pw.Font> openSansBold() async {
//     final fontData = await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");
//     return pw.Font.ttf(fontData);
//   }

//   static Future<pw.Font> materialIcons() async {
//     // This is a placeholder. The material icons font isn't typically used directly for text.
//     // If you need icons, you might use specific icon fonts or SVG.
//     // For now, returning OpenSansRegular as a fallback.
//     // final fontData = await rootBundle.load("assets/fonts/MaterialIcons-Regular.ttf");
//     // return pw.Font.ttf(fontData);
//     return openSansRegular(); // Fallback
//   }
// }
