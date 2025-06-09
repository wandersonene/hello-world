# Guia Rápido - Área Administrativa Web (Aplicativo de Comissionamento a Frio)

## 1. Introdução

Bem-vindo à Área Administrativa Web do Aplicativo de Comissionamento a Frio!

O propósito desta plataforma é permitir que administradores e gestores visualizem, de forma centralizada, todos os projetos e relatórios de inspeção que foram sincronizados pelos engenheiros de campo através do aplicativo móvel.

Para esta versão MVP (Produto Mínimo Viável), a Área Administrativa Web é uma ferramenta de **visualização** (read-only), focada em fornecer acesso rápido e fácil aos dados consolidados no Google Drive.

## 2. Acesso à Aplicação

*   **URL de Acesso:** Para acessar a Área Administrativa Web, utilize o seguinte endereço no seu navegador:
    `[Placeholder: URL da Área Administrativa Web]`
    *(Nota: Esta URL será fornecida pela equipe responsável pela implantação do sistema.)*

*   **Navegadores Suportados:** Recomendamos o uso das versões mais recentes dos seguintes navegadores em computadores desktop ou laptops:
    *   Google Chrome
    *   Mozilla Firefox

## 3. Login

Ao acessar a URL, você será direcionado para a tela de login.

1.  **Tela de Login:** Você verá um botão indicando "Login com Google".
2.  **Realizando o Login:**
    *   Clique no botão **"Login com Google"**.
    *   Uma janela ou pop-up do Google aparecerá, solicitando que você escolha uma conta Google e, em seguida, insira suas credenciais (e-mail e senha), caso ainda não esteja logado no navegador.
    *   Se solicitado, conceda as permissões para que o aplicativo acesse as informações básicas do seu perfil e os arquivos relacionados ao aplicativo no Google Drive.
3.  **Importância da Conta Correta:** É crucial que você utilize a conta Google que foi designada para ter acesso aos dados dos projetos de comissionamento armazenados no Google Drive. Se você utilizar uma conta diferente, não conseguirá visualizar os projetos.

## 4. Painel Principal (Dashboard)

Após o login bem-sucedido, você será direcionado ao Painel Principal (Dashboard).

### 4.1. Visão Geral

O dashboard exibe uma lista de todos os projetos de comissionamento que foram sincronizados pelos engenheiros de campo a partir do aplicativo móvel para a pasta compartilhada "AplicativoDeComissionamento" no Google Drive.

### 4.2. Informações por Projeto

Cada item na lista representa um projeto e exibe as seguintes informações:

*   **Nome do Projeto:** O nome dado ao projeto no momento da sua criação no aplicativo móvel (geralmente, o nome da pasta do projeto no Google Drive).
*   **Data da Última Modificação:** Indica quando o projeto (ou seu relatório/fotos) foi modificado pela última vez no Google Drive. Isso geralmente corresponde à data da última sincronização ou alteração de algum arquivo do projeto.
*   **Relatório (Link):**
    *   Um link clicável (pode ser o nome do arquivo PDF, como "relatorio_ProjetoX.pdf", ou um texto como "Visualizar Relatório").
    *   Ao clicar neste link, o relatório PDF principal do projeto será aberto em uma nova aba do seu navegador para visualização. O relatório é carregado diretamente do Google Drive.
*   **Contagem de Fotos:** O número total de fotos que foram sincronizadas e estão associadas a este projeto na subpasta "Fotos" dentro da pasta do projeto no Google Drive.

### 4.3. Ordenação e Atualização

*   **Ordenação:** Os projetos são listados por padrão com os mais recentemente modificados aparecendo no topo da lista.
*   **Atualizar Lista:** Para garantir que você está vendo a lista mais recente de projetos (caso novos projetos tenham sido sincronizados enquanto você estava com a página aberta), você pode puxar a lista para baixo (se a interface permitir o gesto de "pull-to-refresh") ou procurar por um botão de atualizar/recarregar na tela.

## 5. Logout

Para sair da Área Administrativa Web e proteger o acesso aos dados:

1.  Localize o botão ou ícone de **"Sair"** (Logout). Geralmente, ele está localizado na barra de navegação superior ou em um menu de perfil do usuário.
2.  Clique no botão "Sair". Você será desconectado e redirecionado para a tela de login.

## 6. Solução de Problemas Básicos

*   **Não consigo ver nenhum projeto no Dashboard:**
    *   **Conta Google:** Verifique se você está logado com a conta Google correta, aquela que tem as permissões de acesso à pasta "AplicativoDeComissionamento" no Google Drive onde os projetos são armazenados. Tente sair (Logout) e entrar novamente com a conta correta.
    *   **Sincronização:** Confirme com os engenheiros de campo se eles já sincronizaram algum projeto do aplicativo móvel para o Google Drive.
    *   **Atualizar:** Tente atualizar a página do navegador (F5 ou Ctrl+R/Cmd+R) ou utilizar o mecanismo de atualização da lista de projetos, se disponível.
*   **Link do relatório não funciona ou o PDF não abre:**
    *   **Conexão:** Verifique sua conexão com a internet. O relatório é carregado diretamente do Google Drive.
    *   **Atraso no Drive:** Ocasionalmente, pode haver um pequeno atraso entre a sincronização de um arquivo para o Google Drive e sua total disponibilidade para visualização via link. Tente acessar o link novamente após alguns instantes.
    *   **Bloqueador de Pop-ups:** Verifique se o seu navegador não está bloqueando a abertura de novas abas ou pop-ups, pois o relatório pode ser aberto em uma nova aba.

---
*Fim do Guia Rápido da Área Administrativa Web (MVP)*
