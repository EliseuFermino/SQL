
-- Insere os dados padrão de 2021 até o ultimo dia do mês atual.
SELECT prezi.fn_popular_f_prezi_por_tipo('faturamento');
 
-- ATUALIZAR A FATURAMENTO NO PREZI APENAS DO ANO DE 2025 PARA FRENTE -----------------------------
INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT
    'faturamento',
    SUM(venda_vlr_real ),  -- Soma os valores duplicados
    dia,
    seqcomprador,
    nroempresa
FROM bi.venda_comprador_total_mes
GROUP BY dia, seqcomprador, nroempresa
ON CONFLICT (tipo, dia, seqcomprador, nroempresa)  -- SE JA EXISTIR ESSA INFORMAÇÂO
DO UPDATE SET vlrreal = EXCLUDED.vlrreal
where bi.f_prezi.dia  >= know.fn_date_primeiro_dia_quatro_anos_anterior();

-- PREZI - RENTABILIDADE
 
-- Insere os dados padrão de 2021 até o ultimo dia do mês atual.
SELECT prezi.fn_popular_f_prezi_por_tipo('rentabilidade');

-- ATUALIZAR A RENTABILIDADE NO PREZI APENAS DO ANO DE 2025 PARA FRENTE -----------------------------
WITH aggregated_data AS (
    SELECT
        'rentabilidade' AS tipo,
        SUM(lucratividade_vlrreal) AS vlrreal,  
        dia,
        seqcomprador,
        nroempresa
    FROM bi.venda_comprador_total_mes
    WHERE dia >= know.fn_date_primeiro_dia_quatro_anos_anterior()
    GROUP BY dia, seqcomprador, nroempresa
)
INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT
    tipo,
    vlrreal,
    dia,
    seqcomprador,
    nroempresa
FROM aggregated_data
ON CONFLICT (tipo, dia, seqcomprador, nroempresa)  
DO UPDATE SET
    vlrreal = EXCLUDED.vlrreal
WHERE bi.f_prezi.vlrreal IS DISTINCT FROM EXCLUDED.vlrreal;

 -- Insere os dados padrão de 2021 até o ultimo dia do mês atual.
SELECT prezi.fn_popular_f_prezi_por_tipo('quantidade');
 
-- ATUALIZAR A QUANTIDADE NO PREZI APENAS DO ANO DE 2025 PARA FRENTE -----------------------------
INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT
    'quantidade',
    SUM(qtde_venda_real),  -- Soma os valores duplicados
    dia,
    seqcomprador,
    nroempresa
FROM bi.venda_comprador_total_mes
GROUP BY dia, seqcomprador, nroempresa
ON CONFLICT (tipo, dia, seqcomprador, nroempresa)  -- SE JA EXISTIR ESSA INFORMAÇÂO
DO UPDATE SET vlrreal = EXCLUDED.vlrreal
where bi.f_prezi.dia  >= know.fn_date_primeiro_dia_quatro_anos_anterior();
 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- INSERIR DADOS NOVOS NO PREZI ------------------------------------------------------------------
INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT
    'faturamento',
    SUM(vlrvendabruto ),  -- Soma os valores duplicados
    dia_inicio_mes as dia,
    seqcomprador,
    nroempresa
FROM stage.f_prezi_brasilia
WHERE tipo = 'faturamento'
GROUP BY dia_inicio_mes, seqcomprador, nroempresa
ON CONFLICT (tipo, dia, seqcomprador, nroempresa)  -- SE JA EXISTIR ESSA INFORMAÇÂO
DO UPDATE SET vlrreal = EXCLUDED.vlrreal
where bi.f_prezi.dia  >= know.fn_date_primeiro_dia_quatro_anos_anterior();


INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT
    'rentabilidade',
    SUM(vlrvendabruto ),  -- Soma os valores duplicados
    dia_inicio_mes as dia,
    seqcomprador,
    nroempresa
FROM stage.f_prezi_brasilia
WHERE tipo = 'rentabilidade'
GROUP BY dia_inicio_mes, seqcomprador, nroempresa
ON CONFLICT (tipo, dia, seqcomprador, nroempresa)  -- SE JA EXISTIR ESSA INFORMAÇÂO
DO UPDATE SET vlrreal = EXCLUDED.vlrreal
where bi.f_prezi.dia  >= know.fn_date_primeiro_dia_quatro_anos_anterior();


INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT
    'quantidade',
    SUM(vlrvendabruto ),  -- Soma os valores duplicados
    dia_inicio_mes as dia,
    seqcomprador,
    nroempresa
FROM stage.f_prezi_brasilia
WHERE tipo = 'quantidade'
GROUP BY dia_inicio_mes, seqcomprador, nroempresa
ON CONFLICT (tipo, dia, seqcomprador, nroempresa)  -- SE JA EXISTIR ESSA INFORMAÇÂO
DO UPDATE SET vlrreal = EXCLUDED.vlrreal
where bi.f_prezi.dia  >= know.fn_date_primeiro_dia_quatro_anos_anterior();


Select * 
from stage.f_prezi_brasilia
where dia_inicio_mes = '2025-01-01' and nroempresa = 4 and seqcomprador = 0;

 
