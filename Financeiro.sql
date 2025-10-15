
create table financeiro.excel_fluxo_inicial (
	
)


create table financeiro.excel_cadastro (
	id_conta serial primary key,
	nome_conta varchar(100)
)

CREATE SEQUENCE seq_conta START 1;

CREATE TABLE financeiro.excel_cadastro (
    id_conta SMALLINT NOT NULL DEFAULT nextval('seq_conta'),
    nome_conta varchar(100)
);

alter table financeiro.excel_cadastro add id_categoria smallint;

CREATE SEQUENCE seq_categoria START 1;

CREATE TABLE financeiro.excel_categoria (
    id_categoria SMALLINT NOT NULL DEFAULT nextval('seq_categoria'),
    nome_categoria varchar(100)
);

drop table financeiro.excel_recebimento;

CREATE TABLE financeiro.excel_diversos (
    id_diversos SERIAL,
    dta_diversos DATE,
    id_conta SMALLINT,
    vlr_diversos NUMERIC,
    dta_hora_atu_diversos TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario SMALLINT,
    CONSTRAINT idx_cadastro_dta_diversos PRIMARY KEY (id_diversos, dta_diversos)
);


ALTER TABLE financeiro.excel_diversos
ADD CONSTRAINT fk_diversos_cadastro
FOREIGN KEY (id_conta)
REFERENCES financeiro.excel_cadastro (id_conta)
ON UPDATE CASCADE
ON DELETE RESTRICT;


create table financeiro.stg_file_forma_pagto (
	dta_abertura date,
	nroempresa smallint,
	forma varchar(100),
	valor numeric
)

DELETE FROM financeiro.excel_forma_pagto 
WHERE dta_abertura IN (SELECT MAX(dta_abertura) FROM financeiro.stg_file_forma_pagto);

INSERT INTO financeiro.excel_forma_pagto
(dta_abertura, nroempresa, forma, valor)
SELECT dta_abertura, nroempresa, forma, valor
FROM financeiro.stg_file_forma_pagto;

select * from financeiro.stg_file_forma_pagto;

-- financeiro.excel_forma_pagto definition

-- Drop table

-- DROP TABLE financeiro.excel_forma_pagto;

CREATE TABLE financeiro.excel_forma_pagto (
	dta_abertura date NOT NULL,
	nroempresa int2 NOT NULL,
	forma varchar(100) NULL,
	valor numeric NULL,
	CONSTRAINT pk_dtabertura_nroempresa1 PRIMARY KEY (dta_abertura, nroempresa, forma)
);


SELECT dta_abertura, nroempresa, forma, valor
FROM financeiro.excel_forma_pagto;
