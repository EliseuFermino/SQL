

-- ATUALIZA MERCADOLOGICOS --------------------------------------------------------------

-- Atualiza Departamento
truncate table cadastro.tbl_mercadologico_departamento;
insert into cadastro.tbl_mercadologico_departamento
	(id_departamento, departamento)
select id_departamento, departamento
from cadastro.vw_mercadologico_gyn_atualizado
group by id_departamento, departamento;

update cadastro.tbl_mercadologico_departamento
set order_depto = 1
where departamento = 'MERCEARIA ';

update cadastro.tbl_mercadologico_departamento
set order_depto = 2
where departamento = 'PERECIVEIS ';

update cadastro.tbl_mercadologico_departamento
set order_depto = 3
where departamento = 'BAZAR ';

update cadastro.tbl_mercadologico_departamento
set order_depto = 4
where departamento = 'TEXTIL ';

update cadastro.tbl_mercadologico_departamento
set order_depto = 5
where departamento = 'ELETRO E MOVEIS ';

update cadastro.tbl_mercadologico_departamento
set order_depto = 6
where departamento = 'SEM CADASTRO';



-- Atualiza Secao
truncate table cadastro.tbl_mercadologico_secao;
insert into cadastro.tbl_mercadologico_secao
	(id_departamento, id_secao, secao)
select id_departamento, id_secao, secao
from cadastro.vw_mercadologico_gyn_atualizado
group by id_departamento, id_secao, secao;


-- Atualiza Grupo
truncate table cadastro.tbl_mercadologico_grupo;
insert into cadastro.tbl_mercadologico_grupo
	(id_secao, id_grupo, grupo)
select id_secao, id_grupo, grupo
from cadastro.vw_mercadologico_gyn_atualizado
group by id_secao, id_grupo, grupo;


-- Atualiza subgrupo
truncate table cadastro.tbl_mercadologico_subgrupo;
insert into cadastro.tbl_mercadologico_subgrupo
	(id_grupo, id_subgrupo, subgrupo)
select id_grupo, id_subgrupo, subgrupo
from cadastro.vw_mercadologico_gyn_atualizado
group by id_grupo, id_subgrupo, subgrupo;


-- ATUALIZA VENDAS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

truncate table vendas.stage_subgrupo;

-- PASSO 01 - Atualiza Vendas por Subgrupo 2021 (em média 3 minutos par atualizar)---------------------------------
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select b.id_subgrupo, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda	
FROM vendas.tbl_prod_gyn_2021 as a inner join bi.vw_d_produto_com_mercadologico as b
on a.seqproduto = b.seqproduto 
where dta between '2021-03-01' and '2021-12-31'
group by b.id_subgrupo, grupo, secao, departamento, dta, nroempresa
;

-- INSERE DADOS PARA O MES DE JANEIRO/2021. O PREZI PRECISA DESSA INFORMAÇÃO ---------------------
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select id_subgrupo, '2021-01-01' as dta, nroempresa,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
from vendas.stage_subgrupo
group by id_subgrupo, nroempresa;

-- INSERE DADOS PARA O MES DE FEVEREIRO/2021. O PREZI PRECISA DESSA INFORMAÇÃO ---------------------
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select id_subgrupo, '2021-02-01' as dta, nroempresa,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
from vendas.stage_subgrupo
group by id_subgrupo, nroempresa;

-- PASSO 01 - Atualiza Vendas por Subgrupo 2022 (em média 3 minutos par atualizar)---------------------------------
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select b.id_subgrupo, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda	
FROM vendas.tbl_prod_gyn_2022 as a inner join bi.vw_d_produto_com_mercadologico as b
on a.seqproduto = b.seqproduto
group by b.id_subgrupo, grupo, secao, departamento, dta, nroempresa
;

-- PASSO 01 - Atualiza Vendas por Subgrupo 2023 (em média 3 minutos par atualizar)---------------------------------
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select b.id_subgrupo, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda	
FROM vendas.tbl_prod_gyn_2023 as a inner join bi.vw_d_produto_com_mercadologico as b
on a.seqproduto = b.seqproduto
group by b.id_subgrupo, grupo, secao, departamento, dta, nroempresa
;


-- PASSO 01 - Atualiza Vendas por Subgrupo 2024 (em média 3 minutos par atualizar)---------------------------------
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select b.id_subgrupo, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda	
FROM vendas.tbl_prod_gyn_2024 as a inner join bi.vw_d_produto_com_mercadologico as b
on a.seqproduto = b.seqproduto
group by b.id_subgrupo, grupo, secao, departamento, dta, nroempresa
;


