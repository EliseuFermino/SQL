--
Delete From stage.tbl_produtos_sem_venda_ultimo_7_dias WHERE ultima_entrada = '2025-10-08';

WITH cte AS (
	SELECT dta_referencia, dtaentrada, nroempresa, seqproduto, qtdembalagem, embalagem, 
		sum(quantidade) as quantidade, sum(quantidadeunit) as quantidadeunit, sum(vlrentrada) as vlrentrada
	FROM estoque.f_entradas
	WHERE dtaentrada = '2025-10-08' and nroempresa = '7' and seqproduto in ( 76057, 104793, 68444)
	group by dta_referencia, dtaentrada, nroempresa, seqproduto, qtdembalagem, embalagem
)

INSERT INTO stage.tbl_produtos_sem_venda_ultimo_7_dias
(dta_referencia, dtaentrada, nroempresa, seqproduto, qtdembalagem, embalagem, quantidade, quantidadeunit, vlrentrada)
SELECT dta_referencia, dtaentrada, nroempresa, seqproduto, qtdembalagem, embalagem, quantidade, quantidadeunit, vlrentrada
FROM cte as a;

CREATE OR REPLACE PROCEDURE stage.sp_produtos_sem_venda_ultimo_7_dias(p_data DATE)
LANGUAGE plpgsql
AS $$
BEGIN

-- Exclui os registros com base no filtro ------------------------------------------------------------------------------

	-- SEMPRE A ANALISE SERA DOS ULTIMOS 7 DIAS. EXCLUIR O QUE FOR MAIOR QUE 7 DIAS
	DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada < p_data - 6;

	-- SEMPRE A ANALISE SERA DOS ULTIMOS 7 DIAS. EXCLUIR O QUE FOR MAIOR QUE ONTEM
	DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada > p_data;

	-- EXCLUI SE JA TIVER SIDo PROCESSADO
    DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada = p_data;

-- INSERE AS NF DE ENTRADA ---------------------------------------------------------------------------------------------
	WITH cte AS (
		SELECT dtaentrada, nroempresa, seqproduto, qtdembalagem, embalagem, 
			sum(quantidade) as quantidade, sum(quantidadeunit) as quantidadeunit, sum(vlrentrada) as vlrentrada
		FROM estoque.f_entradas
		WHERE dtaentrada = p_data 
		group by dta_referencia, dtaentrada, nroempresa, seqproduto, qtdembalagem, embalagem
	)
	
	INSERT INTO stage.tbl_produtos_sem_venda_ultimo_7_dias
	( ultima_entrada, nroempresa, sku_estoque, qtde_entrada)
	SELECT  dtaentrada, nroempresa, seqproduto,  quantidadeunit
	FROM cte as a;

	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data);

	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 1);
    CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 2);
	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 3);
	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 4);
    CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 5);
	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 6);	
	
	
-------------------------------------------------------------------------------------------------------------------------------------
    ---RAISE NOTICE 'Registros com ultima_entrada = % foram deletados com sucesso.', p_data;
END;
$$;

CALL stage.sp_produtos_sem_venda_ultimo_7_dias('2025-10-14');

CREATE OR REPLACE PROCEDURE stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data DATE)
LANGUAGE plpgsql
AS $$
BEGIN

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_1 = null,
		venda_2 = null,
		venda_3 = null,
		venda_4 = null,
		venda_5 = null,
		venda_6 = null,
		venda_7 = null,
		status_1 = null,
		status_2 = null,
		status_3 = null,
		status_4 = null,
		status_5 = null,
		status_6 = null,
		status_7 = null
	where a.ultima_entrada = p_data;

-- ATUALIZA QUANTIDADE DE VENDAS----------------------------------------------------------------------------------------
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  	WHERE a.dta = current_date - 1
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_1 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 2
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_2 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;

	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 3
	)
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_3 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;

	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 4
	)
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_4 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 5
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_5 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 6
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_6 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 7
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_7 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;

