# Casos de Teste - Aplicativo de Comissionamento

## Formato do Caso de Teste

*   **ID do Caso:** Identificador único (Ex: CT_MOBILE_LOGIN_001)
*   **Título:** Descrição resumida do objetivo do teste.
*   **Pré-condições:** Condições que devem ser verdadeiras antes da execução do teste.
*   **Passos para Execução:** Sequência numerada de ações a serem realizadas.
*   **Dados de Teste (Opcional):** Valores específicos a serem usados durante o teste.
*   **Resultado Esperado:** O comportamento ou estado esperado do sistema após a execução dos passos.
*   **Resultado Obtido:** (A ser preenchido durante a execução dos testes)
*   **Status:** (Pendente, Passou, Falhou, Bloqueado)

---

## Casos de Teste - Aplicativo Móvel

### Autenticação Local

**ID do Caso:** CT_MOBILE_LOGIN_001
**Título:** Login com credenciais válidas (e-mail)
**Pré-condições:** Usuário previamente cadastrado com e-mail "usuario@teste.com" e senha "senha123". Aplicativo não está logado.
**Passos para Execução:**
1.  Abrir o aplicativo.
2.  Na tela de Login, inserir "usuario@teste.com" no campo "CPF ou Email".
3.  Inserir "senha123" no campo "Senha".
4.  Clicar no botão "Login".
**Dados de Teste:** Email: "usuario@teste.com", Senha: "senha123"
**Resultado Esperado:** Usuário é logado com sucesso e redirecionado para a tela de Dashboard de Projetos.
**Resultado Obtido:** Login bem-sucedido, usuário redirecionado para a tela de Projetos. UI em português.
**Status:** Passou

**ID do Caso:** CT_MOBILE_LOGIN_002
**Título:** Login com senha inválida
**Pré-condições:** Usuário previamente cadastrado com e-mail "usuario@teste.com". Aplicativo não está logado.
**Passos para Execução:**
1.  Abrir o aplicativo.
2.  Na tela de Login, inserir "usuario@teste.com" no campo "CPF ou Email".
3.  Inserir "senha_errada" no campo "Senha".
4.  Clicar no botão "Login".
**Dados de Teste:** Email: "usuario@teste.com", Senha: "senha_errada"
**Resultado Esperado:** Mensagem de erro "Senha inválida. Por favor, tente novamente." (ou similar) é exibida. Usuário permanece na tela de Login.
**Resultado Obtido:** Mensagem "Invalid password. Please try again." exibida. Usuário permaneceu na tela de Login. Observação: Mensagem de erro está em inglês. Necessita tradução para "Senha inválida. Por favor, tente novamente.".
**Status:** Falhou

**ID do Caso:** CT_MOBILE_CADASTRO_001
**Título:** Cadastro de novo usuário com sucesso
**Pré-condições:** O e-mail/CPF a ser cadastrado não existe no sistema.
**Passos para Execução:**
1.  Abrir o aplicativo.
2.  Na tela de Login, clicar em "Não tem uma conta? Registre-se".
3.  Preencher o campo "Nome Completo" com "Usuário Novo Teste".
4.  Preencher o campo "CPF ou Email" com "novousuario@teste.com".
5.  Preencher o campo "Senha" com "novaSenha123".
6.  Preencher o campo "Confirmar Senha" com "novaSenha123".
7.  Clicar no botão "Registrar".
**Dados de Teste:** Nome: "Usuário Novo Teste", Email: "novousuario@teste.com", Senha: "novaSenha123"
**Resultado Esperado:** Usuário é cadastrado com sucesso. Mensagem de sucesso é exibida. Usuário é redirecionado para a tela de Dashboard de Projetos (ou Login, dependendo do fluxo pós-cadastro).
**Resultado Obtido:** Cadastro realizado com sucesso. Usuário redirecionado para a tela de Projetos. Mensagem de boas-vindas "Registration successful! Welcome Usuário Novo Teste." exibida. Observação: Mensagem de boas-vindas parcialmente em inglês. Necessita tradução completa para "Cadastro realizado com sucesso! Bem-vindo(a) Usuário Novo Teste.".
**Status:** Passou com Observações

### Dashboard e Gerenciamento de Projetos

