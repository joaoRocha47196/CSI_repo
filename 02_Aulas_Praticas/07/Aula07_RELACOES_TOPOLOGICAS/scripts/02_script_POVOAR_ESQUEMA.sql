--#############
--# Paulo Trigo
--#############


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



--______________________________________________
-- AJUSTAR DE ACORDO COM O CENARIO QUE IDEALIZOU
------------------------------------------------



--=============
-- Geometria 0D
--=============
DELETE FROM geo_0d;

INSERT INTO geo_0d(id, cor, geo)
    VALUES
        (1, 'Vermelho', ST_GeomFromText('POINT(10 10)')),
        (2, 'Verde', ST_GeomFromText('POINT(12 15)')),
        (3, 'Azul', ST_GeomFromText('POINT(8 25)'));
;




--=============
-- Geometria 1D
--=============
DELETE FROM geo_1d;

INSERT INTO geo_1d(id, nome, geo)
    VALUES
        (1, 'Riacho',ST_GeomFromText('LINESTRING(10 10, 10 40)')),
        (2, 'Riacho2',ST_GeomFromText('LINESTRING(10 11, 10 39)')),
        (3, 'Riacho3',ST_GeomFromText('LINESTRING(8 30, 15 30)')),
        (4, 'Riacho4',ST_GeomFromText('LINESTRING(11 33, 15 33)')),
        (5, 'Riacho5',ST_GeomFromText('LINESTRING(10 11, 10 25, 15 25)')),
        (6, 'Riacho6',ST_GeomFromText('LINESTRING(10 35, 12 35)'))
;



--=============
-- Geometria 2D
--=============
DELETE FROM geo_2d;

INSERT INTO geo_2d(id, nome, geo)
    VALUES
        (1, 'Praia Bacana', ST_GeomFromText('POLYGON((10 10, 10 40, 20 30, 10 10))'))
;