-- SOMA A QUANTIDADE VENDIDA NOS 7 DIAS --------------------------------------------------------------
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set qtde_vendida_total = coalesce(venda_1,0) + coalesce(venda_2,0) + coalesce(venda_3,0) + coalesce(venda_4,0) + coalesce(venda_5,0) + coalesce(venda_6,0) + coalesce(venda_7,0) 	
	where a.ultima_entrada = p_data;
	

---- STATUS DE VENDAS - SE TEM VENDA INSERE 1 ---------------------------------------------------------------------------------------

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_1 = case when a.venda_1 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_2 = case when a.venda_2 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_3 = case when a.venda_3 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_4 = case when a.venda_4 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_5 = case when a.venda_5 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_6 = case when a.venda_6 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_7 = case when a.venda_7 is null then 1 end 
	where a.ultima_entrada = p_data ;

-- VERIFICA OS DIAS DE VENDAS ------------------------------------------------------------------------------------------------------
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_count = Case When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
							 and a.status_4 = 1  
							 and a.status_5 = 1
							 and a.status_6 = 1
                             and a.status_7 = 1 then 7
							When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
							 and a.status_4 = 1  
							 and a.status_5 = 1
                             and a.status_6 = 1 then 6
							When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
							 and a.status_4 = 1  
                             and a.status_5 = 1 then 5
							When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
                             and a.status_4 = 1 then 4
							When a.status_1 = 1 
                             and a.status_2 = 1 
                             and a.status_3 = 1 then 3
							When a.status_1 = 1 
                             and a.status_2 = 1 then 2
							When a.status_1 = 1 then 1
						End					   
	where a.ultima_entrada = p_data ;

-- DELETA AS COMPRAS QUANDO O VALOR DA QUANTIDADE TOTAL FOR IGUAL OU MAIOR DA Ultima_Entrada
DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
WHERE qtde_vendida_total >=  qtde_entrada;

END;
$$;





SELECT *
FROM stage.tbl_produtos_sem_venda_ultimo_7_dias WHERE ultima_entrada = '2025-10-08' AND nroempresa = 7 And sku_estoque in ( 76057, 104793, 68444) ;

SELECT nrodivisao, nroempresa, dta, seqproduto, qtdembalagem, statuscompra, statusvenda, qtdvenda, vlrvendabruto, vlrpromoc, vlrlucratividade, vlrverbavda, dta_atualizacao
FROM venda.f_venda_produto
WHERE dta in ('2025-10-15')  and seqproduto = 61622 and nroempresa = 6;


SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM vendas.tbl_prod_gyn_2025
Where dta = '2025-10-14' and seqproduto = '61622' and nroempresa = '6';

--------------------------------------------------------------------------------------------

-- DROP TABLE cadastro.d_produto;

CREATE TABLE cadastro.d_produto (
	nrodivisao smallint,
	seqprodutodiv varchar(81) NULL,
	seqproduto  NULL,
	desccompleta varchar(255) NULL,
	seqfamilia varchar(38) NULL,
	seqcomprador varchar(3) NULL,
	seqcategoria varchar(5) NULL,
	caminhocompleto varchar(300) NULL,
	dta_atualizacao timestamp NULL
);
CREATE INDEX idx_produto_caminhocompleto_textpattern ON cadastro.d_produto USING btree (caminhocompleto text_pattern_ops);
CREATE INDEX idx_produto_seqproduto ON cadastro.d_produto USING btree (seqproduto);

SELECT count(*)
FROM drop table venda.f_venda_produto_mes;

-------------------------------------------------------------------------------------------



-- Insere os dados na partição ---------------------
INSERT INTO venda.f_venda_produto_mes
SELECT nroempresa, b.dia_inicio_mes , seqproduto, sum(qtdvenda) as qtdvend, sum(vlrvendabruto) as vlrvendabruto, 
	sum(vlrpromoc) as vlrpromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrverbavda) as vlrverbavda	
