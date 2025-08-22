

create or replace FUNCTION know.Turnover_Atualiza(p_ano integer, p_mes integer) 
RETURNS VOID AS $$
DECLARE 
	var_id_gerente_loja integer = 53;
	var_id_gerente_setor integer = 56;

	var_id_encarregado_mercearia integer = 1171;
	var_id_encarregado_frios integer = 1172;
	var_id_encarregado_acougue integer = 1173;
	var_id_encarregado_padaria integer = 1174;
	var_id_encarregado_frente_caixa integer = 1177;
BEGIN

	perform know.TurnOver_Gerente_de_Operacoes(p_ano, p_mes, 1001);
	perform know.TurnOver_Gerente_de_Operacoes(p_ano, p_mes, 1002);

--> GERENTE DE PADARIA	
	perform know.TurnOver_Gerente_de_Operacoes(p_ano, p_mes, 1003);

--> GERENTE DE AÇOUGUE	
	perform know.TurnOver_Gerente_de_Operacoes(p_ano, p_mes, 1004);
	
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

--> ENCARREGADO DE FRIOS
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frios,6);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frios,7);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frios,8);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frios,9);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frios,10);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frios,11);

--> ENCARREGADO DE AÇOUGUE
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_acougue,6);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_acougue,7);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_acougue,8);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_acougue,9);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_acougue,10);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_acougue,11);

--> ENCARREGADO DE PADARIA
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_padaria,6);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_padaria,7);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_padaria,8);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_padaria,9);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_padaria,10);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_padaria,11);

--> ENCARREGADO DE MERCEARIA
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_mercearia,6);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_mercearia,7);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_mercearia,8);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_mercearia,9);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_mercearia,10);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_mercearia,11);

--> ENCARREGADO DE FRENTE DE CAIXA
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frente_caixa,6);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frente_caixa,7);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frente_caixa,8);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frente_caixa,9);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frente_caixa,10);
	perform know.TurnOver_Gerente_Loja(p_ano, p_mes, var_id_encarregado_frente_caixa,11);

END;

$$ LANGUAGE plpgsql;


select know.Turnover_Atualiza(2025, 3);