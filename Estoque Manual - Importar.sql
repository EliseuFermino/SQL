
select MES_REFERENCIA, count(*) 
from estoque.f_estoque_stage
group by MES_REFERENCIA;

delete from estoque.f_estoque_stage where mes_referencia is null;

select * from estoque.f_estoque_stage;

truncate table estoque.f_estoque_stage;

select * from estoque.f_estoque where mes_referencia = '2021-04-30';



INSERT INTO estoque.f_estoque
(nrodivisao, nroempresa, seqproduto, estqloja,  medvdiageral, cmultvlrnf,  mes_referencia)
SELECT nrodivisao, nroempresa, seqproduto, quantidade_em_estoque, media_vda_dia, cto_bruto_unitario,  mes_referencia
FROM estoque.f_estoque_stage
where nroempresa > 0  ;



SELECT ano, id_ordem, fn_date_year_current, seqcomprador, nroempresa, faturamento_vlrreal, RENTABILIDADE_VLRREAL, MARGEM_VLRREAL  
FROM prezi.tbl_media

