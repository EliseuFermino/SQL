
drop table tt_ruptura_produto;
DROP table tt_ruptura_2;



CREATE TEMP TABLE IF NOT EXISTS tt_ruptura_produto (
	dtamovimento date NULL,
	nroempresa int4 NULL,
	seqproduto integer NULL,	
	venda_perdida_qtd float8 NULL,
	vlrvendaperdida float8 null,
	seqcomprador varchar(3) NULL,
	primary key (dtamovimento, nroempresa, seqproduto)
);

CREATE TEMP TABLE IF NOT EXISTS tt_ruptura_2 (
	dtamovimento date NULL,
	nroempresa int4 NULL,
	venda_perdida_qtd float8 NULL,
	vlrvendaperdida float8 NULL,
	seqcomprador varchar(3) NULL,	
	primary key (dtamovimento, nroempresa,seqcomprador)
);

insert into tt_ruptura_produto (dtamovimento, nroempresa,  venda_perdida_qtd, vlrvendaperdida, seqproduto, seqcomprador)
select know.fn_date_bomonth_currentdate(a_1.dtamovimento) as dtamovimento, a_1.nroempresa, sum(a_1.venda_perdida_qtd) , sum(a_1.vlrvendaperdida) , a_1.seqproduto, b_1.seqcomprador
FROM ruptura.tbl_ruptura_produto as a_1 inner JOIN bi.d_produto b_1 
ON a_1.seqproduto = b_1.seqproduto::integer
where a_1.dtamovimento between '2021-01-01' and '2025-12-31' and b_1.nrodivisao = '2' 
group by know.fn_date_bomonth_currentdate(a_1.dtamovimento), a_1.nroempresa, a_1.seqproduto, b_1.seqcomprador;


insert into tt_ruptura_2 (dtamovimento, nroempresa,  venda_perdida_qtd, vlrvendaperdida, seqcomprador )
select a_1.dtamovimento, a_1.nroempresa, sum(a_1.venda_perdida_qtd) , sum(a_1.vlrvendaperdida), a_1.seqcomprador
from tt_ruptura_produto as a_1 
where a_1.seqproduto not IN ( SELECT d_itens_sazonais.seqproduto AS seqproduto FROM bi.d_itens_sazonais)
group by a_1.dtamovimento, a_1.nroempresa, a_1.seqcomprador
;

insert into tt_ruptura_2 (dtamovimento, nroempresa,  venda_perdida_qtd, vlrvendaperdida, seqcomprador)
select dtamovimento, nroempresa, sum(venda_perdida_qtd), sum(vlrvendaperdida), 0 as seqcomprador  
from tt_ruptura_2
group by dtamovimento, nroempresa;


insert into tt_ruptura_2 (dtamovimento, nroempresa,  venda_perdida_qtd, vlrvendaperdida, seqcomprador)
select dtamovimento, 992 as nroempresa, sum(venda_perdida_qtd), sum(vlrvendaperdida), 0 as seqcomprador  
from tt_ruptura_2
group by dtamovimento;


insert into tt_ruptura_2 (dtamovimento, nroempresa,  venda_perdida_qtd, vlrvendaperdida, seqcomprador)
select dtamovimento, 992 as nroempresa, sum(venda_perdida_qtd), sum(vlrvendaperdida), seqcomprador 
from tt_ruptura_2
where seqcomprador <> '0'
group by dtamovimento, seqcomprador;

delete 
from bi.f_prezi
where tipo = 'ruptura' and dia between '2021-01-01' and '2025-12-31'
;

INSERT INTO bi.f_prezi (tipo, vlrreal, dia, seqcomprador, nroempresa)
SELECT 
    'ruptura', 
    vlrvendaperdida,  -- Soma os valores duplicados
    dtamovimento, 
    seqcomprador::smallint,
    nroempresa
 from tt_ruptura_2;    



DROP TABLE IF EXISTS tt;

create temp table tt (
		tipo varchar(50),
		dia_inicio_mes date,
		seqcomprador smallint,
		nroempresa smallint,
		vlrrreal decimal		
	);

	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'ruptura', dia_inicio_mes, c.seqcomprador, b.nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= know.fn_date_primeiro_dia_mes_subsequente_do_ano_atual();
	
	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'ruptura', dia_inicio_mes, 0 as seqcomprador, b.nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= know.fn_date_primeiro_dia_mes_subsequente_do_ano_atual();
	
	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'ruptura', dia_inicio_mes, c.seqcomprador, 992 as nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= know.fn_date_primeiro_dia_mes_subsequente_do_ano_atual();
	
	insert into tt (tipo, dia_inicio_mes, seqcomprador, nroempresa, vlrrreal)
	select distinct 'ruptura', dia_inicio_mes, 0 as seqcomprador, 992 as nroempresa, 0 as vlrrreal
	from bi.vw_d_calendario a cross join bi.d_empresa b cross join bi.d_comprador c
	where b.nrodivisao = 2 
	and c.id_departamento > '0' 
	and a.dia >= know.fn_date_primeiro_dia_mes_subsequente_do_ano_atual();
	
	insert into bi.f_prezi (tipo, dia, seqcomprador, nroempresa, vlrreal)
	select a.tipo, a.dia_inicio_mes, a.seqcomprador, a.nroempresa, 0
	from tt as a left outer join bi.f_prezi b
	on a.tipo = b.tipo
	and a.dia_inicio_mes = b.dia
	and a.seqcomprador = b.seqcomprador
	and a.nroempresa = b.nroempresa
	where b.vlrreal is null;

	