# Detalhamento da Implementação da UI para Resolução de Conflitos de Fotos

Este documento descreve como os widgets Flutter seriam construídos e como a interface do usuário (UI) interagiria com o `SyncProvider` para permitir que o usuário resolva os conflitos de fotos, com base no design da UI (Tarefa 10.2) e na lógica de backend (Tarefa 10.3). Todo o texto e exemplos de código estão em português do Brasil.

## 1. Widget Principal de Resolução de Conflitos (Tela)

Recomenda-se uma tela dedicada em vez de um diálogo simples, dado o potencial volume de informações e interações.

*   **Nome do Widget:** `PhotoConflictResolutionScreen`
*   **Estado:** Será um `StatefulWidget` para gerenciar:
    *   As seleções do usuário para cada conflito individual.
    *   O estado das opções de "Aplicar a todos".
*   **Recebimento de Dados:**
    *   `final List<PhotoConflict> conflicts;` (Recebida do `SyncProvider`)
    *   `final SyncNotifier syncNotifier;` (Referência ao `SyncProvider` para chamar métodos)

*   **Estrutura da UI (Conceitual):**
    ```dart
    // photo_conflict_resolution_screen.dart
    import 'package:flutter/material.dart';
    // import 'package:flutter_riverpod/flutter_riverpod.dart'; // Se estiver usando Riverpod
    // import '../providers/sync_provider.dart'; // Contém SyncNotifier, PhotoConflict, UserConflictResolutionOption
    // import '../models/photo_model.dart'; // Contém Photo
    // import 'package:googleapis/drive/v3.dart' as drive; // Para drive.File
    // import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Para i18n

    class PhotoConflictResolutionScreen extends StatefulWidget {
      final List<PhotoConflict> conflicts;
      final SyncNotifier syncNotifier; // Ou a interface/classe específica do seu provider

      const PhotoConflictResolutionScreen({
        Key? key,
        required this.conflicts,
        required this.syncNotifier,
      }) : super(key: key);

      @override
      _PhotoConflictResolutionScreenState createState() =>
          _PhotoConflictResolutionScreenState();
    }

    class _PhotoConflictResolutionScreenState extends State<PhotoConflictResolutionScreen> {
      // Mapa para guardar as escolhas do usuário para cada foto conflitante
      // Chave: ID da Photo local (localPhoto.id), Valor: UserConflictResolutionOption
      late Map<String, UserConflictResolutionOption> _userChoices;
      bool _isConfirmButtonEnabled = false;

      @override
      void initState() {
        super.initState();
        _userChoices = {
          for (var conflict in widget.conflicts)
            conflict.localPhoto.id!: UserConflictResolutionOption.undecided,
        };
        _checkIfConfirmButtonShouldBeEnabled();
      }

      void _checkIfConfirmButtonShouldBeEnabled() {
        final allDecided = _userChoices.values.every(
          (choice) => choice != UserConflictResolutionOption.undecided
        );
        if (allDecided != _isConfirmButtonEnabled) {
          setState(() {
            _isConfirmButtonEnabled = allDecided;
          });
        }
      }

      void _handleGlobalChoice(UserConflictResolutionOption globalResolution) {
        setState(() {
          for (var conflict in widget.conflicts) {
            _userChoices[conflict.localPhoto.id!] = globalResolution;
          }
          _checkIfConfirmButtonShouldBeEnabled();
        });
      }

      void _handleItemChoice(String localPhotoId, UserConflictResolutionOption choice) {
        setState(() {
          _userChoices[localPhotoId] = choice;
          _checkIfConfirmButtonShouldBeEnabled();
        });
      }

      @override
      Widget build(BuildContext context) {
        final localizations = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Text(localizations.resolvePhotoConflictsTitle),
            automaticallyImplyLeading: false, // Para controlar o "voltar" se necessário
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.resolvePhotoConflictsInstruction),
                SizedBox(height: 16),
                // Ações Globais
                Text(localizations.resolvePhotoConflictsGlobalActionsTitle, style: Theme.of(context).textTheme.titleMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => _handleGlobalChoice(UserConflictResolutionOption.overwriteRemote),
                      child: Text(localizations.resolvePhotoConflictsGlobalOverwriteAll),
                    ),
                    ElevatedButton(
                      onPressed: () => _handleGlobalChoice(UserConflictResolutionOption.keepRemote),
                      child: Text(localizations.resolvePhotoConflictsGlobalKeepAllRemote),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.conflicts.length,
                    itemBuilder: (context, index) {
                      final conflict = widget.conflicts[index];
                      return ConflictListItemWidget(
                        conflict: conflict,
                        currentResolution: _userChoices[conflict.localPhoto.id!]!,
                        onResolutionChanged: (choice) {
                          _handleItemChoice(conflict.localPhoto.id!, choice);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Ação de Cancelar: Notificar o provider e fechar a tela
                        widget.syncNotifier.cancelPhotoConflictResolution();
                        Navigator.of(context).pop();
                      },
                      child: Text(localizations.cancelButtonLabel),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isConfirmButtonEnabled ? () {
                        // Ação de Confirmar: Passar as resoluções para o provider e fechar
                        widget.syncNotifier.updateUserConflictResolutions(_userChoices);
                        widget.syncNotifier.processPhotoUploadsWithResolutions(
                           widget.conflicts.first.localPhoto.projectId!, // Supondo que todas as fotos são do mesmo projeto
                           "ID_DA_PASTA_DE_FOTOS_DO_PROJETO_NO_DRIVE" // Este ID precisa ser acessível
                        );
                        Navigator.of(context).pop();
                      } : null, // Desabilitar se nem todas as decisões foram tomadas
                      child: Text(localizations.confirmAndSyncButtonLabel),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    }
    ```

