# Casos de Teste: Tratamento de Conflitos de Fotos na Sincronização

Este documento define os casos de teste para a funcionalidade de detecção e resolução de conflitos de fotos durante a sincronização com o Google Drive.

---

**ID do Caso de Teste:** CT_PHOTO_CONFLICT_001
**Título do Cenário:** Conflito Detectado - Foto Local é Diferente da Foto no Drive (Usuário Escolhe Sobrescrever no Drive)
**Pré-condições:**
*   Usuário está logado no aplicativo móvel.
*   Usuário está autenticado com uma conta Google válida no aplicativo, com permissão para acesso ao Google Drive.
*   Existe um projeto "P_Conflito_001" no aplicativo local, que já foi sincronizado com o Google Drive anteriormente.
*   Uma foto `img_01.jpg` existe localmente associada ao projeto "P_Conflito_001". O conteúdo desta foto local foi modificado desde a última sincronização, resultando em um MD5 `MD5_LOCAL_ATUALIZADO`.
*   A foto `img_01.jpg` correspondente existe no Google Drive, na pasta do projeto "P_Conflito_001", com um MD5 `MD5_DRIVE_ANTIGO`, onde `MD5_LOCAL_ATUALIZADO != MD5_DRIVE_ANTIGO`.
**Passos para Execução:**
1.  Navegar para a tela de detalhes do projeto "P_Conflito_001".
2.  Iniciar o processo de sincronização do projeto.
3.  Aguardar a detecção de conflitos. A tela/diálogo de "Resolver Conflitos de Fotos" deve ser exibida, listando `img_01.jpg`.
4.  Para a foto `img_01.jpg` na lista de conflitos, selecionar a opção "Substituir no Drive (usar minha foto)" (ou equivalente).
5.  Tocar no botão "Confirmar e Continuar Sincronização" (ou equivalente).
**Dados de Teste (se aplicável):**
*   Foto Local `img_01.jpg` com MD5 `MD5_LOCAL_ATUALIZADO`.
*   Foto no Drive `img_01.jpg` com MD5 `MD5_DRIVE_ANTIGO`.
**Resultado Esperado:**
*   A foto `img_01.jpg` do dispositivo local é enviada para o Google Drive.
*   A versão anterior de `img_01.jpg` no Google Drive é substituída.
*   O arquivo `img_01.jpg` no Google Drive agora possui o MD5 `MD5_LOCAL_ATUALIZADO`.
*   O processo de sincronização do projeto "P_Conflito_001" é concluído com sucesso.
*   Uma mensagem ou log no aplicativo indica que a foto `img_01.jpg` foi atualizada no Drive.
*   O status da foto local `img_01.jpg` é atualizado para "sincronizado".

---

**ID do Caso de Teste:** CT_PHOTO_CONFLICT_002
**Título do Cenário:** Conflito Detectado - Foto Local é Diferente da Foto no Drive (Usuário Escolhe Manter do Drive)
**Pré-condições:**
*   Mesmas do Cenário CT_PHOTO_CONFLICT_001.
**Passos para Execução:**
1.  Navegar para a tela de detalhes do projeto "P_Conflito_001".
2.  Iniciar o processo de sincronização do projeto.
3.  Aguardar a detecção de conflitos. A tela/diálogo de "Resolver Conflitos de Fotos" deve ser exibida, listando `img_01.jpg`.
4.  Para a foto `img_01.jpg` na lista de conflitos, selecionar a opção "Manter do Drive (não enviar a minha)" (ou equivalente).
5.  Tocar no botão "Confirmar e Continuar Sincronização" (ou equivalente).
**Dados de Teste (se aplicável):**
*   Foto Local `img_01.jpg` com MD5 `MD5_LOCAL_ATUALIZADO`.
*   Foto no Drive `img_01.jpg` com MD5 `MD5_DRIVE_ANTIGO`.
**Resultado Esperado:**
*   A foto `img_01.jpg` do dispositivo local NÃO é enviada para o Google Drive.
*   O arquivo `img_01.jpg` no Google Drive permanece inalterado, mantendo o MD5 `MD5_DRIVE_ANTIGO`.
*   O processo de sincronização do projeto "P_Conflito_001" é concluído com sucesso.
*   Uma mensagem ou log no aplicativo indica que a versão do Drive para `img_01.jpg` foi mantida e a local não foi enviada.
*   O status da foto local `img_01.jpg` é atualizado para refletir que a versão do Drive foi mantida (ex: "sincronizado, versão do Drive mantida" ou similar, dependendo da granularidade do status).

