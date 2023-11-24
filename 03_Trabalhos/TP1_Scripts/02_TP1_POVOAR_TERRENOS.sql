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
DROP TABLE IF EXISTS TAUX_LINHA_CONTORNO;
DROP VIEW IF EXISTS V_POLIGONO;
DROP VIEW IF EXISTS V_LINHA_EXTREMO_COINCIDENTE;
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
INSERT INTO gps_ponto VALUES(0,0,'POINT(0 0)');
INSERT INTO gps_ponto VALUES(0,1,'POINT(191.06016115562878 3.617612210964182)');
INSERT INTO gps_ponto VALUES(0,2,'POINT(189.94224871469325 141.8661174066638)');
INSERT INTO gps_ponto VALUES(0,3,'POINT(-3.083966086849614 148.20095457196538)');
INSERT INTO gps_ponto VALUES(0,4,'POINT(6.23197092094685 -29.9197610171031)');


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
-- TAUX_LINHA_CONTORNO
-- 7 b
-- (apenas para usar apresentar no QGIS)
----------------------------
-- CREATE TABLE TAUX_LINHA_CONTORNO ( id SERIAL PRIMARY KEY );
-- SELECT AddGeometryColumn
-- ('', 'taux_linha_contorno', 'g_linha', 0, 'LINESTRING', 2 );
-- 
-- INSERT INTO TAUX_LINHA_CONTORNO( g_linha )
-- SELECT g_linha
-- FROM V_LINHA_CONTORNO;

----------------------------
--VIEW V_LINHA_EXTREMO_COINCIDENTE
-- 7 c
-- (gerar extremidades coincidentes)
----------------------------
CREATE VIEW V_LINHA_EXTREMO_COINCIDENTE( id_terreno, g_linha ) AS
SELECT id_terreno, ST_UnaryUnion(g_linha) as g_linha
FROM V_LINHA_CONTORNO;

----------------------------
-- VIEW V_POLIGONO
-- 7 d
----------------------------
CREATE VIEW V_POLIGONO( id_terreno, g_poligono ) AS
SELECT id_terreno, ST_BuildArea(g_linha)
FROM V_LINHA_EXTREMO_COINCIDENTE;

-- SELECT id_terreno, ST_AsText( g_poligono ) AS g_poligono
-- FROM V_POLIGONO;

UPDATE terreno
SET geo_terreno = V_POLIGONO.g_poligono
FROM V_POLIGONO
WHERE terreno.id_terreno = V_POLIGONO.id_terreno;


