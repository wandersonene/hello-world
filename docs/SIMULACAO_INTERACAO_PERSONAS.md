# Simulação da Interação de Personas com Cenários de Teste de Usabilidade

Este documento apresenta a simulação da interação de três personas fictícias com os cenários de teste de usabilidade definidos para o aplicativo móvel de comissionamento a frio. O objetivo é antecipar possíveis comportamentos, dificuldades e percepções dos usuários finais.

## 1. Definição das Personas

### Persona 1: Carlos Andrade

*   **Nome Fictício:** Carlos Andrade
*   **Idade (aproximada):** 48
*   **Cargo/Experiência Principal:** Engenheiro Eletricista Sênior, com 20 anos de experiência em comissionamento de grandes instalações industriais e subestações.
*   **Nível de Afinidade com Tecnologia/Aplicativos:** Médio. Utiliza smartphone para e-mails, WhatsApp e notícias. Adotou alguns aplicativos específicos para o trabalho quando exigido, mas desconfia de ferramentas que parecem complicar processos simples. Valoriza a robustez e confiabilidade acima de tudo.
*   **Principais Objetivos/Motivações ao usar o app:**
    *   Garantir a precisão e integridade dos dados coletados.
    *   Agilizar a geração de relatórios para não ter que transcrever dados depois.
    *   Ter um registro claro e rastreável das inspeções.
    *   Evitar perda de informações, especialmente em campo.
*   **Possíveis Frustrações com tecnologia em campo:**
    *   Aplicativos lentos ou que travam.
    *   Perda de dados devido a falhas de sincronização ou bateria.
    *   Interfaces confusas que exigem muitos cliques para tarefas simples.
    *   Dificuldade de uso com luvas ou sob luz solar intensa.

### Persona 2: Mariana Lima

*   **Nome Fictício:** Mariana Lima
*   **Idade (aproximada):** 32
*   **Cargo/Experiência Principal:** Técnica em Automação Pleno, 8 anos de experiência em comissionamento de painéis de controle e sistemas de automação industrial.
*   **Nível de Afinidade com Tecnologia/Aplicativos:** Alto. Utiliza diversos aplicativos para organização pessoal e profissional. Adapta-se rapidamente a novas ferramentas e gosta de explorar funcionalidades. Espera que a tecnologia facilite e otimize seu trabalho.
*   **Principais Objetivos/Motivações ao usar o app:**
    *   Aumentar a eficiência e rapidez na coleta de dados e geração de relatórios.
    *   Poder anexar facilmente evidências fotográficas detalhadas.
    *   Ter acesso rápido a normas e projetos anteriores.
    *   Colaborar de forma mais eficaz com a equipe do escritório.
*   **Possíveis Frustrações com tecnologia em campo:**
    *   Aplicativos com usabilidade pobre ou fluxos de trabalho ilógicos.
    *   Sincronização lenta ou que consome muita bateria/dados.
    *   Falta de feedback claro do sistema sobre o que está acontecendo.
    *   Limitações em funcionalidades offline.

### Persona 3: Ricardo Alves

*   **Nome Fictício:** Ricardo Alves
*   **Idade (aproximada):** 25
*   **Cargo/Experiência Principal:** Engenheiro Eletricista Júnior, recém-formado, atualmente em treinamento e acompanhando engenheiros mais experientes em campo. 1 ano de estágio na área.
*   **Nível de Afinidade com Tecnologia/Aplicativos:** Médio-Alto. Cresceu com tecnologia, usa smartphones e apps para diversas atividades. Está aberto a aprender novas ferramentas, mas pode precisar de alguma orientação para entender completamente os processos de comissionamento e como o app se encaixa neles.
*   **Principais Objetivos/Motivações ao usar o app:**
    *   Aprender e aplicar corretamente os procedimentos de inspeção.
    *   Evitar erros comuns de preenchimento.
    *   Causar uma boa impressão pela organização e uso eficiente das ferramentas.
    *   Ter um guia claro das etapas a seguir durante uma inspeção.
