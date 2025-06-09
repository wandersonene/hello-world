# Detalhamento da Implementação da Lógica de Detecção e Coleta de Conflitos de Fotos

Este documento descreve as alterações de código propostas para os serviços do aplicativo móvel (`DriveService`, `PhotoService`/armazenamento local, e `SyncProvider`) a fim de implementar a lógica de backend para a detecção e coleta de conflitos de fotos, conforme a estratégia de MD5 Checksum e o design de UI definidos anteriormente.

## 1. Modificações no `DriveService` (ou serviço de interação com Google Drive)

O `DriveService` será responsável por interagir com a API do Google Drive para buscar metadados de arquivos.

### a) Método para Obter Metadados de Arquivos em Lote: `getRemoteFileMetadataInFolder`

*   **Objetivo:**
    Obter metadados essenciais (ID, nome, MD5 checksum, data de modificação, link de visualização) de todos os arquivos de uma pasta específica no Google Drive (ex: a subpasta "Fotos" de um determinado projeto). Isso deve ser feito com o mínimo de chamadas de API.

*   **Assinatura do Método (Dart):**
    ```dart
    // Em driveservice.dart
    import 'package:googleapis/drive/v3.dart' as drive;

    class DriveService {
      // ... outras partes do serviço ...

      /// Busca os metadados de todos os arquivos dentro de uma pasta específica no Google Drive.
      ///
      /// Retorna uma lista de objetos [drive.File] contendo os metadados solicitados.
      /// Lança uma exceção em caso de erro na API.
      Future<List<drive.File>> getRemoteFileMetadataInFolder(String folderId) async {
        try {
          final driveApi = await _getDriveApi(); // Método auxiliar para obter o cliente autenticado
          List<drive.File> allFiles = [];
          String? nextPageToken;

          do {
            final result = await driveApi.files.list(
              q: "'$folderId' in parents and trashed = false",
              fields: "nextPageToken, files(id, name, md5Checksum, modifiedTime, webViewLink, size)", // 'size' também é útil
              pageToken: nextPageToken,
              // pageSize: 100, // Opcional: controlar o tamanho da página
            );

            if (result.files != null) {
              allFiles.addAll(result.files!);
            }
            nextPageToken = result.nextPageToken;
          } while (nextPageToken != null);

          return allFiles;
        } catch (e) {
          // Tratar erro, logar, e possivelmente relançar uma exceção customizada
          print('Erro ao buscar metadados de arquivos no Drive: $e');
          throw Exception('Falha ao comunicar com o Google Drive.');
        }
      }

      // ... _getDriveApi() e outros métodos ...
    }
    ```

### b) (Opcional) Método para Obter Metadados de um Único Arquivo: `getRemoteFileMetadata`

Embora a listagem em lote seja preferível, um método para buscar um arquivo específico pode ser útil para cenários de fallback ou verificações pontuais.

*   **Assinatura do Método (Dart):**
    ```dart
    // Em driveservice.dart (continuação)

    /// Busca os metadados de um arquivo específico pelo seu nome dentro de uma pasta.
    /// Retorna [null] se o arquivo não for encontrado.
    Future<drive.File?> getRemoteFileMetadataByName(String fileName, String folderId) async {
      try {
        final driveApi = await _getDriveApi();
        final result = await driveApi.files.list(
          q: "name = '$fileName' and '$folderId' in parents and trashed = false",
          fields: "files(id, name, md5Checksum, modifiedTime, webViewLink, size)",
          pageSize: 1, // Esperamos no máximo 1 arquivo com esse nome na pasta
        );
        if (result.files != null && result.files!.isNotEmpty) {
          return result.files!.first;
        }
        return null;
      } catch (e) {
        print('Erro ao buscar metadado de arquivo específico no Drive: $e');
        throw Exception('Falha ao buscar arquivo específico no Google Drive.');
      }
    }

    /// Busca os metadados de um arquivo específico pelo seu ID do Drive.
    Future<drive.File?> getRemoteFileById(String fileId) async {
      try {
        final driveApi = await _getDriveApi();
        final file = await driveApi.files.get(
          fileId,
          $fields: "id, name, md5Checksum, modifiedTime, webViewLink, size",
        ) as drive.File?; // Cast necessário pois $fields pode retornar um tipo diferente
        return file;
      } catch (e) {
        print('Erro ao buscar metadado de arquivo por ID no Drive: $e');
        throw Exception('Falha ao buscar arquivo por ID no Google Drive.');
      }
    }
    ```

