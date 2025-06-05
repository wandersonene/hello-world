# Estratégia de Detecção de Conflitos para Sincronização de Fotos com Google Drive

## 1. Introdução

Este documento descreve a análise e a estratégia recomendada para a detecção de conflitos de arquivos de fotos durante o processo de sincronização entre o aplicativo móvel de comissionamento e o Google Drive. O objetivo é garantir uma forma robusta e eficiente de identificar se uma foto local, prestes a ser sincronizada, conflita com uma versão já existente no Google Drive, permitindo um tratamento adequado desses conflitos.

## 2. Revisão da Abordagem Atual (Conflito de PDF)

A abordagem atual para detecção de conflito do arquivo PDF do relatório principal do projeto baseia-se na comparação do `modifiedTime` (data da última modificação) do arquivo no Google Drive com um campo `updated_at` (ou similar) do projeto no banco de dados local.

*   **Prós para PDF:**
    *   Simples de implementar, pois o PDF é geralmente um único arquivo por projeto e sua lógica de atualização está atrelada à atualização do projeto como um todo.
    *   Menos crítico se um falso positivo ocorrer (ex: pedir para o usuário confirmar o reenvio de um PDF idêntico), pois é apenas um arquivo.

*   **Contras para Fotos Individuais usando apenas `modifiedTime`:**
    *   **Imprecisão:** O `modifiedTime` de um arquivo pode ser alterado sem que o conteúdo real da foto mude (ex: alteração de metadados EXIF por algum processo, cópia do arquivo). Inversamente, o conteúdo pode mudar e o `modifiedTime` não ser um indicador confiável devido a problemas de sincronia de relógio entre o dispositivo e o servidor, ou a forma como o sistema operacional atualiza essa data.
    *   **Performance:** Se for necessário fazer uma chamada de API para obter o `modifiedTime` de cada foto *antes* de decidir se faz o upload, isso pode ser lento para um grande número de fotos.
    *   **Falsos Positivos/Negativos:** Alta probabilidade de identificar erroneamente um conflito ou de falhar em detectar um conflito real.

Devido a essas desvantagens, usar apenas `modifiedTime` não é ideal para fotos, que são múltiplas e cujo conteúdo é o principal fator de diferenciação.

## 3. Análise de Estratégias Alternativas para Fotos

### a) Checksum/Hash (ex: MD5)

*   **Descrição:**
    1.  Para cada foto local a ser sincronizada, calcular seu hash (ex: MD5).
    2.  Antes do upload, verificar se um arquivo com o mesmo nome já existe na pasta de destino no Google Drive.
    3.  Se existir, obter o `md5Checksum` do arquivo no Drive através da API (`files.get` com `fields=id,name,md5Checksum`).
    4.  Comparar o hash local com o `md5Checksum` do Drive.
        *   Se os hashes forem diferentes, o conteúdo dos arquivos difere, indicando um conflito real.
        *   Se os hashes forem iguais, os arquivos são idênticos em conteúdo, e o upload pode ser pulado (ou o arquivo local pode ser marcado como sincronizado sem reenvio).
        *   Se o arquivo no Drive não tiver `md5Checksum` (raro para arquivos enviados pelo Drive API, mas possível para alguns tipos de documentos Google nativos ou arquivos muito grandes), pode-se usar uma estratégia de fallback (ex: tamanho + `modifiedTime`, ou tratar como conflito).
*   **Prós:**
    *   **Alta Precisão:** É a forma mais confiável de determinar se o *conteúdo* de dois arquivos é idêntico ou diferente. A API do Google Drive fornece o `md5Checksum` para a maioria dos arquivos.
    *   **Evita Uploads Desnecessários:** Se os hashes são iguais, o upload da foto pode ser evitado, economizando banda e tempo.
*   **Contras:**
    *   **Custo de Cálculo Local:** Calcular o hash MD5 localmente para cada foto consome recursos de CPU e pode levar tempo, especialmente em dispositivos mais lentos ou para um grande volume de fotos. No entanto, bibliotecas otimizadas podem mitigar isso, e o cálculo pode ser feito em background.
    *   **Chamadas de API:** Se muitos arquivos com nomes idênticos existirem, ainda será necessária uma chamada de API por foto para obter o `md5Checksum` do arquivo remoto e comparar.

### b) Tamanho do Arquivo + Nome

