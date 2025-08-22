
-- bi.vw_d_produto source

CREATE OR REPLACE VIEW bi.vw_d_produto
AS 
with cte as (
SELECT d_produto.nrodivisao,
    d_produto.seqprodutodiv,
    d_produto.seqproduto,
    d_produto.desccompleta,
    d_produto.seqfamilia,
    d_produto.seqcomprador,
    d_produto.seqcategoria,
    d_produto.caminhocompleto,
    d_produto.dta_atualizacao,
    split_part(d_produto.caminhocompleto::text, '\'::text, 1) AS departamento,
    split_part(d_produto.caminhocompleto::text, '\'::text, 2) AS secao,
    split_part(d_produto.caminhocompleto::text, '\'::text, 3) AS grupo,
    split_part(d_produto.caminhocompleto::text, '\'::text, 4) AS subgrupo
   FROM bi.d_produto
  WHERE d_produto.nrodivisao::text = '2'::text
 )
 
 select nrodivisao,
    seqprodutodiv,
    seqproduto,
    desccompleta,
    seqfamilia,
    seqcomprador,
    seqcategoria,
    caminhocompleto,
    dta_atualizacao,     
    case when caminhocompleto = 'SEM PRODUTO \ VAGO NAO USAR' then 'SEM CADASTRO' else departamento end as departamento,
    case when caminhocompleto = 'SEM PRODUTO \ VAGO NAO USAR' then 'SEM CADASTRO' else secao end as secao,
    case when caminhocompleto = 'SEM PRODUTO \ VAGO NAO USAR' then 'SEM CADASTRO' else grupo end as grupo,    
    case when caminhocompleto = 'SEM PRODUTO \ VAGO NAO USAR' then 'SEM CADASTRO' 
         when subgrupo = '' then grupo 
         else subgrupo 
    end as subgrupo           
 from cte 
 ;
 
--  SEM PRODUTO \ VAGO NAO USAR


create  or replace view cadastro.vw_mercadologico_gyn_atualizado
as
with cte as (
SELECT  
caminhocompleto, departamento ,secao, grupo, subgrupo
FROM bi.vw_d_produto
where nrodivisao = '2' and departamento <> 'ALMOXARIFADO ' 
group by caminhocompleto, departamento ,secao, grupo, subgrupo
)

select row_number() over (order by subgrupo) as id_subgrupo, subgrupo,  
	   dense_rank() over (order by grupo) as id_grupo, grupo,
	   dense_rank() over (order by secao) as id_secao, secao,
	   dense_rank() over (order by departamento) as id_departamento, 
	   departamento,
	   caminhocompleto
from cte 
where subgrupo <> '';

------------------------------------------------------------------------------------------------------------------------------------------
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




drop table cadastro.tbl_mercadologico_departamento;
CREATE TABLE cadastro.tbl_mercadologico_departamento (
	id_departamento smallint not NULL,
	departamento text null,
	order_depto smallint,
	primary key (id_departamento)
);


DROP TABLE cadastro.tbl_mercadologico_secao;
CREATE TABLE cadastro.tbl_mercadologico_secao (
	id_secao int8 not NULL,
	secao text null,
	order_secao smallint,	
	id_departamento smallint,
	primary key (id_secao)
);


DROP TABLE cadastro.tbl_mercadologico_grupo;
CREATE TABLE cadastro.tbl_mercadologico_grupo (
	id_grupo int8 not NULL,
	grupo text null,
	order_grupo smallint,	
	id_secao int8,
	primary key (id_grupo)
);


DROP TABLE cadastro.tbl_mercadologico_subgrupo;
CREATE TABLE cadastro.tbl_mercadologico_subgrupo (
	id_subgrupo int8 not NULL,
	subgrupo text null,
	order_subgrupo smallint,	
	id_grupo int8,
	primary key (id_subgrupo)
);


select b.id_subgrupo, dta, nroempresa, sum(vlrvenda) as vlrvenda
FROM vendas.tbl_prod_gyn_2025 as a inner join bi.vw_d_produto_com_mercadologico as b
on a.seqproduto = b.seqproduto
where dta between '2025-05-01' and '2025-05-06' and b.seqcomprador <> '41'
group by b.id_subgrupo, dta, nroempresa
;


-- PASSO 01 - Atualiza Vendas por Subgrupo 2025 (em média 3 minutos par atualizar)--------------------------------
truncate table vendas.stage_subgrupo;
INSERT INTO vendas.stage_subgrupo
(id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
select b.id_subgrupo, dta, nroempresa, 
	sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos, 
	sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrctobruto) as vlrctobruto, sum(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda	
FROM vendas.tbl_prod_gyn_2025 as a inner join bi.vw_d_produto_com_mercadologico as b
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


select dta, nroempresa,  a.seqproduto,  quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.tbl_prod_gyn_2025 as a 
where dta between '2025-05-01' and '2025-05-01'
;

select dta,  sum(vlrvenda) as vlrvenda
FROM vendas.tbl_prod_gyn_2025 as a 
where dta between '2025-05-01' and '2025-05-01'
group by dta
;

SELECT  dta
FROM vendas.vw_dia_subgrupo
where dta between '2025-05-01' and '2025-05-11'
group by dta
order by dta;


SELECT count(distinct caminhocompleto)
FROM bi.vw_d_produto;

create or replace view bi.vw_d_produto_com_mercadologico
as
SELECT nrodivisao, seqprodutodiv, seqproduto, desccompleta, seqfamilia, seqcomprador, seqcategoria, a.caminhocompleto, dta_atualizacao, a.departamento, a.secao, a.grupo, a.subgrupo, b.id_subgrupo
FROM bi.vw_d_produto as a inner join cadastro.vw_mercadologico_gyn_atualizado as b 
on a.departamento = b.departamento
and a.secao = b.secao 
and a.grupo = b.grupo
and a.subgrupo = b.subgrupo;



SELECT seqcomprador, comprador, apelido, status, seqpessoa, dta_atualizacao, 
	case when seqcomprador = 45 and know.fn_date_year_current() >= 2025 and know.fn_date_month_current() between 1 and 4 then id_gerente_categoria = 15 
		 when seqcomprador = 45 and know.fn_date_year_current() >= 2025 and know.fn_date_month_current() >= 5 then id_gerente_categoria = 2
		 else id_gerente_categoria
	end as id_gerente_categoria,
	id_departamento, base_calculo_ruptura, desc_secao, secao, ordem_seqcomprador 
FROM bi.vw_d_comprador;




SELECT a.id_secao, b.secao, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.tbl_dia_secao as a inner join cadastro.tbl_mercadologico_secao as b 
on a.id_secao = b.id_secao
where dta = '2025-05-01'


SELECT dta, nroempresa, empresa, a.seqcomprador, comprador, a.seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, 
vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM vendas.tbl_prod_gyn_2025 as a 
where dta = '2025-05-01' ;


SELECT dta, nroempresa, empresa, a.seqcomprador, comprador, a.seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, 
vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta, b.secao
FROM vendas.tbl_prod_gyn_2025 as a inner join bi.produto_com_mercadologico as b
on a.seqproduto = b.seqproduto
where dta = '2025-05-01' ;

--FROM vendas.tbl_prod_gyn_2025 as a inner join bi.vw_d_produto_com_mercadologico as b
--on a.seqproduto = b.seqproduto
--where dta = '2025-05-01';


DROP TABLE bi.produto_com_mercadologico;
SELECT nrodivisao, seqprodutodiv, seqproduto, desccompleta, seqfamilia, seqcomprador, seqcategoria, caminhocompleto, dta_atualizacao, departamento, secao, grupo, subgrupo, id_subgrupo
into bi.produto_com_mercadologico
FROM bi.vw_d_produto_com_mercadologico;



-- cadastro.produto_com_mercadologico definition

-- Drop table



CREATE TABLE cadastro.produto_com_mercadologico (
	nrodivisao varchar(3) NULL,
	seqprodutodiv varchar(81) NULL,
	seqproduto varchar(38) NULL,
	desccompleta varchar(255) NULL,
	seqfamilia varchar(38) NULL,
	seqcomprador varchar(3) NULL,
	seqcategoria varchar(5) NULL,
	caminhocompleto varchar(300) NULL,
	dta_atualizacao timestamp NULL,
	departamento text NULL,
	secao text NULL,
	grupo text NULL,
	subgrupo text NULL,
	id_subgrupo int8 null
);



SELECT id_departamento, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.tbl_dia_departamento
where dta = '2025-05-01';

SELECT id_secao, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.tbl_dia_secao
where dta = '2025-05-01';

SELECT id_grupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.tbl_dia_grupo
where dta = '2025-05-01';

SELECT id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.tbl_dia_subgrupo
where dta = '2025-05-01';

create or replace view vendas.vw_dia_subgrupo
as
SELECT a.id_subgrupo, dta, nroempresa, quantidade, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda
FROM vendas.tbl_dia_subgrupo as a inner join cadastro.tbl_mercadologico_subgrupo tms 
on a.id_subgrupo  = tms.id_subgrupo 
;


-- EXCLUI TODAS AS QUANTIDADES DO ANO ATUAL
delete 
from bi.f_prezi 
where date_part('year', dia) = date_part('year',date_trunc('year', Current_date)::date)
and tipo = 'preco_medio';

-- ATUALIZAR A QUANTIDADE NO PREZI APENAS DO ANO DE 2025 PARA FRENTE -----------------------------
INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT 
    'preco_medio', 
    case when SUM(qtde_venda_real) = 0 then 0
         when SUM(venda_vlr_real) = 0 then 0
         else SUM(venda_vlr_real) / SUM(qtde_venda_real) -- Soma os valores duplicados
    end,
    dia, 
    seqcomprador,
    nroempresa
FROM bi.venda_comprador_total_mes
GROUP BY dia, seqcomprador, nroempresa
ON CONFLICT (tipo, dia, seqcomprador, nroempresa)  -- SE JA EXISTIR ESSA INFORMAÇÂO
DO UPDATE SET vlrreal = EXCLUDED.vlrreal
where bi.f_prezi.dia  >= date_trunc('year', Current_date)::date;


-- INSER OS VALORES PADRÕES AONDE NÃO HOUVER INFORMAÇÕES

DROP TABLE IF EXISTS tt;

create temp table tt (
		tipo varchar(50),
		dia_inicio_mes date,
		seqcomprador smallint,
		nroempresa smallint,
		vlrrreal decimal		
	);

	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'preco_medio', dia_inicio_mes, c.seqcomprador, b.nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= date_trunc('year', Current_date)::date;
	
	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'preco_medio', dia_inicio_mes, 0 as seqcomprador, b.nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= date_trunc('year', Current_date)::date;
	
	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'preco_medio', dia_inicio_mes, c.seqcomprador, 992 as nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= date_trunc('year', Current_date)::date;
	
	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'preco_medio', dia_inicio_mes, 0 as seqcomprador, 992 as nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= date_trunc('year', Current_date)::date;
	
	insert into bi.f_prezi (tipo, dia, seqcomprador, nroempresa, vlrreal)
	select a.tipo, a.dia_inicio_mes, a.seqcomprador, a.nroempresa, 0
	from tt as a left outer join bi.f_prezi b
	on a.tipo = b.tipo
	and a.dia_inicio_mes = b.dia
	and a.seqcomprador = b.seqcomprador
	and a.nroempresa = b.nroempresa
	where b.vlrreal is null;
	




