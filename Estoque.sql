



with cte as (
	SELECT nroempresa, seqproduto, estqloja, estqtroca, dta_posicao
	FROM bi.f_estoque
	WHERE dta_posicao = (date_trunc('month'::text, dta_posicao) + '1 mon'::interval - '1 day'::interval)
	 and nrodivisao = '2' and estqloja <> 0
),

cte1 as (
	select know.fn_date_year(dta_posicao) as ano, know.fn_date_month(dta_posicao) as mes, seqproduto, sum(estqloja) as estqloja, sum(estqtroca) as estqtroca
	from cte
	group by know.fn_date_year(dta_posicao) , know.fn_date_month(dta_posicao), seqproduto
)

update vendas.tbl_produto_estatistica a
set qtde_estoque = b.estqloja
from cte1 b
where a.ano = b.ano 
and a.mes = b.mes 
and a.seqproduto = b.seqproduto::integer;



-- vendas.vw_produto_estatistica source






