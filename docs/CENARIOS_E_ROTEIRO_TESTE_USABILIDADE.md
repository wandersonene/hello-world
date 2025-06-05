# Cenários de Teste de Usabilidade e Roteiro do Moderador

Este documento define os cenários de teste que serão apresentados aos engenheiros de campo durante as sessões de teste de usabilidade do aplicativo móvel de Comissionamento a Frio, bem como o roteiro para guiar o moderador durante essas sessões.

## 1. Cenários de Teste de Usabilidade (para os Engenheiros)

Os participantes serão apresentados aos seguintes cenários e solicitados a realizar as tarefas descritas.

---

### **Cenário 1: Novo Projeto, Inspeção Visual Inicial e Relatório Preliminar**

*   **Título do Cenário:** Primeiro Contato: Criação de Projeto, Inspeção Inicial e Relatório
*   **Contexto:** Você é um engenheiro de campo e acaba de chegar a uma nova obra para iniciar o comissionamento do Painel Elétrico Geral (QG-01) para o cliente "Construtora Eficiência Ltda.". É o seu primeiro dia no local e sua primeira tarefa é registrar o projeto no aplicativo e realizar uma inspeção visual básica para um relatório preliminar.
*   **Sua Tarefa:**
    1.  Utilizando o aplicativo, crie um novo projeto com os seguintes dados:
        *   **Título do Projeto:** "Inspeção QG-01 - Edifício Comercial Central"
        *   **Cliente:** "Construtora Eficiência Ltda."
        *   **Tipo de Projeto:** "Painel Elétrico de Baixa Tensão"
        *   **Status:** "Em Andamento"
    2.  Após salvar o projeto, acesse-o e adicione um módulo de inspeção do tipo "Inspeção Visual Geral" (ou o nome mais similar disponível).
    3.  Inicie a inspeção deste módulo e preencha os três primeiros itens do checklist da seguinte maneira:
        *   **Item 1 (ex: "Verificação da limpeza geral do painel/equipamento"):** Considere que o painel está limpo e em boas condições. Marque o item apropriadamente.
        *   **Item 2 (ex: "Verificação da fixação de componentes internos e externos"):** Você notou que o parafuso de fixação da tampa frontal inferior está solto. Marque o item como "Não Conforme", adicione uma nota detalhando "Parafuso M6 da tampa frontal inferior solto, necessita reaperto." e capture uma foto que ilustre claramente este problema. Adicione uma legenda informativa à foto.
        *   **Item 3 (ex: "Verificação da identificação de circuitos e componentes"):** A identificação está clara e correta. Marque o item apropriadamente e, para registro, capture uma foto de uma etiqueta de identificação de disjuntor bem visível, adicionando uma legenda.
    4.  Considerando que esta é uma inspeção preliminar, adicione sua assinatura digital ao projeto para validar esta primeira etapa.
    5.  Finalmente, gere um relatório em PDF deste projeto. Após a geração, tente visualizar o relatório no seu dispositivo para conferir as informações inseridas.

---

### **Cenário 2: Continuação de Inspeção, Detalhamento Normativo e Sincronização Completa**

*   **Título do Cenário:** Detalhamento da Inspeção, Normas e Sincronização com a Nuvem
*   **Contexto:** No dia seguinte, você retorna à obra para continuar a inspeção do "Inspeção QG-01 - Edifício Comercial Central". Além de avançar no checklist, você precisa referenciar uma norma técnica importante e, ao final do dia, garantir que todos os dados coletados sejam enviados para o sistema da empresa (Google Drive).
*   **Sua Tarefa:**
    1.  Localize e abra o projeto "Inspeção QG-01 - Edifício Comercial Central" que você iniciou anteriormente.
    2.  Acesse o módulo de "Inspeção Visual Geral" que você começou.
    3.  Suponha que você preencheu mais alguns itens:
        *   **Item 4 (ex: "Verificação de barreiras de proteção e isolamento"):** Marque como "OK".
        *   **Item 5 (ex: "Observação de danos visíveis em cabos ou barramentos"):** Marque como "OK".
    4.  Agora, conclua este módulo de inspeção.
    5.  O engenheiro responsável pelo projeto solicitou que a norma **ABNT NBR 5410** ("Instalações elétricas de baixa tensão") seja formalmente associada a este projeto. Adicione esta norma ao projeto (se o campo de descrição for editável, você pode adicionar "Requisitos para projeto e execução").
    6.  Para garantir o backup e acesso pela equipe do escritório, configure o aplicativo para sincronização com o Google Drive utilizando a conta fornecida ([Moderador_fornece_conta_teste@gmail.com] ou instrui o uso de conta pessoal, se aplicável).
    7.  Após configurar a conta, realize a sincronização completa do projeto "Inspeção QG-01 - Edifício Comercial Central". Observe o feedback do aplicativo durante o processo.
    8.  Após a sincronização bem-sucedida, gere um QR Code para o link do relatório armazenado no Google Drive e simule que você vai compartilhar este link com um colega (você pode usar a opção de compartilhar ou apenas descrever como faria).

