-- DROP FUNCTION prezi.sp_insere_dados_ano_b_aa();

CREATE OR REPLACE FUNCTION prezi.sp_insere_dados_ano_b_aa()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN


---
truncate table prezi.tbl_ano_b;

INSERT INTO prezi.tbl_ano_b
(id_ordem, ano, fn_date_year_current, seqcomprador, nroempresa, entrada_qtide_vlrreal, estoque_vlrreal, ruptura_vlrreal, sku_stoque_vlrreal, skU_venda_vlrreal, inventariada_vlrreal, apontada_vlrreal, quebra_total_vlrreal)
SELECT
    1 as id_ordem,
    know.fn_date_year_current() as ano,
	know.fn_date_year_current(),
    seqcomprador,
    nroempresa,
    SUM(CASE WHEN tipo = 'entrada_qtde' THEN vlrreal END) AS entrada_qtide_vlrreal,
    SUM(CASE WHEN tipo = 'estoque' THEN vlrreal END) AS estoque_vlrreal,
    SUM(CASE WHEN tipo = 'ruptura' THEN vlrreal END) AS ruptura_vlrreal,
    SUM(CASE WHEN tipo = 'sku_estoque' THEN vlrreal END) AS sku_estoque_vlrreal,
    SUM(CASE WHEN tipo = 'sku_venda' THEN vlrreal END) AS sku_venda_vlrreal,
    SUM(CASE WHEN tipo = 'inventariada' THEN vlrreal END) AS inventariada_vlrreal,
    SUM(CASE WHEN tipo = 'apontada' THEN vlrreal END) AS apontada_vlrreal,
	SUM(CASE WHEN tipo = 'quebras_total' THEN vlrreal END) AS quebra_total_vlrreal 
FROM
    bi.f_prezi
WHERE
    dia between know.fn_date_primeiro_dia_do_ano_atual() and know.fn_date_bomonth_current()
    AND tipo IN ('entrada_qtde', 'estoque','ruptura','sku_estoque','sku_venda','inventariada','apontada','quebras_total')
GROUP BY    
    know.fn_date_year_current(),
	know.fn_date_year_current(),
    seqcomprador,
    desccomprador,
    nroempresa;


INSERT INTO prezi.tbl_ano_b
(id_ordem, ano, fn_date_year_current, seqcomprador, nroempresa, entrada_qtide_vlrreal, estoque_vlrreal, ruptura_vlrreal, sku_stoque_vlrreal, skU_venda_vlrreal, inventariada_vlrreal, apontada_vlrreal, quebra_total_vlrreal)
SELECT
    2 as id_ordem,
	know.fn_date_year_current() as ano,
    know.fn_date_ano_anterior(),
    seqcomprador,
    nroempresa,
    SUM(CASE WHEN tipo = 'entrada_qtde' THEN vlrreal END) AS entrada_qtide_vlrreal,
    SUM(CASE WHEN tipo = 'estoque' THEN vlrreal END) AS estoque_vlrreal,
    SUM(CASE WHEN tipo = 'ruptura' THEN vlrreal END) AS ruptura_vlrreal,
    SUM(CASE WHEN tipo = 'sku_estoque' THEN vlrreal END) AS sku_estoque_vlrreal,
    SUM(CASE WHEN tipo = 'sku_venda' THEN vlrreal END) AS sku_venda_vlrreal,
    SUM(CASE WHEN tipo = 'inventariada' THEN vlrreal END) AS inventariada_vlrreal,
    SUM(CASE WHEN tipo = 'apontada' THEN vlrreal END) AS apontada_vlrreal,
	SUM(CASE WHEN tipo = 'quebras_total' THEN vlrreal END) AS quebra_total_vlrreal     
FROM
    bi.f_prezi
WHERE
    dia between know.fn_date_primeiro_dia_do_ano_anterior() and (know.fn_date_primeiro_dia_mes_anterior_do_ano_anterior() + INTERVAL '1 month')::date
    AND tipo IN ('entrada_qtde', 'estoque','ruptura','sku_estoque','sku_venda','inventariada','apontada','quebras_total')
GROUP BY    
    know.fn_date_year_current(),
    know.fn_date_ano_anterior(),
    seqcomprador,
    desccomprador,
    nroempresa;
    

