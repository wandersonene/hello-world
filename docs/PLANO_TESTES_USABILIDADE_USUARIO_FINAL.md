# Plano de Testes de Usabilidade com Usuário Final - Aplicativo de Comissionamento a Frio

## Histórico de Versões

| Data       | Versão | Descrição                                                                 | Autor(es)       |
| :--------- | :----- | :------------------------------------------------------------------------ | :-------------- |
| 20/07/2024 | 1.0    | Versão inicial do Plano de Testes de Usabilidade com Usuário Final.       | IA Assistente   |
|            |        | Consolidação das definições, cenários, roteiro e processos de recrutamento. |                 |
|            |        | Ajustes para foco em feedback de erro e experiência offline.              |                 |

## Sumário

1.  [Introdução e Objetivos Gerais do Teste](#1-introdução-e-objetivos-gerais-do-teste)
2.  [Metodologia dos Testes de Usabilidade](#2-metodologia-dos-testes-de-usabilidade)
    *   [2.1. Abordagem](#21-abordagem)
    *   [2.2. Perfil dos Participantes](#22-perfil-dos-participantes)
    *   [2.3. Número de Participantes](#23-número-de-participantes)
    *   [2.4. Escopo das Funcionalidades Testadas](#24-escopo-das-funcionalidades-testadas)
3.  [Cenários de Teste de Usabilidade](#3-cenários-de-teste-de-usabilidade)
4.  [Roteiro do Moderador](#4-roteiro-do-moderador)
5.  [Preparação do Ambiente de Teste e do Aplicativo](#5-preparação-do-ambiente-de-teste-e-do-aplicativo)
6.  [Recrutamento e Agendamento dos Participantes](#6-recrutamento-e-agendamento-dos-participantes)
7.  [Termo de Consentimento Livre e Esclarecido (TCLE)](#7-termo-de-consentimento-livre-e-esclarecido-tcle)
8.  [Coleta e Análise de Dados](#8-coleta-e-análise-de-dados)
9.  [Cronograma Estimado para os Testes](#9-cronograma-estimado-para-os-testes)
10. [Equipe Responsável](#10-equipe-responsável)

---

## 1. Introdução e Objetivos Gerais do Teste

**Propósito do Documento:**
Este documento detalha o plano abrangente para a condução de testes de usabilidade com usuários finais (engenheiros de campo) para o "Aplicativo de Comissionamento a Frio". Ele serve como um guia central para a equipe de projeto, consolidando todos os aspectos do planejamento, execução e análise desses testes. O foco principal é avaliar a usabilidade da versão MVP (Produto Mínimo Viável) do aplicativo móvel, com ênfase na experiência do usuário em cenários realistas, incluindo a interação com funcionalidades offline e a clareza do feedback fornecido pelo sistema, especialmente em situações de erro.

**Objetivos Gerais do Teste:**
Os principais objetivos desta rodada de testes de usabilidade com os engenheiros de campo são:

*   Avaliar a facilidade de aprendizado das funcionalidades essenciais do aplicativo móvel, desde a criação de um projeto até a sincronização do relatório.
*   Identificar os pontos mais comuns de dificuldade, erro ou confusão na interface do usuário (UI) durante a execução de tarefas típicas de comissionamento a frio.
*   Coletar feedback qualitativo sobre a percepção geral de utilidade e satisfação dos engenheiros de campo com o aplicativo em seu estado atual (MVP).
*   Validar se os fluxos de trabalho implementados no aplicativo são intuitivos e se alinham com as expectativas e práticas de trabalho dos engenheiros em campo.
*   Identificar oportunidades de melhoria na interface e na experiência do usuário (UX/UI) que possam ser incorporadas em futuras iterações do produto.
*   Verificar se a terminologia e a linguagem utilizadas na interface (em português do Brasil) são claras e compreensíveis para o público-alvo.
*   Observar como os usuários interagem com as funcionalidades offline e o processo de sincronização, identificando possíveis preocupações ou dificuldades.
*   **Avaliar a clareza e utilidade das mensagens de erro e outros feedbacks do sistema, especialmente em relação a falhas de sincronização, validação de dados ou perda de conectividade.**
*   **Analisar a experiência do usuário ao operar o aplicativo em modo offline, verificando a percepção sobre a disponibilidade de funcionalidades e a segurança dos dados armazenados localmente.**

## 2. Metodologia dos Testes de Usabilidade

### 2.1. Abordagem
Os testes de usabilidade serão conduzidos utilizando uma abordagem qualitativa. As sessões serão moderadas individualmente por um facilitador treinado, que guiará os participantes através de tarefas baseadas em cenários de uso realistas. A coleta de dados se dará por meio da observação direta do comportamento dos usuários, do registro de seus comentários verbais (incentivando a técnica do "pensar em voz alta"), e de respostas a perguntas específicas após cada tarefa e ao final da sessão.

### 2.2. Perfil dos Participantes
Os participantes ideais para esta rodada de testes de usabilidade devem corresponder ao seguinte perfil:

*   **Profissão:** Engenheiros eletricistas, engenheiros de automação, técnicos de comissionamento, ou profissionais com responsabilidades diretas na execução de inspeções e comissionamentos de campo em instalações elétricas ou industriais.
*   **Experiência em Campo:** Mínimo de 1 a 2 anos de experiência prática realizando comissionamento ou inspeções técnicas em campo.
*   **Familiaridade com Tecnologia:** Busca-se um espectro de familiaridade:
    *   Usuários que utilizam aplicativos móveis regularmente para tarefas pessoais e/ou profissionais, mas podem não ser "early adopters" de todas as novas tecnologias.
    *   Usuários com alta afinidade tecnológica, que utilizam diversos apps e ferramentas digitais no seu dia a dia profissional.
    *   *(Opcional)* Usuários com menos afinidade ou que utilizam ferramentas digitais de forma mais básica no trabalho.
*   **Disponibilidade:** Disponibilidade para participar de uma sessão de teste individual, guiada por um facilitador, com duração estimada de 60 a 90 minutos. As sessões poderão ser remotas (via videoconferência com compartilhamento de tela do dispositivo móvel) ou presenciais, dependendo da logística.
*   **Dispositivo Próprio (Preferencial):** Idealmente, os participantes utilizariam seus próprios smartphones (Android ou iOS, conforme disponibilidade e foco do teste) para simular um ambiente de uso mais realista, desde que as ferramentas de gravação/observação possam ser utilizadas. Caso contrário, dispositivos de teste serão fornecidos.
*   **Critérios Adicionais (Desejáveis):**
    *   Participantes que atuem em diferentes tipos de projetos de comissionamento (ex: subestações, painéis industriais, sistemas de controle) para capturar uma variedade de perspectivas.
    *   Não ter participado ativamente do design ou desenvolvimento conceitual deste aplicativo específico para evitar vieses.

### 2.3. Número de Participantes
Para esta rodada inicial de testes de usabilidade qualitativos, recomenda-se a participação de **3 a 5 engenheiros de campo**.

**Justificativa:** De acordo com pesquisas clássicas de usabilidade (como as divulgadas pelo Nielsen Norman Group), testar com um grupo pequeno de 3 a 5 usuários que se encaixam no perfil do público-alvo geralmente é suficiente para identificar a maioria (cerca de 80-85%) dos problemas de usabilidade mais críticos e recorrentes em uma interface. Este número oferece um bom equilíbrio entre a coleta de insights valiosos e a otimização de recursos (tempo e custo) para esta fase do projeto MVP.

### 2.4. Escopo das Funcionalidades Testadas
As seguintes funcionalidades específicas do aplicativo móvel serão incluídas nos cenários de teste de usabilidade:

*   **Autenticação Local:** Login local.
*   **Gerenciamento de Projetos:** Criação, preenchimento de dados.
*   **Módulos de Inspeção e Checklists:** Adição de módulos, navegação, preenchimento de itens (OK/Não Conforme, texto, números), notas, conclusão de módulo.
*   **Captura e Gerenciamento de Fotos Técnicas:** Adição via câmera/galeria, legendas, visualização, exclusão.
*   **Geração e Uso de Relatórios:** Assinatura digital, geração de PDF/A, visualização.
*   **Sincronização com Google Drive:** Login Google, sincronização manual, feedback de progresso e conclusão.
*   **Indicadores e Feedback:** Interpretação do indicador de conectividade (Online/Offline), mensagens de erro (simuladas ou reais), feedback de status de sincronização.
*   **Uso Offline:** Execução de tarefas essenciais (criação de projeto, inspeção, captura de fotos, salvamento de dados) em modo offline e posterior sincronização.
*   **(Opcional) Configurações e Outros:** Acesso à tela de Configurações, Catálogo ABNT (WebView).

## 3. Cenários de Teste de Usabilidade

Os participantes serão apresentados aos seguintes cenários e solicitados a realizar as tarefas descritas. **Os cenários foram ajustados para incluir observações sobre feedback de erro e experiência offline.**

---

### **Cenário 1: Novo Projeto, Inspeção Visual Inicial e Relatório Preliminar (com Simulação de Conectividade)**

*   **Título do Cenário:** Primeiro Contato: Criação de Projeto, Inspeção Inicial e Relatório
*   **Contexto:** Você é um engenheiro de campo e acaba de chegar a uma nova obra para iniciar o comissionamento do Painel Elétrico Geral (QG-01) para o cliente "Construtora Eficiência Ltda.". É o seu primeiro dia no local e sua primeira tarefa é registrar o projeto no aplicativo e realizar uma inspeção visual básica para um relatório preliminar. **O sinal de internet no local é instável.**
*   **Sua Tarefa:**
    1.  Utilizando o aplicativo, crie um novo projeto com os seguintes dados:
        *   **Título do Projeto:** "Inspeção QG-01 - Edifício Comercial Central"
        *   **Cliente:** "Construtora Eficiência Ltda."
        *   **Tipo de Projeto:** "Painel Elétrico de Baixa Tensão"
        *   **Status:** "Em Andamento"
        *   *(Observar como o usuário reage ao indicador de conectividade, se houver, e se ele tem alguma preocupação em criar o projeto offline ou com sinal fraco).*
    2.  Após salvar o projeto, acesse-o e adicione um módulo de inspeção do tipo "Inspeção Visual Geral".
    3.  Inicie a inspeção deste módulo e preencha os três primeiros itens do checklist:
        *   **Item 1 ("Verificação da limpeza geral"):** Considere que o painel está limpo. Marque o item.
        *   **Item 2 ("Verificação da fixação de componentes"):** Você notou um parafuso solto. Marque como "Não Conforme", adicione a nota "Parafuso M6 da tampa frontal inferior solto, necessita reaperto." e capture uma foto. Adicione uma legenda.
            *   *(Se o aplicativo permitir, o moderador pode instruir o usuário a tentar inserir um tipo de dado inválido em um campo de observação ou legenda para observar a reação a uma possível mensagem de erro de validação).*
        *   **Item 3 ("Verificação da identificação de circuitos"):** Identificação correta. Marque o item e capture uma foto de uma etiqueta, adicionando legenda.
    4.  Adicione sua assinatura digital ao projeto.
    5.  Gere um relatório em PDF. Tente visualizar o relatório.
    6.  **(Simulação de Perda de Conexão)** O moderador informa: "Agora, imagine que você perdeu completamente a conexão com a internet. Como você se sente em relação aos dados que acabou de inserir? Você espera poder continuar trabalhando ou sincronizar algo?"

---

### **Cenário 2: Continuação de Inspeção, Detalhamento Normativo e Sincronização (com Simulação de Falha)**

*   **Título do Cenário:** Detalhamento da Inspeção, Normas e Sincronização com a Nuvem
*   **Contexto:** No dia seguinte, você retorna à obra para continuar a inspeção do "Inspeção QG-01 - Edifício Comercial Central". Você precisa avançar no checklist, referenciar uma norma e, ao final do dia, enviar os dados para o Google Drive. **A conexão à internet foi restabelecida, mas pode estar lenta.**
*   **Sua Tarefa:**
    1.  Localize e abra o projeto "Inspeção QG-01".
    2.  Acesse o módulo "Inspeção Visual Geral" e conclua-o (marque os itens restantes como "OK").
    3.  Adicione a norma **ABNT NBR 5410** ao projeto.
    4.  Configure o aplicativo para sincronização com o Google Drive (se não feito antes).
    5.  Realize a sincronização completa do projeto.
        *   *(Observar a percepção do usuário sobre o feedback de progresso da sincronização).*
        *   **(Simulação de Falha na Sincronização)** O moderador pode, se possível tecnicamente sem alterar o app, simular uma falha (ex: desabilitando a rede no meio do processo, ou se o app tiver um modo de demonstração com falhas). Caso contrário, o moderador pode apresentar verbalmente uma mensagem de erro: "O aplicativo exibiu a seguinte mensagem: 'Erro de Sincronização: Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.' O que você faria? Essa mensagem é clara?"*
    6.  Se a sincronização for bem-sucedida (ou após a discussão da falha simulada), gere um QR Code para o link do relatório e simule o compartilhamento.

---

### **Cenário 3: Consulta de Projeto Antigo, Referência Técnica e Status de Conectividade**

*   **Título do Cenário:** Consulta Rápida, Verificação Técnica e Status de Projeto
*   **Contexto:** Você está em uma reunião de planejamento e precisa acessar informações de um projeto antigo, "Reforma Elétrica - Hospital Municipal", que já foi concluído e sincronizado. Surge uma dúvida técnica e você quer consultar o catálogo da ABNT.
*   **Sua Tarefa:**
    1.  Localize o projeto "Reforma Elétrica - Hospital Municipal".
    2.  Abra os detalhes e visualize o relatório PDF final.
        *   *(Perguntar ao usuário como ele sabe que este relatório está atualizado e sincronizado, e se a informação de status é clara).*
    3.  Acesse o Catálogo ABNT e simule uma busca por uma norma sobre "Sistemas Fotovoltaicos".
        *   *(Observar se o usuário percebe se esta funcionalidade requer conexão e como ele reage se estiver offline).*
    4.  Retorne aos detalhes do projeto "Reforma Elétrica - Hospital Municipal" e verifique o status e a data da última sincronização.
    5.  **(Verificação de Indicador de Conectividade)** O moderador pergunta: "Olhando para a tela principal ou para esta tela de detalhes, você consegue me dizer se o aplicativo está atualmente online ou offline? Essa informação é clara para você?"

---

## 4. Roteiro do Moderador

O roteiro a seguir guiará o moderador. **Ajustes foram feitos para incluir perguntas específicas sobre feedback de erro e experiência offline/conectividade.**

### A. Pré-Sessão (Checklist do Moderador)
*(Conforme definido em `docs/CENARIOS_E_ROTEIRO_TESTE_USABILIDADE.md` - inclui ambiente, equipamentos, materiais, software, preparação do aplicativo. Adicionar verificação de como simular perda de conectividade ou apresentar erros se necessário).*

*   `[ ]` ... (todos os itens anteriores)
*   `[ ]` **Planejar como simular perda de conectividade de forma controlada (ex: desativar Wi-Fi/Dados Móveis no dispositivo no momento certo).**
*   `[ ]` **Ter mensagens de erro mock (se a simulação direta no app não for possível) prontas para apresentar ao usuário no Cenário 2.**

### B. Introdução (Script para o Moderador)
*(Conforme definido em `docs/CENARIOS_E_ROTEIRO_TESTE_USABILIDADE.md`)*.

"Olá, [Nome do Participante]... estamos testando o aplicativo, e não você... pense em voz alta..."

### C. Condução dos Cenários de Teste

**(Para cada um dos 3 cenários ajustados):**

1.  **Apresentar o Cenário:** (Conforme script anterior)
2.  **Observação e Anotações:** (Conforme script anterior)
    *   **Adicionar foco em:**
        *   Reação a indicadores de conectividade (online/offline).
        *   Comentários sobre o funcionamento do app sem internet.
        *   Como o usuário interpreta e reage a qualquer mensagem de erro (real ou simulada).
        *   Se o usuário busca ativamente informações sobre o status da sincronização.

3.  **Perguntas Pós-Tarefa (após cada cenário):**
    *   "Obrigado. Em uma escala de 1 (muito difícil) a 5 (muito fácil), quão fácil ou difícil você achou completar esta tarefa geral de [resumir o objetivo do cenário]?"
    *   "Por que você deu essa nota?"
    *   "Houve alguma parte específica desta tarefa que você achou particularmente fácil ou difícil?"
    *   "Houve algo que você achou confuso, pouco claro ou que te surpreendeu?"
    *   **"Durante esta tarefa, você notou alguma informação sobre o status da conexão (online/offline)? Se sim, ela foi útil ou clara para você?"**
    *   **(Se o cenário envolveu trabalho offline ou perda de conexão simulada): "Como você se sentiu ao realizar tarefas [ou ao pensar em realizar tarefas] sem conexão com a internet? Você ficou preocupado com os dados? O aplicativo passou segurança sobre o que estava acontecendo?"**
    *   **(Se ocorreu algum erro ou foi simulado): "A mensagem de erro que apareceu ([lembrar a mensagem ou mostrá-la novamente]) foi clara para você? O que você entendeu que deveria fazer a partir dela? Como essa mensagem poderia ser melhorada?"**
    *   "O que você achou do feedback do aplicativo sobre [ex: o progresso da sincronização, o salvamento de dados]?"
    *   "Você tem alguma sugestão para tornar esta parte do aplicativo mais fácil de usar ou mais clara?"

### D. Pós-Sessão (Perguntas Gerais de Encerramento)
*(Conforme definido em `docs/CENARIOS_E_ROTEIRO_TESTE_USABILIDADE.md`, com adições)*

*   "Qual foi sua impressão geral sobre o aplicativo...?"
*   "...Qual funcionalidade você achou mais útil...?"
*   "...Qual parte achou mais difícil...?"
*   **"Pensando na necessidade de trabalhar em locais sem internet, como você avalia a capacidade do aplicativo de funcionar offline e depois sincronizar os dados? Isso atende às suas expectativas?"**
*   **"De forma geral, o aplicativo forneceu informações suficientes sobre o que estava acontecendo (por exemplo, se estava salvando, sincronizando, se deu algum erro)? Você se sentiu no controle?"**
*   "Você se veria utilizando este aplicativo no seu dia a dia...?"
*   "Você tem alguma sugestão geral de melhoria...?"
*   "Há mais alguma coisa que você gostaria de comentar...?"

"Suas opiniões... Muito obrigado!"

## 5. Preparação do Ambiente de Teste e do Aplicativo

Esta seção detalha os preparativos necessários para garantir que as sessões de teste de usabilidade ocorram sem problemas técnicos e em um ambiente propício para a coleta de dados.

*   **Ambiente Físico (para testes presenciais):**
    *   Sala silenciosa, bem iluminada e com temperatura agradável.
    *   Mesa e cadeira confortáveis para o participante e o moderador.
    *   Minimizar interrupções externas.
*   **Ambiente Virtual (para testes remotos):**
    *   Garantir que a plataforma de videoconferência (ex: Google Meet, Zoom, Teams) esteja funcionando corretamente em todos os dispositivos envolvidos.
    *   Testar a qualidade do áudio e vídeo.
    *   Instruir o participante sobre como compartilhar a tela do seu dispositivo móvel, se necessário.
*   **Dispositivo de Teste:**
    *   Smartphone (Android ou iOS, conforme o escopo do teste) totalmente carregado.
    *   Versão correta do "Aplicativo de Comissionamento a Frio" instalada e testada.
    *   Conexão estável à internet (Wi-Fi e/ou dados móveis) para partes do teste que exigem conectividade. **Capacidade de desabilitar a conectividade de forma controlada para simular cenários offline.**
    *   Espaço de armazenamento suficiente para novos dados, fotos e relatórios gerados durante o teste.
*   **Software e Contas:**
    *   Aplicativos visualizadores de PDF (ex: Google PDF Viewer, Adobe Acrobat Reader) instalados e funcionando.
    *   Conta Google de teste (ex: `testes.comissionamento@gmail.com`) pré-configurada no dispositivo ou credenciais prontas para login no aplicativo para sincronização com o Google Drive.
        *   Verificar se a pasta destino no Google Drive (ex: "AplicativoDeComissionamento_Testes") existe ou pode ser criada, e se a conta de teste tem permissão de escrita.
    *   Câmera do dispositivo funcionando e, opcionalmente, algumas fotos genéricas na galeria para o teste de seleção de imagens.
    *   Software de gravação de tela e áudio (com consentimento do participante) testado. Para testes remotos, a própria plataforma de videoconferência pode oferecer essa funcionalidade.
*   **Dados de Teste e Configuração do Aplicativo:**
    *   **Usuário de Teste:** Um usuário de teste local pré-cadastrado no aplicativo (ex: `engenheiro.teste@empresa.com` / senha `teste123`) para facilitar o login inicial, a menos que o processo de cadastro seja parte do escopo do teste.
    *   **Projetos Pré-existentes (para Cenário 3):** Se o Cenário 3 exigir a consulta a um projeto "antigo" e já sincronizado, garantir que tal projeto (ex: "Reforma Elétrica - Hospital Municipal") esteja presente no aplicativo e/ou na conta Google Drive de teste. Este projeto deve conter dados representativos, incluindo um relatório PDF.
    *   **Limpeza de Dados (para Cenários 1 e 2):** Para os cenários que envolvem a criação de novos projetos, garantir que o aplicativo esteja em um estado "limpo" ou que projetos anteriores não interfiram nas tarefas atuais. Isso pode envolver a limpeza de dados do aplicativo antes da sessão ou o uso de filtros, se disponíveis.
    *   **Templates de Módulos de Inspeção:** Verificar se os templates de módulos de inspeção necessários para os cenários (ex: "Inspeção Visual Geral") estão disponíveis e corretamente configurados no aplicativo.
*   **Materiais de Suporte para o Moderador:**
    *   Cópias impressas ou digitais do Roteiro do Moderador, Cenários de Teste e Termo de Consentimento Livre e Esclarecido (TCLE).
    *   Bloco de notas e canetas, ou software de anotação digital.
    *   (Opcional) Um pequeno "brinde" ou compensação para agradecer ao participante, se definido.
*   **Teste Piloto:**
    *   É altamente recomendável realizar pelo menos uma sessão de teste piloto completa (com um colega da equipe ou alguém que não esteja diretamente envolvido no desenvolvimento) antes de iniciar os testes com os participantes reais. Isso ajuda a:
        *   Refinar o roteiro e os cenários.
        *   Verificar o tempo estimado para cada tarefa e para a sessão total.
        *   Identificar quaisquer problemas técnicos com o ambiente, dispositivo ou aplicativo.
        *   Praticar a moderação e a coleta de dados.

## 6. Recrutamento e Agendamento dos Participantes
*(Esta seção é um resumo do conteúdo de `docs/RECRUTAMENTO_AGENDAMENTO_TCLE.md`)*

**Processo de Identificação:**
Candidatos serão identificados através de listas internas da empresa, indicações de gestores, grupos de associações profissionais (com ética e permissão) e networking profissional. Os critérios de seleção (profissão, experiência, familiaridade com tecnologia, disponibilidade, dispositivo próprio preferencial, não envolvimento prévio no design do app) serão rigorosamente aplicados. Buscar-se-á diversidade na amostra de participantes.

**Contato Inicial e Convite:**
O contato será preferencialmente por e-mail, utilizando um modelo de convite que detalha o propósito do teste, o que se espera do participante, os detalhes da sessão (duração, formato), a confidencialidade e a forma de agradecimento.

**Agendamento:**
Serão oferecidas opções flexíveis de datas e horários, utilizando ferramentas de agendamento ou comunicação direta. Uma confirmação formal será enviada com todos os detalhes da sessão, incluindo o TCLE para leitura prévia. Lembretes serão enviados 24-48 horas antes da sessão.

## 7. Termo de Consentimento Livre e Esclarecido (TCLE)
*(Esta seção é um resumo do conteúdo de `docs/RECRUTAMENTO_AGENDAMENTO_TCLE.md`)*

Um modelo detalhado de Termo de Consentimento Livre e Esclarecido (TCLE) foi preparado. Ele inclui:
*   Identificação do projeto e do pesquisador.
*   Objetivos do teste.
*   Procedimentos da sessão.
*   Riscos e desconfortos potenciais (mínimos).
*   Benefícios (indiretos, para a melhoria da ferramenta).
*   Garantia de confidencialidade, privacidade e anonimato.
*   Cláusula específica para consentimento da gravação da sessão (áudio, vídeo, tela), sendo opcional para o participante.
*   Direito de participação voluntária e retirada a qualquer momento.
*   Informações de contato para dúvidas.
*   Campo para declaração de consentimento e assinatura do participante e do pesquisador.

O TCLE será enviado antecipadamente e revisado/assinado no início de cada sessão.

## 8. Coleta e Análise de Dados

**Coleta de Dados:**
Os dados serão coletados através dos seguintes métodos:
*   **Anotações do Moderador/Observador:** Observações diretas do comportamento do usuário, dificuldades, hesitações, erros, comentários espontâneos e expressões não verbais.
*   **Gravações de Áudio e Tela:** Com o consentimento explícito dos participantes (registrado no TCLE), as sessões (interação com a tela e áudio "pensando em voz alta") serão gravadas para análise posterior detalhada.
*   **Questionários Pós-Tarefa e Pós-Sessão:** As perguntas estruturadas no roteiro do moderador (escalas de facilidade, perguntas abertas) fornecerão feedback direto.
*   **Relatórios de Problemas (Opcional):** Se o aplicativo tiver um mecanismo de feedback ou se problemas críticos forem encontrados, eles poderão ser formalmente registrados.

**Análise de Dados:**
A análise dos dados coletados será predominantemente qualitativa, com o objetivo de:
*   **Identificar Padrões de Comportamento:** Buscar ações, dificuldades e entendimentos recorrentes entre os participantes.
*   **Listar e Priorizar Problemas de Usabilidade:** Catalogar todos os problemas de usabilidade observados (ex: funcionalidade não encontrada, mensagem de erro confusa, fluxo de tarefa ineficiente). Os problemas serão classificados por frequência, impacto na tarefa e severidade percebida.
*   **Extrair Insights Qualitativos:** Capturar as percepções, opiniões, sugestões e o nível de satisfação geral dos usuários.
*   **Relatório de Resultados:** Compilar os achados em um relatório que inclua:
    *   Sumário executivo dos principais problemas e recomendações.
    *   Metodologia utilizada.
    *   Perfil dos participantes.
    *   Resultados detalhados por cenário/tarefa, incluindo citações relevantes e exemplos de dificuldades.
    *   Lista priorizada de problemas de usabilidade com sugestões de melhoria.
    *   Feedback específico sobre a experiência offline e clareza das mensagens de erro.

## 9. Cronograma Estimado para os Testes (Placeholder)

| Etapa                               | Período Estimado | Responsável(eis)      |
| :---------------------------------- | :--------------- | :-------------------- |
| Finalização do Planejamento         | Semana 1         | [Nome/Equipe UX]      |
| Recrutamento de Participantes       | Semanas 1-2      | [Nome/Equipe UX]      |
| Agendamento das Sessões             | Semana 2         | [Nome/Equipe UX]      |
| Preparação do Ambiente/App (Final)  | Semana 2         | [Nome/Equipe UX/Dev]  |
| Realização dos Testes de Usabilidade | Semana 3         | [Nome/Equipe UX]      |
| Análise dos Dados Coletados         | Semana 4         | [Nome/Equipe UX]      |
| Elaboração do Relatório Final       | Semana 4-5       | [Nome/Equipe UX]      |
| Apresentação dos Resultados         | Semana 5         | [Nome/Equipe UX]      |

*(Este cronograma é uma estimativa e pode ser ajustado conforme a disponibilidade dos participantes e da equipe.)*

## 10. Equipe Responsável (Placeholder)

| Papel                                 | Nome(s)                     | Contato (E-mail)            |
| :------------------------------------ | :-------------------------- | :-------------------------- |
| Coordenador do Projeto de Usabilidade | [Nome do Coordenador]       | [coordenador.ux@email.com]  |
| Moderador(es) Principal(ais)          | [Nome do Moderador 1]       | [moderador1.ux@email.com]   |
|                                       | [Nome do Moderador 2 (Opc)] | [moderador2.ux@email.com]   |
| Observador(es)/Anotador(es)           | [Nome do Observador 1]      | [observador1.ux@email.com]  |
|                                       | [Nome do Observador 2 (Opc)]| [observador2.ux@email.com]  |
| Responsável pelo Recrutamento         | [Nome do Recrutador]        | [recrutador.ux@email.com]   |
| Suporte Técnico (App/Ambiente)        | [Nome do Suporte Dev]       | [suporte.dev@email.com]     |

---
Este plano visa garantir que os testes de usabilidade sejam conduzidos de forma eficaz, fornecendo insights valiosos para o aprimoramento contínuo do Aplicativo de Comissionamento a Frio.
