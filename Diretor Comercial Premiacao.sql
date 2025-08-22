SELECT ano, mes, codempresa, cod_secao, qtde_venda_real, venda_vlr_real, lucratividade_vlrreal
FROM bi.venda_comprador_empresa_mes;

drop table bi.venda_comprador_empresa_ano_mes;

CREATE TABLE bi.venda_comprador_empresa_ano_mes (	
	ano float8 NULL,
	mes float8 NULL,
	codempresa varchar(5) NULL,
	seqcomprador varchar(10) NULL,
	qtde_venda_real float8 NULL,
	venda_vlr_real float8 NULL,
	lucratividade_vlrreal float8 null,
	atualido_em TIMESTAMP default current_timestamp
);

SELECT *
FROM bi.venda_comprador_empresa_ano_mes;

--create unique index idx_vcem_unique on bi.venda_comprador_empresa_ano_mes (vcem_pk, ano, mes, codempresa, seqcomprador);

INSERT INTO bi.venda_comprador_empresa_ano_mes
(ano, mes, codempresa, seqcomprador, qtde_venda_real, venda_vlr_real, lucratividade_vlrreal)
SELECT ano, mes, codempresa, cod_secao, qtde_venda_real, venda_vlr_real, lucratividade_vlrreal
FROM bi.venda_comprador_empresa_mes;

select * from bi.venda_comprador_empresa_ano_mes as a;

\d bi.venda_comprador_empresa_ano_mes

select a.ano, a.mes, a.seqcomprador, sum(a.venda_vlr_real) as venda_vlr_real, sum(a.lucratividade_vlrreal) as lucratividade_vlrreal, sum(a.qtde_venda_real) as qtde_venda_real
from bi.venda_comprador_empresa_ano_mes as a
group by a.ano, a.mes, a.seqcomprador;

SELECT dia, codempresa, cod_secao, venda_vlr_real, lucratividade_vlrreal, ano, mes
FROM bi.venda_comprador_total_mes;


SELECT ano, mes,  id_comprador, id_versao, vlrmetavenda, vlrmetalucratividade
FROM bi.meta_venda_mensal_comprador
where ano='2025' ;

-- DROP TABLE bi.venda_comprador_total_mes cascade;

CREATE TABLE bi.venda_comprador_total_mes (
	dia date NULL,
	nroempresa smallint NULL,
	seqcomprador smallint NULL,
	venda_vlr_real decimal NULL,
	lucratividade_vlrreal decimal NULL,
	ano smallint NULL,
	mes smallint NULL
);

select * FROM bi.venda_vw_comprador_empresa_mes

create or replace view diretor_comercial.vw_meta_mensal_venda_lucratividade_ano_mes_total
as
SELECT ano, mes, sum(vlrmetavenda) as vlrmetavenda, sum(vlrmetalucratividade) as vlrmetalucratividade
FROM bi.meta_vw_venda_mensal_comprador as a inner join bi.vw_d_comprador as b
on a.id_comprador = b.seqcomprador
where b.base_calculo_ruptura = true
group by a.ano, a.mes;


drop view diretor_comercial.vw_realizado_venda_lucratividade_ano_mes_total;
CREATE OR REPLACE VIEW diretor_comercial.vw_realizado_venda_lucratividade_ano_mes_total
AS select a.ano,
    a.mes,
    sum(a.venda_vlr_real) AS venda_vlr_real,
    sum(a.lucratividade_vlrreal) AS lucratividade_vlrreal 
from bi.venda_comprador_total_mes as a inner join bi.d_comprador as b 
on a.seqcomprador = b.seqcomprador
where nroempresa = '992' and b.base_calculo_ruptura = true  
group by a.ano, a.mes;


create or replace view diretor_comercial.vw_PRV_atingimento_venda_lucratividade
as
SELECT a.ano, a.mes, 
	b.vlrmetavenda, a.venda_vlr_real, (a.venda_vlr_real / b.vlrmetavenda) * 100  as perc_ating_venda,
	b.vlrmetalucratividade , a.lucratividade_vlrreal, (a.lucratividade_vlrreal / b.vlrmetalucratividade) * 100 as perc_ating_lucratividade
FROM diretor_comercial.vw_realizado_venda_lucratividade_ano_mes_total as a left outer join diretor_comercial.vw_meta_mensal_venda_lucratividade_ano_mes_total as b 
on a.ano = b.ano
and a.mes = b.mes 

create or replace view diretor_comercial.vw_PRV_atingimento_venda
as
select ano, mes, '1' as meta_id_tipo, perc_ating_venda
from diretor_comercial.vw_PRV_atingimento_venda_lucratividade
where perc_ating_venda is not null;

create or replace view diretor_comercial.vw_PRV_atingimento_lucratividade
as
select ano, mes, '6' as meta_id_tipo, perc_ating_lucratividade
from diretor_comercial.vw_PRV_atingimento_venda_lucratividade
where perc_ating_venda is not null;

create or replace view diretor_comercial.vw_PRV_atingimento
as
select ano, mes, cast(meta_id_tipo as varchar), perc_ating_venda as percAting 
from diretor_comercial.vw_PRV_atingimento_venda
union all 
select ano, mes, cast(meta_id_tipo as varchar), perc_ating_lucratividade as percAting 
from diretor_comercial.vw_PRV_atingimento_lucratividade;

-- *********************************  ATUALIZAÇÃO PRV DIRETOR COMERCIAL  ****************************************************
-- Se precisar, limpe todos os dados da tabela



select * 
from prv_tatico.fato_diretor_comercial;


truncate table diretor_comercial.tblPRV;

-- STEP 1 - Atualiza PRV de (1) Faturamento e (6) Margem 
with cte as (
	select a.ano, a.mes,  a.meta_id_tipo, b.perc_meta_metrica, a.percating, a.percating - b.perc_meta_metrica as dif, b.vlr_premiacao
	from diretor_comercial.vw_PRV_atingimento as a inner join bi.meta_f_prv_diretor_comercial as b
	on a.ano = b.ano 
	and a.mes = b.mes 
	and cast(a.meta_id_tipo as smallint) = b.id_tipo_meta
	where a.mes = 2
),

cte1 as (
select ano, mes, meta_id_tipo, perc_meta_metrica, percating, dif, vlr_premiacao,
	MIN(dif) over (partition by ano, mes, meta_id_tipo) as status
from cte 
where dif >= 0.0
),

cte2 as (
select ano, mes, meta_id_tipo, perc_meta_metrica, percating,  vlr_premiacao, status,
	MAX(perc_meta_metrica) over (partition by ano, mes, meta_id_tipo) as status1
from cte1
),

cte3 as (
select distinct a.ano, a.mes, a.meta_id_tipo, a.perc_meta_metrica, a.percating,  a.vlr_premiacao
	from cte1 as a inner join cte2 as b 
	on a.ano = b.ano
	and a.mes = b.mes
	and a.meta_id_tipo = b.meta_id_tipo
	and a.perc_meta_metrica = b.status1	
)

