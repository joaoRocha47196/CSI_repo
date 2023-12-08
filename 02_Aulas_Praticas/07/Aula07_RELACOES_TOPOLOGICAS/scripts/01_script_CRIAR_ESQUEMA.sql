--#############
--# Paulo Trigo
--#############

--#############################################
-- Cenário: Parque Natural com Trilhas e Pontos de Interesse
--Neste cenário, imagine um parque natural com trilhas, áreas de interesse e pontos de observação.
--As trilhas (geo_1d - linhas) representam caminhos dentro do parque,
--as áreas de interesse (geo_2d - poligonos) delimitam regiões específicas, como áreas de observação de pássaros,
--e os pontos (geo_0d - pontos) marcam locais específicos ao longo das trilhas e nas áreas de interesse.
--#############################################

--=============
-- Liga��o � BD
--=============
\set dataBase my_gis_top
;
\set userName postgres
;
\connect :dataBase :userName
;
--==========================
--==========================


DROP TABLE IF EXISTS geo_0d;
DROP TABLE IF EXISTS geo_1d;
DROP TABLE IF EXISTS geo_2d;

--------------------------------
-- Criar o Esquema Relacional
--------------------------------

CREATE TABLE geo_0d(
    id int PRIMARY KEY,
    cor VARCHAR(20) NOT NULL
);
SELECT AddGeometryColumn('', 'geo_0d', 'geo', 0, 'POINT', 2);


CREATE TABLE geo_1d(
    id int PRIMARY KEY, 
    nome VARCHAR(30) NOT NULL
);
SELECT AddGeometryColumn('', 'geo_1d', 'geo', 0, 'LINESTRING', 2);


CREATE TABLE geo_2d(
    id int PRIMARY KEY, 
    nome VARCHAR(20) UNIQUE NOT NULL
);
SELECT AddGeometryColumn('', 'geo_2d', 'geo', 0, 'POLYGON', 2);




