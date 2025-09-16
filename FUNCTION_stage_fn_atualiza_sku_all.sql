
CREATE OR REPLACE FUNCTION stage.fn_atualiza_sku_all(p_data_base date)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    i int;
    v_colname text;
    v_sql text;
BEGIN
    -- Limpa e carrega estoque de ontem
    TRUNCATE TABLE estoque.f_sku_all;

    INSERT INTO estoque.f_sku_all
        (nroempresa, seqproduto, estqloja, estqtroca, mes_referencia, dta_posicao,
         cmultvlrnf, STATUSCOMPRA, STATUSVENDA, PRECOBASENORMAL)
    SELECT nroempresa, seqproduto, estqloja, estqtroca, mes_referencia, dta_posicao,
           cmultvlrnf, STATUSCOMPRA, STATUSVENDA, PRECOBASENORMAL
    FROM estoque.f_estoque
    WHERE dta_posicao = p_data_base
      AND nrodivisao = 2
      AND seqproduto IN (SELECT sku FROM stage.tbl_sku_all);

    -- Atualiza estoque de ontem na stage
    UPDATE stage.tbl_sku_all a
    SET qtd_estoque_ontem = b.estqloja,
        cmultvlrnf        = b.cmultvlrnf,
        STATUSCOMPRA      = b.STATUSCOMPRA,
        STATUSVENDA       = b.STATUSVENDA,
        PRECOBASENORMAL   = b.PRECOBASENORMAL
    FROM estoque.f_sku_all b
    WHERE a.nroempresa = b.nroempresa
      AND a.sku = b.seqproduto
      AND b.dta_posicao = p_data_base;

    -- Recria vendas dos últimos 21 dias
    TRUNCATE TABLE vendas.f_venda_sku_all;

    INSERT INTO vendas.f_venda_sku_all (dta, nroempresa, seqproduto, quantidade)
    SELECT dta, nroempresa::smallint, seqproduto::bigint, quantidade
    FROM vendas.tbl_prod_gyn_2025
    WHERE dta BETWEEN (p_data_base - INTERVAL '20 day') AND p_data_base
      AND seqproduto::bigint IN (SELECT sku FROM stage.tbl_sku_all);

    -- Atualiza colunas qtd_venda_d1 até qtd_venda_d21 dinamicamente
    FOR i IN 1..21 LOOP
        v_colname := format('qtd_venda_d%s', i);
        v_sql := format($f$
            UPDATE stage.tbl_sku_all a
            SET %I = b.quantidade
            FROM vendas.f_venda_sku_all b
            WHERE a.nroempresa = b.nroempresa::smallint
              AND a.sku = b.seqproduto
              AND b.dta = %L $f$,
              v_colname,
              (p_data_base - (i-1))::date);
        EXECUTE v_sql;
    END LOOP;
END;
$$;


