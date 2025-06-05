# Definição dos Objetivos, Escopo e Participantes para os Testes de Usabilidade com Engenheiros de Campo

## 1. Objetivos dos Testes de Usabilidade

Os principais objetivos desta rodada de testes de usabilidade com os engenheiros de campo são:

*   Avaliar a facilidade de aprendizado das funcionalidades essenciais do aplicativo móvel, desde a criação de um projeto até a sincronização do relatório.
*   Identificar os pontos mais comuns de dificuldade, erro ou confusão na interface do usuário (UI) durante a execução de tarefas típicas de comissionamento a frio.
*   Coletar feedback qualitativo sobre a percepção geral de utilidade e satisfação dos engenheiros de campo com o aplicativo em seu estado atual (MVP).
*   Validar se os fluxos de trabalho implementados no aplicativo são intuitivos e se alinham com as expectativas e práticas de trabalho dos engenheiros em campo.
*   Identificar oportunidades de melhoria na interface e na experiência do usuário (UX/UI) que possam ser incorporadas em futuras iterações do produto.
*   Verificar se a terminologia e a linguagem utilizadas na interface (em português do Brasil) são claras e compreensíveis para o público-alvo.
*   Observar como os usuários interagem com as funcionalidades offline e o processo de sincronização, identificando possíveis preocupações ou dificuldades.

## 2. Escopo das Funcionalidades a Serem Testadas

As seguintes funcionalidades específicas do aplicativo móvel serão incluídas nos cenários de teste de usabilidade:

*   **Autenticação Local:**
    *   Login local de um usuário (assumindo que contas de teste serão pré-cadastradas para os participantes).
    *   *(Opcional, dependendo do tempo e foco):* Cadastro de novo usuário, para avaliar o primeiro contato completo.
*   **Gerenciamento de Projetos:**
    *   Criação de um novo projeto de comissionamento.
    *   Preenchimento e edição dos dados iniciais do projeto (Título, Cliente, Tipo de Projeto, Status).
*   **Módulos de Inspeção e Checklists:**
    *   Adição de um ou mais módulos de inspeção predefinidos a um projeto.
    *   Navegação sequencial (avançar e retroceder) entre os itens de um checklist dentro de um módulo.
    *   Preenchimento dos diferentes tipos de entrada de dados nos itens do checklist:
        *   Seleção de "OK" / "Não Conforme".
        *   Entrada de texto para observações.
        *   Entrada de valores numéricos.
    *   Uso do campo de "Notas Adicionais do Item".
    *   Conclusão de um módulo de inspeção.
*   **Captura e Gerenciamento de Fotos Técnicas:**
    *   Adição de fotos a um item específico do checklist, utilizando:
        *   A câmera do dispositivo para tirar uma nova foto.
        *   A galeria do dispositivo para selecionar uma foto existente.
    *   Adição de legendas às fotos capturadas/selecionadas.
    *   Visualização e exclusão de fotos associadas a um item.
*   **Geração e Uso de Relatórios:**
    *   Adição de uma assinatura digital ao projeto.
    *   Geração do relatório técnico em formato PDF/A.
    *   Visualização do relatório PDF gerado no dispositivo.
*   **Sincronização com Google Drive:**
    *   Processo de login com a conta Google (se ainda não estiver logado nas Configurações).
    *   Sincronização manual de um projeto completo (PDF e fotos) para o Google Drive.
    *   Feedback de progresso e conclusão da sincronização.
*   **(Opcional) Configurações e Outros:**
    *   Interpretação do indicador de conectividade (Online/Offline).
    *   Navegação para a tela de Configurações e entendimento das opções disponíveis (ex: status do login Google).
    *   Acesso à funcionalidade do Catálogo ABNT (WebView).

## 3. Perfil dos Participantes

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

## 4. Número de Participantes

Para esta rodada inicial de testes de usabilidade qualitativos, recomenda-se a participação de **3 a 5 engenheiros de campo**.

**Justificativa:** De acordo com pesquisas clássicas de usabilidade (como as divulgadas pelo Nielsen Norman Group), testar com um grupo pequeno de 3 a 5 usuários que se encaixam no perfil do público-alvo geralmente é suficiente para identificar a maioria (cerca de 80-85%) dos problemas de usabilidade mais críticos e recorrentes em uma interface. Este número oferece um bom equilíbrio entre a coleta de insights valiosos e a otimização de recursos (tempo e custo) para esta fase do projeto MVP. Se os primeiros 3 participantes revelarem problemas muito semelhantes, pode-se considerar a suficiência dos dados. Se os problemas forem muito diversos, estender até 5 participantes pode trazer mais clareza.
