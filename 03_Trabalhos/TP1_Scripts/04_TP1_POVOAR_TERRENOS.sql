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
DELETE FROM gps_ponto;
DELETE FROM TERRENO;
DELETE FROM TIPO_TERRENO;
DROP VIEW IF EXISTS V_POLIGONO;
DROP VIEW IF EXISTS V_LINHA_CONTORNO;
---------------------------------


----------------------------
-- Povoar Dados
----------------------------
-- TIPO_TERRENO
----------------------------
INSERT INTO tipo_terreno( nome )
VALUES
    ('Mundo'),
    ('Montanha'),
    ('Planicie'),
    ('Deserto'),
    ('Vale'),
    ('Floresta'),
    ('Rio')
;

----------------------------
-- TERRENO
----------------------------
INSERT INTO terreno( id_terreno, nome, hierarquia)
VALUES
    (0, 'Mundo', 0),

    (1, 'Montanha', 1),
    (2, 'Floresta', 2),
    (3, 'Rio', 3),

    (4, 'Planicie', 1),
    (5, 'Floresta', 2),
    (6, 'Deserto', 3),
    (7, 'Rio', 4)
;


----------------------------
-- GPS_PONTO
----------------------------

--<COMPLETAR EXPORTANDO OS VALORES DO QGIS>

-- <MUNDO> AINDA PODE SER ALTERADO (OUTRO SHAPE)
INSERT INTO gps_ponto VALUES (0, 0, 'POINT(0 0)');
INSERT INTO gps_ponto VALUES (0, 1, 'POINT(150 0)');
INSERT INTO gps_ponto VALUES (0, 2, 'POINT(150 100)');
INSERT INTO gps_ponto VALUES (0, 3, 'POINT(0 100)');
INSERT INTO gps_ponto VALUES (0, 4, 'POINT(0 0)');


--------------------------------------------------------
--------------------------------------------------------
-- PODE VIR A SER UTIL PARA REPRESENTAR OS POLIGONOS DOS TERRENOS
--------------------------------------------------------
--------------------------------------------------------

CREATE VIEW V_LINHA_CONTORNO( g_linha, id_terreno ) AS 

( SELECT ST_MakeLine( geo_ponto ), id_terreno 
FROM ( SELECT geo_ponto, id_ordem, id_terreno 
FROM gps_ponto 
ORDER BY id_terreno, id_ordem ) AS pontos_ordenados 
GROUP BY id_terreno 
);

----------------------------
-- VIEW V_POLIGONO
-- 7 d
----------------------------
CREATE VIEW V_POLIGONO( id_terreno, g_poligono ) AS
SELECT id_terreno, ST_MakePolygon(g_linha)
FROM V_LINHA_CONTORNO;


UPDATE terreno
SET geo_terreno = V_POLIGONO.g_poligono
FROM V_POLIGONO
WHERE terreno.id_terreno = V_POLIGONO.id_terreno;