---

### **Cenário 3: Consulta de Projeto Antigo, Referência Técnica e Status de Sincronização**

*   **Título do Cenário:** Consulta Rápida, Verificação Técnica e Status de Projeto
*   **Contexto:** Você está em uma reunião de planejamento e precisa acessar rapidamente informações de um projeto antigo, chamado "Reforma Elétrica - Hospital Municipal", que já foi concluído e sincronizado. Adicionalmente, surge uma dúvida técnica e você quer consultar o catálogo da ABNT.
*   **Sua Tarefa:**
    1.  *(Simulação: O moderador pode ter preparado um projeto com este nome ou similar, já sincronizado. Se não, o participante pode usar o projeto do Cenário 1 e 2, assumindo que ele foi sincronizado).*
        Localize o projeto "Reforma Elétrica - Hospital Municipal" na sua lista de projetos.
    2.  Abra os detalhes deste projeto e encontre uma forma de visualizar o relatório PDF final que foi gerado e sincronizado anteriormente.
    3.  Durante a reunião, um colega menciona uma norma sobre "Sistemas Fotovoltaicos". Utilize a funcionalidade do aplicativo para acessar o Catálogo ABNT e simule uma busca rápida por essa norma (não é preciso fazer login ou encontrar a norma exata, apenas demonstre como acessaria e pesquisaria).
    4.  Retorne aos detalhes do projeto "Reforma Elétrica - Hospital Municipal" e verifique qual foi o status e a data da última sincronização registrada para ele.
    5.  Após estas consultas, retorne à tela principal de listagem de projetos.

---

## 2. Roteiro do Moderador do Teste

### A. Pré-Sessão (Checklist do Moderador)

*   **Ambiente e Equipamentos:**
    *   `[ ]` Sala silenciosa e confortável (para testes presenciais) ou ambiente virtual estável.
    *   `[ ]` Dispositivo móvel de teste (Android/iOS) carregado e com a versão correta do aplicativo "Aplicativo de Comissionamento a Frio" instalada.
    *   `[ ]` Conexão à internet (Wi-Fi e/ou dados móveis) estável e funcionando no dispositivo.
    *   `[ ]` Conta Google de teste configurada no dispositivo (ou credenciais prontas para login), com acesso ao Google Drive. Verificar se a pasta "AplicativoDeComissionamento" existe ou pode ser criada.
    *   `[ ]` Aplicativos visualizadores de PDF instalados e funcionando no dispositivo.
    *   `[ ]` Cliente de e-mail configurado no dispositivo (para teste de envio de relatório).
    *   `[ ]` Câmera do dispositivo funcionando e com algumas fotos na galeria (para teste de seleção de fotos).
*   **Materiais:**
    *   `[ ]` Termo de Consentimento Informado (cópias impressas ou link para assinatura digital).
    *   `[ ]` Roteiro do Moderador (este documento) impresso ou facilmente acessível.
    *   `[ ]` Cenários de teste impressos ou em formato digital para fácil apresentação ao participante.
    *   `[ ]` Canetas/bloco de notas para anotações ou software de anotação digital.
*   **Software (se aplicável):**
    *   `[ ]` Software de gravação de tela e áudio (com permissão do participante) testado e funcionando.
    *   `[ ]` Plataforma de videoconferência (para testes remotos) testada e funcionando.
*   **Preparação do Aplicativo:**
    *   `[ ]` Se necessário, pré-cadastrar um usuário de teste local para os cenários de login (ou estar pronto para guiar o cadastro, se for parte do teste).
    *   `[ ]` Limpar dados de projetos anteriores (se o teste exigir um "começo do zero" para o Cenário 1 e 2) ou garantir que existam projetos adequados e sincronizados para o Cenário 3.

### B. Introdução (Script para o Moderador Ler para o Participante)

"Olá, [Nome do Participante], muito obrigado por dedicar seu tempo para nos ajudar hoje! Meu nome é [Nome do Moderador] e serei o facilitador desta sessão.

Hoje, estamos aqui para testar um novo aplicativo chamado 'Aplicativo de Comissionamento a Frio', que foi desenvolvido para auxiliar engenheiros como você nas inspeções e na geração de relatórios.

É muito importante que você saiba que **estamos testando o aplicativo, e não você**. Não existem respostas certas ou erradas, e você não pode cometer erros. Seu feedback honesto é extremamente valioso para nós e nos ajudará a melhorar o aplicativo.

Todas as informações coletadas hoje, incluindo suas opiniões e quaisquer gravações (se você consentir), serão tratadas com confidencialidade e usadas apenas para fins de pesquisa e desenvolvimento deste produto.

Durante a sessão, pedirei que você realize algumas tarefas usando o aplicativo. Enquanto você realiza essas tarefas, eu gostaria que você **pensasse em voz alta**. Isso significa que você deve tentar verbalizar o que está pensando, o que está tentando fazer, o que espera que aconteça, e como está se sentindo sobre a interface. Quanto mais você falar, mais útil será para nós.

