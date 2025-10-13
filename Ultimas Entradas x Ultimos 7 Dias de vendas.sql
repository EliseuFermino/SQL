
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
    DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada = p_data;

    RAISE NOTICE 'Registros com ultima_entrada = % foram deletados com sucesso.', p_data;
END;
$$;
