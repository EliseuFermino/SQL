-- ANO 2025 -----------------------------

truncate table vendas.tbl_vendas_prod_mes_filial;
 
with cte as (

	SELECT know.fn_date_bomonth(know.fn_date_year(dta), know.fn_date_month(dta)) as dia_mes, know.fn_date_year(dta) as ano, know.fn_date_month(dta) as mes,

	a.nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade,

	vlrctobruto, vlrctoliquido, vlrverbavda, b.nrodivisao

	FROM vendas.tbl_prod_gyn_2025 as a inner join bi.vw_d_empresa as b

	on a.nroempresa::integer = b.nroempresa

)

INSERT INTO vendas.tbl_vendas_prod_mes_filial

	  (dia_mes, ano, mes, nroempresa, seqcomprador,  seqproduto,  quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, nrodivisao)

select dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer,

sum(quantidade) as quantidade, sum(contagemprodutos) as contagemprodutos, sum(vlrvenda) as vlrvenda,

sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos,

sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade,

avg(vlrctobruto) as vlrctobruto, avg(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda, nrodivisao

from cte

group by dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer, nrodivisao;
 
--ANO 2024---
 
with cte as (

	SELECT know.fn_date_bomonth(know.fn_date_year(dta), know.fn_date_month(dta)) as dia_mes, know.fn_date_year(dta) as ano, know.fn_date_month(dta) as mes,

	a.nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade,

	vlrctobruto, vlrctoliquido, vlrverbavda, b.nrodivisao

	FROM vendas.tbl_prod_gyn_2024 as a inner join bi.vw_d_empresa as b

	on a.nroempresa::integer = b.nroempresa

)

INSERT INTO vendas.tbl_vendas_prod_mes_filial

	  (dia_mes, ano, mes, nroempresa, seqcomprador,  seqproduto,  quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, nrodivisao)

select dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer,

sum(quantidade) as quantidade, sum(contagemprodutos) as contagemprodutos, sum(vlrvenda) as vlrvenda,

sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos,

sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade,

avg(vlrctobruto) as vlrctobruto, avg(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda, nrodivisao

from cte

group by dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer, nrodivisao;
 
 
--ANO 2023---
 
with cte as (

	SELECT know.fn_date_bomonth(know.fn_date_year(dta), know.fn_date_month(dta)) as dia_mes, know.fn_date_year(dta) as ano, know.fn_date_month(dta) as mes,

	a.nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade,

	vlrctobruto, vlrctoliquido, vlrverbavda, b.nrodivisao

	FROM vendas.tbl_prod_gyn_2023 as a inner join bi.vw_d_empresa as b

	on a.nroempresa::integer = b.nroempresa

)

INSERT INTO vendas.tbl_vendas_prod_mes_filial

	  (dia_mes, ano, mes, nroempresa, seqcomprador,  seqproduto,  quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, nrodivisao)

select dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer,

sum(quantidade) as quantidade, sum(contagemprodutos) as contagemprodutos, sum(vlrvenda) as vlrvenda,

sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos,

sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade,

avg(vlrctobruto) as vlrctobruto, avg(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda, nrodivisao

from cte

group by dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer, nrodivisao;
 
 
--ANO 2022---
 
with cte as (

	SELECT know.fn_date_bomonth(know.fn_date_year(dta), know.fn_date_month(dta)) as dia_mes, know.fn_date_year(dta) as ano, know.fn_date_month(dta) as mes,

	a.nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade,

	vlrctobruto, vlrctoliquido, vlrverbavda, b.nrodivisao

	FROM vendas.tbl_prod_gyn_2022 as a inner join bi.vw_d_empresa as b

	on a.nroempresa::integer = b.nroempresa

)

INSERT INTO vendas.tbl_vendas_prod_mes_filial

	  (dia_mes, ano, mes, nroempresa, seqcomprador,  seqproduto,  quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, nrodivisao)

select dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer,

sum(quantidade) as quantidade, sum(contagemprodutos) as contagemprodutos, sum(vlrvenda) as vlrvenda,

sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos,

sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade,

avg(vlrctobruto) as vlrctobruto, avg(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda, nrodivisao

from cte

group by dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer, nrodivisao;
 
 
--ANO 2021---
 
with cte as (

	SELECT know.fn_date_bomonth(know.fn_date_year(dta), know.fn_date_month(dta)) as dia_mes, know.fn_date_year(dta) as ano, know.fn_date_month(dta) as mes,

	a.nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade,

	vlrctobruto, vlrctoliquido, vlrverbavda, b.nrodivisao

	FROM vendas.tbl_prod_gyn_2021 as a inner join bi.vw_d_empresa as b

	on a.nroempresa::integer = b.nroempresa

)

INSERT INTO vendas.tbl_vendas_prod_mes_filial

	  (dia_mes, ano, mes, nroempresa, seqcomprador,  seqproduto,  quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, nrodivisao)

select dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer,

sum(quantidade) as quantidade, sum(contagemprodutos) as contagemprodutos, sum(vlrvenda) as vlrvenda,

sum(vlrdesconto) as vlrdesconto, sum(vlroperacao) as vlroperacao, sum(vlrtotalsemimpostos) as vlrtotalsemimpostos,

sum(vendapromoc) as vendapromoc, sum(vlrlucratividade) as vlrlucratividade,

avg(vlrctobruto) as vlrctobruto, avg(vlrctoliquido) as vlrctoliquido, sum(vlrverbavda) as vlrverbavda, nrodivisao

from cte

group by dia_mes, ano, mes, nroempresa::int2, seqcomprador::int2, seqproduto::integer, nrodivisao;
 
 
 