## 2. Modificações no `PhotoService` ou Lógica de Armazenamento Local

Estas modificações garantem que o MD5 checksum de cada foto local seja calculado e armazenado.

### a) Cálculo de MD5 ao Salvar/Modificar Foto

*   **Objetivo:** Calcular o hash MD5 de um arquivo de foto local.
*   **Implementação Conceitual (Dart):**
    *   Utilizar o pacote `crypto` e `convert`. Adicionar ao `pubspec.yaml`:
        ```yaml
        dependencies:
          flutter:
            sdk: flutter
          crypto: ^3.0.0 # Verificar a versão mais recente
          convert: ^3.0.0 # Verificar a versão mais recente
        ```
    *   Criar uma função utilitária ou método dentro de um `PhotoService` (ou similar).
        ```dart
        // Em um arquivo de utilitários ou photo_service.dart
        import 'dart:io';
        import 'package:crypto/crypto.dart' as crypto; // Renomeado para evitar conflito com 'drive.File'
        import 'package:convert/convert.dart';

        Future<String> calculateFileMd5(File file) async {
          try {
            final stream = file.openRead();
            final hash = await crypto.md5.bind(stream).first;
            return hex.encode(hash.bytes);
          } catch (e) {
            print("Erro ao calcular MD5 do arquivo ${file.path}: $e");
            // Retornar um valor padrão ou relançar, dependendo da política de erro
            // Para este caso, é crucial que o MD5 seja calculado.
            throw Exception("Não foi possível calcular o MD5 do arquivo: ${file.path}");
          }
        }
        ```
    *   **Integração:** Esta função `calculateFileMd5` deve ser chamada sempre que uma nova foto for adicionada ao sistema (seja pela câmera ou galeria) e antes de ser salva no banco de dados local. Se houver uma funcionalidade de "modificar foto" que substitua o arquivo, o MD5 deve ser recalculado.

### b) Armazenamento do MD5 Local

*   **Modelo `Photo` (`photo_model.dart`):**
    Adicionar um novo campo para armazenar o MD5 checksum calculado localmente.
    ```dart
    class Photo {
      // ... outros campos: id, projectId, itemId, filePath, fileName, legend, etc. ...
      String? localMd5Checksum; // Novo campo
      DateTime? localMd5CalculatedAt; // Opcional: para saber quando foi calculado

      Photo({
        // ... outros parâmetros ...
        this.localMd5Checksum,
        this.localMd5CalculatedAt,
      });

      // ... fromMap, toMap methods ...
      Map<String, dynamic> toMap() {
        var map = {
          // ... outros campos ...
          'localMd5Checksum': localMd5Checksum,
          'localMd5CalculatedAt': localMd5CalculatedAt?.toIso8601String(),
        };
        // ... remover nulos se necessário ...
        return map;
      }

      factory Photo.fromMap(Map<String, dynamic> map) {
        return Photo(
          // ... outros campos ...
          localMd5Checksum: map['localMd5Checksum'],
          localMd5CalculatedAt: map['localMd5CalculatedAt'] != null
              ? DateTime.parse(map['localMd5CalculatedAt'])
              : null,
        );
      }
    }
    ```
*   **`DatabaseService` (ou serviço de banco de dados local):**
    *   A tabela `photos` no SQLite (ou outro DB) precisa ser atualizada para incluir a coluna `localMd5Checksum TEXT` e opcionalmente `localMd5CalculatedAt TEXT`.
    *   Os métodos de `insertPhoto` e `updatePhoto` devem ser ajustados para salvar e ler este novo campo.

## 3. Modificações no `SyncProvider` (ou serviço que orquestra a sincronização)

O `SyncProvider` (usando Riverpod, Provider, BLoC, etc.) gerenciará o estado e a lógica da sincronização, incluindo a detecção e resolução de conflitos.

### a) Novos Modelos/Enums e Estados para Conflitos

*   **`PhotoConflict` (Modelo):**
    Representa um conflito identificado entre uma foto local e uma remota.
    ```dart
    // Pode ser definido em sync_provider.dart ou em um arquivo de modelos de sincronização
    import 'package:googleapis/drive/v3.dart' as drive; // Para drive.File
    // import 'photo_model.dart'; // Para Photo

    class PhotoConflict {
      final Photo localPhoto;
      final drive.File remoteFileMetadata; // Metadados do arquivo conflitante no Drive

      PhotoConflict({
        required this.localPhoto,
        required this.remoteFileMetadata,
      });
    }
    ```

