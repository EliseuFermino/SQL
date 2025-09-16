-- ****** ATUALIZA O ESTOQUE DE ONTEM ***************************************************

TRUNCATE TABLE estoque.f_sku_all;

WITH cte as (
SELECT nroempresa, seqproduto, estqloja, estqtroca , mes_referencia, dta_posicao, cmultvlrnf, STATUSCOMPRA, STATUSVENDA, PRECOBASENORMAL  
FROM estoque.f_estoque
WHERE dta_posicao = '2025-09-14' AND NRODIVISAO = '2'
)

INSERT INTO estoque.f_sku_all
	  (nroempresa, seqproduto, estqloja, estqtroca, mes_referencia, dta_posicao, cmultvlrnf, STATUSCOMPRA, STATUSVENDA, PRECOBASENORMAL)
SELECT nroempresa, seqproduto, estqloja, estqtroca, mes_referencia, dta_posicao, cmultvlrnf, STATUSCOMPRA, STATUSVENDA, PRECOBASENORMAL
FROM cte as a
WHERE seqproduto in (SELECT sku FROM stage.tbl_sku_all)
;

--alter table estoque.f_sku_all add cmultvlrnf numeric;
--alter table stage.tbl_sku_all add cmultvlrnf numeric;

UPDATE stage.tbl_sku_all as a
SET qtd_estoque_ontem = b.estqloja,
    cmultvlrnf = b.cmultvlrnf,
    STATUSCOMPRA = b.STATUSCOMPRA,
    STATUSVENDA = b.STATUSVENDA,
    PRECOBASENORMAL = b.PRECOBASENORMAL    
FROM estoque.f_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA 
AND a.SKU = b.SEQPRODUTO 
AND b.DTA_POSICAO = '2025-09-14';



--ALter table stage.tbl_sku_all add PRECOBASENORMAL numeric;
--ALter table stage.tbl_sku_all add qtd_venda_d21 numeric;


--CREATE INDEX tbl_prod_gyn_2025_idx_dta_seq_produto ON vendas.tbl_prod_gyn_2025 USING btree (dta, seqproduto);

TRUNCATE TABLE vendas.f_venda_sku_all;

-- PREENCHER TEMPORARIA ----------------------------------------------
WITH cte as (
SELECT dta, nroempresa,  seqproduto,  quantidade 
FROM vendas.tbl_prod_gyn_2025
WHERE dta between '2025-08-25' and '2025-09-14'	-- 21 dias à partir do dia de ontem
)

INSERT INTO vendas.f_venda_sku_all
(dta, nroempresa, seqproduto, quantidade)
SELECT dta, nroempresa::smallint,  seqproduto::bigint,  quantidade
FROM cte as a
WHERE seqproduto::bigint in (SELECT sku FROM stage.tbl_sku_all);

-- ****** ATUALIZA A VENDA DE ONTEM ***************************************************
UPDATE stage.tbl_sku_all as a
SET qtd_venda_d1 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-14';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d2 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-13';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d3 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-12';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d4 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-11';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d5 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-10';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d6 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-09';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d7 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-08';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d8 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-07';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d9 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-06';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d10 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-05';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d11 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-04';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d12 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-03';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d13 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-02';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d14 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-09-01';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d15 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-08-31';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d16 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-08-30';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d17 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-08-29';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d18 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-08-28';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d19 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-08-27';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d20 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-08-26';

UPDATE stage.tbl_sku_all as a
SET qtd_venda_d21 = b.quantidade
FROM vendas.f_venda_sku_all as b 
WHERE a.NROEMPRESA = b.NROEMPRESA::smallint 
AND a.SKU = b.SEQPRODUTO
AND b.DTA = '2025-08-25';

