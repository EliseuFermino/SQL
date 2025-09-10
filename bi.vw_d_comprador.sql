
-- bi.vw_d_comprador source

CREATE OR REPLACE VIEW bi.vw_d_comprador
AS SELECT a.seqcomprador,
    a.comprador,
    a.apelido,
    a.status,
    a.seqpessoa,
    a.dta_atualizacao,
    a.id_gerente_categoria,
    a.id_departamento,
    a.base_calculo_ruptura,
    a.desc_secao,
    a.ordem_seqcomprador,
    a.secao,
    a.id_comprador_assistente,
    a.gestor_comercial
   FROM bi.d_comprador a;