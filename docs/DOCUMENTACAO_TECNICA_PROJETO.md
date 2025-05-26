# Documentação Técnica - Aplicativo de Comissionamento a Frio

## 1. Introdução

### 1.1. Objetivo do Documento

Este documento tem como objetivo descrever a arquitetura técnica, os componentes principais, as tecnologias utilizadas, a estrutura de dados e os fluxos de informação do projeto "Aplicativo de Comissionamento a Frio". Ele serve como um guia para desenvolvedores e mantenedores do sistema.

### 1.2. Propósito do Aplicativo

O Aplicativo de Comissionamento a Frio é uma solução multiplataforma (móvel e web) desenvolvida para auxiliar engenheiros de campo na realização de inspeções de comissionamento. Ele permite a coleta de dados em campo (inclusive offline no aplicativo móvel), captura de fotos, associação de normas, geração de relatórios técnicos em PDF/A com assinatura digital e sincronização desses dados com o Google Drive. A Área Administrativa Web permite a visualização dos projetos e relatórios sincronizados.

## 2. Arquitetura Geral

### 2.1. Componentes Principais

O sistema é composto por três componentes principais:

*   **Aplicativo Móvel Flutter (Android, iOS):**
    *   **Responsabilidades:** Destinado aos engenheiros de campo. Permite o cadastro e login local de usuários, criação e gerenciamento de projetos de comissionamento, preenchimento de checklists de inspeção (com diferentes tipos de resposta), captura e associação de fotos técnicas com geolocalização e legendas, associação de normas ABNT, coleta de assinatura digital para os relatórios, geração local de relatórios de inspeção em formato PDF/A e sincronização manual dos dados do projeto (relatório e fotos) com o Google Drive. Funciona offline para a maioria das operações de coleta de dados, com armazenamento local criptografado.
*   **Área Administrativa Web (Flutter Web):**
    *   **Responsabilidades:** Destinada a gestores ou administradores. Permite a autenticação via conta Google e a visualização dos projetos que foram sincronizados pelo aplicativo móvel para a pasta "AplicativoDeComissionamento" no Google Drive. Exibe metadados dos projetos, contagem de fotos e links diretos para visualização dos relatórios PDF armazenados no Drive.
*   **Google Drive:**
    *   **Responsabilidades:** Atua como o sistema de armazenamento em nuvem para os relatórios PDF e as fotos técnicas geradas e sincronizadas pelo aplicativo móvel. Funciona como um backend simplificado, permitindo o acesso aos dados pela Área Administrativa Web através da API do Google Drive.

### 2.2. Diagrama de Arquitetura Simplificado

`[Placeholder: Diagrama de Arquitetura Geral - App Móvel (Flutter) <-> Google Drive API <-> Google Drive (Armazenamento) <-> Google Drive API <-> Admin Web (Flutter Web)]`

**Descrição Textual do Diagrama:**
O Aplicativo Móvel interage com o Google Drive através da API do Google Drive para realizar o upload de relatórios e fotos. A Área Administrativa Web também utiliza a API do Google Drive para listar e acessar os arquivos de projetos sincronizados. Não há comunicação direta entre o Aplicativo Móvel e a Área Administrativa Web; o Google Drive atua como intermediário e repositório de dados.

## 3. Tecnologias Utilizadas

### 3.1. Stack Principal

*   **Flutter SDK:** Versão 3.16.9 (ou versão estável mais recente no momento do desenvolvimento) - Utilizado para o desenvolvimento multiplataforma do aplicativo móvel (Android, iOS) e da área administrativa web.
*   **Dart:** Linguagem de programação principal do Flutter.

### 3.2. Aplicativo Móvel - Principais Pacotes/Plugins

*   **Estado e Injeção de Dependência:**
    *   `provider`: Para gerenciamento de estado reativo.
    *   `get_it`: Para injeção de dependência e localização de serviços.
*   **Banco de Dados Local:**
    *   `sqflite_sqlcipher`: Para persistência de dados local em um banco de dados SQLite criptografado.
*   **Armazenamento Seguro:**
    *   `flutter_secure_storage`: Para armazenar de forma segura a chave de criptografia do banco de dados.
*   **Autenticação Local:**
    *   `crypt`: Para hashing de senhas de usuários locais.
*   **Google Sign-In (Mobile):**
    *   `google_sign_in`: Para autenticação de usuários com contas Google, facilitando a integração com o Google Drive.