*   **`UserConflictResolutionOption` (Enum):**
    Define as possíveis escolhas do usuário para resolver um conflito.
    ```dart
    enum UserConflictResolutionOption {
      undecided,       // Ainda não decidido (estado inicial)
      overwriteRemote, // Usar foto local, sobrescrever no Drive
      keepRemote,      // Manter foto do Drive, não enviar local
    }
    ```

*   **Estados no `SyncProvider` (Exemplo com Riverpod `StateNotifier`):**
    ```dart
    // Em sync_provider.dart
    // import 'package:flutter_riverpod/flutter_riverpod.dart'; // Exemplo

    class SyncState {
      final bool正在同步; // isSyncing
      final bool isCheckingPhotoConflicts;
      final bool hasPhotoConflicts;
      final List<PhotoConflict> photoConflicts;
      // Mapa para guardar a resolução de cada foto local (usando o ID da foto local como chave)
      final Map<String, UserConflictResolutionOption> conflictResolutions;
      final String? syncMessage;
      final double syncProgress;

      SyncState({
        this.isSyncing = false,
        this.isCheckingPhotoConflicts = false,
        this.hasPhotoConflicts = false,
        this.photoConflicts = const [],
        this.conflictResolutions = const {},
        this.syncMessage = '',
        this.syncProgress = 0.0,
      });

      SyncState copyWith({ /* ... params ... */ }) {
        return SyncState( /* ... new values ... */ );
      }
    }

    class SyncNotifier extends StateNotifier<SyncState> {
      SyncNotifier(this.ref) : super(SyncState());

      final Ref ref; // Para ler outros providers/serviços

      // ... outros métodos ...
    }
    ```

### b) Lógica de Detecção e Coleta de Conflitos

Integrada no método principal de sincronização do projeto (ex: `synchronizeProjectPhotos`).