INSERT INTO diretor_comercial.tblprv (ano, mes, meta_id_tipo, perc_meta_metrica, percating, vlr_premiacao)
	select distinct a.ano, a.mes, a.meta_id_tipo, a.perc_meta_metrica, a.percating,  a.vlr_premiacao
	from cte3 as a
ON CONFLICT (pk_tblprv, ano, mes, meta_id_tipo)  
DO UPDATE SET perc_meta_metrica = EXCLUDED.perc_meta_metrica,
		      percating = EXCLUDED.percating,
		      vlr_premiacao = EXCLUDED.vlr_premiacao
;




/*
drop table diretor_comercial.tblprv;

CREATE TABLE diretor_comercial.tblprv (
	pk_tblprv serial primary key,
	ano smallint NULL,
	mes smallint NULL,
	meta_id_tipo varchar NULL,
	perc_meta_metrica numeric NULL,
	percating numeric NULL,
	vlr_premiacao numeric null,
	atualizado_em timestamp default current_timestamp
);

create unique index idx_tblprv on diretor_comercial.tblprv (pk_tblprv, ano, mes, meta_id_tipo);
*/

SELECT ano, mes, codgeraloper, tipo_perda, qtdperda, vlrctobruto, vlrtotalperdapv
FROM diretor_comercial.vw_perda_informada_ano_mes;

select * from diretor_comercial.tblprv;



-- bi.meta_vw_margem_departamento source


drop VIEW bi.meta_vw_margem_departamento cascade;
CREATE OR REPLACE VIEW bi.meta_vw_margem_departamento
AS WITH venda AS (
         SELECT meta_vw_venda_departamentos.nroempresa,
            meta_vw_venda_departamentos.nomereduzido,
            meta_vw_venda_departamentos.id_departamento,
            meta_vw_venda_departamentos.departamento,
            meta_vw_venda_departamentos.descricao_meta,
            meta_vw_venda_departamentos.valor_meta AS meta_venda,
            meta_vw_venda_departamentos.dta_referencia
           FROM bi.meta_vw_venda_departamentos
        ), lucratividade AS (
         SELECT meta_vw_lucratividade_departamentos.nroempresa,
            meta_vw_lucratividade_departamentos.nomereduzido,
            meta_vw_lucratividade_departamentos.id_departamento,
            meta_vw_lucratividade_departamentos.departamento,
            meta_vw_lucratividade_departamentos.descricao_meta,
            meta_vw_lucratividade_departamentos.valor_meta AS meta_lucratividade,
            meta_vw_lucratividade_departamentos.dta_referencia
           FROM bi.meta_vw_lucratividade_departamentos
        )
 SELECT a.nroempresa,
    a.nomereduzido,
    a.id_departamento,
    a.departamento,
    5 AS id_tipo_meta,
    'Margem'::varchar AS descricao_meta,
    b.meta_lucratividade / a.meta_venda AS percentual_meta,
    a.dta_referencia
   FROM venda a
     JOIN lucratividade b ON a.nroempresa::text = b.nroempresa::text AND a.id_departamento = b.id_departamento AND a.dta_referencia::text = b.dta_referencia::text;


SELECT mes_venda, nroempresa, empresa, id_departamento, departamento, qtd_venda, valor_venda, venda_promocao, lucratividade, vlr_verba, custo_bruto, custo_liquido, margem_mes, meta_venda, valor_meta_venda, atg_venda, meta_lucratividade, valor_meta_lucratividade, atg_lucratividade, meta_margem, meta_margem_percentual, atg_margem, meta_self, vlr_minimo, vlr_intermediario, vlr_ideal, atg_venda_self_sob_iter, meta_venda_promoc, meta_venda_promoc_percentual, meta_promoc_valor, meta_promoc_perc_realizado, atg_promoc, meta_perdas_quebras, meta_perda_percentual, meta_perda_valor, atg_perda, meta_sacolas, meta_sacolas_qtd, meta_turnover, meta_turnover_percentual, custo_bruto_perda, custo_liquido_perda, preco_venda_perda, lucro_perda, qtd_sacolas_consumida, venda_bruta_self, vlr_desconto_venda_self, venda_liquida_self
FROM bi.vw_resumo_indicadores_para_prv;



CREATE OR REPLACE VIEW diretor_comercial.vw_prv_atingimento
AS SELECT vw_prv_atingimento_venda.ano,
    vw_prv_atingimento_venda.mes,
    vw_prv_atingimento_venda.meta_id_tipo::character varying AS meta_id_tipo,
    vw_prv_atingimento_venda.perc_ating_venda AS percating
   FROM diretor_comercial.vw_prv_atingimento_venda
UNION ALL
 SELECT vw_prv_atingimento_lucratividade.ano,
    vw_prv_atingimento_lucratividade.mes,
    vw_prv_atingimento_lucratividade.meta_id_tipo::character varying AS meta_id_tipo,
    vw_prv_atingimento_lucratividade.perc_ating_lucratividade AS percating
   FROM diretor_comercial.vw_prv_atingimento_lucratividade;


--CREATE OR REPLACE VIEW diretor_comercial.vw_prv_atingimento_venda
--AS 
	SELECT vw_prv_atingimento_venda_lucratividade.ano,
    vw_prv_atingimento_venda_lucratividade.mes,
    '1' AS meta_id_tipo,
    vw_prv_atingimento_venda_lucratividade.perc_ating_venda
   FROM diretor_comercial.vw_prv_atingimento_venda_lucratividade
  WHERE vw_prv_atingimento_venda_lucratividade.perc_ating_venda IS NOT NULL;


SELECT ano, mes, a.seqcomprador , b.id_gerente_categoria, ano_mes, sum(a.) as vlrmetarupturadefinitiva
FROM metas.vw_venda_mensal_comprador_loja as a inner join bi.d_comprador as b
on a.id_comprador = b.seqcomprador
where mes = 2 
group by ano, mes, id_comprador, ano_mes, b.id_gerente_categoria;


SELECT ano, mes, id_gerente_categoria, ano_mes, sum(a.vlrmetarupturadefinitiva) as vlrmetarupturadefinitiva
FROM bi.meta_vw_venda_mensal_comprador as a
where mes = 2
group by ano, mes, ano_mes, id_gerente_categoria;

SELECT dia, ano, mes, nroempresa, id_gerente_categoria, sum(vlrvendaperdida) as vlr_ruptura_compra
FROM ruptura.vw_total_mensal_por_comprador
where ano='2025' and mes='2'
group by dia, ano, mes, nroempresa, id_gerente_categoria;


drop view ruptura.vw_total_mensal_por_comprador