*   **Google Drive API (Mobile):**
    *   `googleapis` (especificamente `drive.v3`): Para interagir com o Google Drive (criar pastas, fazer upload de arquivos, listar arquivos).
    *   `googleapis_auth` (indiretamente ou diretamente): Para auxiliar na autenticação das chamadas à API.
*   **Geração de PDF:**
    *   `pdf`: Para criar documentos PDF programaticamente.
    *   `open_file_plus`: Para abrir os arquivos PDF gerados no dispositivo.
*   **Captura de Imagem:**
    *   `image_picker`: Para permitir que o usuário selecione imagens da galeria ou capture novas fotos com a câmera.
    *   `geolocator` e `permission_handler`: Para obter dados de geolocalização e gerenciar permissões.
*   **Visualização de Imagem:**
    *   `photo_view`: Para visualização de fotos em tela cheia com zoom.
*   **Assinatura Digital (Touch):**
    *   `signature`: Para capturar assinaturas digitais por toque na tela.
*   **WebView (Catálogo ABNT):**
    *   `flutter_inappwebview`: Para exibir o site do Catálogo ABNT dentro do aplicativo.
*   **Exportação/Compartilhamento:**
    *   `flutter_email_sender`: Para enviar relatórios por e-mail.
    *   `qr_flutter`: Para gerar QR Codes a partir de links do Google Drive.
    *   `share_plus`: Para funcionalidades de compartilhamento genéricas (ex: compartilhar link do QR Code).
    *   `image_gallery_saver`: Para salvar imagens (como QR Codes) na galeria do dispositivo.
*   **Conectividade:**
    *   `connectivity_plus`: Para verificar o status da conexão de rede do dispositivo.
*   **Internacionalização (i18n):**
    *   `flutter_localizations` (sdk: flutter) e `intl`: Para suportar múltiplos idiomas na UI (inglês e português do Brasil).

### 3.3. Área Administrativa Web - Principais Pacotes/Plugins

*   **Estado:** `provider`.
*   **Google Sign-In (Web):** `google_sign_in` (utiliza a infraestrutura web do plugin).
*   **Google Drive API (Web):** `googleapis` (especificamente `drive.v3`).
*   **Internacionalização (i18n):** `flutter_localizations` (sdk: flutter) e `intl`.
*   **URL Launcher (para abrir PDFs do Drive):** `url_launcher` (para abrir links externos, como os `webViewLink` dos PDFs no Drive).

## 4. Estrutura do Banco de Dados Local (Aplicativo Móvel - SQLite)

O banco de dados local é criptografado utilizando SQLCipher. A chave de criptografia é armazenada de forma segura usando `flutter_secure_storage`.

*   **`users`**:
    *   `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
    *   `name` (TEXT NOT NULL)
    *   `username` (TEXT UNIQUE NOT NULL) - Pode ser CPF ou e-mail
    *   `password_hash` (TEXT NOT NULL)
    *   `salt` (TEXT NOT NULL)
*   **`projects`**:
    *   `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
    *   `user_id` (INTEGER, FOREIGN KEY (`users.id`)) - Para vincular projeto ao usuário (se múltiplos usuários locais fossem suportados de forma mais explícita)
    *   `title` (TEXT NOT NULL)
    *   `client` (TEXT)
    *   `project_type` (TEXT)
    *   `status` (TEXT NOT NULL) - Ex: 'Pendente', 'Em Andamento', 'Concluído'
    *   `created_at` (TEXT NOT NULL) - ISO 8601 timestamp
    *   `updated_at` (TEXT NOT NULL) - ISO 8601 timestamp
    *   `signature_path` (TEXT) - Caminho local para a imagem da assinatura
*   **`inspection_modules`**:
    *   `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
    *   `project_id` (INTEGER NOT NULL, FOREIGN KEY (`projects.id`))
    *   `name` (TEXT NOT NULL) - Nome do tipo de módulo (ex: "Inspeção Visual")
    *   `status` (TEXT NOT NULL) - Ex: 'Pendente', 'Em Andamento', 'Concluído'
    *   `created_at` (TEXT NOT NULL)
    *   `updated_at` (TEXT NOT NULL)
*   **`checklist_items`**:
    *   `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
    *   `inspection_module_id` (INTEGER NOT NULL, FOREIGN KEY (`inspection_modules.id`))
    *   `order_index` (INTEGER NOT NULL) - Ordem do item no checklist
    *   `description` (TEXT NOT NULL) - Descrição do item do checklist
    *   `item_type` (TEXT NOT NULL) - Ex: 'ok_not_conform', 'text', 'number', 'notes_only'
    *   `response_ok_not_conform` (TEXT) - 'OK', 'Não Conforme', NULL
    *   `response_text` (TEXT)
    *   `response_number` (REAL)
    *   `notes` (TEXT)