*   **Fluxo Conceitual:**
    ```dart
    // Em SyncNotifier (ou serviço de sincronização)

    Future<void> synchronizeProjectPhotos(String projectId, String projectDriveFolderId, String projectPhotosDriveFolderId) async {
      state = state.copyWith(isSyncing: true, isCheckingPhotoConflicts: true, syncMessage: "Verificando fotos...");

      final photoRepo = ref.read(photoRepositoryProvider); // Exemplo de acesso a dados locais
      final driveService = ref.read(driveServiceProvider); // Exemplo de acesso ao DriveService

      List<Photo> localPhotosToSync = await photoRepo.getPhotosForProject(projectId, status: PhotoSyncStatus.pending); // Fotos pendentes
      List<PhotoConflict> detectedConflicts = [];
      Map<String, UserConflictResolutionOption> initialResolutions = {};

      if (localPhotosToSync.isEmpty) {
        state = state.copyWith(isCheckingPhotoConflicts: false, syncMessage: "Nenhuma foto nova para sincronizar.");
        // Prossiga para outras etapas de sincronização do projeto, se houver
        // state = state.copyWith(isSyncing: false); // Se for a última etapa
        return;
      }

      try {
        List<drive.File> remotePhotosMeta = await driveService.getRemoteFileMetadataInFolder(projectPhotosDriveFolderId);
        Map<String, drive.File> remotePhotosMap = { for (var f in remotePhotosMeta) f.name!: f }; // Mapear por nome para busca fácil

        for (Photo localPhoto in localPhotosToSync) {
          if (localPhoto.localMd5Checksum == null) {
            // Idealmente, o MD5 já foi calculado. Se não, calcular agora (pode impactar performance).
            // Este é um fallback, o MD5 deve ser calculado ao salvar a foto.
            File photoFile = File(localPhoto.filePath); // Supondo que filePath é o caminho completo
            localPhoto.localMd5Checksum = await calculateFileMd5(photoFile); // A função definida anteriormente
            await photoRepo.updatePhoto(localPhoto); // Salvar o MD5 calculado
          }

          drive.File? remotePhotoMeta = remotePhotosMap[localPhoto.fileName];

          if (remotePhotoMeta == null) {
            // Foto é nova no Drive, marcar para upload direto (nenhum conflito)
            initialResolutions[localPhoto.id!] = UserConflictResolutionOption.overwriteRemote; // Upload direto
          } else {
            // Arquivo com mesmo nome existe no Drive, verificar MD5
            if (localPhoto.localMd5Checksum == remotePhotoMeta.md5Checksum) {
              // Hashes MD5 são iguais, arquivos idênticos.
              // Marcar como sincronizado, sem necessidade de upload.
              initialResolutions[localPhoto.id!] = UserConflictResolutionOption.keepRemote; // Ou uma opção 'skipUpload'
              await photoRepo.updatePhotoStatus(localPhoto.id!, PhotoSyncStatus.synced, driveFileId: remotePhotoMeta.id);
            } else {
              // Hashes MD5 diferentes -> CONFLITO!
              detectedConflicts.add(PhotoConflict(localPhoto: localPhoto, remoteFileMetadata: remotePhotoMeta));
              initialResolutions[localPhoto.id!] = UserConflictResolutionOption.undecided; // Usuário precisa decidir
            }
          }
        }

        if (detectedConflicts.isNotEmpty) {
          state = state.copyWith(
            isCheckingPhotoConflicts: false,
            hasPhotoConflicts: true,
            photoConflicts: detectedConflicts,
            conflictResolutions: initialResolutions, // Preenche com 'undecided' para os conflitos
            syncMessage: "Conflitos de fotos detectados. Ação do usuário necessária.",
          );
          // A UI irá observar 'hasPhotoConflicts' e mostrar a tela de resolução.
          // A sincronização de fotos pausa aqui até o usuário resolver.
          return; // Interrompe o fluxo de sincronização de fotos até a resolução
        } else {
          // Nenhum conflito, todas as fotos novas ou já sincronizadas (MD5 igual)
          state = state.copyWith(
            isCheckingPhotoConflicts: false,
            hasPhotoConflicts: false,
            conflictResolutions: initialResolutions, // Contém decisões para upload direto ou skip
            syncMessage: "Nenhum conflito de fotos. Preparando uploads...",
          );
          await processPhotoUploadsWithResolutions(projectId, projectPhotosDriveFolderId); // Chamar diretamente se não houver conflitos
        }

      } catch (e) {
        state = state.copyWith(isCheckingPhotoConflicts: false, syncMessage: "Erro ao verificar conflitos de fotos: $e", isSyncing: false);
      }
    }
    ```

### c) Processamento Pós-Resolução

Este método é chamado após o usuário interagir com a UI de resolução de conflitos e definir as `conflictResolutions`.

*   **Fluxo Conceitual:**
    ```dart
    // Em SyncNotifier

    /// Chamado pela UI após o usuário confirmar as resoluções de conflito.
    void updateUserConflictResolutions(Map<String, UserConflictResolutionOption> resolutions) {
      // Atualiza o estado apenas com as novas resoluções
      // A UI deve garantir que todas as 'undecided' foram resolvidas antes de chamar.
      state = state.copyWith(
          conflictResolutions: Map.from(state.conflictResolutions)..addAll(resolutions),
          hasPhotoConflicts: false, // Assume que os conflitos foram resolvidos para prosseguir
          photoConflicts: [] // Limpa a lista de conflitos da UI
      );
    }

    Future<void> processPhotoUploadsWithResolutions(String projectId, String projectPhotosDriveFolderId) async {
      state = state.copyWith(isSyncing: true, syncMessage: "Processando sincronização de fotos...");

      final photoRepo = ref.read(photoRepositoryProvider);
      final driveService = ref.read(driveServiceProvider); // Usado para fazer upload

      List<Photo> photos = await photoRepo.getPhotosForProject(projectId); // Obter todas as fotos do projeto

      for (Photo localPhoto in photos) {
        UserConflictResolutionOption resolution = state.conflictResolutions[localPhoto.id!] ?? UserConflictResolutionOption.keepRemote; // Default seguro

        if (resolution == UserConflictResolutionOption.overwriteRemote) {
          try {
            state = state.copyWith(syncMessage: "Enviando foto: ${localPhoto.fileName}...");
            File photoFile = File(localPhoto.filePath);
            // Lógica de upload para o DriveService, pode precisar do ID da pasta de fotos do projeto.
            // Ex: await driveService.uploadPhoto(photoFile, projectPhotosDriveFolderId, localPhoto.fileName);
            // Após upload bem-sucedido:
            await photoRepo.updatePhotoStatus(localPhoto.id!, PhotoSyncStatus.synced, driveFileId: "ID_RETORNADO_PELO_DRIVE");
          } catch (e) {
            // Tratar erro de upload específico para esta foto
            await photoRepo.updatePhotoStatus(localPhoto.id!, PhotoSyncStatus.error, errorMessage: e.toString());
            state = state.copyWith(syncMessage: "Erro ao enviar foto: ${localPhoto.fileName}.");
          }
        } else if (resolution == UserConflictResolutionOption.keepRemote) {
          // Se a foto já não estava marcada como sincronizada (ex: MD5 igual), marcar agora.
          if (localPhoto.status != PhotoSyncStatus.synced) { // 'status' é um enum PhotoSyncStatus
             // Se o arquivo remoto já existe (MD5 igual ou usuário escolheu manter), precisamos do ID do Drive.
             // O ID do Drive já deveria ter sido obtido durante a fase de detecção se MD5 era igual.
             // Se o usuário escolheu 'keepRemote' para um conflito, o ID do drive.File estava em PhotoConflict.
             // Esta lógica precisa ser refinada para garantir que o driveFileId seja corretamente associado.
             await photoRepo.updatePhotoStatus(localPhoto.id!, PhotoSyncStatus.synced, driveFileId: localPhoto.driveFileId /* ou de PhotoConflict */);
          }
        }
        // 'undecided' não deveria chegar aqui se a UI forçar resolução.
      }

      state = state.copyWith(isSyncing: false, syncMessage: "Sincronização de fotos concluída.");
      // Chamar a próxima etapa da sincronização geral do projeto, se houver.
    }
    ```

