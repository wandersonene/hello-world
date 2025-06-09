# Design da Interface do Usuário para Resolução de Conflitos de Fotos

## 1. Introdução

Este documento descreve o design conceitual da interface do usuário (UI) para o processo de resolução de conflitos de fotos, que podem ocorrer durante a sincronização com o Google Drive. O design baseia-se na estratégia de detecção de conflitos que utiliza MD5 checksum para identificar diferenças de conteúdo entre fotos locais e remotas com o mesmo nome. O objetivo é fornecer ao usuário uma maneira clara e eficiente de visualizar os conflitos e decidir como resolvê-los. Todo o design e os textos estão em português do Brasil.

## 2. Notificação de Conflitos

*   **Quando Notificar:**
    A notificação ocorrerá após a fase de análise da sincronização, quando o sistema já identificou todos os arquivos de fotos que apresentam conflito (mesmo nome, conteúdo diferente). Isso acontecerá antes que qualquer upload ou download de fotos conflitantes seja efetivamente realizado.

*   **Como Notificar:**
    1.  O processo de sincronização (especificamente para as fotos) será pausado automaticamente.
    2.  Uma mensagem de alerta principal será exibida ao usuário, indicando a detecção de conflitos e a necessidade de sua intervenção. Este pode ser um `AlertDialog` ou um `SnackBar` proeminente com uma ação.
        *   **Exemplo de Texto do Alerta:** "Sincronização Pausada: Conflitos de fotos foram detectados! É necessário revisar os itens para continuar a sincronização das fotos."
        *   **Ação no Alerta:** Um botão "Revisar Conflitos" ou "Resolver Agora".

## 3. Design da Tela/Diálogo de Resolução de Conflitos

Adota-se a **Abordagem 1: Diálogo Único com Lista de Conflitos**, por ser mais escalável e eficiente caso haja múltiplos conflitos. Esta pode ser implementada como uma tela modal que cobre a maior parte da interface atual ou uma nova tela na pilha de navegação.

**Título da Tela/Diálogo:** "Resolver Conflitos de Fotos"

**Instrução Principal (abaixo do título):**
"Foram encontradas fotos com o mesmo nome mas conteúdo diferente entre seu dispositivo e o Google Drive. Para cada item abaixo, escolha qual versão da foto você deseja manter. As alterações serão aplicadas ao continuar a sincronização."

**Layout Conceitual:**

```
+----------------------------------------------------------------------+
| Resolver Conflitos de Fotos                                          |
+----------------------------------------------------------------------+
| Instrução Principal...                                               |
+----------------------------------------------------------------------+
| Ações Globais (Aplicar a todos):                                     |
| [ ] Usar Minhas Fotos (Substituir todas no Drive)                    |
| [ ] Usar Fotos do Drive (Manter todas do Drive)                      |
+----------------------------------------------------------------------+
|                                                                      |
| --- Item de Conflito 1 ---                                           |
| Nome do Arquivo: foto_001.jpg                                        |
|                                                                      |
|   Minha Foto (Dispositivo)          Foto no Drive                    |
|   +-----------------+             +-----------------+                |
|   | Miniatura Local |             | Miniatura Drive | (ou Ícone)     |
|   | (data local)    |             | (data Drive)    |                |
|   +-----------------+             +-----------------+                |
|                                                                      |
|   Opções para foto_001.jpg:                                          |
|   ( ) Substituir no Drive (usar esta foto do dispositivo)            |
|   (o) Manter do Drive (manter esta foto que está no Drive)           |
|                                                                      |
| --- Item de Conflito 2 ---                                           |
| Nome do Arquivo: foto_002.jpg                                        |
|                                                                      |
|   Minha Foto (Dispositivo)          Foto no Drive                    |
|   +-----------------+             +-----------------+                |
|   | Miniatura Local |             | Miniatura Drive | (ou Ícone)     |
|   +-----------------+             +-----------------+                |
|                                                                      |
|   Opções para foto_002.jpg:                                          |
|   (o) Substituir no Drive                                            |
|   ( ) Manter do Drive                                                |
|                                                                      |
| ... (mais itens, scrollável se necessário) ...                       |
|                                                                      |
+----------------------------------------------------------------------+
| [ Confirmar e Continuar Sincronização ]  [ Cancelar Sincronização ]  |
+----------------------------------------------------------------------+
```

