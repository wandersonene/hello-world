# Manual do Usuário - Aplicativo de Comissionamento a Frio (MVP)

## 1. Introdução

Bem-vindo ao Aplicativo de Comissionamento a Frio!

Este aplicativo foi desenvolvido para auxiliar engenheiros de campo na coleta de dados de inspeção e na geração de relatórios diretamente do dispositivo móvel. O foco principal é permitir um trabalho eficiente em campo, inclusive com funcionalidades offline, garantindo que seus dados estejam seguros e acessíveis para posterior sincronização.

## 2. Primeiros Passos

### 2.1. Instalação

O aplicativo está disponível para dispositivos Android e iOS (simulado). Siga as instruções da loja de aplicativos correspondente ao seu dispositivo ou as orientações fornecidas pela sua equipe para instalar o aplicativo.

### 2.2. Cadastro de Novo Usuário

Para utilizar o aplicativo, você precisará criar uma conta local.

1.  Na tela inicial, toque na opção "Não tem uma conta? Registre-se" (ou similar).
2.  Preencha os seguintes campos:
    *   **Nome Completo:** Seu nome completo.
    *   **CPF ou Email:** Seu CPF ou um endereço de e-mail válido que será seu nome de usuário.
    *   **Senha:** Crie uma senha segura.
    *   **Confirmar Senha:** Repita a senha criada.
3.  Toque no botão "Registrar".

**Importante:** Guarde sua senha em um local seguro. No momento, esta versão do aplicativo (MVP) não possui um mecanismo de recuperação de senha local. Caso a esqueça, pode ser necessário reinstalar o aplicativo, o que resultará na perda de dados locais ainda não sincronizados.

### 2.3. Login

Após o cadastro, ou se já possui uma conta:

1.  Na tela inicial, insira seu **CPF ou Email** cadastrado.
2.  Digite sua **Senha**.
3.  Toque no botão "Login".

## 3. Tela Principal (Dashboard de Projetos)

Ao fazer login, você será direcionado para a Tela Principal, também chamada de Dashboard de Projetos.

*   **Lista de Projetos:** Exibe os projetos de comissionamento que você criou ou aos quais tem acesso. Cada projeto pode mostrar um resumo rápido, como título, cliente e status.
*   **Indicador de Conectividade:** No canto superior, um ícone indica seu status de conexão com a internet (Online/Offline). Isso é importante para a funcionalidade de sincronização.
*   **Catálogo ABNT:** Um ícone de livro na barra superior dá acesso rápido ao site do Catálogo ABNT (requer credenciais Confea/Mutua para acesso completo dentro da visualização web).
*   **Configurações:** Um ícone de engrenagem na barra superior leva à tela de Configurações, onde você pode:
    *   Fazer logout da sua conta local no aplicativo.
    *   Fazer login com sua conta Google para habilitar a sincronização com o Google Drive.

## 4. Gerenciando Projetos

### 4.1. Criando um Novo Projeto

1.  Na Tela Principal, toque no botão flutuante de adição "+" (geralmente no canto inferior direito).
2.  Na tela "Adicionar Novo Projeto", preencha os seguintes campos:
    *   **Título do Projeto:** Um nome descritivo para o projeto.
    *   **Cliente:** O nome do cliente associado ao projeto.
    *   **Tipo de Projeto:** Uma breve descrição do tipo de comissionamento (ex: Instalação Elétrica, Painel de Controle).
    *   **Status:** Selecione o status inicial do projeto (ex: Em Andamento, Pendente).
3.  Toque em "Salvar Alterações do Projeto" (ou similar). O novo projeto aparecerá na sua lista.

### 4.2. Visualizando e Editando Projetos

1.  Na Tela Principal, toque sobre um projeto na lista para abrir seus detalhes.
2.  A tela "Detalhes do Projeto" exibirá todas as informações cadastradas, módulos de inspeção, normas associadas e opções de relatório.
3.  Para editar os dados gerais do projeto (Título, Cliente, Tipo, Status), modifique os campos desejados e toque em "Salvar Alterações do Projeto".

### 4.3. Excluindo um Projeto

1.  Na Tela Principal, localize o projeto que deseja excluir.
2.  Deslize o item do projeto para a esquerda (ou pressione e segure, dependendo da interface) para revelar a opção de exclusão.
3.  Toque no ícone de lixeira ou botão "Excluir".
4.  Uma mensagem de confirmação aparecerá: "Você tem certeza que deseja excluir o projeto {nome do projeto}?".
5.  Toque em "Sim, Excluir" para confirmar ou "Não" para cancelar.

**Atenção:** A exclusão de um projeto é permanente e removerá todos os dados associados localmente (módulos de inspeção, fotos, etc.).

