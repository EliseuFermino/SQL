

/****************************************************************************
 SCRIPT MESTRE PARA ATUALIZAÇÃO MANUAL DA d_comprador (SCD TIPO 2)
  - Compara consinco_cadastro.tbl_comprador (a verdade) com bi.d_comprador (o DW)
  - Executa todas as operações dentro de uma transação para segurança.
****************************************************************************/

DROP TABLE IF EXISTS tmp_mudancas_comprador;

BEGIN;

-- Passo 0: Cria uma tabela temporária para armazenar as mudanças.
-- Esta tabela existirá durante toda a transação.
CREATE TEMP TABLE tmp_mudancas_comprador AS
SELECT
    src.seqcomprador,
    src.comprador, src.apelido, src.status, src.seqpessoa, src.id_gerente_categoria, src.id_departamento, src.base_calculo_ruptura, src.desc_secao, src.ordem_seqcomprador, src.secao, src.id_comprador_assistente
FROM
    consinco_cadastro.tbl_comprador src
JOIN
    bi.d_comprador dest ON src.seqcomprador = dest.seqcomprador AND dest.flg_versao_atual = TRUE
WHERE
    -- Adicione aqui TODAS as colunas que você quer monitorar para o histórico.
    src.id_comprador_assistente IS DISTINCT FROM dest.id_comprador_assistente
    -- Exemplo: OR src.id_gerente_categoria IS DISTINCT FROM dest.id_gerente_categoria
;

-- 1. Expira registros antigos que foram identificados e armazenados na tabela temporária.
UPDATE bi.d_comprador dest
SET
    dta_fim_validade = CURRENT_DATE - INTERVAL '1 day',
    flg_versao_atual = FALSE,
    dta_atualizacao = CURRENT_TIMESTAMP
WHERE
    dest.flg_versao_atual = TRUE
    AND EXISTS (
        SELECT 1 FROM tmp_mudancas_comprador m WHERE m.seqcomprador = dest.seqcomprador
    );


-- 2. Insere a nova versão para os registros expirados, usando os dados da tabela temporária.
INSERT INTO bi.d_comprador (
    seqcomprador, comprador, apelido, status, seqpessoa, id_gerente_categoria, id_departamento, base_calculo_ruptura, desc_secao, ordem_seqcomprador, secao, id_comprador_assistente,
    dta_atualizacao, dta_inicio_validade, dta_fim_validade, flg_versao_atual
)
SELECT
    m.seqcomprador, m.comprador, m.apelido, m.status, m.seqpessoa, m.id_gerente_categoria, m.id_departamento, m.base_calculo_ruptura, m.desc_secao, m.ordem_seqcomprador, m.secao, m.id_comprador_assistente,
    CURRENT_TIMESTAMP, -- dta_atualizacao
    CURRENT_DATE,      -- dta_inicio_validade
    NULL,              -- dta_fim_validade
    TRUE               -- flg_versao_atual
FROM
    tmp_mudancas_comprador m;


-- 3. Insere compradores completamente novos (que não existem no DW).
INSERT INTO bi.d_comprador (
    seqcomprador, comprador, apelido, status, seqpessoa, id_gerente_categoria, id_departamento, base_calculo_ruptura, desc_secao, ordem_seqcomprador, secao, id_comprador_assistente,
    dta_atualizacao, dta_inicio_validade, dta_fim_validade, flg_versao_atual
)
SELECT
    src.seqcomprador, src.comprador, src.apelido, src.status, src.seqpessoa, src.id_gerente_categoria, src.id_departamento, src.base_calculo_ruptura, src.desc_secao, src.ordem_seqcomprador, src.secao, src.id_comprador_assistente,
    CURRENT_TIMESTAMP, -- dta_atualizacao
    CURRENT_DATE,      -- dta_inicio_validade
    NULL,              -- dta_fim_validade
    TRUE               -- flg_versao_atual
FROM
    consinco_cadastro.tbl_comprador src
WHERE
    NOT EXISTS (
        SELECT 1
        FROM bi.d_comprador dest
        WHERE dest.seqcomprador = src.seqcomprador
    );

-- A tabela temporária é automaticamente descartada no final da transação/sessão,
-- mas é uma boa prática incluí-la se o script for executado fora de uma transação.
-- DROP TABLE tmp_mudancas_comprador;

COMMIT;

-- ROLLBACK;
