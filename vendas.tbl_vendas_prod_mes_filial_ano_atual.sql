
Truncate Table vendas.tbl_vendas_prod_mes_filial_ano_atual;

INSERT INTO vendas.tbl_vendas_prod_mes_filial_ano_atual
(dia_mes, ano, mes, nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, nrodivisao)
SELECT dia_mes, ano, mes, nroempresa, seqcomprador, seqproduto, quantidade, contagemprodutos, vlrvenda, vlrdesconto, vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, nrodivisao
FROM vendas.tbl_vendas_prod_mes_filial
WHERE ano = know.fn_date_year_current() 