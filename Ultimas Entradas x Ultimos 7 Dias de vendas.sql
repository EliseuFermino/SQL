--
Delete From stage.tbl_produtos_sem_venda_ultimo_7_dias WHERE ultima_entrada = '2025-10-08'

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

	-- Exclui os registros com base no filtro
    DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada = p_data;

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


-------------------------------------------------------------------------------------------------------------------------------------
    ---RAISE NOTICE 'Registros com ultima_entrada = % foram deletados com sucesso.', p_data;
END;
$$;

CALL stage.sp_produtos_sem_venda_ultimo_7_dias('2025-10-08');

select * 
from venda.f_venda_produto as a
where a.dta = 

update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
set venda_1 = b.qtdvendabruto 
from venda.f_venda_produto as b 
where a.ultima_entrada = p_data - 1
a.nroempesa = b.nroempresa
and a.sku_estoque = b.seqproduto


SELECT *
FROM stage.tbl_produtos_sem_venda_ultimo_7_dias WHERE ultima_entrada = '2025-10-08' AND nroempresa = 7 And sku_estoque in ( 76057, 104793, 68444) ;