--=============
-- Ligação à BD
--=============
\set dataBase my_gis_world
;
\set userName postgres
;
\connect :dataBase :userName
--==========================
--==========================

---------------------------------------------------------------------
-- Criar Estrutura de suporte 'a cinematica e 'a nocao de perseguicao
---------------------------------------------------------------------
---------------------------------------------------------------------
DELETE FROM perseguicao;
DROP TABLE IF EXISTS perseguicao CASCADE;
DROP TABLE IF EXISTS objeto_hist CASCADE;
DROP TABLE IF EXISTS objeto CASCADE;
DROP TABLE IF EXISTS objeto_terreno CASCADE;
DROP TABLE IF EXISTS tipo_objeto;


CREATE TABLE tipo_objeto (
    nome VARCHAR(20) PRIMARY KEY,
    velocidade_max real NOT NULL,
    aceleracao_max real NOT NULL
);

CREATE TABLE objeto(
    id INTEGER PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    orientacao real NOT NULL,
    velocidade t_velocidade NOT NULL,
    aceleracao t_aceleracao NOT NULL,
    FOREIGN KEY (nome) REFERENCES tipo_objeto (nome)             
);
SELECT AddGeometryColumn( '', 'objeto', 'g_posicao', 3763, 'POINT', 2 );


CREATE TABLE objeto_hist (
    id_hist SERIAL PRIMARY KEY,
    id integer NOT NULL,
    orientacao real NOT NULL,
    velocidade t_velocidade NOT NULL,
    aceleracao t_aceleracao NOT NULL,
    FOREIGN KEY (id) REFERENCES objeto(id)
);
SELECT AddGeometryColumn( '', 'objeto_hist', 'g_posicao', 3763, 'POINT', 2 );


CREATE TABLE objeto_terreno(
    nome_objeto VARCHAR(20),
    nome_terreno VARCHAR(20),
    efeito real,
    FOREIGN KEY(nome_objeto) REFERENCES tipo_objeto(nome),
    FOREIGN KEY(nome_terreno) REFERENCES tipo_terreno(nome),
    CONSTRAINT pk_objeto_terreno PRIMARY KEY (nome_terreno, nome_objeto)
);

CREATE TABLE perseguicao(
    id_perseguidor INTEGER REFERENCES objeto(id),
    id_alvo INTEGER REFERENCES objeto(id),
    PRIMARY KEY (id_perseguidor, id_alvo)
);

--------------------------------------------------------------
--------------------------------------------------------------
-- Copiar dados de cinematica para historico (cinematica_hist)
--------------------------------------------------------------
--------------------------------------------------------------

INSERT INTO objeto_hist
SELECT nextval('objeto_hist_id_hist_seq'), id, orientacao, velocidade , aceleracao, g_posicao
FROM objeto;