*   **Descrição:**
    1.  Verificar se um arquivo com o mesmo nome existe na pasta de destino no Drive.
    2.  Se existir, comparar o tamanho do arquivo local (em bytes) com o tamanho do arquivo no Drive (obtido via API, `files.get` com `fields=id,name,size`).
    3.  Se os nomes forem iguais, mas os tamanhos forem diferentes, considera-se um conflito.
*   **Prós:**
    *   **Simplicidade e Rapidez:** Obter o tamanho do arquivo localmente é rápido. A comparação é simples. O `size` é um metadado facilmente disponível via API do Drive.
    *   **Menos Chamadas de API se Nomes Diferentes:** Se os nomes dos arquivos locais forem únicos (ex: usando timestamp ou UUID no nome), não há necessidade de chamadas de API para verificar conflitos antes do upload (exceto para listar arquivos existentes e verificar nomes).
*   **Contras:**
    *   **Menor Robustez:** Embora menos comum para fotos, é teoricamente possível que dois arquivos de fotos diferentes tenham exatamente o mesmo tamanho. Mais realisticamente, uma pequena alteração no conteúdo (ex: edição leve, alteração de metadados que afete o tamanho) pode não ser detectada se o tamanho resultante for o mesmo do arquivo original, ou se a diferença de tamanho for desprezível e não considerada.
    *   **Não Detecta Alterações de Conteúdo com Mesmo Tamanho:** Se o conteúdo de uma foto for alterado, mas o tamanho do arquivo permanecer idêntico, essa estratégia não detectará o conflito.

### c) Combinação de `modifiedTime` e Tamanho do Arquivo

*   **Descrição:**
    1.  Verificar se um arquivo com o mesmo nome existe no Drive.
    2.  Se sim, obter `modifiedTime` e `size` do arquivo no Drive.
    3.  Considerar um conflito se o `modifiedTime` do arquivo no Drive for diferente do `modifiedTime` local (ou de um timestamp de "última edição local") **OU** se o `size` for diferente.
*   **Prós:**
    *   Um pouco mais robusto do que usar apenas `modifiedTime` ou apenas `size`.
*   **Contras:**
    *   Ainda herda as limitações e a imprecisão do `modifiedTime`.
    *   A complexidade de gerenciar `modifiedTime` de forma confiável para fotos locais (que podem ser copiadas, movidas, etc.) pode ser alta.

## 4. Considerações de Performance e UX

*   **Número de Fotos:** O aplicativo pode lidar com dezenas ou até centenas de fotos por projeto. Uma estratégia que exija muitas operações por foto (seja cálculo local pesado ou múltiplas chamadas de API por foto) pode tornar a sincronização lenta e frustrante.
*   **Chamadas de API:** É crucial minimizar chamadas de API para evitar "rate limiting" do Google Drive e para acelerar o processo. Estratégias que podem decidir sobre o status de um arquivo localmente ou com poucas chamadas em lote são preferíveis.
*   **Falsos Positivos/Negativos:**
    *   **Falsos Negativos (não detectar um conflito real):** Grave, pois pode levar à perda de dados ou à sobrescrita de uma versão importante da foto no Drive sem o conhecimento do usuário.
    *   **Falsos Positivos (alertar sobre conflito inexistente):** Pode ser irritante para o usuário se ocorrer com frequência, levando-o a ignorar alertas ou a realizar ações desnecessárias.
*   **Feedback ao Usuário:** Independentemente da estratégia, o usuário precisa de feedback claro durante a sincronização, especialmente se conflitos forem detectados e exigirem sua intervenção.

## 5. Recomendação e Justificativa

Recomenda-se a seguinte estratégia híbrida, priorizando a precisão do **MD5 Checksum**, mas com otimizações para performance:

**Estratégia Recomendada: MD5 Checksum com Otimização de Listagem e Upload Condicional**

1.  **Nomenclatura de Arquivos Locais:**
    *   Ao salvar uma foto localmente, utilize um nome de arquivo que seja preferencialmente único dentro do contexto do projeto (ex: `projetoID_itemID_timestamp.jpg` ou `projetoID_itemID_uuid.jpg`). Isso minimiza a chance de colisões de nome por si só.
    *   Armazene o `filePath`, `fileName`, `local_md5_checksum` (calculado no momento de salvar/editar a foto) e `size` em um registro local associado à foto no banco de dados do aplicativo. O cálculo do MD5 pode ser feito em uma thread de background para não bloquear a UI.

