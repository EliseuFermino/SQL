
--- EMPRESA: Tatico
--- CRIADO POR: Eliseu Fermino dos Santos
--- Data: 09/09/23025
--- OBJETIVO: Filtra osa dados de Sku's em Estoque e Sku's em Venda elimenta as tabelas abaixo para alimentar o Painel da Controladoria
--- Gatilho: Esse script é dispoarado pelo Spoon - Atualiza Prezi (Pentahoo que atualiza o Prezi)

-- ************************ SKU ESTOQUE *****************************************************************************
truncate table stage.tbl_sku_estoque;

with cte as (
	SELECT mes_referencia, nroempresa, seqproduto, count(distinct seqproduto) as sku_estoque
	FROM estoque.f_estoque
	where nrodivisao = 2 and ESTQLOJA > 0 and MES_REFERENCIA = '2025-09-01'
	group by mes_referencia, nroempresa, seqproduto
),

cte2 as (
	SELECT mes_referencia, nroempresa, a.seqproduto, 'sku_estoque', count(distinct a.seqproduto)
	FROM cte as a inner join bi.D_PRODUTO as b
	on a.SEQPRODUTO = b.SEQPRODUTO::int4 inner join bi.VW_D_COMPRADOR as c 
	on b.SEQCOMPRADOR::numeric = c.SEQCOMPRADOR
	where c.DESC_SECAO is not null
	group by mes_referencia, nroempresa, a.seqproduto 
)

INSERT INTO stage.tbl_sku_estoque
(mes_referencia, seqproduto, nroempresa, "?column?", count)
SELECT mes_referencia, seqproduto, nroempresa, "?column?", count 
FROM cte2 as a;

-- *************************** SKU VENDA *****************************************************************************
truncate table stage.tbl_sku_venda;

WITH cte AS (
	-- Encontra os produtos únicos vendidos por dia
	SELECT dia_mes AS dia_inicial, seqproduto, NROEMPRESA 
	FROM vendas.tbl_vendas_prod_mes_filial
	WHERE dia_mes = '2025-09-01'
	GROUP BY dia_mes, seqproduto, NROEMPRESA
),
 
cte1 AS (
	-- Filtra e conta os SKUs para a divisão e comprador desejados
	SELECT a.dia_inicial, COUNT(DISTINCT a.seqproduto) AS sku_venda, NROEMPRESA, a.seqproduto
	FROM cte AS a 
	INNER JOIN bi.d_produto AS b ON a.seqproduto = b.seqproduto::int
	WHERE b.nrodivisao = '2' 
	  AND b.seqcomprador <> '41'
	GROUP BY a.dia_inicial, NROEMPRESA, a.seqproduto
)

INSERT INTO stage.tbl_sku_venda
(dia_inicial, sku_venda, seqproduto_venda, nroempresa)
select dia_inicial, sku_venda, seqproduto, nroempresa 
from cte1 as a;

-- *********************** A T U A L I Z A Ç Õ E S ******************************************************************

---
truncate table stage.tbl_sku_all;

-- LOJA 06 ----------------------------------------------------------
truncate table stage.tbl_sku_06;

INSERT INTO stage.tbl_sku_06 (sku, nroempresa)
SELECT seqproduto, nroempresa
FROM stage.tbl_sku_estoque
WHERE NROEMPRESA = 6;

INSERT INTO stage.tbl_sku_06 (sku, nroempresa)
SELECT seqproduto_venda, nroempresa
FROM stage.tbl_sku_venda
WHERE NROEMPRESA = 6;

DELETE FROM stage.tbl_sku_06 a
USING stage.tbl_sku_06 b
WHERE a.ctid < b.ctid
  AND a.sku = b.sku;

-- Atualiza SKU Estoque
UPDATE stage.tbl_sku_06 AS a
SET SKU_ESTOQUE = b.SEQPRODUTO 
FROM stage.tbl_sku_estoque AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO ;