## 2. Widget do Item de Lista de Conflito (`ConflictListItemWidget`)

*   **Nome do Widget:** `ConflictListItemWidget`
*   **Estado:** Pode ser um `StatelessWidget` se a seleção for gerenciada pelo widget pai, ou `StatefulWidget` se gerenciar seu próprio estado de seleção antes de notificar o pai. No exemplo acima, o pai (`PhotoConflictResolutionScreen`) gerencia as escolhas.
*   **Recebimento de Dados:**
    *   `final PhotoConflict conflict;`
    *   `final UserConflictResolutionOption currentResolution;`
    *   `final ValueChanged<UserConflictResolutionOption> onResolutionChanged;`

*   **Estrutura da UI (Conceitual):**
    ```dart
    // conflict_list_item_widget.dart
    import 'package:flutter/material.dart';
    import 'dart:io'; // Para File
    // ... outros imports ...

    class ConflictListItemWidget extends StatelessWidget {
      final PhotoConflict conflict;
      final UserConflictResolutionOption currentResolution;
      final ValueChanged<UserConflictResolutionOption> onResolutionChanged;

      const ConflictListItemWidget({
        Key? key,
        required this.conflict,
        required this.currentResolution,
        required this.onResolutionChanged,
      }) : super(key: key);

      @override
      Widget build(BuildContext context) {
        final localizations = AppLocalizations.of(context)!; // Para i18n

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${localizations.fileNameLabel}: ${conflict.localPhoto.fileName}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna Foto Local
                    Expanded(
                      child: Column(
                        children: [
                          Text(localizations.resolvePhotoConflictsLocalPhotoTitle, style: Theme.of(context).textTheme.labelMedium),
                          SizedBox(height: 4),
                          _buildThumbnail(File(conflict.localPhoto.filePath!)), // Supondo filePath não nulo
                          // (Opcional) Text("Modificada em: ${conflict.localPhoto.modifiedDate}"),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    // Coluna Foto do Drive
                    Expanded(
                      child: Column(
                        children: [
                          Text(localizations.resolvePhotoConflictsDrivePhotoTitle, style: Theme.of(context).textTheme.labelMedium),
                          SizedBox(height: 4),
                          _buildDriveThumbnail(conflict.remoteFileMetadata),
                          // (Opcional) Text("Modificada em: ${conflict.remoteFileMetadata.modifiedTime}"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Opções de Resolução (Radio Buttons)
                Text(localizations.resolvePhotoConflictsResolutionOptionsTitle, style: Theme.of(context).textTheme.labelMedium),
                RadioListTile<UserConflictResolutionOption>(
                  title: Text(localizations.resolvePhotoConflictsOverwriteRemoteOption),
                  value: UserConflictResolutionOption.overwriteRemote,
                  groupValue: currentResolution,
                  onChanged: (value) => onResolutionChanged(value!),
                  dense: true,
                ),
                RadioListTile<UserConflictResolutionOption>(
                  title: Text(localizations.resolvePhotoConflictsKeepRemoteOption),
                  value: UserConflictResolutionOption.keepRemote,
                  groupValue: currentResolution,
                  onChanged: (value) => onResolutionChanged(value!),
                  dense: true,
                ),
              ],
            ),
          ),
        );
      }

      Widget _buildThumbnail(File imageFile) {
        // Carregar e exibir miniatura do arquivo local
        if (imageFile.existsSync()) {
          return Image.file(imageFile, width: 100, height: 100, fit: BoxFit.cover);
        }
        return Container(width: 100, height: 100, color: Colors.grey[300], child: Icon(Icons.broken_image));
      }

      Widget _buildDriveThumbnail(drive.File remoteFileMeta) {
        // Tentar carregar miniatura do Drive se webViewLink ou thumbnailLink estiver disponível
        // Caso contrário, um placeholder.
        // if (remoteFileMeta.thumbnailLink != null) {
        //   return Image.network(remoteFileMeta.thumbnailLink!, width: 100, height: 100, fit: BoxFit.cover);
        // }
        // if (remoteFileMeta.webViewLink != null) { // webViewLink não é a imagem direta
        //   // Poderia usar um WebView pequeno, mas é complexo para uma miniatura.
        // }
        return Container(
          width: 100,
          height: 100,
          color: Colors.blue[100],
          child: Icon(Icons.cloud_done_outlined, color: Colors.blue[700]), // Ícone do Drive
          // alignment: Alignment.center,
          // child: Text("Drive", style: TextStyle(color: Colors.blue[700])),
        );
      }
    }
    ```

