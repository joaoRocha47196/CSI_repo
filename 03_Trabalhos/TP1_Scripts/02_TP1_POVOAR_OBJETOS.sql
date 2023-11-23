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


-- Eliminar Dados (anteriores)
--=============================
DELETE FROM tipo_objeto;
---------------------------------


----------------------------
-- Povoar Dados
----------------------------
-- TIPO_TERRENO
----------------------------
INSERT INTO tipo_objeto(nome, velocidade_max, aceleracao_max)
VALUES
    ('Carro', 200, 30),
    ('Mota', 230, 40),
    ('Barco', 100, 15),
    ('Mota-Agua', 140, 30),
    ('Bicleta', 60, 10),
    ('Camião', 140, 20)
;
----------------------------
-- GPS_PONTO
----------------------------

--<COMPLETAR EXPORTANDO OS VALORES DO QGIS>
--INSERT INTO gps_ponto VALUES (1, 1, ST_MakePoint(-1.21383647798742, 0.534591194968554) );
