


WITH cte_meta_venda as (
	SELECT ano, mes, nroempresa, seqcomprador, meta_venda, meta_rentabilidade,
		SUM(meta_venda) OVER (PARTITION BY ano, mes, seqcomprador) as meta_venda_divisao
	FROM metas.tbl_venda_empresa_mes
	WHERE ano = 2025 and mes = 6 
),

cte_meta_venda_divisao as (
	SELECT ano, mes, nroempresa, seqcomprador, meta_venda, meta_rentabilidade, meta_venda_divisao,
		know.fn_divide_dois_numeros(meta_venda, meta_venda_divisao) * 100 as perc_part
	FROM cte_meta_venda
),

cte_meta_ruptura as (
	SELECT ano, mes, id_comprador, id_versao, vlrmetarupturadefinitiva as meta_ruptura
	FROM bi.meta_venda_mensal_comprador
	WHERE ano = 2025 and mes = 6 and vlrmetarupturadefinitiva > 0
),

cte_meta_ruptura_final as (
	select a.ano, a.mes, a.nroempresa, a.seqcomprador, b.meta_ruptura, a.perc_part,
		know.fn_multiplica_dois_numeros(b.meta_ruptura, a.perc_part) / 100 as vlr_meta_ruptura_empresa
	FROM cte_meta_venda_divisao as a inner join cte_meta_ruptura as b 
	ON a.ano = b.ano 
	AND a.mes = b.mes 
	AND a.seqcomprador = b.id_comprador
)

SELECT a.ano, a.mes, a.nroempresa, a.seqcomprador, vlr_meta_ruptura_empresa
FROM cte_meta_ruptura_final as a;

SELECT *  from metas.tbl_venda_empresa_mes where ano = 2025 and mes = 6;


-----------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION metas.sp_atualizar_meta_ruptura(
    p_ano INTEGER,
    p_mes INTEGER
)
RETURNS void AS $$
/*
----------------------------------------------------------------------------------------------------
-- Objetivo:         Calcula e atualiza o valor da meta de ruptura para cada empresa e comprador
--                   com base na distribuição proporcional da meta de venda.
--
-- Autor:            Eliseu Fermino dos Santos
-- Empresa:          Tatico Supermercados
-- Data de Criação:  11/07/2025
-- Versão:           1.0
--
-- Parâmetros:
--   p_ano (INTEGER): O ano de referência para o cálculo (ex: 2025).
--   p_mes (INTEGER): O mês de referência para o cálculo (ex: 6 para Junho).
--
-- Retorno:
--   void: A função não retorna nenhum valor, mas executa uma operação de UPDATE na
--         tabela metas.tbl_venda_empresa_mes.
--
-- Dependências:
--   Tabelas de Leitura:
--     - metas.tbl_venda_empresa_mes
--     - bi.meta_venda_mensal_comprador
--   Tabela de Escrita:
--     - metas.tbl_venda_empresa_mes
--   Funções:
--     - know.fn_divide_dois_numeros(n, n)
--     - know.fn_multiplica_dois_numeros(n, n)
--
-- Exemplo de Uso:
--   SELECT metas.sp_atualizar_meta_ruptura(2025, 6);
----------------------------------------------------------------------------------------------------
*/
BEGIN
    WITH cte_meta_venda AS (
        -- Calcula a meta de venda total do comprador (somando todas as suas empresas)
        SELECT 
            ano, mes, nroempresa, seqcomprador, meta_venda, meta_rentabilidade,
            SUM(meta_venda) OVER (PARTITION BY ano, mes, seqcomprador) as meta_venda_divisao
        FROM metas.tbl_venda_empresa_mes
        WHERE ano = p_ano AND mes = p_mes -- <<-- Parâmetros utilizados aqui
    ),
    cte_meta_venda_divisao AS (
        -- Calcula o percentual de participação de cada empresa na meta de venda do comprador
        SELECT 
            ano, mes, nroempresa, seqcomprador, meta_venda, meta_rentabilidade, meta_venda_divisao,
            know.fn_divide_dois_numeros(meta_venda, meta_venda_divisao) * 100 as perc_part
        FROM cte_meta_venda
    ),
    cte_meta_ruptura AS (
        -- Busca a meta de ruptura definitiva do comprador
        SELECT 
            ano, mes, id_comprador, id_versao, vlrmetarupturadefinitiva as meta_ruptura
        FROM bi.meta_venda_mensal_comprador
        WHERE ano = p_ano AND mes = p_mes AND vlrmetarupturadefinitiva > 0 -- <<-- Parâmetros utilizados aqui
    ),
    cte_meta_ruptura_final AS (
        -- Junta os dados e distribui a meta de ruptura proporcionalmente
        SELECT 
            a.ano, a.mes, a.nroempresa, a.seqcomprador, b.meta_ruptura, a.perc_part,
            know.fn_multiplica_dois_numeros(b.meta_ruptura, a.perc_part) / 100 as vlr_meta_ruptura_empresa
        FROM cte_meta_venda_divisao AS a
        INNER JOIN cte_meta_ruptura AS b ON a.ano = b.ano AND a.mes = b.mes AND a.seqcomprador = b.id_comprador
    )
    -- Executa o UPDATE na tabela de destino
    UPDATE metas.tbl_venda_empresa_mes AS t
    SET
        -- Define o novo valor para a coluna 'meta_ruptura'
        meta_ruptura = s.vlr_meta_ruptura_empresa
    FROM
        -- A fonte dos dados é o resultado final dos nossos cálculos
        cte_meta_ruptura_final AS s
    WHERE
        -- Condição de ligação para garantir que estamos atualizando a linha correta
        t.ano = s.ano
        AND t.mes = s.mes
        AND t.nroempresa = s.nroempresa
        AND t.seqcomprador = s.seqcomprador;

END;
$$ LANGUAGE plpgsql;

SELECT metas.sp_atualizar_meta_ruptura(2025, 6);
