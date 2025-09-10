
with cte as (
	SELECT mes_referencia, nroempresa, seqproduto, count(distinct seqproduto) as sku_estoque
	FROM estoque.f_estoque
	where nrodivisao = 2 and ESTQLOJA > 0 and MES_REFERENCIA = '2025-09-01'
	group by mes_referencia, nroempresa, seqproduto
)


SELECT mes_referencia, nroempresa, a.seqproduto, 'sku_estoque', count(distinct a.seqproduto)
FROM cte as a inner join bi.D_PRODUTO as b
on a.SEQPRODUTO = b.SEQPRODUTO::int4 inner join bi.VW_D_COMPRADOR as c 
on b.SEQCOMPRADOR::numeric = c.SEQCOMPRADOR
where c.DESC_SECAO is not null
group by mes_referencia, nroempresa, a.seqproduto ;

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