INSERT INTO prezi.tbl_ano_b
(id_ordem, ano, fn_date_year_current, seqcomprador, nroempresa, entrada_qtide_vlrreal, estoque_vlrreal, ruptura_vlrreal, sku_stoque_vlrreal, skU_venda_vlrreal, inventariada_vlrreal, apontada_vlrreal, quebra_total_vlrreal)
WITH base_data AS (
    -- Esta CTE simplesmente seleciona os dados brutos da sua tabela tbl_media
    -- aplicando os filtros de nroempresa e seqcomprador
    SELECT
        id_ordem,
		ano,
        fn_date_year_current,
        seqcomprador,
        nroempresa,
        entrada_qtide_vlrreal, 
        estoque_vlrreal, 
        ruptura_vlrreal, 
        sku_stoque_vlrreal, 
        skU_venda_vlrreal, 
        inventariada_vlrreal, 
        apontada_vlrreal,
        quebra_total_vlrreal
    FROM
        prezi.tbl_ano_b
    WHERE  
         id_ordem IN (1, 2) -- Para garantir que pegamos apenas as linhas de 2025 (id=1) e 2024 (id=2)
),
calculated_growth AS (
    -- Esta CTE calcula o percentual de crescimento para cada combinação de nroempresa e seqcomprador
    SELECT
        3 AS id_ordem, -- Definindo id_ordem = 3 para a nova linha de crescimento
		t1.ano,
        '% Cresc'::text AS fn_date_year_current, -- Texto para a coluna de ano
        t1.seqcomprador,
        t1.nroempresa,
        -- Faturamento % Crescimento
        ROUND(((t1.entrada_qtide_vlrreal / NULLIF(t2.entrada_qtide_vlrreal, 0)) - 1) * 100, 2) AS entrada_qtide_vlrreal,
        -- Rentabilidade % Crescimento
        ROUND(((t1.estoque_vlrreal / NULLIF(t2.estoque_vlrreal, 0)) - 1) * 100, 2) AS estoque_vlrreal,
        -- Margem % Crescimento
        ROUND(((t1.ruptura_vlrreal / NULLIF(t2.ruptura_vlrreal, 0)) - 1) * 100, 2) AS ruptura_vlrreal,
        -- Quantidade % Crescimento
        ROUND(((t1.sku_stoque_vlrreal / NULLIF(t2.sku_stoque_vlrreal, 0)) - 1) * 100, 2) AS sku_stoque_vlrreal,
        -- Preço Médio % Crescimento
        ROUND(((t1.skU_venda_vlrreal / NULLIF(t2.skU_venda_vlrreal, 0)) - 1) * 100, 2) AS skU_venda_vlrreal,
        -- Ticket Médio % Crescimento
        ROUND(((t1.inventariada_vlrreal / NULLIF(t2.inventariada_vlrreal, 0)) - 1) * 100, 2) AS inventariada_vlrreal,
        -- Clientes % Crescimento
        ROUND(((t1.apontada_vlrreal / NULLIF(t2.apontada_vlrreal, 0)) - 1) * 100, 2) AS apontada_vlrreal,
		-- Quebras Total % Crescimento
        ROUND(((t1.quebra_total_vlrreal / NULLIF(t2.quebra_total_vlrreal, 0)) - 1) * 100, 2) AS quebra_total_vlrreal
    FROM
        base_data t1 -- Representa os dados de id_ordem = 1 (2025)
    JOIN
        base_data t2 ON t1.seqcomprador = t2.seqcomprador
                     AND t1.nroempresa = t2.nroempresa
                     -- Assegura que estamos comparando o mesmo comprador e empresa
    WHERE
        t1.id_ordem = 1 -- Valor mais recente (2025)
        AND t2.id_ordem = 2 -- Valor anterior (2024)
)
-- Seleciona APENAS as linhas de crescimento percentual
SELECT
    id_ordem,
	ano,
    fn_date_year_current,
    seqcomprador,
    nroempresa,
    entrada_qtide_vlrreal, 
    estoque_vlrreal, 
    ruptura_vlrreal, 
    sku_stoque_vlrreal, 
    skU_venda_vlrreal, 
    inventariada_vlrreal, 
    apontada_vlrreal,
	quebra_total_vlrreal
FROM
    calculated_growth
ORDER BY
    nroempresa,
    seqcomprador;



END;
$function$
;

--SELECT prezi.sp_insere_dados_ano_b_aa();