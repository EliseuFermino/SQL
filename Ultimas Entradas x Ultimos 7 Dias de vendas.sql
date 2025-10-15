--
Delete From stage.tbl_produtos_sem_venda_ultimo_7_dias WHERE ultima_entrada = '2025-10-08';

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

-- Exclui os registros com base no filtro ------------------------------------------------------------------------------

	-- SEMPRE A ANALISE SERA DOS ULTIMOS 7 DIAS. EXCLUIR O QUE FOR MAIOR QUE 7 DIAS
	DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada < p_data - 6;

	-- SEMPRE A ANALISE SERA DOS ULTIMOS 7 DIAS. EXCLUIR O QUE FOR MAIOR QUE ONTEM
	DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada > p_data;

	-- EXCLUI SE JA TIVER SIDo PROCESSADO
    DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
    WHERE ultima_entrada = p_data;

-- INSERE AS NF DE ENTRADA ---------------------------------------------------------------------------------------------
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

	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data);

	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 1);
    CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 2);
	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 3);
	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 4);
    CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 5);
	CALL stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data - 6);	
	
	
-------------------------------------------------------------------------------------------------------------------------------------
    ---RAISE NOTICE 'Registros com ultima_entrada = % foram deletados com sucesso.', p_data;
END;
$$;

CALL stage.sp_produtos_sem_venda_ultimo_7_dias('2025-10-13');

CREATE OR REPLACE PROCEDURE stage.sp_produtos_sem_venda_ultimo_7_dias_atualiza_vendas(p_data DATE)
LANGUAGE plpgsql
AS $$
BEGIN

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_1 = null,
		venda_2 = null,
		venda_3 = null,
		venda_4 = null,
		venda_5 = null,
		venda_6 = null,
		venda_7 = null,
		status_1 = null,
		status_2 = null,
		status_3 = null,
		status_4 = null,
		status_5 = null,
		status_6 = null,
		status_7 = null
	where a.ultima_entrada = p_data;

-- ATUALIZA QUANTIDADE DE VENDAS----------------------------------------------------------------------------------------
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  	WHERE a.dta = current_date - 1
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_1 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 2
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_2 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;

	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 3
	)
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_3 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;

	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 4
	)
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_4 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 5
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_5 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 6
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_6 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;
	
	with cte_venda as (
		SELECT a.nroempresa, a.seqproduto, a.qtdvenda
	  	FROM venda.f_venda_produto AS a
	  WHERE a.dta = current_date - 7
	)

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set venda_7 = b.qtdvenda 
	from cte_venda as b 
	where a.ultima_entrada = p_data
	and a.nroempresa = b.nroempresa
	and a.sku_estoque = b.seqproduto;

-- SOMA A QUANTIDADE VENDIDA NOS 7 DIAS --------------------------------------------------------------
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set qtde_vendida_total = coalesce(venda_1,0) + coalesce(venda_2,0) + coalesce(venda_3,0) + coalesce(venda_4,0) + coalesce(venda_5,0) + coalesce(venda_6,0) + coalesce(venda_7,0) 	
	where a.ultima_entrada = p_data;
	

---- STATUS DE VENDAS - SE TEM VENDA INSERE 1 ---------------------------------------------------------------------------------------

	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_1 = case when a.venda_1 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_2 = case when a.venda_2 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_3 = case when a.venda_3 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_4 = case when a.venda_4 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_5 = case when a.venda_5 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_6 = case when a.venda_6 is null then 1 end 
	where a.ultima_entrada = p_data ;
	
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_7 = case when a.venda_7 is null then 1 end 
	where a.ultima_entrada = p_data ;

-- VERIFICA OS DIAS DE VENDAS ------------------------------------------------------------------------------------------------------
	update stage.tbl_produtos_sem_venda_ultimo_7_dias as a 
	set status_count = Case When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
							 and a.status_4 = 1  
							 and a.status_5 = 1
							 and a.status_6 = 1
                             and a.status_7 = 1 then 7
							When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
							 and a.status_4 = 1  
							 and a.status_5 = 1
                             and a.status_6 = 1 then 6
							When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
							 and a.status_4 = 1  
                             and a.status_5 = 1 then 5
							When a.status_1 = 1 
                             and a.status_2 = 1 
							 and a.status_3 = 1 
                             and a.status_4 = 1 then 4
							When a.status_1 = 1 
                             and a.status_2 = 1 
                             and a.status_3 = 1 then 3
							When a.status_1 = 1 
                             and a.status_2 = 1 then 2
							When a.status_1 = 1 then 1
						End					   
	where a.ultima_entrada = p_data ;

-- DELETA AS COMPRAS QUANDO O VALOR DA QUANTIDADE TOTAL FOR IGUAL OU MAIOR DA Ultima_Entrada
DELETE FROM stage.tbl_produtos_sem_venda_ultimo_7_dias
WHERE qtde_vendida_total >=  qtde_entrada;

END;
$$;





SELECT *
FROM stage.tbl_produtos_sem_venda_ultimo_7_dias WHERE ultima_entrada = '2025-10-08' AND nroempresa = 7 And sku_estoque in ( 76057, 104793, 68444) ;

SELECT nrodivisao, nroempresa, dta, seqproduto, qtdembalagem, statuscompra, statusvenda, qtdvenda, vlrvendabruto, vlrpromoc, vlrlucratividade, vlrverbavda, dta_atualizacao
FROM venda.f_venda_produto
WHERE dta in ('2025-10-11','2025-10-12')  and seqproduto = 92684 and nroempresa = 6;


SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
INTO vendas.vi
FROM vendas.tbl_prod_gyn_2025
Where dta = '2025-10-13';