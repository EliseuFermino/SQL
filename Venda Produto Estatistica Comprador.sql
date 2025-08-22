/*

-- DROP TABLE vendas.tbl_produto_estatistica_comprador;

CREATE TABLE vendas.tbl_produto_estatistica_comprador (
	dia date NOT NULL,
	ano int2 NULL,
	mes int2 NULL,
	ano_mes varchar(7) NULL,
	seqcomprador int2 NOT NULL,
	seqproduto int4 NOT NULL,
	descproduto varchar(100) NULL,
	quantidade float8 NULL,
	vlrvenda float8 NULL,
	vlrlucratividade float8 NULL,
	rnk int2 NULL,
	venda_total float8 NULL,
	venda_acumulada float8 NULL,
	total_sku int2 NULL,
	percmargem float8 NULL,
	perc_part float8 NULL,
	lucratividade_total float8 NULL,
	lucratividade_acumulada float8 NULL,
	rn int2 NULL,
	perda_informada numeric NULL,
	qtde_estoque numeric NULL,
	vlrvendapromoc numeric NULL,
	CONSTRAINT tbl_produto_estatistica_comprador_pkey PRIMARY KEY (dia, seqcomprador, seqproduto)
);
 
*/
-- where dta between '2025-03-01' and '2025-03-31' and a.seqcomprador <> '41'
truncate table vendas.tbl_produto_estatistica_comprador;
 
-- POR SECAO
with cte0 as (
SELECT b.ano, b.mes, b.ano_mes, seqcomprador, seqproduto, sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrlucratividade) as vlrlucratividade, sum(vendapromoc) as vendapromoc
FROM vendas.tbl_prod_gyn_2025 as a inner join bi.vw_d_calendario as b
on a.dta = b.dia
where a.seqcomprador <> '41'
group by b.ano, b.mes, b.ano_mes, seqcomprador, seqproduto
),
 
cte as (
    select ano, mes, ano_mes, seqcomprador , seqproduto, sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrlucratividade) as vlrlucratividade, sum(vendapromoc) as vlrvendapromoc
    from cte0 as a 
    group by  ano, mes, ano_mes, seqcomprador , seqproduto
),
 
cte1 as (
select ano, mes, ano_mes, seqcomprador, seqproduto, quantidade, vlrvenda,vlrlucratividade,
    row_number() over(partition by seqcomprador, ano_mes order by seqcomprador, ano_mes, vlrvenda desc) as rnk,
    case when vlrvenda = 0 then 0
         when vlrlucratividade = 0 then 0
         else (vlrlucratividade / vlrvenda )
    end as percMargem,
    vlrvendapromoc
from cte
),
 
cte2 as (
select ano, mes, ano_mes, seqcomprador, seqproduto, quantidade, vlrvenda,vlrlucratividade, rnk,
    case when rnk <= 10 then 10
         when rnk <= 20 then 20
         when rnk <= 30 then 30
         when rnk <= 40 then 40
         when rnk <= 50 then 50
         when rnk <= 60 then 60
         when rnk <= 70 then 70
         when rnk <= 80 then 80
         when rnk <= 90 then 90
         when rnk <= 100 then 100  
         else 999
    end as rn,
    percMargem,
    vlrvendapromoc
from cte1
),
 
cte3 as (
select ano, mes, ano_mes, seqcomprador, seqproduto, quantidade, vlrvenda,vlrlucratividade,
    rnk, rn,    
    sum(vlrvenda) over(partition by seqcomprador, ano_mes) as venda_total,
    sum(vlrvenda) over (partition by seqcomprador, ano_mes, rn order by seqcomprador, ano_mes, vlrvenda desc ) AS venda_acumulada,
    sum(vlrlucratividade) over(partition by seqcomprador, ano_mes) as lucratividade_total,
    sum(vlrlucratividade) over (partition by seqcomprador, ano_mes, rn order by seqcomprador, ano_mes, vlrvenda desc) AS lucratividade_acumulada,
    count(seqproduto) over(partition by seqcomprador, ano_mes) as total_sku,
    case when vlrvenda = 0 then 0
         when vlrlucratividade = 0 then 0
         else (vlrlucratividade / vlrvenda )
    end as percMargem,
    vlrvendapromoc
from cte2
)
 
INSERT INTO vendas.tbl_produto_estatistica_comprador
(dia, ano, mes, ano_mes, seqcomprador, seqproduto, descproduto, quantidade, vlrvenda, vlrlucratividade, rnk, venda_total, venda_acumulada, total_sku, percmargem, perc_part, lucratividade_total, lucratividade_acumulada,rn,vlrvendapromoc)
select TO_DATE(ano || '-' || mes || '-01', 'YYYY-MM-DD') as dia,  ano, mes, ano_mes,
a.seqcomprador::smallint, a.seqproduto::int, b.desccompleta, quantidade, vlrvenda ,vlrlucratividade,
rnk, venda_total, venda_acumulada, total_sku, percMargem,
    (venda_acumulada / venda_total)  as perc_part,
  lucratividade_total, lucratividade_acumulada, rn, vlrvendapromoc
from cte3 as a inner join bi.d_produto as b
on a.seqproduto = b.seqproduto
where b.nrodivisao = '2'
;
 