CREATE OR REPLACE VIEW ruptura.vw_total_mensal_por_comprador
AS SELECT (((b.ano || '-'::text) || b.mes) || '-01'::text)::date AS dia,
    b.ano,
    b.mes,
    992 AS nroempresa,
    a.seqcomprador,
    c.id_gerente_categoria,
    sum(a.vlrvendaperdida) AS vlrvendaperdida
   FROM bi.vw_f_ruptura_analitica a JOIN bi.vw_d_calendario b 
   ON a.dta = b.dia inner join bi.vw_d_comprador as c
   on a.seqcomprador::float8 = c.seqcomprador::float8
  GROUP BY b.ano, b.mes, a.seqcomprador, c.id_gerente_categoria
  ORDER BY b.ano, b.mes;

drop table prv_tatico.fato_diretor_comercial;

create table prv_tatico.fato_diretor_comercial (
	dta date,
	ano smallint,
	mes smallint,
	ano_mes char(7),
	id_tipo smallint,
	desc_tipo varchar(20),
	seqcomprador float8,
	vlr_meta float8,
	vlr_realizado float8,
	perc_meta_ating float8,
	vlr_premio_94 float8,
	vlr_premio_96 float8,	
	vlr_premio_98 float8,
	vlr_premio_100 float8,
	vlr_premio_103 float8,	
	vlr_premio_105 float8,
	primary key(dta, id_tipo, seqcomprador)
);

truncate table prv_tatico.fato_diretor_comercial;

delete from prv_tatico.fato_diretor_comercial where ano=2025 and mes= 4;

insert into prv_tatico.fato_diretor_comercial (dta, ano, mes, ano_mes, id_tipo, desc_tipo, seqcomprador)
select '2025-04-01', 2025, 4, '2025_4', a.id_tipo_meta::smallint, a.descricao_meta, 9999
from bi.meta_d_tipo as a
where a.id_tipo_meta in ('1','4','5','13','15');

select *
from diretor_comercial.tblprv;

select *
from  prv_tatico.fato_diretor_comercial
order by id_tipo;

update prv_tatico.fato_diretor_comercial as a
set perc_meta_ating = b.percating,	
	vlr_premio_94 = case when b.percating < 96 then b.percating else 0 end,
	vlr_premio_96 = case when b.percating >= 96 and b.percating < 98 then b.vlr_premiacao else 0 end,					
	vlr_premio_98 = case when b.percating >= 98 and b.percating < 100 then b.vlr_premiacao else 0 end,
	vlr_premio_100 = case when b.percating >= 100 and b.percating < 103 then b.vlr_premiacao else 0 end,
	vlr_premio_103 = case when b.percating >= 103 and b.percating < 105 then b.vlr_premiacao else 0 end,
	vlr_premio_105 = case when b.percating >= 105 then b.vlr_premiacao else 0 end	
from diretor_comercial.tblprv as b
where 
	a.id_tipo = b.meta_id_tipo::smallint and
	b.ano = 2025 and b.Mes = 4;

update prv_tatico.fato_diretor_comercial as a
set vlr_meta = know.fn_diretor_comercial_vlr_meta_venda(2025,4),
    vlr_realizado = Know.fn_diretor_comercial_realizado_venda(2025,4)   
where ano = 2025 and Mes = 4 and id_tipo = 1;




