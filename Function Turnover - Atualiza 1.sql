

create or replace FUNCTION know.Turnover_Atualiza(p_ano integer, p_mes integer) 
RETURNS VOID AS $$
DECLARE 
	var_id_gerente_loja integer = 53;
	var_id_gerente_setor integer = 56;
BEGIN

	perform know.TurnOver_Gerente_de_Operacoes(p_ano, p_mes, 1001);
	perform know.TurnOver_Gerente_de_Operacoes(p_ano, p_mes, 1002);
	
--> GERENTE LOJA
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_loja,6);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_loja,7);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_loja,8);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_loja,9);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_loja,10);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_loja,11);

--> GERENTE SETOR
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_setor,6);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_setor,7);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_setor,8);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_setor,9);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_setor,10);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_gerente_setor,11);

END;

$$ LANGUAGE plpgsql;


select know.Turnover_Atualiza(2025, 3);