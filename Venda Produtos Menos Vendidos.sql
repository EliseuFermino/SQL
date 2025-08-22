
INSERT INTO vendas.tbl_vendas_prod_mes_divisao_comprador
(dia_mes, ano, mes, nrodivisao, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT dia_mes, ano, mes, b.nrodivisao , seqcomprador, seqproduto, 
SUM(quantidade) as quantidade, SUM(contagemprodutos) as contagemprodutos, SUM(vlrvenda) as vlrvenda, SUM(vlrdesconto) as vlrdesconto, 
SUM(vlroperacao) as vlroperacao, SUM(vlrtotalsemimpostos) as vlrtotalsemimpostos, SUM(vendapromoc) as vendapromoc, 
SUM(vlrlucratividade) as vlrlucratividade, SUM(vlrctobruto) as vlrctobruto, SUM(vlrctoliquido) as vlrctoliquido, SUM(vlrverbavda) as vlrverbavda
FROM vendas.tbl_vendas_prod_mes_filial as a inner join bi.d_empresa as b
on a.nroempresa = b.nroempresa
where Ano=2025 and Mes=4 and quantidade <= 1
group by dia_mes, ano, mes, b.nrodivisao , seqcomprador, seqproduto;

---------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE vendas.tbl_vendas_prod_mes_divisao_comprador (
	dia_mes date NOT NULL,
	ano int2 NULL,
	mes int2 NULL,
	nrodivisao int2 NOT NULL,
	seqcomprador int2 NOT NULL,
	seqproduto int4 NOT NULL,
	quantidade float8 NULL,
	contagemprodutos float8 NULL,
	vlrvenda float8 NULL,
	vlrdesconto float8 NULL,
	vlroperacao float8 NULL,
	vlrtotalsemimpostos float8 NULL,
	vendapromoc float8 NULL,
	vlrlucratividade float8 NULL,
	vlrctobruto float8 NULL,
	vlrctoliquido float8 NULL,
	vlrverbavda float8 NULL,
	CONSTRAINT tbl_vendas_prod_mes_divisao_comprador_pkey PRIMARY KEY (dia_mes, nrodivisao, seqcomprador, seqproduto)
);

drop view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_1;

create or replace view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos
as
select 1 as unidade, dia_mes, ano, mes, nroempresa, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria, nrodivisao, 1 as sku
FROM vendas.tbl_vendas_prod_mes_filial as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade <=1 

union all
select 2 as unidade, dia_mes, ano, mes, nroempresa, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria, nrodivisao, 1 as sku
FROM vendas.tbl_vendas_prod_mes_filial as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 1.0001 and 2 
union all
select 3 as unidade, dia_mes, ano, mes, nroempresa, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria, nrodivisao, 1 as sku
FROM vendas.tbl_vendas_prod_mes_filial as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 2.0001 and 3 
union all
select 4 as unidade, dia_mes, ano, mes, nroempresa, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria, nrodivisao, 1 as sku
FROM vendas.tbl_vendas_prod_mes_filial as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 3.0001 and 4 
union all
select 5 as unidade, dia_mes, ano, mes, nroempresa, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria, nrodivisao, 1 as sku
FROM vendas.tbl_vendas_prod_mes_filial as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 4.0001 and 5 ;


select unidade, dia_mes, ano, mes, nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, 
vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, id_gerente_categoria, desc_secao, desc_comprador_categoria, nrodivisao,
count(distinct seqproduto)  as SKU_Unico
from vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_1
where ano = 2025 and mes = 4
group by unidade, dia_mes, ano, mes, nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, 
vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, id_gerente_categoria, desc_secao, desc_comprador_categoria, nrodivisao

drop view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_resumo

create or replace view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_resumo
as
with cte as (
	select unidade, dia_mes, count(distinct seqproduto) as SKU, sum(vlrvenda) as vlrVenda, sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrdesconto) as vlrdesconto, seqcomprador, id_gerente_categoria, desc_secao
	from vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_1 
	group by unidade, dia_mes, seqcomprador, id_gerente_categoria, desc_secao
),