CREATE OR REPLACE FUNCTION know.eomonth(date_input date)
 RETURNS date
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN (date_trunc('month', date_input) + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
END;
$function$
;


------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION know.fn_diretor_comercial_vlr_meta_venda(p_ano INT, p_mes INT) 
RETURNS NUMERIC AS $$
DECLARE 
    v_vlrmetavenda NUMERIC;
BEGIN
    SELECT vlrmetavenda 
    INTO v_vlrmetavenda
    FROM diretor_comercial.vw_meta_mensal_venda_lucratividade_ano_mes_total
    WHERE ano = p_ano AND mes = p_mes;

    RETURN v_vlrmetavenda;
END;
$$ LANGUAGE plpgsql;

SELECT know.fn_diretor_comercial_vlr_meta_venda(2025, 4);


create function Know.fn_diretor_comercial_realizado_venda(p_ano int, p_mes int)
returns numeric as $$
declare vReturn numeric;
begin
	SELECT venda_vlr_real
	into vReturn
	FROM diretor_comercial.vw_realizado_venda_lucratividade_ano_mes_total
	where ano = p_ano and mes = p_mes;

	return vReturn;
end;
$$ language plpgsql;

select Know.fn_diretor_comercial_realizado_venda(2025,4)


SELECT Know.atualizar_fato_diretor_comercial(2025, 4);

-----------------------------------------------------------------------------------------------------------------------




-- FUNCTION know.atualizar_fato_diretor_comercial
create or replace FUNCTION know.atualizar_fato_diretor_comercial(p_ano INT, p_mes INT, p_id_tipo_meta INT) 
RETURNS VOID AS $$
DECLARE 
	v_vlr_meta NUMERIC;
	v_vlr_realizado NUMERIC;
	v_percentual NUMERIC;
BEGIN
    -- Remove os dados da tabela antes de inserir novos registros
	IF p_id_tipo_meta = 1 THEN
	    DELETE FROM prv_tatico.fato_diretor_comercial where ano = p_ano and mes = p_mes;

	    -- Insere novos dados
	    INSERT INTO prv_tatico.fato_diretor_comercial (dta, ano, mes, ano_mes, id_tipo, desc_tipo, seqcomprador)
	    SELECT know.fn_date_bomonth(p_ano, p_mes), p_ano, p_mes, know.fn_date_ano_mes(p_ano, p_mes), 
	           a.id_tipo_meta::SMALLINT, a.descricao_meta, 9999
	    FROM bi.meta_d_tipo AS a
	    WHERE a.id_tipo_meta IN ('1', '4', '5', '13', '15');
	END IF;

	-- 1 - Vendas
	IF p_id_tipo_meta = 1 THEN
	    -- Atualiza os valores após a inserção
	    UPDATE prv_tatico.fato_diretor_comercial AS a
	    SET vlr_meta = know.fn_diretor_comercial_vlr_meta_venda(p_ano, p_mes),
	        vlr_realizado = know.fn_diretor_comercial_realizado_venda(p_ano, p_mes)   
	    WHERE ano = p_ano AND mes = p_mes AND id_tipo = p_id_tipo_meta;
	END IF;

	-- 4 - Ruptura de Compra
	IF p_id_tipo_meta = 4 THEN
	    -- Atualiza os valores após a inserção
	    UPDATE prv_tatico.fato_diretor_comercial AS a
	    SET vlr_meta = know.fn_diretor_comercial_meta_ruptura(p_ano, p_mes),
	        vlr_realizado = know.fn_diretor_comercial_realizado_ruptura(p_ano, p_mes)   
	    WHERE ano = p_ano AND mes = p_mes AND id_tipo = p_id_tipo_meta;
	END IF;

	-- 5 - Margem
	IF p_id_tipo_meta = 5 THEN
	    -- Atualiza os valores após a inserção
	    UPDATE prv_tatico.fato_diretor_comercial AS a
	    SET vlr_meta = know.fn_diretor_comercial_meta_margem(p_ano, p_mes),
	        vlr_realizado = know.fn_diretor_comercial_realizado_margem(p_ano, p_mes)   
	    WHERE ano = p_ano AND mes = p_mes AND id_tipo = p_id_tipo_meta;
	END IF;

	-- 15 - Dias de Estoque
	IF p_id_tipo_meta = 15 THEN
	    -- Atualiza os valores após a inserção
	    UPDATE prv_tatico.fato_diretor_comercial AS a
	    SET vlr_meta = know.fn_diretor_comercial_meta_estoque(p_ano, p_mes),
	        vlr_realizado = know.fn_diretor_comercial_realizado_estoque(p_ano, p_mes)   
	    WHERE ano = p_ano AND mes = p_mes AND id_tipo = p_id_tipo_meta;
	END IF;
	
	-- Obtém os valores de vlr_meta e vlr_realizado para calcular o percentual
	SELECT vlr_meta, vlr_realizado
    INTO v_vlr_meta, v_vlr_realizado
    FROM prv_tatico.fato_diretor_comercial
    WHERE ano = p_ano AND mes = p_mes AND id_tipo = p_id_tipo_meta;
   
 	-- Evita divisão por zero
	IF p_id_tipo_meta in (4, 15) THEN		
		IF v_vlr_realizado = 0 OR v_vlr_realizado IS NULL THEN
	        v_percentual := 0;  -- Se o realizado for 0 ou NULL, evita erro de divisão
	    ELSE
	        v_percentual := (( v_vlr_meta / v_vlr_realizado) * 100);  -- Calcula o percentual
	    END IF;
	ELSE
	    IF v_vlr_realizado = 0 OR v_vlr_realizado IS NULL THEN
	        v_percentual := 0;  -- Se o realizado for 0 ou NULL, evita erro de divisão
	    ELSE
	        v_percentual := ((v_vlr_realizado / v_vlr_meta) * 100);  -- Calcula o percentual
	    END IF;
	END IF;

	-- Atualiza o percentual de atingimento da meta
	UPDATE prv_tatico.fato_diretor_comercial AS a
	SET perc_meta_ating = v_percentual
	WHERE ano = p_ano AND mes = p_mes and id_tipo = p_id_tipo_meta;
	
	update prv_tatico.fato_diretor_comercial as a		
		set vlr_premio_94 = case when v_percentual < 96 then know.fn_diretor_comercial_vlr_premiacao(p_Ano, p_Mes, 1, v_percentual) end,
		vlr_premio_96 = case when v_percentual >= 96 and v_percentual < 98 then know.fn_diretor_comercial_vlr_premiacao(p_Ano, p_Mes, 1, v_percentual) end,			
		vlr_premio_98 = case when v_percentual >= 98 and v_percentual < 100 then know.fn_diretor_comercial_vlr_premiacao(p_Ano, p_Mes, 1, v_percentual) end,		
		vlr_premio_100 = case when v_percentual >= 100 then know.fn_diretor_comercial_vlr_premiacao(p_Ano, p_Mes, 1, v_percentual) end	
	where a.ano = p_Ano and a.Mes = p_Mes and id_tipo = p_id_tipo_meta;

END;
$$ LANGUAGE plpgsql;




create or replace FUNCTION know.atualizar_fato_gerente_comprador(p_ano INT, p_mes INT, p_id_tipo_meta INT, p_id_gerente_categoria INT) 
RETURNS VOID AS $$
DECLARE 
	v_vlr_meta NUMERIC;
	v_vlr_realizado NUMERIC;
	v_percentual NUMERIC;
BEGIN
    -- Remove os dados da tabela antes de inserir novos registros
	--IF p_id_tipo_meta = 1 THEN
	    DELETE FROM prv_tatico.fato_gerente_comprador where ano = p_ano and mes = p_mes and id_gerente_categoria = p_id_gerente_categoria;

	    -- 1 - Vendas
	    INSERT INTO prv_tatico.fato_gerente_comprador
		(dta, ano, mes, ano_mes, id_tipo,  id_gerente_categoria, vlr_realizado)
		select dia, ano, mes, know.fn_date_ano_mes(ano, mes) as ano_mes, 1 as id_tipo, id_gerente_categoria, venda_vlr_real
		from vendas.vw_gerente_categoria_mes
		where ano = p_ano and mes = p_mes and nroempresa = 992 and id_gerente_categoria = p_id_gerente_categoria ;

	
	-- 14 - Lucratividade Ajustada
	    INSERT INTO prv_tatico.fato_gerente_comprador
		(dta, ano, mes, ano_mes, id_tipo, id_gerente_categoria, vlr_realizado)
		select dia, ano, mes, know.fn_date_ano_mes(ano, mes) as ano_mes, 14 as id_tipo, id_gerente_categoria, vlr_lucratividade_ajustada
		from vendas.vw_gerente_categoria_mes
		where ano = p_ano and mes = p_mes and nroempresa = 992 and id_gerente_categoria = p_id_gerente_categoria ;

	-- 13 - Margem Ajustada
	    INSERT INTO prv_tatico.fato_gerente_comprador
		(dta, ano, mes, ano_mes, id_tipo, id_gerente_categoria, vlr_realizado)
		select dia, ano, mes, know.fn_date_ano_mes(ano, mes) as ano_mes, 13 as id_tipo, id_gerente_categoria, perc_margem_ajustada
		from vendas.vw_gerente_categoria_mes
		where ano = p_ano and mes = p_mes and nroempresa = 992 and id_gerente_categoria = p_id_gerente_categoria ;



	-- 4 - Ruptura
	 	INSERT INTO prv_tatico.fato_gerente_comprador
		(dta, ano, mes, ano_mes, id_tipo,  id_gerente_categoria, vlr_realizado)
		select dia, ano, mes,  know.fn_date_ano_mes(ano::int2, mes::int2), 4, id_gerente_categoria, vlrvendaperdida
		from ruptura.vw_total_mensal_por_gerente_categoria
		where ano = p_ano and mes = p_mes and id_gerente_categoria = p_id_gerente_categoria ;



	-- 15 - Dias de Estoque
		INSERT INTO prv_tatico.fato_gerente_comprador
		(dta, ano, mes, ano_mes, id_tipo, id_gerente_categoria, vlr_realizado)
		select dta_posicao, ano, mes, know.fn_date_ano_mes(ano::int2, mes::int2), 15, id_gerente_categoria, estoque_dia_real
		from estoque.vw_gerente_comprador_mes as a
		where ano=p_ano and mes=p_mes and id_gerente_categoria = p_id_gerente_categoria  ;



	--- ****** ATUALIZA AS METAS ****************************************
	-- 1 - Venda	
		update prv_tatico.fato_gerente_comprador as a 
		set vlr_meta = b.vlrmetavenda
		from metas.vw_venda_mensal_gerente_comprador_empresa as b
		where a.id_gerente_categoria = b.id_gerente_categoria
		   and b.ano = p_ano and b.mes = p_mes and a.id_tipo = 1 and b.id_gerente_categoria = p_id_gerente_categoria ;


	-- 14 - Lucratividade	
		update prv_tatico.fato_gerente_comprador as a 
		set vlr_meta = b.vlrmetalucratividade
		from metas.vw_venda_mensal_gerente_comprador_empresa as b
		where a.id_gerente_categoria = b.id_gerente_categoria
		   and b.ano = p_ano and b.mes = p_mes and a.id_tipo = 14 and b.id_gerente_categoria = p_id_gerente_categoria ;

	-- 13 - Margem
		update prv_tatico.fato_gerente_comprador as a 
		set vlr_meta = b.meta_margem
		from metas.vw_venda_mensal_gerente_comprador_empresa as b
		where a.id_gerente_categoria = b.id_gerente_categoria
		   and b.ano = p_ano and b.mes = p_mes and a.id_tipo = 13 and b.id_gerente_categoria = p_id_gerente_categoria ;

	-- 4 - ruptura
		update prv_tatico.fato_gerente_comprador as a 
		set vlr_meta = b.vlrmetarupturadefinitiva
		from metas.vw_venda_mensal_gerente_comprador_empresa as b
		where a.id_gerente_categoria = b.id_gerente_categoria
		   and b.ano = p_ano and b.mes = p_mes and a.id_tipo = 4 and b.id_gerente_categoria = p_id_gerente_categoria ;


	-- 15 - estoque dia
		update prv_tatico.fato_gerente_comprador as a 
		set vlr_meta = meta_estoque_dia
		from metas.vw_estoque_dia_gerente_comprador as b
		where a.id_gerente_categoria = b.id_gerente_categoria
		   and b.ano = p_ano and b.mes = p_mes and a.id_tipo = 15 and b.id_gerente_categoria = p_id_gerente_categoria ;


	-- Atualiza a descrição do tipo
	update prv_tatico.fato_gerente_comprador as a
	set desc_tipo = b.descricao_meta
	from bi.meta_d_tipo as b
	where a.id_tipo = b.id_tipo_meta::int2 and a.id_gerente_categoria = p_id_gerente_categoria ;

--	
	update prv_tatico.fato_gerente_comprador as a
	set grupo_tipo = 'Margem'
	where ano=p_ano and mes=p_mes and id_tipo in (13,14) and id_gerente_categoria = p_id_gerente_categoria ;

	update prv_tatico.fato_gerente_comprador as a
	set grupo_tipo = 'Venda'
	where ano=p_ano and mes=p_mes and id_tipo = 1 and id_gerente_categoria = p_id_gerente_categoria ;

   
 	-- Calcular Percentual ------------------------------------------------------------
    update prv_tatico.fato_gerente_comprador as a
	set perc_meta_ating = case when vlr_meta = 0 then 0
							   when vlr_realizado = 0 then 0
							   when id_tipo in (4,15) then ((vlr_meta / vlr_realizado) * 100)
							   else ((vlr_realizado / vlr_meta) * 100)
						  end;


-- ****** FAZ CALCULO DA VENDA E DA MARGEM PARA PAGAMENTO *********************************************************************************************************************
	DELETE FROM prv_tatico.fato_gerente_comprador_pagto WHERE Ano=p_ano and mes=p_mes and id_gerente_categoria = p_id_gerente_categoria ;

	with cte_premiacao as (
		SELECT dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, a.id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
			vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
			b.perc_minimo_premiacao, (perc_meta_ating - b.perc_minimo_premiacao) as dif_ating
		FROM prv_tatico.fato_gerente_comprador as a inner join prv_tatico.tbl_premiacao_perc as b
		on a.ano = b.ano 
		and a.mes = b.mes
		where a.ano=p_ano and a.mes=p_mes and grupo_tipo in ('Venda', 'Margem') and a.id_gerente_categoria = p_id_gerente_categoria
	),
	
	cte_premiacao_1 as (
	SELECT dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
			vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
			dif_ating, case when dif_ating >= 0 then 'Premio' else 'Nao' end as status_premio
		FROM cte_premiacao as a
	),
		
	cte_premiacao_2 as (
	SELECT dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
			vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
			dif_ating, status_premio, 
			row_number() over (partition by ano_mes, id_gerente_categoria, grupo_tipo, status_premio order by ano_mes, id_gerente_categoria, status_premio, grupo_tipo, perc_meta_ating desc) as ordem_premiacao
		FROM cte_premiacao_1 as a
	),
	
	cte_premiacao_3 as (
	select dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
			vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
			dif_ating, status_premio, ordem_premiacao,
			case when status_premio = 'Premio' and ordem_premiacao = 1 then 'premio_calc' end as Calc_Prem
	from cte_premiacao_2 as a
	),
	
	cte_premiacao_4 as (
	select dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
			vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
			dif_ating, status_premio, ordem_premiacao, Calc_Prem,
			row_number() over (partition by Calc_Prem, ano_mes, id_gerente_categoria  order by Calc_Prem, ano_mes, id_gerente_categoria,  perc_meta_ating desc) as ordem_elegivel_premio,
			count(Calc_Prem) over (partition by ano_mes, id_gerente_categoria, Calc_Prem order by ano_mes, id_gerente_categoria, Calc_Prem) as pre_elegivel_premio
	from cte_premiacao_3 as a
	)
	
	INSERT INTO prv_tatico.fato_gerente_comprador_pagto
	(dta, ano, mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo, dif_ating, status_premio, ordem_premiacao, calc_prem, ordem_elegivel_premio, pre_elegivel_premio, apto)	
	select dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
			vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
			dif_ating, status_premio, ordem_premiacao, Calc_Prem, ordem_elegivel_premio, pre_elegivel_premio,
			case when pre_elegivel_premio = 2 and ordem_elegivel_premio = 2 then 'ok' end as apto		
	from cte_premiacao_4 as a;


-- ***************************************************************************************************************************************************************************************

--	select * 
--	from prv_tatico.fato_gerente_comprador_pagto a
--	where a.ano=2025 and a.Mes=3 and id_gerente_categoria=7 and pre_elegivel_premio=2 and apto='ok' ;

 --ATUALIZA VALOR DE PREMIOS DA VENDA, LUCRATIVIDADE E MARGEM 
	update prv_tatico.fato_gerente_comprador_pagto as a		
	set vlr_premio = know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria),
		vlr_premio_94 = case when perc_meta_ating < 96 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,
		vlr_premio_96 = case when perc_meta_ating >= 96 and perc_meta_ating < 98 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,			
		vlr_premio_98 = case when perc_meta_ating >= 98 and perc_meta_ating < 100 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,	
		vlr_premio_100 = case when perc_meta_ating >= 100 and perc_meta_ating < 103 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,		
		vlr_premio_103 = case when perc_meta_ating >= 103 and perc_meta_ating < 105 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,
		vlr_premio_105 = case when perc_meta_ating >= 105 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end	
	where a.ano=p_Ano and a.Mes=p_Mes and apto='ok' and id_gerente_categoria=p_id_gerente_categoria and pre_elegivel_premio=2;

