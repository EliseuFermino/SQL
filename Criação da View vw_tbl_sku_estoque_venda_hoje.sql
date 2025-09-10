
CREATE OR REPLACE VIEW bi.vw_tbl_sku_estoque_venda_hoje
AS
SELECT dia, nroempresa, sku_estoque, sku_venda, dif_skus
FROM bi.tbl_sku_estoque_venda
WHERE dia = (SELECT MAX(dia) FROM bi.tbl_sku_estoque_venda);