cte_comprador as (
	select unidade, dia_mes, SKU, vlrVenda, vendapromoc, vlrlucratividade, vlrdesconto, seqcomprador, id_gerente_categoria, desc_secao
	from cte
),

cte_union as (
	select unidade, dia_mes, SKU, vlrVenda, vendapromoc, vlrlucratividade, vlrdesconto, seqcomprador, id_gerente_categoria, desc_secao
	from cte_comprador	
)

select unidade, dia_mes, sku,  vlrvenda, vlrdesconto, vendapromoc, vlrlucratividade, vlrlucratividade / vlrvenda as margem,
	100. * vlrvenda / sum(vlrvenda) over (partition by dia_mes, id_gerente_categoria order by dia_mes, id_gerente_categoria) as part, seqcomprador, a.id_gerente_categoria, b.desc_comprador_categoria, desc_secao
from cte_union as a inner join cadastro.d_comprador_categoria as b 
on a.id_gerente_categoria = b.id_comprador_categoria;


select * 
from vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_resumo
where seqcomprador = 14;



--------------------------------------------------------------------------------------------------------------------------------------------------------

/*

	Na tabela ruptura.f_ruptura_produto criada pelo Felipe importar os dados da CONSCINCO e joga nessa tabela. 
	Como somos Goiania, o código abaixo traz só as lojas de Goiania.

*/







alter table vendas.tbl_vendas_prod_mes_filial add nrodivisao smallint;

/*


INSERT INTO vendas.tbl_vendas_prod_mes_divisao_comprador
(dia_mes, ano, mes, nrodivisao, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda)
SELECT dia_mes, ano, mes, b.nrodivisao , seqcomprador, seqproduto, 
SUM(quantidade) as quantidade, SUM(contagemprodutos) as contagemprodutos, SUM(vlrvenda) as vlrvenda, SUM(vlrdesconto) as vlrdesconto, 
SUM(vlroperacao) as vlroperacao, SUM(vlrtotalsemimpostos) as vlrtotalsemimpostos, SUM(vendapromoc) as vendapromoc, 
SUM(vlrlucratividade) as vlrlucratividade, SUM(vlrctobruto) as vlrctobruto, SUM(vlrctoliquido) as vlrctoliquido, SUM(vlrverbavda) as vlrverbavda
FROM vendas.tbl_vendas_prod_mes_filial as a inner join bi.d_empresa as b
on a.nroempresa = b.nroempresa
where Ano=2025 and Mes=4 and quantidade <= 1
group by dia_mes, ano, mes, b.nrodivisao , seqcomprador, seqproduto;

---------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE vendas.tbl_vendas_prod_mes_divisao_comprador (
	dia_mes date NOT NULL,
	ano int2 NULL,
	mes int2 NULL,
	nrodivisao int2 NOT NULL,
	seqcomprador int2 NOT NULL,
	seqproduto int4 NOT NULL,
	quantidade float8 NULL,
	contagemprodutos float8 NULL,
	vlrvenda float8 NULL,
	vlrdesconto float8 NULL,
	vlroperacao float8 NULL,
	vlrtotalsemimpostos float8 NULL,
	vendapromoc float8 NULL,
	vlrlucratividade float8 NULL,
	vlrctobruto float8 NULL,
	vlrctoliquido float8 NULL,
	vlrverbavda float8 NULL,
	CONSTRAINT tbl_vendas_prod_mes_divisao_comprador_pkey PRIMARY KEY (dia_mes, nrodivisao, seqcomprador, seqproduto)
);

drop view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_1;

create or replace view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_1
as
select 1 as unidade, dia_mes, ano, mes, nrodivisao, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria
FROM vendas.tbl_vendas_prod_mes_divisao_comprador as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade <=1 
union all
SELECT 2 as unidade, dia_mes, ano, mes, nrodivisao, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria
FROM vendas.tbl_vendas_prod_mes_divisao_comprador as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 1.0001 and 2 
union all
SELECT 3 as unidade, dia_mes, ano, mes, nrodivisao, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria
FROM vendas.tbl_vendas_prod_mes_divisao_comprador as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 2.0001 and 3 
union all
SELECT 4 as unidade, dia_mes, ano, mes, nrodivisao, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria
FROM vendas.tbl_vendas_prod_mes_divisao_comprador as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 3.0001 and 4 
union all
SELECT 5 as unidade, dia_mes, ano, mes, nrodivisao, a.seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, b.id_gerente_categoria, b.desc_secao, c.desc_comprador_categoria
FROM vendas.tbl_vendas_prod_mes_divisao_comprador as a inner join bi.d_comprador as b
	on a.seqcomprador = b.seqcomprador inner join cadastro.d_comprador_categoria as c
	on b.id_gerente_categoria = c.id_comprador_categoria
where quantidade between 4.0001 and 5 ;

drop view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_resumo

create or replace view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_resumo
as
with cte as (
	select unidade, dia_mes, count(distinct seqproduto) as SKU, sum(vlrvenda) as vlrVenda, sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade, sum(vlrdesconto) as vlrdesconto, seqcomprador, id_gerente_categoria, desc_secao
	from vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_1 
	group by unidade, dia_mes, seqcomprador, id_gerente_categoria, desc_secao
),

cte_comprador as (
	select unidade, dia_mes, SKU, vlrVenda, vendapromoc, vlrlucratividade, vlrdesconto, seqcomprador, id_gerente_categoria, desc_secao
	from cte
),

cte_union as (
	select unidade, dia_mes, SKU, vlrVenda, vendapromoc, vlrlucratividade, vlrdesconto, seqcomprador, id_gerente_categoria, desc_secao
	from cte_comprador	
)

select unidade, dia_mes, sku,  vlrvenda, vlrdesconto, vendapromoc, vlrlucratividade, vlrlucratividade / vlrvenda as margem,
	100. * vlrvenda / sum(vlrvenda) over (partition by dia_mes, id_gerente_categoria order by dia_mes, id_gerente_categoria) as part, seqcomprador, a.id_gerente_categoria, b.desc_comprador_categoria, desc_secao
from cte_union as a inner join cadastro.d_comprador_categoria as b 
on a.id_gerente_categoria = b.id_comprador_categoria;


select * 
from vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_resumo
where seqcomprador = 14;



*/