**ID do Caso:** CT_MOBILE_PROJETO_001
**Título:** Criação de novo projeto
**Pré-condições:** Usuário logado no aplicativo.
**Passos para Execução:**
1.  Na tela Dashboard de Projetos, clicar no botão "+" (FAB).
2.  Na tela "Adicionar Novo Projeto", preencher o campo "Título do Projeto" com "Projeto Teste Alpha".
3.  Preencher o campo "Cliente" com "Cliente Alpha".
4.  Preencher o campo "Tipo de Projeto" com "Instalação Elétrica".
5.  Selecionar "Em Andamento" no campo "Status".
6.  Clicar no botão "Salvar Alterações do Projeto".
**Dados de Teste:** Título: "Projeto Teste Alpha", Cliente: "Cliente Alpha", Tipo: "Instalação Elétrica", Status: "Em Andamento"
**Resultado Esperado:** Projeto é criado com sucesso e aparece na lista da Dashboard de Projetos. Mensagem de sucesso é exibida.
**Resultado Obtido:** Projeto criado e listado corretamente. Mensagem de sucesso "Project added successfully!" exibida. Observação: Mensagem em inglês. Necessita tradução para "Projeto adicionado com sucesso!".
**Status:** Passou com Observações

**ID do Caso:** CT_MOBILE_PROJETO_002
**Título:** Visualização de projeto existente
**Pré-condições:** Usuário logado. Existe pelo menos um projeto cadastrado (ex: "Projeto Teste Alpha").
**Passos para Execução:**
1.  Na tela Dashboard de Projetos, localizar o "Projeto Teste Alpha".
2.  Verificar se o título, status e cliente (se aplicável) são exibidos corretamente na lista.
**Resultado Esperado:** As informações básicas do projeto são visíveis e corretas na lista.
**Resultado Obtido:** Informações do projeto (título, status, cliente, data de atualização) visíveis e corretas.
**Status:** Passou

**ID do Caso:** CT_MOBILE_PROJETO_003
**Título:** Edição de um projeto existente
**Pré-condições:** Usuário logado. Existe um projeto "Projeto Teste Alpha".
**Passos para Execução:**
1.  Na tela Dashboard de Projetos, clicar no "Projeto Teste Alpha" para abrir seus detalhes.
2.  Alterar o campo "Status" para "Concluído".
3.  Alterar o campo "Cliente" para "Cliente Alpha Editado".
4.  Clicar no botão "Salvar Alterações do Projeto".
5.  Voltar para a Dashboard de Projetos (se a tela de edição não fechar automaticamente).
**Dados de Teste:** Novo Status: "Concluído", Novo Cliente: "Cliente Alpha Editado"
**Resultado Esperado:** As informações do projeto são atualizadas. Na Dashboard, o "Projeto Teste Alpha" reflete o novo status. Mensagem de sucesso é exibida.
**Resultado Obtido:** Informações atualizadas e salvas. Mensagem "Project updated successfully!" exibida. Ao retornar para a lista, o projeto reflete as alterações. Observação: Mensagem de sucesso da edição está em inglês. Necessita tradução para "Projeto atualizado com sucesso!".
**Status:** Passou com Observações

**ID do Caso:** CT_MOBILE_PROJETO_004
**Título:** Exclusão de um projeto
**Pré-condições:** Usuário logado. Existe um projeto "Projeto Teste Alpha".
**Passos para Execução:**
1.  Na tela Dashboard de Projetos, deslizar o item "Projeto Teste Alpha" para a esquerda.
2.  No diálogo de confirmação, clicar em "Sim, Excluir".
**Resultado Esperado:** O projeto "Projeto Teste Alpha" é removido da lista. Mensagem de sucesso é exibida.
**Resultado Obtido:** Projeto removido da lista. Mensagem "Projeto "Projeto Teste Alpha" excluído." exibida.
**Status:** Passou

### Módulos de Inspeção e Checklist

**ID do Caso:** CT_MOBILE_INSPECAO_001
**Título:** Adição de módulo de inspeção predefinido
**Pré-condições:** Usuário logado, projeto "Projeto Teste Alpha" aberto na tela de Detalhes/Edição do Projeto.
**Passos para Execução:**
1.  Na seção "Módulos de Inspeção", clicar no botão "+".
2.  No diálogo "Adicionar Novo Módulo de Inspeção", selecionar "Inspeção Visual" no dropdown.
3.  Clicar em "Adicionar".
**Resultado Esperado:** O módulo "Inspeção Visual" é adicionado à lista de módulos do projeto com status "Pendente".
**Resultado Obtido:** Módulo "Inspeção Visual" adicionado com status "Pendente". Mensagem "Módulo "Inspeção Visual" adicionado!" exibida.
**Status:** Passou