*   **Possíveis Frustrações com tecnologia em campo:**
    *   Não entender a terminologia específica do aplicativo ou do domínio sem ajuda.
    *   Sentir-se perdido no fluxo de navegação do app.
    *   Receber mensagens de erro pouco claras e não saber como proceder.
    *   Medo de fazer algo errado no app que comprometa os dados do projeto.

## 2. Simulação Narrativa da Interação por Persona e Cenário

Utilizaremos os cenários principais definidos no `docs/PLANO_TESTES_USABILIDADE_USUARIO_FINAL.md`.

---

### Persona 1: Carlos Andrade

#### **Cenário 1: Novo Projeto, Inspeção Visual Inicial e Relatório Preliminar (com Simulação de Conectividade)**

*   **Abordagem da Persona:** Carlos é metódico e um pouco cético. Ele lê as instruções com atenção e procura por semelhanças com os formulários em papel que usou por anos. Procura botões e termos claros.

*   **"Pensando em Voz Alta" (Simulado) e Interação:**
    1.  **Criação do Projeto:** "Ok, 'novo projeto'. Onde está isso? Ah, esse botão '+' flutuante. Parece ser o padrão hoje em dia." Clica. "Título do Projeto... 'Inspeção QG-01 - Ed. Comercial Central'. Cliente... 'Construtora Eficiência'. Tipo de Projeto... deixa eu ver as opções... 'Painel Elétrico de Baixa Tensão', confere. Status 'Em Andamento'." Salva. "Até aqui, sem problemas. Os campos são o que eu esperaria."
        *   *(Conectividade)* "Notei que o app mostrou 'offline' rapidamente ali em cima. Ele salva isso localmente, né? Espero que sim, porque nem sempre tem sinal bom na obra."
    2.  **Adicionar Módulo:** "Agora, adicionar 'Inspeção Visual Geral'. Entro no projeto... 'Adicionar Módulo'. Simples." Seleciona o módulo.
    3.  **Preencher Checklist:**
        *   **Item 1:** "Limpeza geral... está ok." Marca "OK". "Fácil."
        *   **Item 2 (Não Conforme):** "Fixação de componentes... parafuso solto. Marco 'Não Conforme'." "Preciso da nota: 'Parafuso M6 da tampa frontal inferior solto, necessita reaperto.' Onde digito? Ah, 'Notas do Item'." Digita. "Agora a foto. 'Adicionar Foto'... 'Câmera'." Tira a foto. "Legenda... 'Tampa inferior solta'." Salva a foto. "Isso de adicionar foto direto no item é bom. Antigamente era uma confusão com fotos separadas."
        *   **Item 3:** "Identificação... ok." Marca "OK". Tira foto e adiciona legenda.
    4.  **Assinatura:** "Assinatura digital... prático, se for seguro." Acessa a função e assina. "Foi mais fácil do que pensei."
    5.  **Gerar PDF:** "Gerar relatório PDF." Clica. "Gerou rápido." Tenta visualizar. "Abriu o PDF, as informações parecem estar todas lá. A foto com a legenda também. Bom."
    6.  **(Simulação de Perda de Conexão)** Moderador: "Imagine que perdeu a conexão." Carlos: "Bom, se ele salvou tudo até aqui no aparelho, como parece que fez, estou tranquilo. Sincronizo quando voltar para o escritório ou pegar um sinal melhor. O importante é não perder o que já fiz."

*   **Pontos de Dificuldade/Hesitação:**
    *   Poderia hesitar inicialmente em encontrar o botão de "novo projeto" se não fosse o "+" flutuante.
    *   Se a nomenclatura dos módulos de inspeção não fosse clara, ele poderia demorar a encontrar o correto.
