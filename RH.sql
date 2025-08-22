drop view vw_demitidos;
drop view vw_contratacoes;
drop view rh.vw_funcionarios;

create or replace view rh.vw_funcionarios
as
select know.fn_date_year(datadm) as ano_adm, know.fn_date_month(datadm) as mes_adm, 
	   know.fn_date_year(datafa) as ano_afa, know.fn_date_month(datafa) as mes_afa,
	   know.fn_date_year(datfil) as ano_fil, know.fn_date_month(datfil) as mes_fil,
	numemp, tipcol, numcad, nomfun, numcpf, tipsex, datadm, tipadm, tipoadmissao, datdem, caudem, desdem, sitafa, datafa, datfil, dessit, codccu, nomccu, codfil, filctb, numcgc, estcar, codcar, titcar, codcb2, trim(motivod) as motivod
FROM rh.funcionarios as a 
where codfil in (1,2,3,4,5,6);

SELECT COUNT(*)
FROM rh.vw_funcionarios as a
where ano_adm = 2025 and mes_adm = 3 ;


SELECT nrodivisao, divisao, nroempresa, nomereduzido, dta_atualizacao, nroempresa_senior, nome_importa, nroempresa_char, id_supervisor_geral, id_supervisor_acougue, id_supervisor_padaria
FROM bi.d_empresa;

create or replace view rh.vw_contratacoes
as
SELECT ano_adm, mes_adm, numemp, tipcol, numcad, nomfun, numcpf, tipsex, datadm, tipadm, tipoadmissao, datdem, caudem, desdem, sitafa, datafa, datfil, dessit, codccu, nomccu, codfil, filctb, numcgc, estcar, codcar, titcar, codcb2, motivod
FROM rh.vw_funcionarios
;

drop view vw_movimentacao_funcionarios;
drop view rh.vw_demitidos;
create or replace view rh.vw_demitidos
as
SELECT ano_afa, mes_afa, numemp, -tipcol as tipcol, numcad as numcad, nomfun, numcpf, tipsex, datadm, tipadm, tipoadmissao, datdem, caudem, desdem, sitafa, datafa, datfil, dessit, codccu, nomccu, codfil, filctb, numcgc, estcar, codcar, titcar, codcb2, motivod
FROM rh.vw_funcionarios
where sitafa = 7 and motivod <> 'Transferencia' ;

drop view rh.vw_transferidos;
create or replace view rh.vw_transferidos
as
SELECT ano_fil, mes_fil, numemp, tipcol, numcad, nomfun, numcpf, tipsex, datadm, tipadm, tipoadmissao, datdem, caudem, desdem, sitafa, datafa, datfil, dessit, codccu, nomccu, codfil, filctb, numcgc, estcar, codcar, titcar, codcb2, motivod
FROM rh.vw_funcionarios
where tipadm = 4;

create or replace view vw_movimentacao_funcionarios
as
with cte as (
SELECT numemp, tipcol
FROM rh.vw_contratacoes
union all 
SELECT numemp, tipcol
FROM rh.vw_demitidos
)

select numemp, sum(tipcol) as tipcol
from cte
group by numemp;

-----

create or replace view vw_contratacoes_all
as
SELECT ano_adm, mes_adm, numemp, tipcol, numcad, nomfun, numcpf, tipsex, datadm, tipadm, tipoadmissao, datdem, caudem, desdem, sitafa, datafa, datfil, dessit, codccu, nomccu, codfil, filctb, numcgc, estcar, codcar, titcar, codcb2, motivod
FROM rh.vw_funcionarios
;

create or replace view vw_demitidos_all
as
SELECT ano_adm, mes_adm, numemp, -tipcol as tipcol, numcad as numcad, nomfun, numcpf, tipsex, datadm, tipadm, tipoadmissao, datdem, caudem, desdem, sitafa, datafa, datfil, dessit, codccu, nomccu, codfil, filctb, numcgc, estcar, codcar, titcar, codcb2, motivod
FROM rh.vw_funcionarios
where sitafa = 7 and motivod <> 'Transferencia' ;

create or replace view vw_transferidos_all
as
SELECT ano_adm, mes_adm, numemp, tipcol, numcad, nomfun, numcpf, tipsex, datadm, tipadm, tipoadmissao, datdem, caudem, desdem, sitafa, datafa, datfil, dessit, codccu, nomccu, codfil, filctb, numcgc, estcar, codcar, titcar, codcb2, motivod
FROM rh.vw_funcionarios
where ano_fil = 2025 and mes_fil <= 3 and tipadm = 4;

/*

Total Transferidos = 
VAR transf = 
CALCULATE(
          COUNTROWS(Funcionarios),
          Funcionarios[TIPADM]=4,
          USERELATIONSHIP(calendario[Datas],Funcionarios[DATFIL])
          )
VAR TRANSFERIDOS = IF(ISBLANK(transf),0,transf)
RETURN
TRANSFERIDOS

*/