create or replace view vendas.vw_vendas_prod_mes_divisao_comprador_qtde_menos_SKU
as
select 1 as unidade, dia_mes, ano, mes, seqcomprador,  count(distinct seqproduto) as SKU_Unico
FROM vendas.tbl_vendas_prod_mes_divisao_comprador 
where quantidade <=1  
group by unidade, ano, mes, seqcomprador, dia_mes
union all
select 2 as unidade, dia_mes, ano, mes, seqcomprador,  count(distinct seqproduto) as SKU_Unico
FROM vendas.tbl_vendas_prod_mes_divisao_comprador 
where quantidade between 1.0001 and 2 
group by unidade, ano, mes, seqcomprador, dia_mes
union all
select 3 as unidade, dia_mes, ano, mes, seqcomprador,  count(distinct seqproduto) as SKU_Unico
FROM vendas.tbl_vendas_prod_mes_divisao_comprador 
where quantidade between 2.0001 and 3 
group by unidade, ano, mes, seqcomprador, dia_mes
union all
select 4 as unidade, dia_mes, ano, mes, seqcomprador,  count(distinct seqproduto) as SKU_Unico
FROM vendas.tbl_vendas_prod_mes_divisao_comprador 
where quantidade between 3.0001 and 4
group by unidade, ano, mes, seqcomprador, dia_mes 
union all
select 5 as unidade, dia_mes, ano, mes, seqcomprador,  count(distinct seqproduto) as SKU_Unico
FROM vendas.tbl_vendas_prod_mes_divisao_comprador 
where quantidade between 4.0001 and 5   
group by unidade, ano, mes, seqcomprador, dia_mes


SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM bi.venda_prod_gyn
where dta between '2025-04-01' and '2025-05-30' and seqproduto = '109893' and nroempresa = '9'