**Elementos Detalhados da Tela/Diálogo:**

1.  **Título:** "Resolver Conflitos de Fotos"
2.  **Instrução Principal:** Texto conforme descrito acima.
3.  **Ações Globais (Opcional, mas recomendado para usabilidade):**
    *   Um agrupamento de Radio Buttons ou Checkboxes para aplicar uma decisão a todos os conflitos listados.
    *   **Opção 1:** "Aplicar a todos: Usar minhas fotos (substituir todas no Drive)"
        *   Ao selecionar, todas as fotos na lista abaixo teriam sua opção "Substituir no Drive" marcada.
    *   **Opção 2:** "Aplicar a todos: Usar fotos do Drive (manter todas do Drive)"
        *   Ao selecionar, todas as fotos na lista abaixo teriam sua opção "Manter do Drive" marcada.
    *   *Nota:* Se uma ação global for selecionada, as opções individuais ainda podem ser alteradas pelo usuário antes da confirmação final.

4.  **Lista de Conflitos (Scrollável):**
    *   Cada item da lista representa uma foto conflitante e contém:
        *   **Nome do Arquivo:** Label "Nome do Arquivo:" seguido do nome (ex: `foto_fachada_painel.jpg`).
        *   **Comparativo Visual (lado a lado):**
            *   **Coluna "Minha Foto (Dispositivo)":**
                *   Miniatura da foto local.
                *   (Opcional, se útil) Data de modificação/captura da foto local.
            *   **Coluna "Foto no Drive":**
                *   Miniatura da foto do Google Drive.
                    *   *Desafio Técnico:* Obter a miniatura do Drive pode exigir uma chamada de API adicional por foto. Se for custoso, um ícone padrão representando "Arquivo do Google Drive" pode ser usado, acompanhado da data de modificação do Drive para ajudar na decisão. A prioridade é exibir a miniatura local, que está prontamente disponível.
                *   (Opcional, se útil e disponível) Data de modificação da foto no Drive.
        *   **Opções de Resolução para o Item (Radio Buttons):**
            *   Um grupo de Radio Buttons por foto conflitante, garantindo que apenas uma opção seja selecionada para ela.
            *   **Opção A:** "Substituir no Drive (usar esta foto do dispositivo)"
            *   **Opção B:** "Manter do Drive (manter esta foto que está no Drive)"
            *   *Default:* Nenhuma opção pré-selecionada, ou "Manter do Drive" como uma escolha mais conservadora, forçando o usuário a decidir ativamente por sobrescrever. Para MVP, nenhuma pré-seleção é recomendada para garantir atenção do usuário.

5.  **Botões de Ação no Rodapé do Diálogo/Tela:**
    *   **Botão Primário:** "Confirmar e Continuar Sincronização"
        *   Ação: Processa as escolhas feitas para cada conflito (e as ações globais, se usadas) e retoma o processo de sincronização de fotos, aplicando as resoluções.
        *   Habilitação: Este botão só fica habilitado se todas as fotos conflitantes tiverem uma opção de resolução selecionada.
    *   **Botão Secundário:** "Cancelar Sincronização" (ou "Resolver Depois")
        *   Ação: Fecha o diálogo de resolução de conflitos. A sincronização das fotos (ou pelo menos das fotos conflitantes e suas dependentes) é interrompida. O status dessas fotos permanece como "conflito pendente". O usuário pode tentar sincronizar novamente mais tarde, o que re-apresentaria a tela de resolução.

## 4. Opções de Resolução Detalhadas (MVP)

Para o MVP, as opções de resolução por foto e as ações globais serão:

**Para cada foto individualmente:**

1.  **"Substituir no Drive"**
    *   **Label Completa:** "Substituir no Drive (usar esta foto do dispositivo)"
    *   **Ação:** A versão local da foto será enviada ao Google Drive, substituindo o arquivo existente com o mesmo nome na pasta do projeto.
2.  **"Manter do Drive"**
    *   **Label Completa:** "Manter do Drive (manter esta foto que está no Drive)"
    *   **Ação:** A versão local da foto não será enviada. A versão que já existe no Google Drive será considerada a correta/atual para este nome de arquivo. A foto local pode ser marcada internamente como "descartada" ou "não sincronizar".