FROM venda.f_venda_produto as a inner join cadastro.vw_d_calendario as b 
ON a.dta = b.dia 
WHERE dta >= DATE '2025-01-01' AND dta < DATE '2025-12-31'
group by nroempresa, b.dia_inicio_mes , seqproduto;


-- Insere os dados na partição ---------------------

-- ATUALIZA VENDA POR PRODUTO MENSAL, sempre buscando os ultimos 31 dias
DELETE FROM venda.f_venda_produto_mes WHERE dia_inicio_mes between current_date - 31 AND current_date - 1;

INSERT INTO venda.f_venda_produto_mes
SELECT nroempresa, b.dia_inicio_mes , seqproduto, sum(qtdvenda) as qtdvend, sum(vlrvendabruto) as vlrvendabruto, 
	sum(vlrpromoc) as vlrpromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrverbavda) as vlrverbavda	
FROM venda.f_venda_produto as a inner join cadastro.vw_d_calendario as b 
ON a.dta = b.dia 
WHERE dia_inicio_mes between current_date - 31 AND current_date - 1
group by nroempresa, b.dia_inicio_mes , seqproduto;



truncate table stage.f_prezi_brasilia;

-- Faturamento
INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'faturamento' as tipo, a.nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto
FROM venda.f_venda_comprador_mes as a inner join cadastro.d_empresa as b
ON a.nroempresa = b.nroempresa
WHERE b.nrodivisao = 1 and a.nroempresa not in (200,900);

INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'faturamento' as tipo, nroempresa, dia_inicio_mes, 0 as seqcomprador, sum(vlrvendabruto) as vlrvendabruto
FROM stage.f_prezi_brasilia as a
group by tipo, dia_inicio_mes, nroempresa;

INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'faturamento' as tipo, 991 as nroempresa, dia_inicio_mes, seqcomprador, sum(vlrvendabruto) as vlrvendabruto
FROM stage.f_prezi_brasilia as a
group by tipo, dia_inicio_mes, seqcomprador
;

-- Rentabilidade
INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'rentabilidade' as tipo, a.nroempresa, dia_inicio_mes, seqcomprador, a.vlrlucratividade 
FROM venda.f_venda_comprador_mes as a inner join cadastro.d_empresa as b
ON a.nroempresa = b.nroempresa
WHERE b.nrodivisao = 1 and a.nroempresa not in (200,900);

INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'rentabilidade' as tipo, nroempresa, dia_inicio_mes, 0 as seqcomprador, sum(vlrvendabruto ) as vlrvendabruto
FROM stage.f_prezi_brasilia as a
WHERE tipo = 'rentabilidade'
group by tipo, dia_inicio_mes, nroempresa;

INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'rentabilidade' as tipo, 991 as nroempresa, dia_inicio_mes, seqcomprador, sum(vlrvendabruto ) as vlrvendabruto
FROM stage.f_prezi_brasilia as a
WHERE tipo = 'rentabilidade'
group by tipo, dia_inicio_mes, seqcomprador
;

-- Quantidade
INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'quantidade' as tipo, a.nroempresa, dia_inicio_mes, seqcomprador, a.qtdvenda  
FROM venda.f_venda_comprador_mes as a inner join cadastro.d_empresa as b
ON a.nroempresa = b.nroempresa
WHERE b.nrodivisao = 1 and a.nroempresa not in (200,900);

INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'quantidade' as tipo, nroempresa, dia_inicio_mes, 0 as seqcomprador, sum(vlrvendabruto ) as vlrvendabruto
FROM stage.f_prezi_brasilia as a
WHERE tipo = 'quantidade'
group by tipo, dia_inicio_mes, nroempresa;

INSERT INTO stage.f_prezi_brasilia
(tipo, nroempresa, dia_inicio_mes, seqcomprador, vlrvendabruto)
SELECT 'quantidade' as tipo, 991 as nroempresa, dia_inicio_mes, seqcomprador, sum(vlrvendabruto ) as vlrvendabruto
FROM stage.f_prezi_brasilia as a
WHERE tipo = 'quantidade'
group by tipo, dia_inicio_mes, seqcomprador
;