Se você tiver alguma dúvida durante a sessão, pode perguntar. Dependendo da pergunta, eu talvez não possa respondê-la imediatamente, pois estamos interessados em ver como você interage com o aplicativo por conta própria. Mas farei o meu melhor para responder ao final da sessão.

Esta sessão deve durar aproximadamente [60-90] minutos.

Você tem alguma pergunta antes de começarmos?

*(Pausa para perguntas)*

Ótimo. Antes de iniciarmos, peço que você leia e assine este Termo de Consentimento Informado, que formaliza o que conversamos sobre o uso dos dados e sua participação voluntária. *(Apresentar o termo)*."

*(Aguardar assinatura e sanar dúvidas sobre o termo)*

### C. Condução dos Cenários de Teste (Para cada cenário)

**(Para cada um dos 3 cenários definidos anteriormente):**

1.  **Apresentar o Cenário:**
    *   "Agora, vamos para o primeiro/próximo cenário."
    *   Entregue o cartão com o cenário (ou leia em voz alta de forma clara):
        *   "**Título do Cenário:** [Título do Cenário]"
        *   "**Contexto:** [Ler o contexto do cenário]"
        *   "**Sua Tarefa:** [Ler a tarefa do cenário]"
    *   "Você pode ler novamente se precisar. Alguma dúvida sobre o que o cenário está pedindo?" *(Esclarecer o objetivo da tarefa, mas não como usar a interface).*
    *   "Lembre-se de pensar em voz alta enquanto realiza as tarefas."

2.  **Observação e Anotações:**
    *   Observe atentamente o participante.
    *   Anote:
        *   Caminhos que o usuário percorre na interface.
        *   Pontos onde hesita ou parece confuso.
        *   Erros cometidos (e se/como consegue se recuperar).
        *   Comentários espontâneos (positivos ou negativos).
        *   Expressões faciais ou linguagem corporal que indiquem frustração ou satisfação.
        *   Tempo aproximado para completar sub-tarefas chave (se relevante para os objetivos).
        *   Funcionalidades que o usuário não consegue encontrar ou usar.
    *   Use prompts neutros para incentivar o "pensar em voz alta" se o participante ficar em silêncio por muito tempo:
        *   "O que você está pensando agora?"
        *   "O que você esperava que acontecesse ao tocar aí?"
        *   "Como isso se compara com o que você esperava?"

3.  **Perguntas Pós-Tarefa (após a conclusão de cada cenário ou tentativa significativa):**
    *   "Obrigado. Em uma escala de 1 (muito difícil) a 5 (muito fácil), quão fácil ou difícil você achou completar esta tarefa geral de [resumir o objetivo do cenário]?"
    *   "Por que você deu essa nota?"
    *   "Houve alguma parte específica desta tarefa que você achou particularmente fácil ou difícil?"
    *   "Houve algo que você achou confuso, pouco claro ou que te surpreendeu nesta parte do aplicativo?"
    *   "Você esperava que alguma funcionalidade ou botão se comportasse de forma diferente do que aconteceu?"
    *   "O que você achou da funcionalidade de [mencionar uma funcionalidade chave usada no cenário, ex: 'adicionar fotos ao item do checklist' ou 'o processo de sincronização com o Drive']?"
    *   "Você tem alguma sugestão para tornar esta parte do aplicativo mais fácil de usar?"

*(Repetir para todos os cenários)*

### D. Pós-Sessão (Perguntas Gerais de Encerramento)

"Muito bem, concluímos todos os cenários que tínhamos planejado. Agora, gostaria de fazer algumas perguntas mais gerais sobre sua experiência com o aplicativo como um todo."

*   "Qual foi sua impressão geral sobre o aplicativo 'Aplicativo de Comissionamento a Frio'?"
*   "Se você pudesse descrever o aplicativo em poucas palavras, quais seriam?"
*   "Qual funcionalidade ou parte do aplicativo você achou mais útil ou mais gostou? Por quê?"
*   "Qual parte do aplicativo você achou mais difícil de usar, mais confusa ou menos útil? Por quê?"
*   "Existe alguma funcionalidade que você esperava encontrar no aplicativo e não encontrou, ou algo que ele não fez da maneira que você imaginava?"
*   "Pensando no seu dia a dia de trabalho em campo, você se veria utilizando este aplicativo? Por quê ou por que não?"
*   "Se sim, com que frequência você acha que o utilizaria?"
*   "Você tem alguma sugestão geral de melhoria para o aplicativo, seja algo novo ou algo que poderia ser diferente?"
*   "Há mais alguma coisa que você gostaria de comentar ou adicionar sobre sua experiência hoje?"

"Suas opiniões e o tempo que você dedicou hoje são extremamente valiosos para nós e realmente ajudarão a tornar este aplicativo melhor para os engenheiros de campo. Muito obrigado pela sua participação e colaboração!"

*(Encerrar a gravação, se houver. Entregar qualquer incentivo, se aplicável.)*
