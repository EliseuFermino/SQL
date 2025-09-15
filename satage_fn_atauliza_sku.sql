
CREATE OR REPLACE FUNCTION stage.fn_atualiza_sku(
    p_ref_date date DEFAULT (CURRENT_DATE - 1),           -- data a consolidar (ex.: ontem)
    p_divisao  int  DEFAULT 2,                             -- nrodivisao
    p_excluir_seqcomprador int DEFAULT 41,                 -- excluir este comprador
    p_stores int[] DEFAULT ARRAY[6,7,8,9,10,11]            -- lojas a processar (06–11)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_mes_referencia date := date_trunc('month', p_ref_date)::date;
    v_loja int;
    v_tbl_loja text;
BEGIN
    -- ============================ SKU ESTOQUE ============================
    TRUNCATE TABLE stage.tbl_sku_estoque;

    WITH cte AS (
        SELECT
            mes_referencia,
            nroempresa,
            seqproduto,
            COUNT(DISTINCT seqproduto) AS sku_estoque
        FROM estoque.f_estoque
        WHERE nrodivisao = p_divisao
          AND estqloja > 0
          AND mes_referencia = v_mes_referencia
        GROUP BY mes_referencia, nroempresa, seqproduto
    ),
    cte2 AS (
        SELECT
            a.mes_referencia,
            a.nroempresa,
            a.seqproduto,
            'sku_estoque',                         -- mantém sua 4ª coluna literal
            COUNT(DISTINCT a.seqproduto)
        FROM cte a
        INNER JOIN bi.d_produto b
            ON a.seqproduto = b.seqproduto::int4
        INNER JOIN bi.vw_d_comprador c
            ON b.seqcomprador::numeric = c.seqcomprador
        WHERE c.desc_secao IS NOT NULL
        GROUP BY a.mes_referencia, a.nroempresa, a.seqproduto
    )
    INSERT INTO stage.tbl_sku_estoque
        (mes_referencia, seqproduto, nroempresa, "?column?", count)
    SELECT
        mes_referencia, seqproduto, nroempresa, "?column?", count
    FROM cte2;

    -- ============================ SKU VENDA ==============================
    TRUNCATE TABLE stage.tbl_sku_venda;

    WITH cte AS (
        -- produtos únicos vendidos no dia p_ref_date
        SELECT dia_mes AS dia_inicial, seqproduto, nroempresa
        FROM vendas.tbl_vendas_prod_mes_filial
        WHERE dia_mes = p_ref_date
        GROUP BY dia_mes, seqproduto, nroempresa
    ),
    cte1 AS (
        SELECT
            a.dia_inicial,
            COUNT(DISTINCT a.seqproduto) AS sku_venda,
            a.nroempresa,
            a.seqproduto
        FROM cte a
        INNER JOIN bi.d_produto b
            ON a.seqproduto = b.seqproduto::int
        WHERE b.nrodivisao = p_divisao::text      -- b.nrodivisao é texto no seu SQL original
          AND b.seqcomprador <> p_excluir_seqcomprador::text
        GROUP BY a.dia_inicial, a.nroempresa, a.seqproduto
    )
    INSERT INTO stage.tbl_sku_venda
        (dia_inicial, sku_venda, seqproduto_venda, nroempresa)
    SELECT dia_inicial, sku_venda, seqproduto, nroempresa
    FROM cte1;

    -- ========================= ATUALIZAÇÕES POR LOJA ====================
    TRUNCATE TABLE stage.tbl_sku_all;

    FOREACH v_loja IN ARRAY p_stores LOOP
        v_tbl_loja := format('stage.tbl_sku_%s', to_char(v_loja, 'FM00'));

        -- Limpa a tabela da loja
        EXECUTE format('TRUNCATE TABLE %I', v_tbl_loja);

        -- Insere base vinda do estoque
        EXECUTE format(
            'INSERT INTO %I (sku, nroempresa)
             SELECT seqproduto, nroempresa
             FROM stage.tbl_sku_estoque
             WHERE nroempresa = $1',
            v_tbl_loja
        ) USING v_loja;

        -- Insere base vinda da venda
        EXECUTE format(
            'INSERT INTO %I (sku, nroempresa)
             SELECT seqproduto_venda, nroempresa
             FROM stage.tbl_sku_venda
             WHERE nroempresa = $1',
            v_tbl_loja
        ) USING v_loja;

        -- Remove duplicados por SKU (mantém 1 linha por SKU)
        EXECUTE format(
            'DELETE FROM %1$I a
             USING %1$I b
             WHERE a.ctid < b.ctid
               AND a.sku = b.sku',
            v_tbl_loja
        );

        -- Atualiza SKU_ESTOQUE
        EXECUTE format(
            'UPDATE %1$I a
             SET sku_estoque = b.seqproduto
             FROM stage.tbl_sku_estoque b
             WHERE a.nroempresa = b.nroempresa
               AND a.sku = b.seqproduto',
            v_tbl_loja
        );

        -- Atualiza SKU_VENDA
        EXECUTE format(
            'UPDATE %1$I a
             SET sku_venda = b.seqproduto_venda
             FROM stage.tbl_sku_venda b
             WHERE a.nroempresa = b.nroempresa
               AND a.sku = b.seqproduto_venda',
            v_tbl_loja
        );

        -- Consolida da loja para o ALL
        EXECUTE format(
            'INSERT INTO stage.tbl_sku_all (sku, nroempresa, sku_venda, sku_estoque)
             SELECT sku, nroempresa, sku_venda, sku_estoque
             FROM %I',
            v_tbl_loja
        );
    END LOOP;

    -- ======================= HISTÓRICO DIÁRIO (BI) ======================
    -- Usa p_ref_date para manter consistência: apaga e reinsere do mesmo dia.
    DELETE FROM bi.tbl_sku_estoque_venda
    WHERE dia = p_ref_date;

    INSERT INTO bi.tbl_sku_estoque_venda
        (dia, nroempresa, sku_estoque, sku_venda, dif_skus)
    SELECT
        p_ref_date AS dia,
        nroempresa,
        COUNT(sku_estoque) AS sku_estoque,
        COUNT(sku_venda)   AS sku_venda,
        COUNT(sku_estoque) - COUNT(sku_venda) AS dif_skus
    FROM stage.tbl_sku_all
    GROUP BY nroempresa;

END;
$$;