-- *********************** ADICIONA O RESTANTE DAS CONTAS ****************************************************************************************************************************

	INSERT INTO prv_tatico.fato_gerente_comprador_pagto
	(dta, ano, mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, apto)	
	select a.dta, a.ano, a.mes, a.ano_mes, a.id_tipo, a.desc_tipo, a.id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, b.apto
	from prv_tatico.fato_gerente_comprador as a left outer join prv_tatico.vw_premiados as b
	on a.ano = b.ano
	and a.mes = b.mes 
	and a.id_gerente_categoria = b.id_gerente_categoria
	where a.ano=p_ano and a.mes=p_mes and a.grupo_tipo is null and a.id_gerente_categoria = p_id_gerente_categoria ;

-- ATUALIZA VALOR DE PREMIOS DA VENDA, LUCRATIVIDADE E MARGEM 

--		update prv_tatico.fato_gerente_comprador_pagto as a		
--		set status_premio = 'Premio'
--		where a.ano=p_ano and a.Mes=p_mes and id_gerente_categoria=p_id_gerente_categoria  and perc_meta_ating between 94 and 105 and id_tipo=15 and pre_elegivel_premio=2;

--		select * 
--		from prv_tatico.fato_gerente_comprador_pagto a
--		where a.ano=2025 and a.Mes=3 and id_gerente_categoria=7  and perc_meta_ating between 94 and 105 and id_tipo=15 and apto='ok';
	
		update prv_tatico.fato_gerente_comprador_pagto as a		
		set vlr_premio = know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria),
			vlr_premio_94 = case when perc_meta_ating < 96 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,
			vlr_premio_96 = case when perc_meta_ating >= 96 and perc_meta_ating < 98 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,			
			vlr_premio_98 = case when perc_meta_ating >= 98 and perc_meta_ating < 100 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,	
			vlr_premio_100 = case when perc_meta_ating >= 100 and perc_meta_ating < 103 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,		
			vlr_premio_103 = case when perc_meta_ating >= 103 and perc_meta_ating < 105 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end,
			vlr_premio_105 = case when perc_meta_ating >= 105 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, p_id_gerente_categoria) end	
		where a.ano=p_Ano and a.Mes=p_Mes and id_tipo=15 and id_gerente_categoria=p_id_gerente_categoria and apto='ok' and perc_meta_ating between 94 and 105;	

	-- Totaliza
	update prv_tatico.fato_gerente_comprador_pagto as a		
	set vlr_premio_Total = Coalesce(vlr_premio_94,0) + Coalesce(vlr_premio_96,0) + Coalesce(vlr_premio_98,0) + Coalesce(vlr_premio_100,0) + Coalesce(vlr_premio_103,0) + Coalesce(vlr_premio_105,0)
	where a.ano=p_Ano and a.Mes=p_Mes and id_gerente_categoria=p_id_gerente_categoria;