*   **`photos`**:
    *   `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
    *   `project_id` (INTEGER NOT NULL, FOREIGN KEY (`projects.id`))
    *   `inspection_module_id` (INTEGER, FOREIGN KEY (`inspection_modules.id`)) - Opcional, se a foto for do módulo em geral
    *   `checklist_item_id` (INTEGER, FOREIGN KEY (`checklist_items.id`)) - Opcional, se a foto for de um item específico
    *   `local_path` (TEXT NOT NULL) - Caminho do arquivo da foto no dispositivo
    *   `drive_id` (TEXT) - ID do arquivo no Google Drive após sincronização
    *   `caption` (TEXT)
    *   `latitude` (REAL)
    *   `longitude` (REAL)
    *   `timestamp` (TEXT NOT NULL) - ISO 8601 timestamp da captura
*   **`sync_logs`**:
    *   `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
    *   `project_id` (INTEGER NOT NULL, FOREIGN KEY (`projects.id`))
    *   `last_sync_timestamp` (TEXT NOT NULL)
    *   `status` (TEXT NOT NULL) - Ex: 'Success', 'Error', 'In Progress'
    *   `message` (TEXT) - Detalhes do erro ou sucesso
    *   `drive_report_folder_id` (TEXT) - ID da pasta do projeto no Drive
    *   `drive_report_file_id` (TEXT) - ID do arquivo PDF do relatório no Drive
    *   `drive_report_web_link` (TEXT) - Link de visualização do PDF no Drive
    *   `drive_photos_folder_id` (TEXT) - ID da subpasta "Fotos" no Drive
*   **`normas`** (para armazenar as normas ABNT associadas):
    *   `id` (TEXT PRIMARY KEY) - Código da norma, ex: "ABNT NBR 5410"
    *   `description` (TEXT NOT NULL)
*   **`project_normas`** (tabela de junção para relação N:N entre projetos e normas):
    *   `project_id` (INTEGER NOT NULL, FOREIGN KEY (`projects.id`))
    *   `norma_id` (TEXT NOT NULL, FOREIGN KEY (`normas.id`))
    *   PRIMARY KEY (`project_id`, `norma_id`)

`[Placeholder: Diagrama do Modelo de Dados do BD Local - representação visual das tabelas e seus relacionamentos]`

## 5. Fluxos de Dados Principais

### 5.1. Fluxo de Login Local (App Móvel)

1.  **Entrada do Usuário:** Usuário insere CPF/Email e Senha na `LoginScreen`.
2.  **Validação:** Campos são validados (formato, preenchimento).
3.  **Busca no BD:** `AuthService` busca o usuário no banco de dados local (`users`) pelo `username`.
4.  **Verificação de Senha:** Se usuário encontrado, `AuthService` compara o hash da senha fornecida (usando o `salt` armazenado e `crypt`) com o `password_hash` armazenado.
5.  **Atualização de Estado:** Se a verificação for bem-sucedida, o `UserProvider` (ou similar) é atualizado com os dados do usuário.
6.  **Navegação:** Usuário é redirecionado para o `ProjectListScreen` (Dashboard).

### 5.2. Fluxo de Coleta de Dados e Geração de Relatório (App Móvel)

1.  **Criação/Seleção de Projeto:** Usuário cria um novo projeto ou seleciona um existente no `ProjectListScreen`.
2.  **Detalhes do Projeto:** Dados do projeto (título, cliente, etc.) são inseridos/editados na `ProjectDetailsScreen` e salvos no BD local (`projects` table) via `ProjectProvider` e `DatabaseService`.
3.  **Módulos de Inspeção:** Usuário adiciona módulos de inspeção predefinidos ao projeto. Módulos são criados na tabela `inspection_modules`, e os itens de checklist correspondentes são populados na tabela `checklist_items`.
4.  **Preenchimento do Checklist:** Na `InspectionScreen`, o usuário preenche os itens (status, notas, fotos). Dados são salvos em `checklist_items` e `photos` via `InspectionProvider` e `DatabaseService`.
5.  **Assinatura:** Usuário desenha e salva a assinatura na `SignatureScreen`. A imagem da assinatura é salva localmente e o caminho é armazenado em `projects.signature_path`.
6.  **Geração de PDF:** Usuário aciona a geração do PDF. O `PdfService` coleta todos os dados relevantes do `DatabaseService` (projeto, módulos, itens, fotos, assinatura) e compila o relatório PDF/A. O PDF é salvo localmente.