---

**ID do Caso de Teste:** CT_PHOTO_CONFLICT_003
**Título do Cenário:** Múltiplos Conflitos - Resoluções Individuais Diferentes
**Pré-condições:**
*   Usuário logado e autenticado no Google Drive.
*   Projeto "P_MultiConflito_003" existe localmente e foi sincronizado anteriormente.
*   Foto `foto_A.jpg`: Local com MD5 `MD5_LA_NOVO`, no Drive com MD5 `MD5_DA_ANTIGO` (`MD5_LA_NOVO != MD5_DA_ANTIGO`).
*   Foto `foto_B.jpg`: Local com MD5 `MD5_LB_NOVO`, no Drive com MD5 `MD5_DB_ANTIGO` (`MD5_LB_NOVO != MD5_DB_ANTIGO`).
*   Foto `foto_C.jpg`: Local com MD5 `MD5_LC_NOVO`, não existe no Google Drive (foto nova).
**Passos para Execução:**
1.  Iniciar a sincronização do projeto "P_MultiConflito_003".
2.  Na tela de "Resolver Conflitos de Fotos":
    *   Para `foto_A.jpg`, selecionar "Substituir no Drive".
    *   Para `foto_B.jpg`, selecionar "Manter do Drive".
3.  Confirmar as resoluções e continuar a sincronização.
**Resultado Esperado:**
*   A foto `foto_A.jpg` no Google Drive é atualizada e seu MD5 se torna `MD5_LA_NOVO`.
*   A foto `foto_B.jpg` no Google Drive NÃO é alterada e seu MD5 permanece `MD5_DB_ANTIGO`. A versão local de `foto_B.jpg` não é enviada.
*   A foto `foto_C.jpg` é enviada para o Google Drive, e seu MD5 no Drive é `MD5_LC_NOVO`.
*   A sincronização do projeto é concluída com sucesso.
*   Logs refletem as ações tomadas para cada foto.

---

**ID do Caso de Teste:** CT_PHOTO_CONFLICT_004
**Título do Cenário:** Múltiplos Conflitos - Ação Global "Substituir todas no Drive"
**Pré-condições:**
*   Mesmas do Cenário CT_PHOTO_CONFLICT_003.
**Passos para Execução:**
1.  Iniciar a sincronização do projeto "P_MultiConflito_003".
2.  Na tela de "Resolver Conflitos de Fotos", selecionar a ação global "Substituir todas no Drive (usar minhas fotos)" (ou equivalente).
3.  Confirmar as resoluções e continuar a sincronização.
**Resultado Esperado:**
*   A foto `foto_A.jpg` no Google Drive é atualizada e seu MD5 se torna `MD5_LA_NOVO`.
*   A foto `foto_B.jpg` no Google Drive é atualizada e seu MD5 se torna `MD5_LB_NOVO`.
*   A foto `foto_C.jpg` é enviada para o Google Drive (pois não tinha conflito e a ação global de "substituir" não a afeta negativamente, ela seria enviada de qualquer forma). O MD5 no Drive é `MD5_LC_NOVO`.
*   A sincronização do projeto é concluída com sucesso.
*   Logs refletem que as versões locais de `foto_A.jpg` e `foto_B.jpg` foram usadas.

---

