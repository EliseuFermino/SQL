-- where dta between '2025-03-01' and '2025-03-31' and a.seqcomprador <> '41'

truncate table vendas.tbl_produto_estatistica;

-- POR SECAO
with cte0 as (
SELECT b.ano, b.mes, b.ano_mes, seqcomprador, seqproduto, sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrlucratividade) as vlrlucratividade
FROM bi.venda_prod_gyn as a inner join bi.vw_d_calendario as b
on a.dta = b.dia
where dta >= '2025_01-01' and a.seqcomprador <> '41' 
group by b.ano, b.mes, b.ano_mes, seqcomprador, seqproduto
),

cte as (
	select ano, mes, ano_mes, b.id_gerente_categoria , seqproduto, sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrlucratividade) as vlrlucratividade
	from cte0 as a inner join bi.vw_d_comprador as b
	on a.seqcomprador = b.seqcomprador::varchar
	group by  ano, mes, ano_mes, id_gerente_categoria , seqproduto
),

cte1 as (
select ano, mes, ano_mes, id_gerente_categoria, seqproduto, quantidade, vlrvenda,vlrlucratividade, 
	row_number() over(partition by id_gerente_categoria, ano_mes order by id_gerente_categoria, ano_mes, vlrvenda desc) as rnk,	
	case when vlrvenda = 0 then 0 
	     when vlrlucratividade = 0 then 0 
	     else (vlrlucratividade / vlrvenda ) 
	end as percMargem
from cte
),

cte2 as (
select ano, mes, ano_mes, id_gerente_categoria, seqproduto, quantidade, vlrvenda,vlrlucratividade, rnk,
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
	percMargem
from cte1
),

cte3 as (
select ano, mes, ano_mes, id_gerente_categoria, seqproduto, quantidade, vlrvenda,vlrlucratividade, 
	rnk, rn,	
	sum(vlrvenda) over(partition by id_gerente_categoria, ano_mes) as venda_total,
	sum(vlrvenda) over (partition by id_gerente_categoria, ano_mes, rn order by id_gerente_categoria, ano_mes, vlrvenda desc ) AS venda_acumulada,
	sum(vlrlucratividade) over(partition by id_gerente_categoria, ano_mes) as lucratividade_total,
	sum(vlrlucratividade) over (partition by id_gerente_categoria, ano_mes, rn order by id_gerente_categoria, ano_mes, vlrvenda desc) AS lucratividade_acumulada,
	count(seqproduto) over(partition by id_gerente_categoria, ano_mes) as total_sku,
	case when vlrvenda = 0 then 0 
	     when vlrlucratividade = 0 then 0 
	     else (vlrlucratividade / vlrvenda ) 
	end as percMargem
from cte2
)

INSERT INTO vendas.tbl_produto_estatistica
(dia, ano, mes, ano_mes, id_gerente_categoria, seqproduto, descproduto, quantidade, vlrvenda, vlrlucratividade, rnk, venda_total, venda_acumulada, total_sku, percmargem, perc_part, lucratividade_total, lucratividade_acumulada,rn)
select TO_DATE(ano || '-' || mes || '-01', 'YYYY-MM-DD') as dia,  ano, mes, ano_mes, 
a.id_gerente_categoria::smallint, a.seqproduto::int, b.desccompleta, quantidade, vlrvenda ,vlrlucratividade, 
rnk, venda_total, venda_acumulada, total_sku, percMargem,
	(venda_acumulada / venda_total)  as perc_part,
  lucratividade_total, lucratividade_acumulada, rn
from cte3 as a inner join bi.d_produto as b 
on a.seqproduto = b.seqproduto
where b.nrodivisao = '2'
;

-- ATUALIZA A PERDA INFORMADA
with perdas_comprador as (


)

update vendas.tbl_produto_estatistica as a	
set a.perda_informada = b.vlrtotalperdapv
from perdas_comprador as b


perdas_empresa as (
	SELECT dta, 0 as seqcomprador, seqproduto, sum(vlrctobruto) as vlrctobruto, sum(vlrtotalperdapv) as vlrtotalperdapv
	FROM bi.f_perdas_quebras
	where tipo_perda = 'INFORMADA'
	group by dta, seqproduto
)



