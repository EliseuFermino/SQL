
/*
 
  TABELAS:
  
   bi.venda_comprador_total_mes 
 
*/

--- Step 1
truncate table bi.venda_comprador_total_mes;
 
---- Step 2
-- INSERIR VENDA E A LUCRATIVIDADE TOTAL DAS LOJAS POR SEÇÃO -------------------------------------------------------------------------------------
INSERT INTO bi.venda_comprador_total_mes
(dia, nroempresa, seqcomprador, venda_vlr_real, lucratividade_vlrreal, ano, mes, qtde_venda_real, perc_margem_real)
select cast(ano || '-' || mes || '-01' as date) as dia, cast(codempresa as smallint) , cast(cod_secao as smallint), venda_vlr_real,
	lucratividade_vlrreal, ano, mes, qtde_venda_real, lucratividade_vlrreal / venda_vlr_real * 100 as perc_margem_real
FROM bi.venda_vw_comprador_empresa_mes_prezi
;
 
-- Atualiza a QUEBRA INFORMADA pelo Custo Bruto. -------------------------------------------------------------------------------------------------------------
with cte as (
	select b.ano, b.mes, nroempresa, seqcomprador, sum(vlrctobruto) as vlrctobruto, sum(vlrtotalperdapv) as vlrtotalperdapv
	from bi.f_perdas_quebras as a inner join bi.vw_d_calendario as b
	on a.dta = b.dia
	where tipo_perda = 'INFORMADA'
	group by b.ano, b.mes, nroempresa, seqcomprador
),
 
cte1 as (
	select know.fn_date_bomonth(ano::int, mes::int) as dia_inicial, ano, mes, nroempresa, seqcomprador, vlrctobruto, vlrtotalperdapv
	from cte
)
 
update bi.venda_comprador_total_mes as a	
set vlr_perda_inf_cb = b.vlrctobruto,
    vlr_perda_inf_pv = b.vlrtotalperdapv
from cte1 as b
where a.dia = b.dia_inicial
  and a.nroempresa = b.nroempresa::int2
  and a.seqcomprador::int2 = b.seqcomprador::int2;
 
-- Calcula a Lucratividade Ajustada. A partir de Abril/2025 a Lucratividade e Margem ajustada usam a Perda Informada a Preço de Venda.
update bi.venda_comprador_total_mes as a	
set vlr_lucratividade_ajustada = case when dia >= '2025-04-01' then lucratividade_vlrreal - coalesce(vlr_perda_inf_pv,0)  
									  else lucratividade_vlrreal - coalesce(vlr_perda_inf_cb,0)
							     end;
 
-- Calcula a perc Margem Ajustada.
update bi.venda_comprador_total_mes as a	
set perc_margem_ajustada = vlr_lucratividade_ajustada / venda_vlr_real * 100;
 
-- ATUALIZA ID DO NOME DO COMPRADOR DA PASTA
update bi.venda_comprador_total_mes as a
set id_gerente_categoria = b.id_gerente_categoria
from bi.vw_d_comprador as b
where a.seqcomprador = b.seqcomprador::int2;
 
---- Step 3
-- INSERIR VENDA E A LUCRATIVIDADE TOTAL DAS LOJAS POR TOTAL
INSERT INTO bi.venda_comprador_total_mes
(dia, nroempresa, seqcomprador, venda_vlr_real, lucratividade_vlrreal, ano, mes, qtde_venda_real, perc_margem_real, vlr_perda_inf_cb, vlr_lucratividade_ajustada, id_gerente_categoria)
select dia, nroempresa, 0 as cod_secao, SUM(venda_vlr_real) as venda_vlr_real,
	SUM(lucratividade_vlrreal) as lucratividade_vlrreal, ano, mes,
	sum(qtde_venda_real),
	SUM(lucratividade_vlrreal) / SUM(venda_vlr_real) * 100 as perc_margem_real,
	sum(vlr_perda_inf_cb),
	sum(vlr_lucratividade_ajustada),
	id_gerente_categoria
FROM bi.venda_comprador_total_mes
group by ano, mes, dia, nroempresa, id_gerente_categoria;
 
 
-- Calcula a perc Margem Ajustada.
update bi.venda_comprador_total_mes as a	
set perc_margem_ajustada = vlr_lucratividade_ajustada / venda_vlr_real * 100;
 
--- step 4
-- INSERIR VENDA E A LUCRATIVIDADE TOTAL DA EMPRESA
INSERT INTO bi.venda_comprador_total_mes
(dia, nroempresa, seqcomprador, venda_vlr_real, lucratividade_vlrreal, ano, mes, qtde_venda_real, perc_margem_real,  vlr_perda_inf_cb, vlr_lucratividade_ajustada, id_gerente_categoria)
select dia, 992 as nroempresa, seqcomprador, SUM(venda_vlr_real) as venda_vlr_real,
	SUM(lucratividade_vlrreal) as lucratividade_vlrreal, ano, mes,
	sum(qtde_venda_real) as qtde_venda_real	,
	SUM(lucratividade_vlrreal) / SUM(venda_vlr_real) * 100 as perc_margem_real,
	sum(vlr_perda_inf_cb) as vlr_perda_inf_cb,
	sum(vlr_lucratividade_ajustada),
	id_gerente_categoria
FROM bi.venda_comprador_total_mes
group by ano, mes, dia, seqcomprador, id_gerente_categoria;
 
-- Calcula a perc Margem Ajustada.
update bi.venda_comprador_total_mes as a	
set perc_margem_ajustada = vlr_lucratividade_ajustada / venda_vlr_real * 100;