*   **Erros Cometidos (Simulados):**
    *   Poderia esquecer de adicionar uma legenda à foto se não fosse explicitamente solicitado ou se o campo não fosse proeminente. Se o app desse um erro por legenda obrigatória (não é o caso no MVP), ele ficaria um pouco irritado: "Por que não avisou antes de eu tentar salvar?"
*   **Sucessos e Facilidades:**
    *   Achou o fluxo de criação de projeto e preenchimento de checklist bastante direto.
    *   Gostou da funcionalidade de anexar fotos diretamente aos itens.
    *   A geração de PDF foi considerada eficiente.
*   **Feedback sobre Conectividade/Offline:**
    *   Percebeu o indicador de conectividade.
    *   Mostrou-se confortável com o trabalho offline, contanto que os dados estejam salvos localmente de forma segura. Sua principal preocupação é a perda de dados.

---

### Persona 2: Mariana Lima

#### **Cenário 2: Continuação de Inspeção, Detalhamento Normativo e Sincronização (com Simulação de Falha)**

*   **Abordagem da Persona:** Mariana é ágil e espera que o app acompanhe seu ritmo. Ela explora a interface rapidamente e tenta antecipar os próximos passos.

*   **"Pensando em Voz Alta" (Simulado) e Interação:**
    1.  **Abrir Projeto:** "Continuar o 'QG-01'. Abro a lista de projetos, clico nele. Intuitivo."
    2.  **Concluir Módulo:** "Acessar 'Inspeção Visual Geral'... preencher os itens 4 e 5 como 'OK'." Marca rapidamente. "Agora, 'Concluir Módulo'. Deve ter um botão no final da lista ou um menu." Encontra e conclui.
    3.  **Adicionar Norma:** "Adicionar norma ABNT NBR 5410. Onde seria isso? Nos detalhes do projeto, talvez?" Navega para os detalhes. "Ah, aqui, 'Normas Aplicáveis'. Adiciono."
    4.  **Configurar Sincronização Google Drive:** "Configurar Google Drive. Provavelmente nas Configurações do app." Acessa Configurações. "Login com Google. Padrão." Faz o login. "Ok, conectado."
    5.  **Sincronizar Projeto:** "Volto para o projeto e procuro o botão de sincronizar. Ícone de nuvem, geralmente." Clica para sincronizar.
        *   *(Feedback de Progresso)* "Gosto de ver uma barra de progresso ou um status claro, especialmente se tiver muitas fotos."
        *   **(Simulação de Falha na Sincronização)** Moderador apresenta mensagem: "Erro de Sincronização: Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente." Mariana: "Ok, a mensagem é clara. 'Verifique sua conexão'. Eu checaria meu Wi-Fi ou dados móveis. Se estivesse tudo ok, tentaria de novo. Se o erro persistir, talvez eu procurasse uma opção de 'tentar mais tarde' ou um log de erros mais detalhado para ver se é algo específico."
    6.  **Gerar QR Code (após sincronização bem-sucedida):** "Gerar QR Code do relatório no Drive. Interessante. Onde estaria essa opção? Talvez no menu do projeto sincronizado ou na lista de relatórios?" Procura. "Aqui! Facilita o compartilhamento."

*   **Pontos de Dificuldade/Hesitação:**
    *   Poderia hesitar em encontrar a opção de "Adicionar Norma" se não estivesse claramente nos detalhes do projeto.
    *   Achar a opção de "Gerar QR Code" pode depender da sua proeminência na UI.
*   **Erros Cometidos (Simulados):**
    *   Se a mensagem de erro da falha de sincronização fosse genérica (ex: "Erro código 50023"), ela ficaria frustrada: "Que erro é esse? O que eu faço agora? Preciso de mais informação!"
*   **Sucessos e Facilidades:**
    *   Navegação entre projetos e módulos considerada rápida.
    *   Login com Google e início da sincronização foram diretos.
    *   A clareza da mensagem de erro simulada foi positiva.