-- POR EMPRESA
with cte as (
SELECT dia, ano, mes, ano_mes, 0 as id_gerente_categoria, seqproduto, sum(quantidade) as quantidade, sum(vlrvenda) as vlrvenda, sum(vlrlucratividade) as vlrlucratividade
FROM vendas.tbl_produto_estatistica
group by dia, ano, mes, ano_mes, seqproduto
),

cte1 as (
select dia, ano, mes, ano_mes, id_gerente_categoria, seqproduto, quantidade, vlrvenda,vlrlucratividade, 
	row_number() over(partition by ano_mes order by  ano_mes, vlrvenda desc) as rnk,	
	case when vlrvenda = 0 then 0 
	     when vlrlucratividade = 0 then 0 
	     else (vlrlucratividade / vlrvenda ) 
	end as percMargem
from cte
),

cte2 as (
select dia, ano, mes, ano_mes, seqproduto, quantidade, vlrvenda,vlrlucratividade, rnk , id_gerente_categoria,
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
	percMargem
from cte1
),

cte3 as (
select dia, ano, mes, ano_mes, id_gerente_categoria, seqproduto, quantidade, vlrvenda,vlrlucratividade, 
	rnk, rn,	
	sum(vlrvenda) over(partition by  ano_mes) as venda_total,
	sum(vlrvenda) over (partition by  ano_mes, rn order by id_gerente_categoria, ano_mes, vlrvenda desc ) AS venda_acumulada,
	sum(vlrlucratividade) over(partition by  ano_mes) as lucratividade_total,
	sum(vlrlucratividade) over (partition by  ano_mes, rn order by id_gerente_categoria, ano_mes, vlrvenda desc) AS lucratividade_acumulada,
	count(seqproduto) over(partition by  ano_mes) as total_sku,
	case when vlrvenda = 0 then 0 
	     when vlrlucratividade = 0 then 0 
	     else (vlrlucratividade / vlrvenda ) 
	end as percMargem
from cte2
)

INSERT INTO vendas.tbl_produto_estatistica
(dia, ano, mes, ano_mes, id_gerente_categoria, seqproduto, descproduto, quantidade, vlrvenda, vlrlucratividade, rnk, venda_total, venda_acumulada, total_sku, percmargem, perc_part, lucratividade_total, lucratividade_acumulada,rn)
select dia,  ano, mes, ano_mes, 
a.id_gerente_categoria::smallint, a.seqproduto::int, b.desccompleta, quantidade, vlrvenda ,vlrlucratividade, 
rnk, venda_total, venda_acumulada, total_sku, percMargem,
	(venda_acumulada / venda_total)  as perc_part,
  lucratividade_total, lucratividade_acumulada, rn
from cte3 as a inner join bi.d_produto as b 
on a.seqproduto = b.seqproduto::int
where b.nrodivisao = '2' 
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- vendas.vw_produto_estatistica source

CREATE OR REPLACE VIEW vendas.vw_produto_estatistica
AS SELECT a.dia,
    a.ano,
    a.mes,
    a.ano_mes,
    a.id_gerente_categoria,
    a.seqproduto,
    a.descproduto,
    a.quantidade,
    a.vlrvenda,
    (SUM(a.vlrvenda) * 2) over (partition by ano_mes, id_gerente_categoria order by ano_mes, id_gerente_categoria) AS perc_part_venda,
    a.vlrlucratividade,
    a.rnk,
    a.venda_total,
    a.venda_acumulada,
    a.total_sku,
    a.percmargem,
    a.perc_part,
    a.lucratividade_total,
    a.lucratividade_acumulada,
    a.rn,
    a.perda_informada,
    a.qtde_estoque
   FROM vendas.tbl_produto_estatistica a;




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT dia, ano, mes, ano_mes, id_gerente_categoria, seqproduto, descproduto, quantidade, vlrvenda, perc_part_venda, vlrlucratividade, rnk, venda_total, venda_acumulada, total_sku, percmargem, perc_part, lucratividade_total, lucratividade_acumulada, rn, perda_informada, qtde_estoque
FROM vendas.vw_produto_estatistica
where ano_mes = '2025_4' and id_gerente_categoria = 0
order by rnk;