-- Atualiza SKU Venda
UPDATE stage.tbl_sku_06 AS a
SET SKU_VENDA = b.SEQPRODUTO_VENDA
FROM stage.tbl_sku_venda AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO_VENDA ;


-- LOJA 07 ----------------------------------------------------------
truncate table stage.tbl_sku_07;

INSERT INTO stage.tbl_sku_07 (sku, nroempresa)
SELECT seqproduto, nroempresa
FROM stage.tbl_sku_estoque
WHERE NROEMPRESA = 7;

INSERT INTO stage.tbl_sku_07 (sku, nroempresa)
SELECT seqproduto_venda, nroempresa
FROM stage.tbl_sku_venda
WHERE NROEMPRESA = 7;

DELETE FROM stage.tbl_sku_07 a
USING stage.tbl_sku_07 b
WHERE a.ctid < b.ctid
  AND a.sku = b.sku;

-- Atualiza SKU Estoque
UPDATE stage.tbl_sku_07 AS a
SET SKU_ESTOQUE = b.SEQPRODUTO 
FROM stage.tbl_sku_estoque AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO ;


-- Atualiza SKU Venda
UPDATE stage.tbl_sku_07 AS a
SET SKU_VENDA = b.SEQPRODUTO_VENDA
FROM stage.tbl_sku_venda AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO_VENDA ;



-- LOJA 08 ----------------------------------------------------------
truncate table stage.tbl_sku_08;

INSERT INTO stage.tbl_sku_08 (sku, nroempresa)
SELECT seqproduto, nroempresa
FROM stage.tbl_sku_estoque
WHERE NROEMPRESA = 8;

INSERT INTO stage.tbl_sku_08 (sku, nroempresa)
SELECT seqproduto_venda, nroempresa
FROM stage.tbl_sku_venda
WHERE NROEMPRESA = 8;

DELETE FROM stage.tbl_sku_08 a
USING stage.tbl_sku_08 b
WHERE a.ctid < b.ctid
  AND a.sku = b.sku;

-- Atualiza SKU Estoque
UPDATE stage.tbl_sku_08 AS a
SET SKU_ESTOQUE = b.SEQPRODUTO 
FROM stage.tbl_sku_estoque AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO ;


-- Atualiza SKU Venda
UPDATE stage.tbl_sku_08 AS a
SET SKU_VENDA = b.SEQPRODUTO_VENDA
FROM stage.tbl_sku_venda AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO_VENDA ;



-- LOJA 09 ----------------------------------------------------------
truncate table stage.tbl_sku_09;

INSERT INTO stage.tbl_sku_09 (sku, nroempresa)
SELECT seqproduto, nroempresa
FROM stage.tbl_sku_estoque
WHERE NROEMPRESA = 9;

INSERT INTO stage.tbl_sku_09 (sku, nroempresa)
SELECT seqproduto_venda, nroempresa
FROM stage.tbl_sku_venda
WHERE NROEMPRESA = 9;

DELETE FROM stage.tbl_sku_09 a
USING stage.tbl_sku_09 b
WHERE a.ctid < b.ctid
  AND a.sku = b.sku;

-- Atualiza SKU Estoque
UPDATE stage.tbl_sku_09 AS a
SET SKU_ESTOQUE = b.SEQPRODUTO 
FROM stage.tbl_sku_estoque AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO ;


-- Atualiza SKU Venda
UPDATE stage.tbl_sku_09 AS a
SET SKU_VENDA = b.SEQPRODUTO_VENDA
FROM stage.tbl_sku_venda AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO_VENDA ;



-- LOJA 10 ----------------------------------------------------------
truncate table stage.tbl_sku_10;

INSERT INTO stage.tbl_sku_10 (sku, nroempresa)
SELECT seqproduto, nroempresa
FROM stage.tbl_sku_estoque
WHERE NROEMPRESA = 10;

INSERT INTO stage.tbl_sku_10 (sku, nroempresa)
SELECT seqproduto_venda, nroempresa
FROM stage.tbl_sku_venda
WHERE NROEMPRESA = 10;