**Para as ações globais (aplicar a todos):**

1.  **"Aplicar a todos: Usar minhas fotos (substituir todas no Drive)"**
    *   **Ação:** Marca a opção "Substituir no Drive" para todos os itens de conflito listados.
2.  **"Aplicar a todos: Usar fotos do Drive (manter todas do Drive)"**
    *   **Ação:** Marca a opção "Manter do Drive" para todos os itens de conflito listados.

**Opção Avançada (Não MVP): "Manter Ambas"**
A opção "Manter ambas (enviar minha foto com novo nome)" poderia ser considerada para futuras versões. Isso envolveria renomear o arquivo local antes do upload (ex: `foto_001_copia.jpg`) ou o arquivo remoto. Isso adiciona complexidade ao gerenciamento de arquivos e referências.

## 5. Textos da UI (Resumo)

*   **Título do Diálogo/Tela:** "Resolver Conflitos de Fotos"
*   **Instrução Principal:** "Foram encontradas fotos com o mesmo nome mas conteúdo diferente entre seu dispositivo e o Google Drive. Para cada item abaixo, escolha qual versão da foto você deseja manter. As alterações serão aplicadas ao continuar a sincronização."
*   **Labels de Colunas/Seções (por item):** "Minha Foto (Dispositivo)", "Foto no Drive"
*   **Labels das Opções de Resolução (por item):**
    *   "Substituir no Drive (usar esta foto do dispositivo)"
    *   "Manter do Drive (manter esta foto que está no Drive)"
*   **Labels das Ações Globais:**
    *   "Aplicar a todos: Usar minhas fotos (substituir todas no Drive)"
    *   "Aplicar a todos: Usar fotos do Drive (manter todas do Drive)"
*   **Botões de Ação Principais:**
    *   "Confirmar e Continuar Sincronização"
    *   "Cancelar Sincronização" (ou "Resolver Depois", "Adiar Decisões")

## 6. Fluxo de Interação do Usuário

1.  O usuário inicia o processo de sincronização do projeto (que inclui fotos).
2.  O sistema realiza a análise de metadados e hashes MD5, identificando X fotos conflitantes.
3.  A sincronização de fotos é pausada.
4.  O diálogo/tela "Resolver Conflitos de Fotos" é exibido, listando as X fotos.
5.  O usuário examina a lista:
    *   Para cada foto, ele seleciona uma das opções de resolução ("Substituir no Drive" ou "Manter do Drive").
    *   OU, o usuário pode usar uma das "Ações Globais" para aplicar uma decisão padrão a todos os itens e, em seguida, ajustar individualmente se necessário.
6.  Uma vez que todas as fotos conflitantes tenham uma resolução definida, o botão "Confirmar e Continuar Sincronização" se torna ativo.
7.  **Caminho A: Usuário clica em "Confirmar e Continuar Sincronização"**
    *   O diálogo é fechado.
    *   O sistema de sincronização aplica as resoluções escolhidas:
        *   Fotos marcadas como "Substituir no Drive" são enviadas, sobrescrevendo as versões no Drive.
        *   Fotos marcadas como "Manter do Drive" são ignoradas para upload; a versão do Drive é mantida. O status local dessas fotos é atualizado para refletir que a versão do Drive foi escolhida.
    *   A sincronização das demais fotos não conflitantes (e outros dados do projeto) continua normalmente.
    *   Ao final, uma mensagem de sucesso da sincronização (ou com outros avisos, se houver) é exibida.
8.  **Caminho B: Usuário clica em "Cancelar Sincronização"**
    *   O diálogo é fechado.
    *   A sincronização das fotos conflitantes (e possivelmente de todas as fotos do projeto, para simplificar o MVP) é interrompida.
    *   As fotos conflitantes permanecem em um estado "conflito pendente" no dispositivo.
    *   O usuário pode ser informado que "A sincronização foi cancelada. Os conflitos de fotos precisarão ser resolvidos em uma próxima tentativa de sincronização."

Este design visa fornecer controle ao usuário de forma clara, minimizando o risco de perda de dados e tornando o processo de resolução de conflitos o mais transparente possível.
