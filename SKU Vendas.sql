
WITH cte AS (
	-- Encontra os produtos únicos vendidos por dia
	SELECT dia_mes AS dia_inicial, seqproduto
	FROM vendas.tbl_vendas_prod_mes_filial
	GROUP BY dia_mes, seqproduto
),
 
cte1 AS (
	-- Filtra e conta os SKUs para a divisão e comprador desejados
	SELECT a.dia_inicial, COUNT(DISTINCT a.seqproduto) AS sku_venda
	FROM cte AS a 
	INNER JOIN bi.d_produto AS b ON a.seqproduto = b.seqproduto::int
	WHERE b.nrodivisao = '2' 
	  AND b.seqcomprador <> '41'
	GROUP BY a.dia_inicial
)
 
-- Atualiza a tabela bi.f_prezi com os dados calculados
UPDATE bi.f_prezi
SET 
    vlrreal = cte1.sku_venda
FROM 
    cte1
WHERE 
    -- Cláusula de ligação para encontrar a linha correspondente
    bi.f_prezi.dia = cte1.dia_inicial
    
    -- Filtros para garantir que apenas a linha correta seja atualizada
    AND bi.f_prezi.tipo = 'sku_venda'
    AND bi.f_prezi.nroempresa = 992
    AND bi.f_prezi.seqcomprador = 0;
    
 
-- ATUALIZA OU INSERE SKU DE VENDA - TOTAL DA LOJA -----------------------------------------------------------------------------------------------------------------------------------------
WITH cte AS (
	-- Calcula a contagem de SKUs únicos por dia e empresa
	SELECT 
		dia_mes AS dia, 
		nroempresa, 
		COUNT(DISTINCT seqproduto) AS sku_venda
	FROM vendas.tbl_vendas_prod_mes_filial
	GROUP BY dia_mes, nroempresa
)
 
-- Atualiza a tabela bi.f_prezi com os dados da CTE
UPDATE bi.f_prezi
SET 
    vlrreal = cte.sku_venda
FROM 
    cte
WHERE 
    -- Condição de ligação para encontrar a linha correta a ser atualizada
    bi.f_prezi.dia = cte.dia
    AND bi.f_prezi.nroempresa = cte.nroempresa
    
    -- Filtros para garantir que estamos modificando apenas o registro desejado
    AND bi.f_prezi.tipo = 'sku_venda'
    AND bi.f_prezi.seqcomprador = 0;


 
-- ATUALIZA OU INSERE SKU DE VENDA - TOTAL DA EMPRESA - POR COMPRADOR ------------------------------------------------------------------------------------------------------------
WITH cte AS (
	-- Encontra os produtos únicos vendidos por dia
	SELECT 
		dia_mes AS dia_inicial, 
		seqproduto
	FROM vendas.tbl_vendas_prod_mes_filial
	GROUP BY dia_mes, seqproduto
),
 
cte1 AS (
	-- Filtra e conta os SKUs para a divisão e comprador desejados
	SELECT 
		a.dia_inicial, 
		b.seqcomprador, 
		COUNT(DISTINCT a.seqproduto) AS sku_venda
	FROM cte AS a 
	INNER JOIN bi.d_produto AS b ON a.seqproduto = b.seqproduto::int
	WHERE b.nrodivisao = '2' 
	  AND b.seqcomprador <> '41'
	GROUP BY a.dia_inicial, b.seqcomprador
)
 
-- Atualiza a tabela bi.f_prezi com os dados calculados
UPDATE bi.f_prezi
SET 
    vlrreal = cte1.sku_venda
FROM 
    cte1
WHERE 
    -- Cláusulas de ligação para encontrar a linha correspondente
    bi.f_prezi.dia = cte1.dia_inicial
    AND bi.f_prezi.seqcomprador = cte1.seqcomprador::smallint
    
    -- Filtros para garantir que estamos modificando apenas o registro desejado
    AND bi.f_prezi.tipo = 'sku_venda'
    AND bi.f_prezi.nroempresa = 992;
 
-- ATUALIZA OU INSERE SKU VENDA - TOTAL POR FILIAL - POR COMPRADOR --------------------------------------------------------------------------------------------------------------------------------
WITH cte AS (
	-- Agrupa as vendas por dia, produto e empresa
	SELECT 
		dia_mes AS dia_inicial, 
		seqproduto, 
		nroempresa
	FROM vendas.tbl_vendas_prod_mes_filial
	GROUP BY dia_inicial, seqproduto, nroempresa
),
 
cte1 AS (
	-- Filtra e conta os SKUs para a divisão e comprador desejados, agora por empresa
	SELECT 
		a.dia_inicial, 
		b.seqcomprador, 
		COUNT(DISTINCT a.seqproduto) AS sku_venda, 
		a.nroempresa
	FROM cte AS a 
	INNER JOIN bi.d_produto AS b ON a.seqproduto = b.seqproduto::int
	WHERE b.nrodivisao = '2' 
	  AND b.seqcomprador <> '41'
	GROUP BY a.dia_inicial, b.seqcomprador, a.nroempresa
)
 
-- Atualiza a tabela bi.f_prezi com os dados calculados
UPDATE bi.f_prezi
SET 
    vlrreal = cte1.sku_venda
FROM 
    cte1
WHERE 
    -- Cláusulas de ligação para encontrar a linha correta a ser atualizada
    bi.f_prezi.dia = cte1.dia_inicial
    AND bi.f_prezi.seqcomprador = cte1.seqcomprador::smallint
    AND bi.f_prezi.nroempresa = cte1.nroempresa
    
    -- Filtros para garantir que estamos modificando apenas o registro desejado
    AND bi.f_prezi.tipo = 'sku_venda';
 