--	from prv_tatico.fato_gerente_comprador_pagto as a	
--	where ano=2025 and mes=3 and id_gerente_categoria = 4 and status_premio = 'Premio' and calc_prem is null;

--	update prv_tatico.fato_gerente_comprador_pagto
--	set vlr_premio_94 = null,
--		vlr_premio_96 = null,
--		vlr_premio_98 = null,
--		vlr_premio_100 = null,
--		vlr_premio_103 = null,
--		vlr_premio_105 = null,
--		vlr_premio = null,
--		vlr_premio_Total = null
--	where ano=p_ano and mes=p_mes and id_gerente_categoria = p_id_gerente_categoria and status_premio = 'Premio' and calc_prem is null;*/


/*	update prv_tatico.fato_gerente_comprador_pagto as a		
	set vlr_premio_94 = case when perc_meta_ating < 96 then know.fn_diretor_gerente_comprador_vlr_premiacao(p_Ano, p_Mes, 1, perc_meta_ating::numeric, 7) end		
	where a.ano=p_Ano and a.Mes=p_Mes and apto='ok' and id_gerente_categoria=7;*/



/*select * 
from prv_tatico.fato_gerente_comprador_pagto as a
where a.ano=2025 and a.Mes=2 and apto='ok' and id_gerente_categoria=7;*/
	

END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------------------------------------------------------------------------------------------
create or replace view prv_tatico.vw_premiados
as
SELECT dta, ano, mes, ano_mes, id_gerente_categoria, status_premio,  apto
FROM prv_tatico.fato_gerente_comprador_pagto
where pre_elegivel_premio = 2 and apto='ok';

	select a.dta, a.ano, a.mes, a.ano_mes, a.id_tipo, a.desc_tipo, a.id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, b.apto
	from prv_tatico.fato_gerente_comprador as a left outer join prv_tatico.vw_premiados as b
	on a.ano = b.ano
	and a.mes = b.mes 
	and a.id_gerente_categoria = b.id_gerente_categoria
	where a.ano=2025 and a.mes=4 and a.grupo_tipo is null and a.id_gerente_categoria = 4 ;


SELECT dta, ano, mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo, dif_ating, status_premio, ordem_premiacao, calc_prem, ordem_elegivel_premio, pre_elegivel_premio, apto, vlr_premio_total
FROM prv_tatico.fato_gerente_comprador_pagto
where ano=2025 and mes=4 and id_gerente_categoria = 4;

SELECT know.atualizar_fato_gerente_comprador(2025, 4, 1);


    DELETE FROM prv_tatico.fato_gerente_comprador where ano = p_ano and mes = p_mes and id_gerente_categoria = p_id_gerente_categoria;

	    -- 1 - Vendas
	    INSERT INTO prv_tatico.fato_gerente_comprador
		(dta, ano, mes, ano_mes, id_tipo,  id_gerente_categoria, vlr_realizado)
		select dia, ano, mes, know.fn_date_ano_mes(ano, mes) as ano_mes, 1 as id_tipo, id_gerente_categoria, venda_vlr_real
		from vendas.vw_gerente_categoria_mes
		where ano = 2025 and mes = 4 and nroempresa = 992 and id_gerente_categoria = 1 ;




SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 1);	-- Venda
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 2);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 3);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 4);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 5);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 6);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 7);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 8);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 9);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 10);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 11);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 12);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 13);	-- Margem Ajustada
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 14);	-- Lucratividade Ajustada
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 15);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 16);
SELECT Know.atualizar_fato_gerente_comprador(2025, 6, 1, 17);

