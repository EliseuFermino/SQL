
SELECT COUNT(*)
FROM bi.venda_prod_gyn;

SELECT COUNT(*)
FROM vendas.tbl_prod_gyn_2025 ;

truncate table vendas.tbl_prod_gyn_2025 ;
insert into vendas.tbl_prod_gyn_2025 
(dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta)
SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM bi.venda_prod_gyn
where dta between '2025-01-01' and '2025-12-31';

truncate table vendas.tbl_prod_gyn_2024 ;
insert into vendas.tbl_prod_gyn_2024 
(dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta)
SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM bi.venda_prod_gyn
where dta between '2024-01-01' and '2024-12-31';

truncate table vendas.tbl_prod_gyn_2023 ;
insert into vendas.tbl_prod_gyn_2023
(dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta)
SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM bi.venda_prod_gyn
where dta between '2023-01-01' and '2023-12-31';

truncate table vendas.tbl_prod_gyn_2022 ;
insert into vendas.tbl_prod_gyn_2022
(dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta)
SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM bi.venda_prod_gyn
where dta between '2022-01-01' and '2022-12-31';

truncate table vendas.tbl_prod_gyn_2021 ;
insert into vendas.tbl_prod_gyn_2021
(dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta)
SELECT dta, nroempresa, empresa, seqcomprador, comprador, seqproduto, descricao, quantidade, contagemprodutos, vlrvenda, vlrdesconto, 
vlroperacao, vlrtotalsemimpostos, vendapromoc, vlrlucratividade, vlrctobruto, vlrctoliquido, vlrverbavda, dta_consulta
FROM bi.venda_prod_gyn
where dta between '2021-01-01' and '2021-12-31';



CREATE TABLE vendas.tbl_prod_gyn_2021 (
	dta date NULL,
	nroempresa varchar(5) NULL,
	empresa varchar(250) NULL,
	seqcomprador varchar(10) NULL,
	comprador varchar(250) NULL,
	seqproduto varchar(15) NULL,
	descricao varchar(250) NULL,
	quantidade float8 NULL,
	contagemprodutos float8 NULL,
	vlrvenda float8 NULL,
	vlrdesconto float8 NULL,
	vlroperacao float8 NULL,
	vlrtotalsemimpostos float8 NULL,
	vendapromoc float8 NULL,
	vlrlucratividade float8 NULL,
	vlrctobruto float8 NULL,
	vlrctoliquido float8 NULL,
	vlrverbavda float8 NULL,
	dta_consulta timestamp NULL
);
CREATE INDEX tbl_prod_gyn_2021_idx ON vendas.tbl_prod_gyn_2021 USING btree (dta, nroempresa, seqcomprador);