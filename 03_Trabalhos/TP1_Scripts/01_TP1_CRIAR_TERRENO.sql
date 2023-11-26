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


DROP TABLE IF EXISTS gps_ponto;
DROP TABLE IF EXISTS terreno;
DROP TABLE IF EXISTS tipo_terreno CASCADE;


---------------------------------
-- TIPO_TERRENO
---------------------------------
CREATE TABLE tipo_terreno (
    nome VARCHAR(20) PRIMARY KEY
);



---------------------------------
-- TERRENO
---------------------------------
CREATE TABLE terreno (
    id_terreno INTEGER PRIMARY KEY, 
    nome VARCHAR(20) NOT NULL,
    hierarquia INTEGER NOT NULL,
    FOREIGN KEY (nome) REFERENCES tipo_terreno (nome)             
);
SELECT AddGeometryColumn('', 'terreno', 'geo_terreno', 3763, 'POLYGON', 2);




---------------------------------
-- GPS_PONTO
---------------------------------
CREATE TABLE gps_ponto (
    id_terreno INTEGER NOT NULL,
    id_ordem INTEGER NOT NULL,
    FOREIGN KEY (id_terreno) REFERENCES terreno(id_terreno),
    CONSTRAINT pk_geo_point PRIMARY KEY (id_terreno, id_ordem)
);

SELECT AddGeometryColumn('', 'gps_ponto', 'geo_ponto', 0, 'POINT', 2);