CREATE OR REPLACE FUNCTION know.TurnOver_Total(p_ano numeric, p_mes numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE 
    v_return NUMERIC;
	v_quadro_funcionarios NUMERIC;
BEGIN	

	with func as (
	SELECT  numemp, tipcol
	FROM rh.vw_contratacoes
	union all
	SELECT  numemp, tipcol
	FROM rh.vw_demitidos
	),
	quadro_funcionarios as (
		select numemp, sum(tipcol) as qf
		from func
		group by numemp
	)

	SELECT qf
    INTO v_quadro_funcionarios
    FROM quadro_funcionarios
	--WHERE Ano = p_ano and Mes = p_mes;
	;


	with func as (
	SELECT  numemp, tipcol
	FROM rh.vw_contratacoes
	union all
	SELECT  numemp, tipcol
	FROM rh.vw_demitidos
	),
	quadro_funcionarios as (
		select numemp, sum(tipcol) as tipcol
		from func
		group by numemp
	),
	contratacoes as (
		SELECT numemp, sum(tipcol) as tipcol
		FROM rh.vw_contratacoes as a
		WHERE ano_adm = p_ano and mes_adm = p_mes
		group by numemp
	),
	demitidos as (
		SELECT numemp, sum(-tipcol) as tipcol
		FROM rh.vw_demitidos
		WHERE ano_afa = p_ano and mes_afa = p_mes
		group by numemp
	),
	transferidos as (
		SELECT numemp, sum(tipcol) as tipcol
		FROM rh.vw_transferidos
		WHERE ano_fil = p_ano and mes_fil = p_mes
		group by numemp
	),
	calc_turnover_1 as (
		select *
		from demitidos
		union all
		select *
		from contratacoes
		union all
		select *
		from transferidos
	),
		calc_turnover_2 as (
		select numemp, sum(tipcol) as func, sum(tipcol) / 2 as func_resumo
		from calc_turnover_1
		group by numemp
	),
		calc_turnover_3 as (
		select numemp, func, func_resumo,
			((func_resumo / v_quadro_funcionarios) * 100) as turnover
		from calc_turnover_2
	)

	select turnover 
	into v_quadro_funcionarios
	from calc_turnover_3;

	v_return = v_quadro_funcionarios;
    RETURN v_return;
END;
$function$
;

create or replace view rh.vw_turnover_total
as
select know.fn_date_bomonth(2025,3) as data, know.TurnOver_Total(2025,3);


---- TURNOVER POR LOJA ---------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION know.TurnOver_Total_Filial(p_ano integer, p_mes integer, p_filial integer)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE 
    v_return NUMERIC;
	v_quadro_funcionarios NUMERIC;
BEGIN	

	with func as (
	SELECT numemp, tipcol
	FROM rh.vw_contratacoes
	WHERE datadm <= know.fn_date_eomonth(know.fn_date_bomonth(p_ano, p_mes)) and filctb = p_filial
	union all
	SELECT  numemp, tipcol
	FROM rh.vw_demitidos
	WHERE datafa <= know.fn_date_eomonth(know.fn_date_bomonth(p_ano, p_mes)) and filctb = p_filial
	),
	quadro_funcionarios as (
		select numemp, sum(tipcol) as qf
		from func
		group by numemp
	)

	SELECT qf
    INTO v_quadro_funcionarios
    FROM quadro_funcionarios	
	;


	with func as (
	SELECT  numemp, tipcol
	FROM rh.vw_contratacoes
	WHERE datadm <= know.fn_date_eomonth(know.fn_date_bomonth(p_ano, p_mes)) and filctb = p_filial
	union all
	SELECT  numemp, tipcol
	FROM rh.vw_demitidos
	WHERE datafa <= know.fn_date_eomonth(know.fn_date_bomonth(p_ano, p_mes)) and filctb = p_filial
	),
	quadro_funcionarios as (
		select numemp, sum(tipcol) as tipcol
		from func
		group by numemp
	),
	contratacoes as (
		SELECT numemp, sum(tipcol) as tipcol
		FROM rh.vw_contratacoes as a
		WHERE ano_adm = p_ano and mes_adm = p_mes and filctb = p_filial
		group by numemp
	),
	demitidos as (
		SELECT numemp, sum(-tipcol) as tipcol
		FROM rh.vw_demitidos
		WHERE ano_afa = p_ano and mes_afa = p_mes and filctb = p_filial
		group by numemp
	),
	transferidos as (
		SELECT numemp, sum(tipcol) as tipcol
		FROM rh.vw_transferidos
		WHERE ano_fil = p_ano and mes_fil = p_mes and filctb = p_filial
		group by numemp
	),
	calc_turnover_1 as (
		select *
		from demitidos
		union all
		select *
		from contratacoes
		union all
		select *
		from transferidos
	),
		calc_turnover_2 as (
		select numemp, sum(tipcol) as func, sum(tipcol) / 2 as func_resumo
		from calc_turnover_1
		group by numemp
	),
		calc_turnover_3 as (
		select numemp, func, func_resumo,
			((func_resumo / v_quadro_funcionarios) * 100) as turnover
		from calc_turnover_2
	)

	select turnover 
	into v_quadro_funcionarios
	from calc_turnover_3;

	v_return = v_quadro_funcionarios;
    RETURN v_return;
END;
$function$
;

select know.TurnOver_Total_Filial(2025,3,6);

-- DROP FUNCTION know.fn_date_bomonth(int4, int4);