Select * 
from stage.f_prezi_brasilia
where dia_inicio_mes = '2025-01-01' and nroempresa = 4 and seqcomprador = 0;

-- financeiro.vw_tbl_despesa_geral source

ALTER TABLE financeiro.tbl_despesa_geral
ADD COLUMN id_despesa_geral BIGSERIAL;

UPDATE financeiro.tbl_despesa_geral
SET id_despesa_geral = nextval(pg_get_serial_sequence('financeiro.tbl_despesa_geral', 'id_despesa_geral'))
WHERE id_despesa_geral IS NULL;

ALTER TABLE financeiro.tbl_despesa_geral
ADD CONSTRAINT pk_tbl_despesa_geral PRIMARY KEY (id_despesa_geral);

update financeiro.tbl_despesa_geral
set dta_antecipacao = null

select * 
from financeiro.tbl_despesa_geral
where data_arquivo = '2025_10_17' and dta_vencimento_programado = '2025_10_17'
order by dta_antecipacao desc;

select * 
from financeiro.tbl_despesa_geral
where data_arquivo = '2025_10_17' and dta_vencimento_programado = '2025_10_20'
order by dta_antecipacao desc;

select * 
from financeiro.tbl_despesa_geral
where data_arquivo = '2025_10_17' and dta_vencimento_programado = '2025_10_20'
order by dta_antecipacao desc;

select data_arquivo , dta_vencimento_programado , dta_pagamento, dta_antecipacao 
from financeiro.tbl_despesa_geral
where data_arquivo = '2025_10_17' and dta_pagamento = '2025_10_17'
;

select data_arquivo , dta_vencimento_programado , dta_pagamento, dta_antecipacao , especie
from financeiro.vw_tbl_despesa_geral
where data_arquivo = '2025_10_17' and dta_pagamento = '2025_10_17' and especie = 'DOIMIC';

alter table financeiro.tbl_despesa_geral add dta_pagamento date;
---------------------------------------------------------------------------------------------------------------

-- financeiro.vw_tbl_despesa_geral source



--------------------------------------------------------------
TRUNCATE TABLE venda.f_venda_comprador_mes ;

INSERT INTO venda.f_venda_comprador_mes
(nroempresa, dia_inicio_mes, seqcomprador, qtdvenda, vlrvendabruto, vlrpromoc, vlrlucratividade, vlrverbavda)
SELECT nroempresa, dia_inicio_mes, b.seqcomprador::int4 , 
	sum(qtdvenda) as qtdvenda, sum(vlrvendabruto) as vlrvendabruto, sum(vlrpromoc) as vlrpromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrverbavda) as vlrverbavda	
FROM venda.f_venda_produto_mes as a inner join cadastro.vw_d_produto_brasilia as b 
on a.seqproduto::varchar  = b.seqproduto 
WHERE b.nrodivisao = '1' and a.nroempresa not in (6,7,8,9,10,11,900) 
GROUP BY nroempresa, dia_inicio_mes, b.seqcomprador::int4
;

INSERT INTO venda.f_venda_comprador_mes
(nroempresa, dia_inicio_mes, seqcomprador, qtdvenda, vlrvendabruto, vlrpromoc, vlrlucratividade, vlrverbavda)
SELECT nroempresa, dia_inicio_mes, b.seqcomprador::int4 , 
	sum(qtdvenda) as qtdvenda, sum(vlrvendabruto) as vlrvendabruto, sum(vlrpromoc) as vlrpromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrverbavda) as vlrverbavda	
FROM venda.f_venda_produto_mes as a inner join cadastro.vw_d_produto_goiania as b 
on a.seqproduto::varchar  = b.seqproduto
WHERE b.nrodivisao = '2' and nroempresa not in (1,2,3,4,5,12,13,14,15,16,17,200,900)
GROUP BY nroempresa, dia_inicio_mes, b.seqcomprador::int4
;