select * from prv_tatico.fato_gerente_comprador;


CREATE OR REPLACE FUNCTION prv_tatico.f_Atulizar_PRV_Comercial(
    p_ano INTEGER,
    p_mes INTEGER,
    p_id_tipo_meta INTEGER,
    p_id_gerencte_comprador INTEGER[] -- O 4º parâmetro também é um array
)
RETURNS void AS $$
BEGIN
    -- Chama a função para cada valor que a função unnest() extrair do array
    PERFORM Know.atualizar_fato_gerente_comprador(p_ano, p_mes, p_id_tipo_meta, s.id_gerente_comprador)
    FROM unnest(p_id_gerencte_comprador) AS s(id_gerente_comprador);
END;
$$ LANGUAGE plpgsql;



SELECT prv_tatico.f_Atulizar_PRV_Comercial(
    2025, 
    7, 
    1, 
    ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
);

-

drop view prv_tatico.vw_fato_gerente_comprador;
create or replace view prv_tatico.vw_fato_gerente_comprador
as
with cte_premiacao as (
	SELECT dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
		vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
		b.perc_minimo_premiacao, (perc_meta_ating - b.perc_minimo_premiacao) as dif_ating
	FROM prv_tatico.fato_gerente_comprador as a inner join prv_tatico.tbl_premiacao_perc as b
	on a.ano = b.ano 
	and a.mes = b.mes
	where grupo_tipo in ('Venda', 'Margem') 
),

cte_premiacao_1 as (
SELECT dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
		vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
		dif_ating, case when dif_ating >= 0 then 'Premio' else 'Nao' end as status_premio
	FROM cte_premiacao as a
),
	
cte_premiacao_2 as (
SELECT dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
		vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
		dif_ating, status_premio, 
		row_number() over (partition by ano_mes, id_gerente_categoria, grupo_tipo, status_premio order by ano_mes, id_gerente_categoria, status_premio, grupo_tipo, perc_meta_ating  asc) as ordem_premiacao
	FROM cte_premiacao_1 as a
),

cte_premiacao_3 as (
select dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
		vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
		dif_ating, status_premio, ordem_premiacao,
		case when status_premio = 'Premio' and ordem_premiacao = 1 then 'premio_calc' end as Calc_Prem
from cte_premiacao_2 as a
),

cte_premiacao_4 as (
select dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
		vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
		dif_ating, status_premio, ordem_premiacao, Calc_Prem,
		row_number() over (partition by Calc_Prem, ano_mes, id_gerente_categoria  order by Calc_Prem, ano_mes, id_gerente_categoria,  perc_meta_ating asc) as ordem_elegivel_premio,
		count(Calc_Prem) over (partition by ano_mes, id_gerente_categoria, Calc_Prem order by ano_mes, id_gerente_categoria, Calc_Prem) as pre_elegivel_premio
from cte_premiacao_3 as a
)

select dta, a.ano, a.mes, ano_mes, id_tipo, desc_tipo, id_gerente_categoria, vlr_meta, vlr_realizado, perc_meta_ating, 
		vlr_premio_94, vlr_premio_96, vlr_premio_98, vlr_premio_100, vlr_premio_103, vlr_premio_105, grupo_tipo,
		dif_ating, status_premio, ordem_premiacao, Calc_Prem, ordem_elegivel_premio, pre_elegivel_premio,
		case when pre_elegivel_premio = 2 and ordem_elegivel_premio = 1 then 'ok' end as apto		
from cte_premiacao_4 as a

--row_number() over (partition by ano_mes, id_gerente_categoria order by ano_mes, id_gerente_categoria, perc_meta_ating asc) as ordem_premiacao
create table prv_tatico.tbl_Premiacao_Perc (
	id serial,
	ano smallint,
	mes smallint,
	perc_minimo_premiacao numeric
)

create or replace view vendas.vw_gerente_categoria_mes
as
with cte_venda_comprador as (
	SELECT dia, nroempresa, ano, mes, id_gerente_categoria,
	sum(venda_vlr_real) as venda_vlr_real, 
	sum(lucratividade_vlrreal) as lucratividade_vlrreal, 
	sum(qtde_venda_real) as qtde_venda_real, 
	sum(vlr_perda_inf_cb) as vlr_perda_inf_cb, 
	sum(vlr_lucratividade_ajustada) as vlr_lucratividade_ajustada  
	FROM bi.venda_comprador_total_mes
	where seqcomprador = 0
	group by dia, nroempresa, ano, mes, id_gerente_categoria
)

select dia, nroempresa, ano, mes, id_gerente_categoria, venda_vlr_real, 
lucratividade_vlrreal, qtde_venda_real, vlr_perda_inf_cb, vlr_lucratividade_ajustada,
(lucratividade_vlrreal / venda_vlr_real) * 100 as perc_margem_real,
(vlr_lucratividade_ajustada / venda_vlr_real) * 100 as  perc_margem_ajustada
from cte_venda_comprador;


select * 
from prv_tatico.fato_comprador
where id_tipo in (1, 13, 14);


update prv_tatico.fato_comprador as a	
set bi.f_perdas_quebras

SELECT ano, mes, id_tipo_meta, id_meta_metrica, perc_meta_metrica, vlr_premiacao
FROM bi.meta_f_prv_diretor_comercial
where ano = 2025 and mes = 2 and id_tipo_meta = 1 and perc_meta_metrica >=;

SELECT Know.atualizar_fato_diretor_comercial(2025, 6, 1);
SELECT Know.atualizar_fato_diretor_comercial(2025, 6, 4);
SELECT Know.atualizar_fato_diretor_comercial(2025, 6, 5);
SELECT Know.atualizar_fato_diretor_comercial(2025, 6, 15);

select *
from  prv_tatico.fato_diretor_comercial
order by mes, id_tipo;

alter table bi.meta_f_prv add nroempresa smallint;

create table bi.meta_f_prv_det (
	id_prv smallint,
	ano smallint,
	mes smallint,
	id_meta_metrica smallint,
	perc_meta_metrica numeric,
	vlr_premiacao numeric
)

SELECT 
FROM truncate table bi.meta_f_prv;

-- know.fn_diretor_comercial_realizado_venda
-- diretor_comercial.vw_realizado_venda_lucratividade_ano_mes_total

SELECT dta_posicao, a.ano, a.mes, medvdia, qtddisponivel, estoque_dia_real, sum(diametaestoque) as diametaestoque
FROM estoque.vw_dia_realizado_diretor_comercial as a inner join bi.meta_ruptura_estoque as b
on a.ano = b.ano 
and a.mes = b.id_mes
group by dta_posicao, a.ano, a.mes, medvdia, qtddisponivel, estoque_dia_real;