DELETE FROM stage.tbl_sku_10 a
USING stage.tbl_sku_10 b
WHERE a.ctid < b.ctid
  AND a.sku = b.sku;

-- Atualiza SKU Estoque
UPDATE stage.tbl_sku_10 AS a
SET SKU_ESTOQUE = b.SEQPRODUTO 
FROM stage.tbl_sku_estoque AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO ;


-- Atualiza SKU Venda
UPDATE stage.tbl_sku_10 AS a
SET SKU_VENDA = b.SEQPRODUTO_VENDA
FROM stage.tbl_sku_venda AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO_VENDA ;



-- LOJA 11 ----------------------------------------------------------
truncate table stage.tbl_sku_11;

INSERT INTO stage.tbl_sku_11 (sku, nroempresa)
SELECT seqproduto, nroempresa
FROM stage.tbl_sku_estoque
WHERE NROEMPRESA = 11;

INSERT INTO stage.tbl_sku_11 (sku, nroempresa)
SELECT seqproduto_venda, nroempresa
FROM stage.tbl_sku_venda
WHERE NROEMPRESA = 11;

DELETE FROM stage.tbl_sku_11 a
USING stage.tbl_sku_11 b
WHERE a.ctid < b.ctid
  AND a.sku = b.sku;

-- Atualiza SKU Estoque
UPDATE stage.tbl_sku_11 AS a
SET SKU_ESTOQUE = b.SEQPRODUTO 
FROM stage.tbl_sku_estoque AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO ;


-- Atualiza SKU Venda
UPDATE stage.tbl_sku_11 AS a
SET SKU_VENDA = b.SEQPRODUTO_VENDA
FROM stage.tbl_sku_venda AS b 
WHERE a.nroempresa = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO_VENDA ;


------ ALL ---------------------------------------------------------------------------

INSERT INTO stage.tbl_sku_all (sku, nroempresa, SKU_VENDA, SKU_ESTOQUE)
SELECT sku, nroempresa, sku_venda , sku_estoque FROM stage.tbl_sku_06;

INSERT INTO stage.tbl_sku_all (sku, nroempresa, SKU_VENDA, SKU_ESTOQUE)
SELECT sku, nroempresa, sku_venda , sku_estoque FROM stage.tbl_sku_07;

INSERT INTO stage.tbl_sku_all (sku, nroempresa, SKU_VENDA, SKU_ESTOQUE)
SELECT sku, nroempresa, sku_venda , sku_estoque FROM stage.tbl_sku_08;

INSERT INTO stage.tbl_sku_all (sku, nroempresa, SKU_VENDA, SKU_ESTOQUE)
SELECT sku, nroempresa, sku_venda , sku_estoque FROM stage.tbl_sku_09;

INSERT INTO stage.tbl_sku_all (sku, nroempresa, SKU_VENDA, SKU_ESTOQUE)
SELECT sku, nroempresa, sku_venda , sku_estoque FROM stage.tbl_sku_10;

INSERT INTO stage.tbl_sku_all (sku, nroempresa, SKU_VENDA, SKU_ESTOQUE)
SELECT sku, nroempresa, sku_venda , sku_estoque FROM stage.tbl_sku_11;

-- ********************** CRIA HISTÓRICO DIÁRIO *******************************************************************
DELETE FROM bi.tbl_sku_estoque_venda WHERE dia = CURRENT_DATE - 1;

INSERT INTO bi.tbl_sku_estoque_venda
(dia, nroempresa, sku_estoque, sku_venda, dif_skus)
SELECT CURRENT_DATE - 1 as Dia, nroempresa, count(sku_estoque) as sku_estoque, count(sku_venda) as sku_venda, count(sku_estoque) - count(sku_venda) as dif_skus
FROM stage.tbl_sku_all
GROUP BY CURRENT_DATE - 1, nroempresa;