**ID do Caso:** CT_MOBILE_INSPECAO_002
**Título:** Navegação e preenchimento de itens de checklist
**Pré-condições:** Usuário logado. Projeto "Projeto Teste Alpha" com módulo "Inspeção Visual" adicionado. Tela de Inspeção do módulo "Inspeção Visual" aberta.
**Passos para Execução:**
1.  Verificar se o primeiro item ("Limpeza geral do painel/equipamento") é exibido.
2.  Clicar em "OK".
3.  Clicar em "Próximo".
4.  No segundo item ("Fixação de componentes"), clicar em "Não Conforme".
5.  No campo "Notas Adicionais do Item", inserir "Componente X solto".
6.  Clicar em "Próximo" até chegar ao item "Observações adicionais da inspeção visual".
7.  No campo de texto da resposta, inserir "Painel necessita de limpeza profunda".
8.  Clicar em "Concluir Inspeção" (após responder todos os obrigatórios).
**Resultado Esperado:** Respostas são salvas para cada item. Status do módulo "Inspeção Visual" muda para "Concluído" (ou "Em Andamento" se nem todos obrigatórios foram preenchidos antes de sair e voltar).
**Resultado Obtido:** Respostas salvas corretamente ao navegar entre itens (auto-save funciona). Ao clicar em "Concluir Inspeção" (após todos os obrigatórios serem preenchidos), o status do módulo atualizou para "Concluído". Navegação de volta para tela de detalhes do projeto. Observação de Usabilidade: Botão "Concluir Inspeção" poderia estar no final da lista de itens, não apenas na AppBar, para um fluxo mais intuitivo. Feedback sobre itens obrigatórios pendentes é exibido via SnackBar se tentar concluir antes, o que é bom.
**Status:** Passou com Observações

### Captura de Fotos e Relatórios

**ID do Caso:** CT_MOBILE_FOTO_001
**Título:** Adição de foto da câmera a um item de checklist
**Pré-condições:** Usuário logado. Tela de Inspeção de um módulo aberta, em um item qualquer.
**Passos para Execução:**
1.  Na seção "Fotos do Item", clicar no botão "Adicionar Foto" (ícone de câmera).
2.  Selecionar "Câmera".
3.  Permitir acesso à câmera e localização, se solicitado.
4.  Capturar uma foto. Confirmar o uso da foto.
5.  Na caixa de diálogo "Adicionar Legenda", inserir "Foto do painel frontal". Clicar em "Salvar".
**Resultado Esperado:** Foto é capturada, salva localmente, e sua miniatura aparece na seção "Fotos do Item" com a legenda.
**Resultado Obtido:** Fluxo de permissão para câmera e localização funcionou. Foto capturada e salva. Legenda adicionada. Miniatura visível.
**Status:** Passou

**ID do Caso:** CT_MOBILE_RELATORIO_001
**Título:** Geração de relatório PDF
**Pré-condições:** Usuário logado. Projeto "Projeto Teste Alpha" aberto na tela de Detalhes/Edição, com alguns módulos e itens preenchidos, e uma assinatura digital salva.
**Passos para Execução:**
1.  Clicar no botão "Gerar Relatório PDF".
2.  Aguardar a geração do relatório.
3.  Quando a SnackBar aparecer com a opção "ABRIR", clicar nela.
**Resultado Esperado:** O relatório PDF é gerado com sucesso, contendo dados do projeto, módulos, itens de checklist, fotos (se houver) e a assinatura. O PDF é aberto em um visualizador externo.
**Resultado Obtido:** Relatório PDF/A gerado. Ao abrir, verificou-se que os dados do projeto, módulos e itens preenchidos constam. Fotos associadas aos itens estão presentes, com suas legendas. Assinatura digital (imagem) presente.
**Status:** Passou

### Sincronização e Conectividade

**ID do Caso:** CT_MOBILE_SYNC_001
**Título:** Sincronização bem-sucedida de projeto com Google Drive
**Pré-condições:** Usuário logado no aplicativo e autenticado com uma conta Google válida (via tela de Configurações). Projeto "Projeto Teste Alpha" existe localmente. Conexão com a internet ativa.
**Passos para Execução:**
1.  Na tela Dashboard de Projetos, localizar "Projeto Teste Alpha".
2.  Clicar no ícone de sincronização para este projeto.
3.  Aguardar o término da sincronização.
**Resultado Esperado:** O status da sincronização do projeto é atualizado para "Success" ou "Sucesso", com a data/hora da última sincronização. O relatório PDF e as fotos são enviados para a pasta correta no Google Drive do usuário.
**Resultado Obtido:** Sincronização iniciada com feedback de "Iniciando...", progresso de "Enviando PDF...", "Enviando Fotos X de Y...". Concluído com sucesso. Status atualizado na UI. Arquivos verificados no Google Drive na pasta "AplicativoDeComissionamento/Projeto_Teste_Alpha" e "AplicativoDeComissionamento/Projeto_Teste_Alpha/Fotos". Link do relatório no Drive armazenado no SyncLog. Observação: Feedback de progresso para cada arquivo individual durante o upload de fotos poderia ser mais detalhado (ex: nome do arquivo). Confirmação de conflito para fotos (além do PDF) não implementada (assume overwrite).
**Status:** Passou com Observações