SELECT a.dta_posicao , sum(medvdia) as medvdia
FROM estoque.vw_por_comprador_filial_dia as a inner join bi.d_comprador as b
on a.seqcomprador = b.seqcomprador
where dta_posicao between '2025-03-01' and '2025-03-25' and b.base_calculo_ruptura = true
group by a.dta_posicao 
order by a.dta_posicao;

create or replace view metas.vw_ruptura_estoque_dia
as
with cte as (
SELECT b.ano, b.mes, nroempresa,  nroitens, qtdtotal, medvdia, qtddisponivel, apelido
FROM estoque.vw_por_comprador_filial_dia as a inner join bi.vw_d_calendario as b
on a.dta_posicao = b.dia
),

cte1 as (
select ano,mes, 992 as nroempresa, apelido,
	sum(nroitens) as nroitens, sum(qtdtotal) as qtdtotal, sum(medvdia) as medvdia, sum(qtddisponivel) as qtddisponivel
from cte as a 
group by ano, mes, apelido
),

cte2 as (
	select a.ano, a.mes, nroempresa, nroitens, qtdtotal, medvdia, qtddisponivel, apelido, b.diametaestoque, 
	(medvdia * b.diametaestoque) as vlr_estoque_ideal
	from cte1 as a inner join bi.meta_ruptura_estoque as b
	on a.ano = b.ano 
	and a.mes = b.id_mes
	and a.apelido = b.desc_secao 
)

select ano, mes, nroempresa, sum(medvdia) as medvdia, sum(vlr_estoque_ideal) as vlr_estoque_ideal,
	(sum(vlr_estoque_ideal) / sum(medvdia)) as meta_estoque_dia
from cte2 as a inner join bi.vw_d_comprador as b
on a.apelido = b.apelido
where b.base_calculo_ruptura = true
group by ano, mes, nroempresa;



-- estoque.vw_por_comprador_filial_dia source
--
--CREATE OR REPLACE VIEW estoque.vw_por_comprador_filial_dia
--AS 
SELECT dta_posicao,   
    apelido,
    sum(nroitens) as nroitens,
    sum(qtdtotal) as qtdtotal,
    sum(medvdia) as medvdia,
    sum(qtddisponivel) as qtddisponivel
   FROM bi.f_estoque_comprador
   WHERE EXTRACT(DAY FROM dta_posicao) = EXTRACT(DAY FROM (dta_posicao + INTERVAL '1 day' - INTERVAL '1 month'))
   group by dta_posicao, apelido
   order by dta_posicao ;


----------------------------------------------------------------------------------------------------------------------------


SELECT ano, mes, id_tipo_meta, id_meta_metrica, perc_meta_metrica, vlr_premiacao
FROM bi.meta_f_prv_diretor_comercial
where ano = 2025 and mes = 3 and id_tipo_meta = 1 and perc_meta_metrica <= 97.99
order by perc_meta_metrica desc 
limit 1;


create or replace view bi.meta_f_prv
as
SELECT ano, mes, id_tipo_meta, seqcomprador, nroempresa, a.id_prv, b.perc_meta_metrica, b.vlr_premiacao
FROM bi.meta_f_prv_grupo as a inner join bi.meta_f_prv_grupo_det as b
on a.id_prv = b.id_prv

SELECT dia, nroempresa, seqcomprador, venda_vlr_real, lucratividade_vlrreal, ano, mes, qtde_venda_real
FROM bi.venda_comprador_total_mes
where ano=2025 and mes = 2 and nroempresa = 992;


drop VIEW bi.vw_d_calendario
------------------------------------------------------------------------
CREATE OR REPLACE VIEW bi.vw_d_calendario
AS 
WITH cte AS (
         SELECT dc."Column1" AS dia,
            to_char(dc."Column1"::timestamp with time zone, 'TMDay'::text) AS dia_nome,
            date_part('day'::text, dc."Column1") AS dia_numero,
            date_part('month'::text, dc."Column1") AS mes,
            date_part('year'::text, dc."Column1") AS ano,
            to_char(dc."Column1"::timestamp with time zone, 'TMMonth'::text) AS nome_mes,
            date_trunc('month'::text, dc."Column1"::timestamp with time zone)::date AS dia_inicio_mes,
            date_part('dow'::text, dc."Column1") + 1::double precision AS numero_dia_semana,
            date_part('week'::text, dc."Column1") AS num_semana
           FROM bi.d_calendario dc
        )
 SELECT cte.dia,  	
    cte.dia_nome,
    cte.dia_numero,
    "left"(cte.dia_nome, 3) AS dia_nome_reduzido,
    concat(to_char(cte.dia::timestamp with time zone, 'DD/MM/YYYY'::text), ' - ', "left"(cte.dia_nome, 3)) AS data,
    cte.mes,
    cte.ano,
    cte.nome_mes,
    cte.dia_inicio_mes,
    (cte.ano || '_'::text) || cte.mes AS ano_mes,
    cte.numero_dia_semana,
    count(cte.numero_dia_semana) OVER (PARTITION BY cte.ano, cte.mes, cte.dia_nome) AS total_numero_dia_semana,
    cte.num_semana,
    case when ano = 2025 then ((cte.dia - INTERVAL '1 month') + interval '1 days')::date
 	     when ano = 2026 then ((cte.dia - INTERVAL '1 month') + interval '1 days')::date
 	end AS mesmo_dia_mes_passado,	-- O Ano 2026 tem que ajustar
 	case when ano = 2025 then (cte.dia - INTERVAL '1 year')::date 
 	     when ano = 2026 then (cte.dia - INTERVAL '1 year')::date 
 	end AS mesmo_dia_ano_passado	-- O Ano 2026 tem que ajustar 	
   FROM cte
;


create or replace view bi.vw_d_produto
as
SELECT nrodivisao, seqprodutodiv, seqproduto, desccompleta, seqfamilia, seqcomprador, seqcategoria, caminhocompleto, dta_atualizacao,
    SPLIT_PART(caminhocompleto, '\', 1) AS departamento,
    SPLIT_PART(caminhocompleto, '\', 2) AS secao,
    SPLIT_PART(caminhocompleto, '\', 3) AS grupo,
    SPLIT_PART(caminhocompleto, '\', 4) AS subgrupo
FROM bi.d_produto;


SELECT dia, nroempresa, ano, mes, id_gerente_categoria, venda_vlr_real, lucratividade_vlrreal, qtde_venda_real, vlr_perda_inf_cb, vlr_lucratividade_ajustada, perc_margem_real, perc_margem_ajustada
FROM vendas.vw_gerente_categoria_mes
WHERE ano=2025 and mes=7;


SELECT dia, nroempresa, seqcomprador, venda_vlr_real, lucratividade_vlrreal, ano, mes, qtde_venda_real, perc_margem_real, vlr_perda_inf_cb, vlr_lucratividade_ajustada, perc_margem_ajustada, id_gerente_categoria, vlr_perda_inf_pv, atualizacao
FROM bi.venda_comprador_total_mes
WHERE ano=2025 and mes=7;

