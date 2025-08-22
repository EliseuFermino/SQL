truncate table ruptura.tbl_ruptura_compra_mes_comprador_empresa;

INSERT INTO ruptura.tbl_ruptura_compra_mes_comprador_empresa
(dia, seqcomprador, nroempresa, vlrvendaperdida)
SELECT date_trunc('month',dia) as dia, seqcomprador::smallint, nroempresa::smallint, sum(vlrruptura) as vlrvendaperdida
FROM ruptura.vw_f_ruptura_produto
group by nroempresa, seqcomprador, date_trunc('month',dia), nroempresa;

INSERT INTO ruptura.tbl_ruptura_compra_mes_comprador_empresa
(dia, seqcomprador, nroempresa, vlrvendaperdida)
SELECT date_trunc('month',dtamovimento) as dia, seqcomprador::smallint, nroempresa::smallint, sum(vlrvendaperdida) as vlrvendaperdida
FROM ruptura.tbl_ruptura_produto_
WHERE dtamovimento < '2024-09-01'
group by nroempresa, seqcomprador, date_trunc('month',dtamovimento), nroempresa;

INSERT INTO ruptura.tbl_ruptura_compra_mes_comprador_empresa
(dia, seqcomprador, nroempresa, vlrvendaperdida)
SELECT dia, 0 as seqcomprador, nroempresa, sum(vlrvendaperdida)
FROM ruptura.tbl_ruptura_compra_mes_comprador_empresa
group by dia, nroempresa;

INSERT INTO ruptura.tbl_ruptura_compra_mes_comprador_empresa
(dia, seqcomprador, nroempresa, vlrvendaperdida)
SELECT dia, seqcomprador, 992 as nroempresa, sum(vlrvendaperdida)
FROM ruptura.tbl_ruptura_compra_mes_comprador_empresa
group by dia, seqcomprador;


--SELECT date_trunc('month',dtamovimento) as dia, seqcomprador::smallint, nroempresa::smallint, sum(vlrvendaperdida) as vlrvendaperdida
--FROM ruptura.tbl_ruptura_produto_
--WHERE dtamovimento between '2022-12-01' and '2023-05-01' and nroempresa = 6
--group by nroempresa, seqcomprador, date_trunc('month',dtamovimento), nroempresa;