### 5.3. Fluxo de Sincronização com Google Drive (App Móvel)

1.  **Autenticação Google:** Usuário faz login com Google via `GoogleAuthService` na `SettingsScreen` ou no início do fluxo de sincronização.
2.  **Seleção de Projeto:** Usuário inicia a sincronização para um projeto específico.
3.  **Interação com Drive:** O `DriveService` (ou `SyncService`):
    *   Verifica/cria a pasta base "AplicativoDeComissionamento".
    *   Verifica/cria a pasta do projeto (ex: "Projeto Teste Alpha") dentro da pasta base.
    *   Verifica/cria a subpasta "Fotos" dentro da pasta do projeto.
    *   Faz upload do arquivo PDF do relatório para a pasta do projeto. Trata conflitos básicos (sobrescrever se o local for mais novo ou se o usuário confirmar).
    *   Faz upload de cada foto associada para a subpasta "Fotos".
4.  **Log de Sincronização:** `DatabaseService` atualiza a tabela `sync_logs` com o timestamp, status, IDs dos arquivos/pastas no Drive e o link de visualização web do relatório.

### 5.4. Fluxo de Visualização de Dados (Admin Web)

1.  **Autenticação Google (Admin):** Administrador faz login com Google na `LoginScreenWeb` usando `GoogleAuthServiceWeb`.
2.  **Busca de Dados no Drive:** O `AdminProvider`, utilizando o `DriveServiceWeb` (que é inicializado após login bem-sucedido):
    *   Lista o conteúdo da pasta "AplicativoDeComissionamento" no Google Drive do usuário autenticado.
    *   Para cada subpasta de projeto encontrada:
        *   Extrai o nome do projeto (nome da pasta).
        *   Busca o arquivo PDF principal do relatório (por nome padrão, ex: `relatorio_*.pdf`).
        *   Obtém o `webViewLink` para o PDF.
        *   Lista os arquivos na subpasta "Fotos" para obter a contagem.
        *   Obtém a data da última modificação da pasta/arquivo principal do relatório.
3.  **Exibição no Dashboard:** `DashboardScreenWeb` exibe os dados coletados em uma tabela ou lista, com links para abrir os relatórios PDF.
4.  **Abertura de Relatório:** Ao clicar no link do relatório, `url_launcher` abre o `webViewLink` do PDF em uma nova aba do navegador.

## 6. Guia de Configuração do Ambiente de Desenvolvimento (Mobile e Web)

### 6.1. Pré-requisitos Globais

*   **Flutter SDK:** Versão 3.16.9 ou superior. (Verificar a versão exata utilizada no `pubspec.yaml` de cada projeto).
*   **Git:** Para clonar o repositório.
*   **IDE:** Android Studio, VS Code ou outra IDE com suporte a Flutter.

### 6.2. Passos Comuns para Ambos os Projetos

1.  **Clonar o Repositório:** `git clone <URL_DO_REPO_PRINCIPAL>`
2.  Navegar para o diretório do subprojeto desejado:
    *   Aplicativo Móvel: `cd field_engineer_app` (ou o nome da pasta raiz do app móvel)
    *   Área Administrativa Web: `cd admin_web_app`
3.  **Instalar Dependências:** Executar `flutter pub get` no diretório do subprojeto.

### 6.3. Específico para Aplicativo Móvel (`field_engineer_app`)

1.  **Configurar Dispositivos/Emuladores:**
    *   **Android:** Android Studio para gerenciamento de AVDs ou conectar um dispositivo físico com modo de desenvolvedor e depuração USB ativados.
    *   **iOS:** Xcode para gerenciamento de simuladores ou conectar um dispositivo físico (requer macOS e configuração de provisionamento Apple Developer).