with perdas_comprador as (
    SELECT dta, seqcomprador, seqproduto, sum(vlrctobruto) as vlrctobruto, sum(vlrtotalperdapv) as vlrtotalperdapv
    FROM bi.f_perdas_quebras
    where tipo_perda = 'INFORMADA'
    group by dta, seqproduto, seqcomprador
),
 
perdas_empresa as (
    SELECT dta, 0 as seqcomprador, seqproduto, sum(vlrctobruto) as vlrctobruto, sum(vlrtotalperdapv) as vlrtotalperdapv
    FROM bi.f_perdas_quebras
    where tipo_perda = 'INFORMADA'
    group by dta, seqproduto
),
 
perdas as (
    select dta, seqcomprador::int2, seqproduto, vlrctobruto, vlrtotalperdapv from perdas_comprador union all
    select dta, seqcomprador::int2, seqproduto, vlrctobruto, vlrtotalperdapv from perdas_empresa
)
 
update vendas.tbl_produto_estatistica_comprador as a  
set perda_informada = b.vlrtotalperdapv
from perdas as b
where a.dia = b.dta
  and a.seqproduto::varchar = b.seqproduto::varchar
;
 
 
-- POR EMPRESA
with cte as (
SELECT dia, ano, mes, ano_mes, 0 as seqcomprador, seqproduto, sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrlucratividade) as vlrlucratividade, sum(vlrvendapromoc) as vlrvendapromoc
FROM vendas.tbl_produto_estatistica_comprador
group by dia, ano, mes, ano_mes, seqproduto
),
 
cte1 as (
select dia, ano, mes, ano_mes, seqcomprador, seqproduto, quantidade, vlrvenda,vlrlucratividade,
    row_number() over(partition by ano_mes order by  ano_mes, vlrvenda desc) as rnk,    
    case when vlrvenda = 0 then 0
         when vlrlucratividade = 0 then 0
         else (vlrlucratividade / vlrvenda )
    end as percMargem,
    vlrvendapromoc
from cte
),
 
cte2 as (
select dia, ano, mes, ano_mes, seqproduto, quantidade, vlrvenda,vlrlucratividade, rnk , seqcomprador,
    case when rnk <= 10 then 10
         when rnk <= 20 then 20
         when rnk <= 30 then 30
         when rnk <= 40 then 40
         when rnk <= 50 then 50
         when rnk <= 60 then 60
         when rnk <= 70 then 70
         when rnk <= 80 then 80
         when rnk <= 90 then 90
         when rnk <= 100 then 100  
         else 999
    end as rn,
    percMargem,
    vlrvendapromoc
from cte1
),
 
cte3 as (
select dia, ano, mes, ano_mes, seqcomprador, seqproduto, quantidade, vlrvenda,vlrlucratividade,
    rnk, rn,    
    sum(vlrvenda) over(partition by  ano_mes) as venda_total,
    sum(vlrvenda) over (partition by  ano_mes, rn order by seqcomprador, ano_mes, vlrvenda desc ) AS venda_acumulada,
    sum(vlrlucratividade) over(partition by  ano_mes) as lucratividade_total,
    sum(vlrlucratividade) over (partition by  ano_mes, rn order by seqcomprador, ano_mes, vlrvenda desc) AS lucratividade_acumulada,
    count(seqproduto) over(partition by  ano_mes) as total_sku,
    case when vlrvenda = 0 then 0
         when vlrlucratividade = 0 then 0
         else (vlrlucratividade / vlrvenda )
    end as percMargem,
    vlrvendapromoc
from cte2
)
 
INSERT INTO vendas.tbl_produto_estatistica_comprador
(dia, ano, mes, ano_mes, seqcomprador, seqproduto, descproduto, quantidade, vlrvenda, vlrlucratividade, rnk, venda_total, venda_acumulada, total_sku, percmargem, perc_part, lucratividade_total, lucratividade_acumulada,rn, vlrvendapromoc)
select dia,  ano, mes, ano_mes,
a.seqcomprador::smallint, a.seqproduto::int, b.desccompleta, quantidade, vlrvenda ,vlrlucratividade,
rnk, venda_total, venda_acumulada, total_sku, percMargem,
    (venda_acumulada / venda_total)  as perc_part,
  lucratividade_total, lucratividade_acumulada, rn, vlrvendapromoc
from cte3 as a inner join bi.d_produto as b
on a.seqproduto = b.seqproduto::int
where b.nrodivisao = '2'
;
 
 


-- vendas.vw_estatistica_top_empresa source

CREATE OR REPLACE VIEW vendas.vw_estatistica_top_empresa_comprador
AS SELECT a.dia,
    a.ano,
    a.mes,
    a.ano_mes,
    a.seqcomprador,
    a.quantidade,
    a.vlrvenda,
    a.vlrlucratividade,
    a.rnk,
    a.venda_total,
    a.venda_acumulada,
    a.total_sku,
    a.percmargem,
    a.perc_part,
    a.lucratividade_total,
    a.lucratividade_acumulada,
    a.lucratividade_acumulada / a.venda_acumulada AS perc_margem_acumulada
   FROM vendas.tbl_produto_estatistica_comprador as a
  WHERE (a.rnk = ANY (ARRAY[10, 20, 30, 40, 50, 60, 70, 80, 90, 100])) AND a.seqcomprador = 0
  ORDER BY a.rnk;