**ID do Caso de Teste:** CT_PHOTO_CONFLICT_005
**Título do Cenário:** Múltiplos Conflitos - Ação Global "Manter todas do Drive"
**Pré-condições:**
*   Mesmas do Cenário CT_PHOTO_CONFLICT_003.
**Passos para Execução:**
1.  Iniciar a sincronização do projeto "P_MultiConflito_003".
2.  Na tela de "Resolver Conflitos de Fotos", selecionar a ação global "Manter todas do Drive (não enviar as minhas conflitantes)" (ou equivalente).
3.  Confirmar as resoluções e continuar a sincronização.
**Resultado Esperado:**
*   A foto `foto_A.jpg` no Google Drive NÃO é alterada e seu MD5 permanece `MD5_DA_ANTIGO`.
*   A foto `foto_B.jpg` no Google Drive NÃO é alterada e seu MD5 permanece `MD5_DB_ANTIGO`.
*   A foto `foto_C.jpg` é enviada para o Google Drive (pois não era conflitante e a ação global de "manter do Drive" para conflitos não a impede de ser enviada como nova). O MD5 no Drive é `MD5_LC_NOVO`.
*   A sincronização do projeto é concluída com sucesso.
*   Logs refletem que as versões do Drive para `foto_A.jpg` e `foto_B.jpg` foram mantidas.

---

**ID do Caso de Teste:** CT_PHOTO_CONFLICT_006
**Título do Cenário:** Sem Conflitos de Foto (Fotos Novas ou Idênticas em Conteúdo)
**Pré-condições:**
*   Usuário logado e autenticado no Google Drive.
*   Projeto "P_SemConflito_006" existe localmente.
*   Foto `nova_01.jpg` existe localmente no projeto, com MD5 `MD5_NOVA`, e não existe no Google Drive.
*   Foto `identica_01.jpg` existe localmente no projeto, com MD5 `MD5_ID_LOCAL`.
*   Foto `identica_01.jpg` também existe no Google Drive na pasta do projeto, com MD5 `MD5_ID_DRIVE`, onde `MD5_ID_LOCAL == MD5_ID_DRIVE`.
**Passos para Execução:**
1.  Iniciar a sincronização do projeto "P_SemConflito_006".
**Resultado Esperado:**
*   A tela/diálogo de "Resolver Conflitos de Fotos" NÃO é exibida.
*   A foto `nova_01.jpg` é enviada para o Google Drive. Seu MD5 no Drive é `MD5_NOVA`.
*   A foto `identica_01.jpg` NÃO é enviada novamente para o Google Drive (otimização de sincronização, pois o conteúdo é idêntico).
*   A sincronização do projeto é concluída com sucesso.
*   O status das fotos locais `nova_01.jpg` e `identica_01.jpg` é atualizado para "sincronizado".

---

**ID do Caso de Teste:** CT_PHOTO_CONFLICT_007
**Título do Cenário:** Cancelamento na Tela de Resolução de Conflitos
**Pré-condições:**
*   Mesmas do Cenário CT_PHOTO_CONFLICT_001 (conflito detectado para `img_01.jpg` no projeto "P_Conflito_001").
**Passos para Execução:**
1.  Navegar para a tela de detalhes do projeto "P_Conflito_001".
2.  Iniciar o processo de sincronização do projeto.
3.  Aguardar a detecção de conflitos. A tela/diálogo de "Resolver Conflitos de Fotos" deve ser exibida.
4.  Tocar no botão "Cancelar" (ou equivalente) na tela de resolução de conflitos.
**Resultado Esperado:**
*   A tela de resolução de conflitos é fechada.
*   Nenhuma alteração é feita na foto `img_01.jpg` no Google Drive (permanece com `MD5_DRIVE_ANTIGO`).
*   A foto `img_01.jpg` local não é enviada.
*   O processo de sincronização das fotos para o projeto "P_Conflito_001" é interrompido ou marcado como "requer atenção" / "cancelado pelo usuário". Outros tipos de dados do projeto (ex: PDF principal) podem ou não ser sincronizados, dependendo da estratégia de cancelamento (para MVP, aceitável que a sincronização das fotos seja totalmente interrompida, e as fotos conflitantes permaneçam com status "conflito pendente").
*   O usuário pode retornar à tela anterior (ex: detalhes do projeto).

---