## 3. Interação com o `SyncProvider`

*   **Observação do Estado:**
    O widget responsável por iniciar a sincronização (ex: `ProjectDetailsScreen`) deve observar o `SyncProvider`.
    ```dart
    // Exemplo em ProjectDetailsScreen usando Riverpod
    // Consumer(
    //   builder: (context, ref, child) {
    //     final syncState = ref.watch(syncNotifierProvider); // syncNotifierProvider é o StateNotifierProvider
    //     final syncNotifier = ref.read(syncNotifierProvider.notifier);

    //     // Escutar mudanças de estado para navegação
    //     ref.listen<SyncState>(syncNotifierProvider, (previous, next) {
    //       if (next.hasPhotoConflicts && !next.isCheckingPhotoConflicts) {
    //         // Evitar múltiplas navegações se o estado persistir
    //         if (ModalRoute.of(context)?.settings.name != '/photoConflictResolution') {
    //            WidgetsBinding.instance.addPostFrameCallback((_) { // Garante que build está completo
    //             Navigator.of(context).push(
    //               MaterialPageRoute(
    //                 settings: RouteSettings(name: '/photoConflictResolution'), // Para evitar push múltiplo
    //                 builder: (_) => PhotoConflictResolutionScreen(
    //                   conflicts: next.photoConflicts,
    //                   syncNotifier: syncNotifier,
    //                 ),
    //               ),
    //             );
    //           });
    //         }
    //       }
    //     });

    //     return ElevatedButton(
    //       onPressed: syncState.isSyncing
    //           ? null
    //           : () => syncNotifier.synchronizeProject(projectId, projectDriveFolderId, projectPhotosDriveFolderId),
    //       child: Text(syncState.isSyncing ? syncState.syncMessage : "Sincronizar Projeto"),
    //     );
    //   },
    // )
    ```

*   **Atualização das Resoluções no `SyncProvider`:**
    Conforme mostrado no `ElevatedButton` de "Confirmar e Sincronizar" do `PhotoConflictResolutionScreen`, os métodos do `syncNotifier` são chamados:
    1.  `widget.syncNotifier.updateUserConflictResolutions(_userChoices);`
    2.  `widget.syncNotifier.processPhotoUploadsWithResolutions(...);`

*   **Cancelamento:**
    O botão "Cancelar" no `PhotoConflictResolutionScreen` chama:
    `widget.syncNotifier.cancelPhotoConflictResolution();`
    O `SyncProvider` deve ter um método `cancelPhotoConflictResolution` que ajusta o estado interno (ex: limpa `hasPhotoConflicts`, `photoConflicts`, e talvez defina uma mensagem de "sincronização de fotos cancelada pelo usuário").

## 4. Gerenciamento de Estado Interno da UI de Conflitos

*   O `_PhotoConflictResolutionScreenState` mantém o mapa `_userChoices`.
*   Este mapa é inicializado com todas as resoluções como `UserConflictResolutionOption.undecided`.
*   Cada `ConflictListItemWidget` usa o `currentResolution` deste mapa para definir o estado de seus RadioButtons.
*   Quando um RadioButton é alterado, a callback `onResolutionChanged` atualiza o `_userChoices` no `_PhotoConflictResolutionScreenState` através do método `_handleItemChoice`.
*   As "Ações Globais" (`_handleGlobalChoice`) também modificam diretamente o mapa `_userChoices`.
*   O botão "Confirmar e Sincronizar" só é habilitado (`_isConfirmButtonEnabled`) quando todas as entradas em `_userChoices` são diferentes de `UserConflictResolutionOption.undecided`.

Este detalhamento fornece uma estrutura clara para construir a UI de resolução de conflitos de fotos, integrando-a com o `SyncProvider` para um fluxo de dados e ações coeso. A internacionalização (i18n) foi considerada com o uso de `AppLocalizations.of(context)!` para os textos da UI.