2.  **Processo de Sincronização:**
    *   **Passo 1: Listar Arquivos Remotos:** Para um projeto sendo sincronizado, primeiro liste *todos* os arquivos na pasta de destino do projeto no Google Drive. Obtenha `id`, `name`, `md5Checksum` e `size` para cada arquivo remoto. Armazene essa lista temporariamente.
        *   *Otimização:* Esta é uma única chamada de API (`files.list` com `q` para filtrar pela pasta pai e `fields` apropriado) para obter os metadados de todos os arquivos remotos relevantes.
    *   **Passo 2: Comparação Local:** Para cada foto local que precisa ser sincronizada:
        *   **Verificação por Nome:** Procure na lista de arquivos remotos (obtida no Passo 1) um arquivo com o mesmo `fileName`.
        *   **Se NÃO existir arquivo com mesmo nome remoto:** A foto é nova. Faça o upload. Após o upload bem-sucedido, armazene o `id` do Drive e o `md5Checksum` (retornado pela API do Drive após o upload) no registro local da foto.
        *   **Se existir arquivo com mesmo nome remoto:**
            *   Compare o `local_md5_checksum` (pré-calculado e armazenado) com o `md5Checksum` do arquivo remoto.
            *   **Se os hashes MD5 forem IGUAIS:** O conteúdo do arquivo é o mesmo. Nenhum upload é necessário. Apenas atualize o registro local da foto com o `id` do Drive do arquivo correspondente, marcando-a como sincronizada.
            *   **Se os hashes MD5 forem DIFERENTES:** **CONFLITO DETECTADO.** O conteúdo do arquivo local é diferente do arquivo remoto com o mesmo nome. O aplicativo deve acionar a interface de resolução de conflitos (descrita em outra tarefa).
            *   **Se o arquivo remoto não tiver `md5Checksum` (caso raro):** Como fallback, compare o `size` do arquivo local com o `size` do arquivo remoto. Se os tamanhos forem diferentes, trate como conflito. Se os tamanhos forem iguais, pode-se optar por tratar como conflito (mais seguro) ou considerar sincronizado (risco de falso negativo). Dada a raridade e a importância de não perder dados, tratar como conflito é o mais prudente aqui.

**Justificativa:**

*   **Precisão:** O uso do MD5 checksum é a forma mais precisa de identificar se o conteúdo das fotos difere, minimizando falsos negativos e falsos positivos relacionados ao conteúdo.
*   **Performance:**
    *   O cálculo do MD5 local é feito uma vez quando a foto é salva/modificada, e não repetidamente durante cada ciclo de sincronização, diluindo o custo computacional.
    *   A listagem de arquivos remotos é feita com uma única chamada de API eficiente por projeto.
    *   Uploads desnecessários são evitados se os hashes MD5 locais e remotos coincidirem, economizando tempo e dados.
    *   Não são necessárias chamadas de API individuais *por foto* para verificar metadados *antes* de decidir sobre um conflito, a menos que um arquivo com o mesmo nome já exista.
*   **Robustez:** A estratégia lida bem com arquivos novos, arquivos idênticos e arquivos com conteúdo diferente.
*   **Experiência do Usuário:** Embora o cálculo inicial do MD5 possa adicionar um pequeno overhead ao salvar a foto, isso geralmente ocorre em momentos onde o usuário já espera alguma operação de I/O. A sincronização se torna mais confiável. A interface de resolução de conflitos só será acionada quando houver uma diferença real de conteúdo.

**Abordagem MVP e Melhorias Futuras:**

*   **MVP Mais Simples (se a implementação do MD5 pré-calculado for complexa inicialmente):**
    1.  Ao sincronizar, para cada foto local:
    2.  Verifique se existe um arquivo com o mesmo nome no Drive.
    3.  **Se existir:** Faça uma chamada de API para obter o `md5Checksum` e `size` do arquivo remoto. Calcule o MD5 da foto local *agora*. Compare.
        *   Isso aumenta as chamadas de API e o cálculo de MD5 durante a sincronização, mas simplifica o armazenamento local (não precisa de `local_md5_checksum` pré-calculado).
    4.  **Se não existir:** Faça o upload.
    *   *Desvantagem do MVP:* Performance de sincronização mais lenta se houver muitas fotos que já existem no Drive com o mesmo nome.
