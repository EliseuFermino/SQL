
WITH cte As (
	SELECT dta, seqproduto, sum(vlrvenda) as vlrvenda, sum(QUANTIDADE) as qtdade
	FROM vendas.tbl_prod_gyn_2025 
	WHERE dta between '2025-05-01' and '2025-08-06' 
	GROUP BY dta, seqproduto
)


INSERT INTO vendas.stage_prod_a
(dta, seqproduto, vlrvenda, qtdade)
SELECT dta, seqproduto, vlrvenda, qtdade 
into vendas.stage_prod_A
FROM cte as a 
WHERE seqproduto::integer IN (SELECT seqproduto
					 FROM vendas.vw_produto_estatistica
					 WHERE ID_GERENTE_CATEGORIA = 0 AND CLASSIFICACAO_ABC = 'A' AND dia between '2025-05-01' and '2025-08-01'
					 group by seqproduto
					)
;

with cte_seqproduto as (
	SELECT seqproduto
	FROM vendas.stage_prod_a
	group by seqproduto
),

cte_calendario as (
	SELECT dia
	FROM bi.vw_d_calendario
	WHERE dia between '2025-05-01' and '2025-08-06'
),

cte_parametro as (
	select dia,  seqproduto
	from cte_calendario as a CROSS JOIN cte_seqproduto as b
),

cte_final as (
SELECT a.dia, a.seqproduto as produto, b.dta, b.seqproduto as seqproduto_venda 
FROM cte_parametro as a left join vendas.stage_prod_a as b
ON a.dia = b.dta 
AND a.seqproduto = b.SEQPRODUTO 
)

select dia, count(produto) as num_produto
FROM cte_final
WHERE dia between '2025-08-01' and '2025-08-06' and seqproduto_venda is NULL 
GROUP BY  dia;