SELECT nroempresa, dia_inicio_mes, seqcomprador, qtdvenda, vlrvendabruto, vlrpromoc, vlrlucratividade, vlrverbavda
FROM venda.f_venda_comprador_mes as a inner join cadastro.d_comprador as b
WHERE dia_inicio_mes = '2025-01-01';

ALTER TABLE venda.f_venda_comprador_mes
  ALTER COLUMN qtdvenda TYPE numeric(14,4)
  USING ROUND(qtdvenda, 4);

select * from venda.f_venda_comprador_mes 
where dia_inicio_mes = '2025-09-01'


truncate table stage.tbl_despesa_geral;

DELETE FROM financeiro.tbl_despesa_geral WHERE data_arquivo IN (SELECT max(data_arquivo) FROM stage.tbl_despesa_geral);

INSERT INTO financeiro.tbl_despesa_geral
               (data_arquivo, pessoa, nroempresa, id_bco, agencia, id_especie, titulo, serie, parc, id_depositario, dta_emissao, dta_movimento, dta_vencimento_programado, prazo_efetivo, sc, dias_de_atraso, dv, vlr_multa, vlr_juros, perc_desc_financeiro, perc_desc_acordo, vlr_desconto, vlr_taxa_adm, vlr_original, vlr_aberto, vlr_liquido, a, p)
SELECT data_arquivo, pessoa, nroempresa, b.id_bco , agencia, d.id_especie , titulo, serie, parc, c.id_depositario , dta_emissao, dta_movimento, dta_vencimento_programado, prazo_efetivo, sc, dias_de_atraso, dv, vlr_multa, vlr_juros, perc_desc_financeiro, perc_desc_acordo, vlr_desconto, vlr_taxa_adm, vlr_original, vlr_aberto, vlr_liquido, a, p
FROM stage.tbl_despesa_geral as a inner join financeiro.tbl_bco as b 
ON a.bco = b.bco inner join financeiro.tbl_depositario as c 
ON a.depositario = c.depositario inner join financeiro.tbl_especie as d 
ON a.especie = d.especie 

order by seqcomprador, nroempresa;


SELECT nroempresa, dia_inicio_mes, b.seqcomprador::int4 , a.seqproduto ,
	sum(qtdvenda) as qtdvenda, sum(vlrvendabruto) as vlrvendabruto, sum(vlrpromoc) as vlrpromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrverbavda) as vlrverbavda	
FROM venda.f_venda_produto_mes as a inner join cadastro.vw_d_produto as b 
on a.seqproduto::varchar  = b.seqproduto
WHERE b.nrodivisao = '1' and a.nroempresa = 1 and a.dia_inicio_mes = '2025-09-01' and b.seqcomprador = '1'
GROUP BY nroempresa, dia_inicio_mes, b.seqcomprador::int4, a.seqproduto
;

SELECT nrodivisao, seqprodutodiv, seqproduto, desccompleta, seqfamilia, seqcomprador, seqcategoria, caminhocompleto, dta_atualizacao, departamento, secao, grupo, subgrupo, seqfornecedor, nomerazao, fantasia
FROM cadastro.vw_d_produto
where nrodivisao = '1' and seqproduto in ('23489','99931','113125')
;

SELECT nrodivisao, nroempresa, dta, seqproduto, qtdembalagem, statuscompra, statusvenda, qtdvenda, vlrvendabruto, vlrpromoc, vlrlucratividade, vlrverbavda, dta_atualizacao
FROM venda.f_venda_produto
WHERE dta BETWEEN '2025-09-01' and '2025-09-30' and seqproduto = 99931 and nroempresa = 1;

CREATE OR REPLACE VIEW cadastro.vw_d_produto_Goiania as
SELECT nrodivisao, seqprodutodiv, seqproduto, desccompleta, seqfamilia, seqcomprador, seqcategoria, caminhocompleto, dta_atualizacao, departamento, secao, grupo, subgrupo, seqfornecedor, nomerazao, fantasia
FROM cadastro.vw_d_produto
WHERE nrodivisao = '2'
;