*   **Melhorias Futuras:**
    *   **Sincronização em Background:** Todo o processo de cálculo de MD5 e sincronização deve rodar em threads de background para não bloquear a UI.
    *   **Detecção de Renomeação/Movimentação (Muito Complexo):** Se um arquivo for renomeado no Drive, esta estratégia o trataria como um novo arquivo no local e um arquivo excluído no Drive (se a lógica de "arquivos apenas no Drive" for implementada). Rastrear movimentações/renomeações é significativamente mais complexo e geralmente fora do escopo de MVPs.
    *   **Comparação Delta (Não aplicável para fotos):** Para alguns tipos de arquivos, apenas as diferenças (deltas) são sincronizadas. Isso não é prático para arquivos de imagem binários como JPEGs.

## 6. Descrição Clara da Lógica da Estratégia Escolhida (Recomendada)

1.  **Ao Adicionar/Modificar uma Foto no App (Localmente):**
    *   Salvar a foto no armazenamento local.
    *   Gerar um nome de arquivo único (ex: `projetoID_itemID_timestamp.jpg`).
    *   **Calcular o MD5 checksum da foto (em background).**
    *   Armazenar no banco de dados local: `caminho_do_arquivo`, `nome_do_arquivo`, `md5_local_calculado`, `tamanho_do_arquivo`, `status_sincronizacao = 'pendente'`.

2.  **Durante o Processo de Sincronização de um Projeto:**
    *   **Obter Lista Remota:**
        *   Fazer uma chamada à API do Google Drive (`files.list`) para buscar todos os arquivos na pasta do projeto no Drive.
        *   Para cada arquivo remoto, obter: `id_drive`, `nome_arquivo_drive`, `md5_drive`, `tamanho_drive`.
        *   Armazenar essa lista em memória.
    *   **Iterar sobre Fotos Locais Pendentes:**
        *   Para cada foto local com `status_sincronizacao = 'pendente'`:
            *   Tentar encontrar na lista remota um arquivo onde `nome_arquivo_drive == nome_do_arquivo` (da foto local).
            *   **Caso A: Nenhum arquivo com mesmo nome encontrado no Drive.**
                *   Fazer upload da foto local para o Drive.
                *   Após upload bem-sucedido, a API do Drive retornará o `id_drive_novo` e `md5_drive_novo` do arquivo recém-criado.
                *   Atualizar o registro local da foto: `status_sincronizacao = 'sincronizado'`, `id_google_drive = id_drive_novo`, `md5_remoto_confirmado = md5_drive_novo`.
            *   **Caso B: Arquivo com mesmo nome encontrado no Drive.**
                *   Comparar `md5_local_calculado` (da foto local) com `md5_drive` (do arquivo remoto correspondente).
                *   **Se `md5_local_calculado == md5_drive`:**
                    *   Os arquivos são idênticos. Nenhum upload necessário.
                    *   Atualizar o registro local da foto: `status_sincronizacao = 'sincronizado'`, `id_google_drive = id_drive` (do arquivo remoto existente), `md5_remoto_confirmado = md5_drive`.
                *   **Se `md5_local_calculado != md5_drive`:**
                    *   **CONFLITO!** O conteúdo é diferente.
                    *   Marcar a foto local com `status_sincronizacao = 'conflito'`.
                    *   Adicionar à lista de conflitos a serem apresentados ao usuário para resolução. A resolução pode envolver opções como: "Manter versão local (sobrescrever no Drive)", "Manter versão do Drive (descartar alterações locais)", "Salvar ambos (renomear local ou remoto)".
                *   **Se `md5_drive` não estiver disponível no arquivo remoto (raro):**
                    *   Comparar `tamanho_do_arquivo` (local) com `tamanho_drive` (remoto).
                    *   Se tamanhos diferentes -> CONFLITO (mesma ação acima).
                    *   Se tamanhos iguais -> Tratar como CONFLITO (mais seguro) ou, alternativamente, como sincronizado (com risco mínimo). Recomenda-se tratar como conflito.
    *   **(Opcional) Verificar Arquivos Apenas no Drive:**
        *   Comparar a lista de arquivos remotos com os registros locais de fotos sincronizadas. Se um arquivo existir no Drive mas não tiver correspondente local (ou o correspondente local foi excluído), decidir sobre a ação (ex: baixar para o app, excluir do Drive, ignorar - dependendo dos requisitos). Esta lógica é para uma sincronização bidirecional completa.

Esta estratégia oferece um bom equilíbrio, garantindo a integridade dos dados fotográficos e otimizando o processo de sincronização.
