
truncate table stage.tblruptura_analitica;

INSERT INTO bi.f_ruptura_analitica
(dta, nroempresa, nomereduzido, seqcomprador, apelido, seqfornecedor, fornecedor, seqproduto, desccompleta, embalagem,  venda_perdida_qtd, vlrvendaperdida, vlrlucro)
select '2025-05-01' as dta, a.nroempresa, c.nomereduzido, b.seqcomprador, d.apelido, b.seqfornecedor::int, b.nomerazao as fornecedor, a.seqproduto, b.desccompleta, 
	a.embalagem, a.qtde_perdida, a.venda_perdida, a.lucro_perdido
FROM stage.tblruptura_analitica a inner join cadastro.vw_produto_com_fornecedor b
on a.seqproduto = b.seqproduto inner join bi.d_empresa c 
on a.nroempresa = c.nroempresa inner join bi.d_comprador d
on b.seqcomprador = cast(d.seqcomprador as varchar);

-- delete from bi.f_ruptura_analitica where dta = '2025-03-20';