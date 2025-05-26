# Plano de Teste - Aplicativo de Comissionamento

## 1. Introdução

Este plano de teste descreve a estratégia e o escopo para testar o Aplicativo de Comissionamento (móvel) e sua Área Administrativa Web (MVP). O objetivo é verificar a funcionalidade, usabilidade e confiabilidade dos recursos críticos para garantir que o software atenda aos requisitos definidos e proporcione uma boa experiência ao usuário.

## 2. Escopo dos Testes

### 2.1. Funcionalidades Críticas do Aplicativo Móvel

As seguintes funcionalidades do aplicativo móvel serão testadas:

*   **Autenticação Local:**
    *   Cadastro de novo usuário (CPF/e-mail e senha).
    *   Login de usuário existente.
    *   Validação de credenciais (válidas e inválidas).
*   **Dashboard de Projetos:**
    *   Criação de novos projetos.
    *   Visualização da lista de projetos existentes.
    *   Edição de dados gerais de um projeto.
    *   Exclusão de projetos.
*   **Detalhes e Edição do Projeto:**
    *   Preenchimento e salvamento do formulário de dados gerais do projeto.
    *   Associação e desassociação de Normas ABNT (entrada manual).
*   **Módulos de Inspeção:**
    *   Adição de módulos de inspeção predefinidos a um projeto.
    *   Navegação sequencial pelos itens de um checklist (anterior/próximo).
    *   Preenchimento dos diferentes tipos de itens de checklist:
        *   OK / Não Conforme.
        *   Entrada de Texto.
        *   Entrada Numérica.
    *   Atualização do status do módulo de inspeção (Pendente, Em Andamento, Concluído).
*   **Captura e Associação de Fotos Técnicas:**
    *   Acesso à câmera para captura de novas fotos.
    *   Acesso à galeria para seleção de fotos existentes.
    *   Salvamento local das fotos.
    *   Associação de fotos a itens específicos do checklist.
    *   Adição de legendas às fotos.
    *   Visualização e exclusão de fotos associadas.
*   **Geração de Relatório PDF (com Assinatura Digital):**
    *   Coleta de dados do projeto, módulos de inspeção, itens de checklist e fotos.
    *   Geração de relatório em formato PDF/A.
    *   Incorporação de assinatura digital (capturada por toque) no relatório.
    *   Exportação/abertura do relatório PDF gerado.
    *   Envio do relatório por e-mail.
*   **Sincronização Manual com Google Drive:**
    *   Autenticação com conta Google.
    *   Upload do relatório PDF e fotos associadas para uma pasta específica do projeto no Google Drive.
    *   Feedback visual do status da sincronização.
    *   Tratamento básico de conflitos de arquivo (para PDF).
    *   Geração e compartilhamento de QR Code para o link do relatório no Drive.
*   **Segurança:**
    *   Verificação da criptografia do banco de dados SQLite local (SQLCipher).
*   **UX/UI:**
    *   Verificação do indicador de conectividade (online/offline).
    *   Navegação geral e usabilidade.
*   **Integração com Catálogo ABNT:**
    *   Acesso e navegação no site ABNT Catálogo via WebView.

### 2.2. Funcionalidades da Área Administrativa Web (MVP)

As seguintes funcionalidades da área administrativa web serão testadas:

*   **Autenticação:**
    *   Login com conta Google.
*   **Dashboard de Projetos:**
    *   Visualização da lista de projetos sincronizados a partir do Google Drive (pasta "AplicativoDeComissionamento").
    *   Exibição de informações básicas do projeto (nome, data da última modificação no Drive).
*   **Visualização de Relatórios:**
    *   Abertura/visualização do relatório PDF principal do projeto diretamente do Google Drive.
    *   Visualização da contagem de fotos sincronizadas.

## 3. Dispositivos Alvo e Ambiente

### 3.1. Mobile

*   **Android:**
    *   Samsung Galaxy S21 (Android 12 ou superior)
    *   Xiaomi Redmi Note 11 (Android 13 ou superior)
    *   Google Pixel 6 (Android 14 ou superior - via emulador, se físico não disponível)
*   **iOS:**
    *   Emulador iOS (versão mais recente do iOS suportada pelo Flutter)

### 3.2. Web Admin

*   **Navegadores (Desktop):**
    *   Google Chrome (versão mais recente)
    *   Mozilla Firefox (versão mais recente)

## 4. Critérios de Passa/Falha

*   **Passou:** Todas as etapas do caso de teste são executadas com sucesso e o resultado obtido corresponde ao resultado esperado, sem erros críticos ou bloqueios. Pequenos defeitos de UI que não afetam a funcionalidade podem ser registrados, mas o caso ainda pode ser considerado "Passou com Observações".
*   **Falhou:** Uma ou mais etapas do caso de teste não podem ser concluídas, o resultado obtido difere significativamente do resultado esperado, ou são encontrados erros críticos (ex: crashes, perda de dados, funcionalidade principal inoperante).
*   **Bloqueado:** O caso de teste não pode ser executado devido a um defeito em uma funcionalidade pré-requisito.

## 5. Entregáveis do Teste

*   Este documento (Plano de Teste - TEST_PLAN.md).
*   Lista de Casos de Teste (TEST_CASES.md).
*   Relatório de Sumário de Testes (a ser gerado após a execução dos testes, não faz parte deste documento inicial).

---
Este plano de teste será atualizado conforme necessário durante o ciclo de desenvolvimento e teste do projeto.