**ID do Caso:** CT_MOBILE_CONECTIVIDADE_001
**Título:** Verificação do indicador de conectividade (Online)
**Pré-condições:** Dispositivo móvel conectado à internet (Wi-Fi ou dados móveis).
**Passos para Execução:**
1.  Abrir o aplicativo e navegar para a tela Dashboard de Projetos.
2.  Observar o ícone de conectividade na AppBar.
**Resultado Esperado:** O ícone de conectividade indica status "Online" (ex: ícone de Wi-Fi verde).
**Resultado Obtido:** Ícone de Wi-Fi verde exibido na AppBar com tooltip "Online".
**Status:** Passou

**ID do Caso:** CT_MOBILE_CONECTIVIDADE_002
**Título:** Verificação do indicador de conectividade (Offline)
**Pré-condições:** Dispositivo móvel sem conexão com a internet (modo avião ou Wi-Fi/dados desligados).
**Passos para Execução:**
1.  Abrir o aplicativo e navegar para a tela Dashboard de Projetos.
2.  Observar o ícone de conectividade na AppBar.
**Resultado Esperado:** O ícone de conectividade indica status "Offline" (ex: ícone de Wi-Fi cortado, vermelho).
**Resultado Obtido:** Ícone de Wi-Fi cortado vermelho exibido na AppBar com tooltip "Offline - Sem conexão com a rede".
**Status:** Passou

---

## Casos de Teste - Área Administrativa Web (MVP)

**ID do Caso:** CT_WEB_LOGIN_001
**Título:** Login com conta Google válida
**Pré-condições:** Administrador possui uma conta Google válida configurada no navegador. URL da aplicação web admin acessível.
**Passos para Execução:**
1.  Acessar a URL da Área Administrativa Web.
2.  Na tela de Login, clicar no botão "Login com Google".
3.  Seguir o fluxo de autenticação do Google, selecionando a conta correta e permitindo acesso, se solicitado.
**Resultado Esperado:** Login é bem-sucedido. Administrador é redirecionado para o Dashboard Web, que exibe "Admin Dashboard - Projetos no Drive". O nome/email do usuário logado é exibido na AppBar.
**Resultado Obtido:** Login realizado com sucesso através do fluxo Google. Redirecionado para o Dashboard. Nome do usuário e foto de perfil (se disponível) exibidos corretamente na AppBar. UI em português.
**Status:** Passou

**ID do Caso:** CT_WEB_DASHBOARD_001
**Título:** Visualização da lista de projetos sincronizados
**Pré-condições:** Administrador logado. Existem projetos sincronizados (com PDF e pasta "Fotos") na pasta "AplicativoDeComissionamento" no Google Drive da conta associada. (Simular 2-3 projetos com dados variados).
**Passos para Execução:**
1.  Acessar o Dashboard da Área Administrativa Web.
2.  Observar a lista de projetos.
**Resultado Esperado:** A lista exibe os nomes dos projetos (nome da pasta do Drive), data da última modificação (do Drive), link para o relatório PDF principal e contagem de fotos na subpasta "Fotos". Projetos são ordenados por data de modificação (mais recentes primeiro).
**Resultado Obtido:** Lista de projetos exibida corretamente com nome da pasta, data da última modificação (formatada como dd/MM/yyyy HH:mm). Link para o PDF principal (primeiro encontrado) e contagem de fotos exibidos. Ordenação por data de modificação (mais recente primeiro) verificada. Observação: Para um grande número de projetos, a falta de paginação ou busca pode ser um problema, mas para MVP está funcional. A interface é responsiva.
**Status:** Passou com Observações

**ID do Caso:** CT_WEB_RELATORIO_001
**Título:** Abertura de um relatório PDF do Drive
**Pré-condições:** Administrador logado. Um projeto listado no Dashboard possui um relatório PDF sincronizado e o link `webViewLink` é válido.
**Passos para Execução:**
1.  No Dashboard, localizar um projeto com relatório PDF.
2.  Clicar no link/botão para abrir o relatório PDF (ex: nome do arquivo PDF ou um ícone).
**Resultado Esperado:** O relatório PDF é aberto em uma nova aba do navegador ou baixado, permitindo sua visualização (comportamento depende do navegador e configuração do Drive).
**Resultado Obtido:** Ao clicar no nome do relatório PDF, o link `webViewLink` do Google Drive é aberto em uma nova aba, exibindo o PDF no visualizador do Google Drive corretamente.
**Status:** Passou

---