*   **Feedback sobre Conectividade/Offline:**
    *   Espera que o app gerencie bem a transição entre online e offline.
    *   Valoriza o feedback claro sobre o status da sincronização e possíveis erros.

---

### Persona 3: Ricardo Alves

#### **Cenário 3: Consulta de Projeto Antigo, Referência Técnica e Status de Conectividade**

*   **Abordagem da Persona:** Ricardo é cuidadoso e um pouco ansioso para não cometer erros. Ele pode demorar um pouco mais para encontrar as coisas, mas tenta seguir a lógica do app.

*   **"Pensando em Voz Alta" (Simulado) e Interação:**
    1.  **Localizar Projeto Antigo:** "Preciso achar 'Reforma Elétrica - Hospital Municipal'. Tem uma busca na lista de projetos? Ou um filtro por 'Concluído'?" Explora a lista. "Achei! Clico para abrir."
    2.  **Visualizar PDF Sincronizado:** "Visualizar o relatório PDF final. Deve estar aqui nos detalhes do projeto... 'Ver Relatório PDF' ou algo assim." Clica. "Abriu. Parece o relatório final mesmo."
        *   *(Status de Sincronização)* "Como sei que este é o *último* sincronizado? Tem alguma data ou status aqui?" Procura por indicadores de data/hora da última sincronização do relatório.
    3.  **Acessar Catálogo ABNT:** "Consultar Catálogo ABNT. Onde fica isso? Menu principal? Configurações?" Procura. "Ah, um item 'Catálogo ABNT'. Clico." (Abre o WebView). "Ok, parece um site. Digitaria 'Sistemas Fotovoltaicos' na busca do site."
        *   *(Conectividade para WebView)* "Isso precisa de internet, certo? Se eu estivesse offline, essa tela não carregaria ou daria um aviso?"
    4.  **Verificar Status da Última Sincronização:** "Voltar para os detalhes do projeto 'Reforma Elétrica'. Onde diz quando foi a última sincronização? Talvez um campo 'Última Sincronização bem-sucedida em DD/MM/AAAA HH:MM'?" Procura essa informação.
    5.  **(Verificação de Indicador de Conectividade)** Moderador: "O app está online ou offline?" Ricardo: "Deixa eu ver... tem aquele ícone de nuvem ou Wi-Fi no topo? Se tiver verde, online. Se vermelho ou com um traço, offline. Precisa ser bem visível."

*   **Pontos de Dificuldade/Hesitação:**
    *   Pode ter dificuldade em encontrar informações específicas como a data da última sincronização se não estiverem claramente visíveis.
    *   Pode ficar confuso se o acesso ao Catálogo ABNT (WebView) falhar offline sem uma mensagem clara do porquê.
*   **Erros Cometidos (Simulados):**
    *   Se não houver uma barra de busca ou filtros eficientes, ele pode demorar muito para achar um projeto antigo em uma lista longa.
    *   Poderia não entender que o Catálogo ABNT é uma funcionalidade online e ficar confuso se não funcionar offline. Uma mensagem como "Funcionalidade online. Verifique sua conexão." seria útil.
*   **Sucessos e Facilidades:**
    *   Achar e abrir o projeto e o PDF foi relativamente fácil.
    *   O acesso ao Catálogo ABNT (se o link estiver claro) também.
*   **Feedback sobre Conectividade/Offline:**
    *   Preocupa-se em saber se as funcionalidades exigem conexão.
    *   Um indicador de conectividade global e persistente seria muito valorizado por ele.
    *   Mensagens claras sobre o que acontece quando tenta usar uma função online estando offline são importantes.

---

Estas simulações narrativas ajudam a antecipar como diferentes perfis de usuários podem interagir com o aplicativo, destacando áreas potenciais de confusão ou frustração, bem como funcionalidades que provavelmente serão bem recebidas. Elas reforçam a importância de feedback claro do sistema, especialmente em relação à conectividade, status de sincronização e mensagens de erro.