## 5. Coleta de Dados de Inspeção

### 5.1. Acessando Módulos de Inspeção

1.  Abra um projeto na tela de "Detalhes do Projeto".
2.  Role até a seção "Módulos de Inspeção".
3.  Para adicionar um novo módulo, toque no botão "+ Adicionar Módulo de Inspeção".
4.  Selecione o tipo de módulo predefinido da lista (ex: "Inspeção Visual", "Inspeção de Painel Elétrico"). O módulo será adicionado à lista com status "Pendente".

### 5.2. Navegando em um Checklist

1.  Na seção "Módulos de Inspeção" de um projeto, toque sobre um módulo para iniciar ou continuar a inspeção.
2.  Você será levado à tela de Inspeção, que exibe um item do checklist por vez.
3.  Use os botões "Anterior" e "Próximo" para navegar entre os itens do checklist.
4.  A descrição do item de inspeção é exibida claramente.

### 5.3. Preenchendo Itens do Checklist

Para cada item do checklist, você pode registrar:

*   **Status do Item:** Marque como "OK" ou "Não Conforme".
*   **Observações (Texto):** Alguns itens podem ter campos de texto para observações específicas.
*   **Valores Numéricos:** Alguns itens podem requerer a entrada de valores numéricos.
*   **Notas Adicionais do Item:** Um campo de texto geral para notas adicionais sobre aquele item específico.

As informações são salvas automaticamente ao navegar para o próximo item ou ao sair da tela de inspeção.

### 5.4. Capturando e Associando Fotos Técnicas

1.  Em cada item do checklist, há uma seção "Fotos do Item".
2.  Toque no botão "Adicionar Foto".
3.  Escolha a opção:
    *   **Câmera:** Para tirar uma nova foto.
    *   **Galeria:** Para selecionar uma foto existente no seu dispositivo.
4.  Após capturar ou selecionar a foto, você será solicitado a adicionar uma **Legenda**. Digite uma descrição para a foto e salve.
5.  As miniaturas das fotos associadas ao item serão exibidas. Toque em uma miniatura para visualizá-la em tela cheia.
6.  Para excluir uma foto, geralmente há um ícone de lixeira na visualização da foto ou ao lado da miniatura. Confirme a exclusão.

### 5.5. Concluindo uma Inspeção

1.  Após preencher todos os itens do checklist de um módulo (especialmente os obrigatórios, se houver), toque no botão "Concluir Inspeção" (geralmente na barra superior da tela de inspeção).
2.  Se houver itens obrigatórios não preenchidos, o aplicativo poderá alertá-lo.
3.  Ao concluir, o status do módulo de inspeção (ex: na tela de Detalhes do Projeto) será atualizado para "Concluído".

## 6. Gerando Relatórios PDF

### 6.1. Adicionando Assinatura (Opcional)

1.  Na tela de "Detalhes do Projeto", localize a seção "Assinatura do Relatório".
2.  Toque em "Assinar Relatório" (ou similar).
3.  Uma área para desenho será exibida. Desenhe sua assinatura usando o toque na tela.
4.  Toque em "Salvar Assinatura". Você pode "Limpar Assinatura" para desenhar novamente.

### 6.2. Geração do PDF

1.  Na tela de "Detalhes do Projeto", toque no botão "Gerar Relatório PDF".
2.  O aplicativo coletará todos os dados do projeto, inspeções e fotos para compilar o relatório.
3.  Uma mensagem indicará que o relatório foi gerado e salvo localmente (ex: "Relatório gerado: nome_do_arquivo.pdf").
4.  Geralmente, uma opção "ABRIR" ou um ícone aparecerá para visualizar o PDF diretamente no dispositivo usando um aplicativo visualizador de PDF.

## 7. Sincronização com Google Drive

Para fazer backup e compartilhar seus projetos e relatórios, você pode sincronizá-los com o Google Drive.

### 7.1. Login com Google

1.  Acesse a tela de "Configurações" do aplicativo (ícone de engrenagem na Tela Principal).
2.  Na seção "Conta Google", toque em "Login com Google".
3.  Siga as instruções na tela para selecionar sua conta Google e conceder as permissões necessárias para que o aplicativo acesse seu Google Drive (especificamente para criar/gerenciar arquivos na pasta do aplicativo).

### 7.2. Sincronizando um Projeto

1.  Com o login do Google ativo, vá para a tela de "Detalhes do Projeto".
2.  Toque no botão "Sincronizar com Google Drive" (ou um ícone de nuvem/sincronização).
3.  O aplicativo exibirá o progresso:
    *   Conectando...
    *   Verificando pastas no Drive...
    *   Gerando PDF (se ainda não foi gerado ou se houve alterações)...
    *   Enviando PDF...
    *   Enviando Fotos...