2.  **Configuração de Google Services (para Google Sign-In e Drive API):**
    *   **Android:**
        *   Obter o arquivo `google-services.json` do projeto Firebase associado e colocá-lo em `android/app/`.
        *   Garantir que o SHA-1 (e SHA-256, se necessário) do certificado de assinatura esteja configurado no console do Firebase e no Google Cloud Platform para as credenciais OAuth.
    *   **iOS:**
        *   Obter o arquivo `GoogleService-Info.plist` do projeto Firebase e configurá-lo no Xcode.
        *   Configurar o URL Scheme no Xcode.
        *   Garantir que o Bundle ID esteja correto e configurado no GCP para as credenciais OAuth.
3.  **Chaves de API (se aplicável):** Se alguma outra API necessitar de chaves (ex: geolocalização, mapas), seguir as instruções de configuração específicas.
4.  **Executar o Aplicativo:** `flutter run`

### 6.4. Específico para Área Administrativa Web (`admin_web_app`)

1.  **Configuração de Credenciais OAuth para Web no GCP:**
    *   No Google Cloud Platform, para o mesmo projeto usado pelo app móvel, criar um ID de cliente OAuth 2.0 do tipo "Aplicativo da Web".
    *   Configurar as "Origens JavaScript autorizadas" (ex: `http://localhost:PORT` para desenvolvimento, e a URL de produção após o deploy).
    *   Configurar os "URIs de redirecionamento autorizados" (similarmente para desenvolvimento e produção).
    *   O ID do Cliente gerado será utilizado pela biblioteca `google_sign_in` para web. Geralmente, ele é configurado no momento da inicialização do Google Sign-In no código ou através de um arquivo de configuração específico do Firebase para web (se o Firebase for usado para hospedar ou gerenciar a configuração).
2.  **Executar o Aplicativo Web:**
    *   `flutter run -d chrome` (ou `edge`, `firefox`, etc.)
    *   Para builds de produção: `flutter build web` e hospedar os arquivos da pasta `build/web`.

### 6.5. Internacionalização (i18n)

*   Após qualquer alteração nos arquivos `.arb` (localizados em `lib/l10n/` dentro de cada projeto respectivo):
    *   Navegue para o diretório raiz do projeto (móvel ou web).
    *   Execute o comando `flutter gen-l10n`.
    *   Isso irá regenerar os arquivos Dart de localização (ex: `app_localizations.dart` e delegados).

## 7. Configuração da API do Google Drive

Para que o aplicativo móvel e a área administrativa web possam interagir com o Google Drive, as seguintes configurações são necessárias no Google Cloud Platform (GCP):