## 4. Fluxo de Sincronização de Fotos Modificado

1.  **Início da Sincronização de Fotos:**
    *   O `SyncProvider` define `isCheckingPhotoConflicts = true`.
2.  **Busca de Metadados:**
    *   O `DriveService.getRemoteFileMetadataInFolder()` é chamado para obter a lista de arquivos de fotos e seus metadados (incluindo MD5) da pasta do projeto no Google Drive.
3.  **Comparação Local:**
    *   Para cada foto local pendente:
        *   O MD5 local (idealmente já calculado e armazenado) é comparado com o MD5 dos arquivos remotos com mesmo nome.
        *   Se não há arquivo remoto com mesmo nome, a foto é marcada para upload direto.
        *   Se há arquivo com mesmo nome e MD5s diferentes, um `PhotoConflict` é criado e adicionado a uma lista.
        *   Se há arquivo com mesmo nome e MD5s iguais, a foto local é marcada como já sincronizada (nenhum upload necessário).
4.  **Verificação de Conflitos:**
    *   Se a lista de `PhotoConflict` estiver vazia:
        *   O `SyncProvider` prossegue para `processPhotoUploadsWithResolutions()` com as decisões já tomadas (upload direto ou skip).
    *   Se houver conflitos:
        *   O `SyncProvider` atualiza seu estado: `hasPhotoConflicts = true`, `photoConflicts` (lista preenchida).
        *   A UI reage a esse estado e exibe a tela de resolução de conflitos.
        *   A sincronização de fotos aguarda a intervenção do usuário.
5.  **Resolução pelo Usuário (UI):**
    *   O usuário interage com a tela de resolução, fazendo suas escolhas para cada conflito.
    *   Ao confirmar, a UI chama um método no `SyncProvider` (ex: `updateUserConflictResolutions()`) passando as resoluções.
    *   Em seguida, a UI dispara `processPhotoUploadsWithResolutions()`.
6.  **Processamento Final:**
    *   O `SyncProvider`, agora com as resoluções definidas pelo usuário, itera sobre as fotos:
        *   Faz upload das fotos marcadas para "overwriteRemote".
        *   Pula o upload das fotos marcadas para "keepRemote" (e atualiza o status local para sincronizado).
    *   Atualiza o status de sincronização de cada foto no banco de dados local.
7.  **Conclusão:**
    *   O `SyncProvider` finaliza o processo de sincronização de fotos e pode prosseguir para outras etapas da sincronização geral do projeto.

Este detalhamento fornece uma base sólida para a implementação da lógica de detecção e resolução de conflitos de fotos, focando na integridade dos dados e na experiência do usuário.