4.  Ao final, uma mensagem de "Sincronização concluída com sucesso!" ou de erro será exibida.
5.  **O que é sincronizado:** O relatório PDF principal do projeto e todas as fotos associadas são enviados para uma pasta específica do projeto dentro da pasta "AplicativoDeComissionamento" no seu Google Drive.
6.  **Conflito de PDF:** Se o relatório PDF no Google Drive for mais recente que o seu local, você poderá ser perguntado se deseja sobrescrever o arquivo no Drive com a versão local.

## 8. Exportando e Compartilhando Dados

### 8.1. Enviar Relatório por E-mail

1.  Após gerar o PDF de um projeto (ver seção 6.2), na tela de "Detalhes do Projeto", o botão "Enviar Relatório por E-mail" (ou similar) deve se tornar ativo.
2.  Toque neste botão. O aplicativo tentará abrir seu cliente de e-mail padrão com o PDF anexado.
3.  Preencha o destinatário, assunto (geralmente pré-preenchido) e corpo do e-mail, e envie.

### 8.2. Gerar QR Code do Relatório no Drive

1.  Após uma sincronização bem-sucedida do projeto com o Google Drive (ver seção 7.2), na tela de "Detalhes do Projeto", toque no botão "Gerar QR Code do Relatório no Drive".
2.  Um QR Code será exibido na tela. Este QR Code representa o link direto para o relatório PDF armazenado no Google Drive.
3.  **Como usar:**
    *   Outra pessoa pode escanear este QR Code com um leitor para abrir o relatório.
    *   Você pode ter opções como "Compartilhar Link" (para enviar o link textual) ou "Salvar QR na Galeria".

## 9. Catálogo ABNT

1.  Na Tela Principal (Dashboard de Projetos), toque no ícone de livro na barra superior.
2.  Isso abrirá uma visualização web interna (WebView) do site ABNT Catálogo.
3.  **Nota:** Para acesso completo aos recursos do ABNT Catálogo, você precisará de suas credenciais Confea/Mutua, que deverão ser inseridas dentro do ambiente do site na WebView.
4.  **Adicionando Normas Manualmente:** Para associar normas a um projeto específico, vá para a tela de "Detalhes do Projeto", seção "Normas", e use o botão "Adicionar Norma". Você precisará inserir o ID da norma e sua descrição manualmente.

## 10. Solução de Problemas Básicos

*   **"Esqueci minha senha local, o que faço?"**
    *   Conforme mencionado na seção 2.2, esta versão MVP não possui recuperação de senha local. Perder a senha significa perder o acesso aos dados *locais* que não foram sincronizados. Pode ser necessário reinstalar o aplicativo ou limpar seus dados (o que apagará os projetos no dispositivo). Mantenha sua senha segura.
*   **"Sincronização Falhou."**
    *   Verifique sua conexão com a internet (Wi-Fi ou dados móveis).
    *   Vá em "Configurações" e verifique se você está logado com a conta Google correta. Tente sair e logar novamente.
    *   Tente sincronizar novamente.
    *   Verifique se há espaço de armazenamento suficiente no seu Google Drive.
    *   Se o erro persistir, anote a mensagem de erro (se houver) e contate o suporte.
*   **"Relatório não gera."**
    *   Certifique-se de que o projeto possui módulos de inspeção e que há dados preenchidos neles. Um relatório vazio ou com dados insuficientes pode não ser gerado corretamente.
    *   Verifique se há armazenamento livre suficiente no seu dispositivo.

## Apêndice A: Placeholders para Capturas de Tela

*   `[Placeholder: Tela de Login com campos destacados]`
*   `[Placeholder: Tela de Cadastro com campos]`
*   `[Placeholder: Tela Principal - Dashboard de Projetos com lista e ícones da AppBar]`
*   `[Placeholder: Tela de Detalhes do Projeto - seções Módulos, Normas, Assinatura, botões de Ação]`
*   `[Placeholder: Tela de Novo Projeto/Edição de Projeto com campos]`
*   `[Placeholder: Tela de Inspeção - item de checklist com opções OK/Não Conforme e campo de notas]`
*   `[Placeholder: Tela de Inspeção - seção de Fotos do Item com miniaturas]`
*   `[Placeholder: Tela de Assinatura]`
*   `[Placeholder: Tela de Configurações - opções de Login Google]`
*   `[Placeholder: Exemplo de QR Code gerado]`
*   `[Placeholder: Pop-up de confirmação de exclusão]`
*   `[Placeholder: Indicador de conectividade Online e Offline]`

---
*Fim do Manual do Usuário (MVP)*