1.  **Criar/Selecionar Projeto no GCP:** Acesse o [Google Cloud Console](https://console.cloud.google.com/) e crie um novo projeto ou selecione um existente.
2.  **Ativar a API do Google Drive:**
    *   No menu de navegação, vá para "APIs e Serviços" > "Biblioteca".
    *   Procure por "Google Drive API" e habilite-a para o seu projeto.
3.  **Configurar a Tela de Consentimento OAuth:**
    *   No menu de navegação, vá para "APIs e Serviços" > "Tela de consentimento OAuth".
    *   Configure o tipo de usuário (Interno ou Externo). Para testes e produção com usuários externos, escolha "Externo".
    *   Preencha as informações solicitadas (nome do app, e-mail de suporte, domínios autorizados, etc.).
    *   Adicione os escopos necessários. O escopo principal utilizado é `https://www.googleapis.com/auth/drive.file`. Este escopo permite acesso por arquivo criado pelo app, o que é uma boa prática de segurança. Alternativamente, `https://www.googleapis.com/auth/drive.appdata` poderia ser usado se os arquivos devessem ser armazenados na pasta oculta de dados do aplicativo, mas `drive.file` é mais apropriado para a funcionalidade de visualização pelo admin e acesso do usuário à pasta "AplicativoDeComissionamento".
4.  **Criar Credenciais de ID do Cliente OAuth 2.0:**
    *   No menu de navegação, vá para "APIs e Serviços" > "Credenciais".
    *   Clique em "+ CRIAR CREDENCIAIS" e selecione "ID do cliente OAuth".
    *   **Para o Aplicativo Móvel (Android):**
        *   Selecione "Android".
        *   Preencha o nome do pacote (ex: `br.com.example.field_engineer_app`).
        *   Insira a impressão digital SHA-1 do seu certificado de assinatura (debug e release).
    *   **Para o Aplicativo Móvel (iOS):**
        *   Selecione "iOS".
        *   Preencha o ID do pacote (Bundle ID).
    *   **Para a Área Administrativa Web:**
        *   Selecione "Aplicativo da Web".
        *   Adicione as "Origens JavaScript autorizadas" (ex: `http://localhost` e a porta durante o desenvolvimento, e a URL de produção).
        *   Adicione os "URIs de redirecionamento autorizados" (geralmente a mesma URL da aplicação, para onde o Google redirecionará após a autenticação).
    *   Salve as credenciais geradas. O ID do Cliente será usado pelo app web. Para mobile, os arquivos `google-services.json` / `GoogleService-Info.plist` geralmente contêm as informações necessárias.

## 8. Segurança

### 8.1. Medidas Implementadas

*   **Autenticação Local (App Móvel):**
    *   As senhas dos usuários locais são armazenadas usando hashing com salt (biblioteca `crypt` - PBKDF2).
*   **Criptografia do Banco de Dados Local (App Móvel):**
    *   O banco de dados SQLite é criptografado usando `sqflite_sqlcipher`.
    *   A chave de criptografia do banco de dados é gerada e armazenada de forma segura no dispositivo utilizando `flutter_secure_storage`.
*   **Comunicação Segura:**
    *   Todas as comunicações com as APIs do Google (Sign-In, Drive) são realizadas sobre HTTPS.
*   **Flutter Web - Content Security Policy (CSP):**
    *   A aplicação web Flutter por padrão já inclui mecanismos para mitigar riscos de XSS. Configurações adicionais de CSP podem ser implementadas no servidor de hospedagem para maior segurança.
*   **Escopos de API Restritos:**
    *   As permissões solicitadas para a API do Google Drive são limitadas ao escopo `drive.file` (ou similar), permitindo que o aplicativo acesse apenas os arquivos que ele mesmo criou ou que foram explicitamente abertos pelo usuário, ou arquivos dentro de uma pasta específica criada pelo app ("AplicativoDeComissionamento").

### 8.2. Considerações Futuras

*   **Autenticação gov.br:** Para integração futura com sistemas governamentais, a autenticação via gov.br pode ser explorada, exigindo um fluxo OAuth 2.0 ou OpenID Connect específico e conformidade com os padrões de segurança do governo.
*   **Revisões de Segurança:** Auditorias de segurança periódicas no código e infraestrutura.
*   **Gerenciamento Avançado de Chaves:** Para a chave de criptografia do BD, considerar mecanismos de rotação ou derivação de chaves mais complexos se os requisitos de segurança aumentarem.

## 9. Estrutura do Código (Visão Geral)

A estrutura de diretórios principal dentro de `lib/` para ambos os projetos (móvel e web, com adaptações) segue um padrão comum em projetos Flutter:

*   **`main.dart`**: Ponto de entrada da aplicação, configuração inicial do `MaterialApp`.
*   **`app_localizations.dart` (e `generated/` ou `.dart_tool/flutter_gen/`):** Arquivos gerados para internacionalização.
*   **`l10n/`**: Contém os arquivos `.arb` para as strings de tradução.
*   **`models/`**: Contém as classes de modelo de dados (ex: `Project`, `User`, `InspectionModule`, `ChecklistItem`, `Photo`).
*   **`providers/`**: Contém os ChangeNotifiers para gerenciamento de estado com o `provider` (ex: `AuthProvider`, `ProjectProvider`, `AdminProvider`).
*   **`screens/` (ou `pages/` ou `ui/screens/`)**: Contém os widgets que representam telas inteiras da aplicação (ex: `LoginScreen`, `ProjectListScreen`, `ProjectDetailsScreen`, `InspectionScreen`, `DashboardScreenWeb`).
*   **`services/`**: Contém classes de serviço para lógica de negócios e interações com APIs ou banco de dados (ex: `AuthService`, `DatabaseService`, `DriveService`, `PdfService`, `GoogleAuthServiceWeb`).
*   **`widgets/` (ou `ui/widgets/`)**: Contém widgets reutilizáveis usados em múltiplas telas (ex: `ProjectCard`, `ConnectivityIndicator`, `SignaturePadWidget`).
*   **`utils/`**: Contém classes utilitárias e constantes (ex: formatadores de data, validadores, constantes de rotas).
*   **`service_locator.dart` (ou `service_locator_mobile.dart` / `service_locator_web.dart`):** Configuração do `get_it` para injeção de dependência.

---
*Fim da Documentação Técnica (MVP)*