-- PASSO 01 - Atualiza Vendas por Subgrupo 2025 (em média 3 minutos par atualizar)--------------------------------
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select b.id_subgrupo, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda	
FROM vendas.tbl_prod_gyn_2025 as a inner join bi.vw_d_produto_com_mercadologico as b
on a.seqproduto = b.seqproduto
group by b.id_subgrupo, grupo, secao, departamento, dta, nroempresa
;


-- INSERE DADOS PARA OS MESES SUB-SEQUENTES ATÉ O FINAL DO ANO CORRENTE. O PREZI PRECISA DESSA INFORMAÇÃO ---------------------
with cte_slv_ano_atual as (
select id_subgrupo, nroempresa
from vendas.stage_subgrupo
where dta between know.fn_date_primeiro_dia_do_ano_atual() and know.fn_date_eomonth(know.fn_date_ontem()) 
group by id_subgrupo,  nroempresa
),

cte_dias as (
select dia, dia_numero
from bi.vw_d_calendario
where dia between know.fn_date_eomonth(know.fn_date_ontem()) + 1 and know.fn_date_ultimo_dia_do_ano_atual()
)

INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select b.id_subgrupo, a.dia,  b.nroempresa , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
from cte_dias as a cross join cte_slv_ano_atual as b
where a.dia_numero = 1;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- ATUALIZA AS VENDAS NAS TABELAS QUENTES --------------------------------
-- SUBGRUPO -  (em média 16 segundos para atualizar)
truncate table vendas.tbl_dia_subgrupo;
INSERT INTO vendas.tbl_dia_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.stage_subgrupo;

-- GRUPO	--  (em média 10 segundos para atualizar)
truncate table vendas.tbl_dia_grupo;
INSERT INTO vendas.tbl_dia_grupo
(id_grupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT b.id_grupo, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda
FROM vendas.tbl_dia_subgrupo as a inner join cadastro.tbl_mercadologico_subgrupo as b
on a.id_subgrupo = b.id_subgrupo
group by b.id_grupo, dta, nroempresa;

-- SECAO	-- (em média 3 segundos para atualizar)
truncate table vendas.tbl_dia_secao;
INSERT INTO vendas.tbl_dia_secao
(id_secao, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT b.id_secao, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda
FROM vendas.tbl_dia_grupo as a inner join cadastro.tbl_mercadologico_grupo as b
on a.id_grupo = b.id_grupo
group by b.id_secao, dta, nroempresa;

-- DEPARTAMENTO	-- (em média 1 segundos para atualizar)
truncate table vendas.tbl_dia_departamento;
INSERT INTO vendas.tbl_dia_departamento 
(id_departamento, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT b.id_departamento, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda
FROM vendas.tbl_dia_secao as a inner join cadastro.tbl_mercadologico_secao as b
on a.id_secao = b.id_secao
group by b.id_departamento, dta, nroempresa;

-- ATUALIZA MES --------------------------------------------
truncate table vendas.tbl_mes_subgrupo;
INSERT INTO vendas.tbl_mes_subgrupo
(id_subgrupo, nroempresa, ano, mes, dta, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT id_subgrupo, nroempresa,  know.fn_date_year(dta) as ano, know.fn_date_month(dta) as mes, know.fn_date_bomonth_currentdate(dta) as dia_inicial,
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda
FROM vendas.tbl_dia_subgrupo
group by id_subgrupo, nroempresa, know.fn_date_year(dta), know.fn_date_month(dta), know.fn_date_bomonth_currentdate(dta);

truncate table vendas.tbl_mes_grupo;
INSERT INTO vendas.tbl_mes_grupo
(id_grupo, nroempresa, ano, mes, dta, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT b.id_grupo, nroempresa,  ano, mes, dta,
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda
FROM vendas.tbl_mes_subgrupo as a inner join cadastro.tbl_mercadologico_subgrupo as b
on a.id_subgrupo = b.id_subgrupo
group by b.id_grupo, nroempresa, ano, mes, dta;

truncate table vendas.tbl_mes_secao;
INSERT INTO vendas.tbl_mes_secao
(id_secao, nroempresa, ano, mes, dta, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT b.id_secao, nroempresa,  ano, mes, dta,
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda
FROM vendas.tbl_mes_grupo as a inner join cadastro.tbl_mercadologico_grupo as b
on a.id_grupo = b.id_grupo
group by b.id_secao, nroempresa, ano, mes, dta;

truncate table vendas.tbl_mes_departamento;
INSERT INTO vendas.tbl_mes_departamento
(id_departamento, nroempresa, ano, mes, dta, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT b.id_departamento, nroempresa,  ano, mes, dta,
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda
FROM vendas.tbl_mes_secao as a inner join cadastro.tbl_mercadologico_secao as b
on a.id_secao = b.id_secao
group by b.id_departamento, nroempresa, ano, mes, dta;