

--select know.TurnOver_Gerente_Loja(2025,3, 53,9);

-- DEELTE FUNCTION know.TurnOver_Gerente_Loja(p_ano integer, p_mes integer, p_id_cargo integer, p_filial integer);

CREATE OR REPLACE FUNCTION know.TurnOver_Gerente_Loja(p_ano integer, p_mes integer, p_id_cargo integer, p_filial integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE 
    v_return NUMERIC;
	v_quadro_funcionarios NUMERIC;
BEGIN	

	DELETE FROM prv_tatico.f_turnover WHERE dta_referencia = know.fn_date_bomonth(p_ano, p_mes) and nroempresa = p_filial and id_cargo = p_id_cargo ;

	with func as (
	SELECT numemp, tipcol
	FROM rh.vw_contratacoes
	WHERE datadm <= know.fn_date_eomonth(know.fn_date_bomonth(p_ano, p_mes)) and filctb = p_filial 
      AND codccu IN (SELECT codccu FROM cadastro.d_cargos_prv_detalhe where id_cargo = p_id_cargo::varchar)
	union all
	SELECT  numemp, tipcol
	FROM rh.vw_demitidos
	WHERE datafa <= know.fn_date_eomonth(know.fn_date_bomonth(p_ano, p_mes)) and filctb = p_filial
      AND codccu IN (SELECT codccu FROM cadastro.d_cargos_prv_detalhe where id_cargo = p_id_cargo::varchar)
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
	  AND codccu IN (SELECT codccu FROM cadastro.d_cargos_prv_detalhe where id_cargo = p_id_cargo::varchar)
	union all
	SELECT  numemp, tipcol
	FROM rh.vw_demitidos
	WHERE datafa <= know.fn_date_eomonth(know.fn_date_bomonth(p_ano, p_mes)) and filctb = p_filial
      AND codccu IN (SELECT codccu FROM cadastro.d_cargos_prv_detalhe where id_cargo = p_id_cargo::varchar)
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
          AND codccu IN (SELECT codccu FROM cadastro.d_cargos_prv_detalhe where id_cargo = p_id_cargo::varchar)
		group by numemp
	),
	demitidos as (
		SELECT numemp, sum(-tipcol) as tipcol
		FROM rh.vw_demitidos
		WHERE ano_afa = p_ano and mes_afa = p_mes and filctb = p_filial
          AND codccu IN (SELECT codccu FROM cadastro.d_cargos_prv_detalhe where id_cargo = p_id_cargo::varchar)
		group by numemp
	),
	transferidos as (
		SELECT numemp, sum(tipcol) as tipcol
		FROM rh.vw_transferidos
		WHERE ano_fil = p_ano and mes_fil = p_mes and filctb = p_filial
          AND codccu IN (SELECT codccu FROM cadastro.d_cargos_prv_detalhe where id_cargo = p_id_cargo::varchar)
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


	INSERT INTO prv_tatico.f_turnover
	(dta_referencia, nroempresa, id_cargo, id_departamento, id_tipo_meta, turnover, dta_atualizacao)
	 SELECT know.fn_date_bomonth(p_ano, p_mes), p_filial, p_id_cargo, 0, 8, turnover, know.fn_hour_minutes_atual()
	 FROM calc_turnover_3;
	
END;
$function$
;

