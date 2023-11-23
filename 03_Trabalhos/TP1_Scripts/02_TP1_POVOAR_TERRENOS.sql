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

    (4, 'Planice', 1),
    (5, 'Floresta', 2),
    (6, 'Deserto', 3),
    (7, 'Rio', 4),
;


----------------------------
-- GPS_PONTO
----------------------------

--<COMPLETAR EXPORTANDO OS VALORES DO QGIS>
--INSERT INTO gps_ponto VALUES (1, 1, ST_MakePoint(-1.21383647798742, 0.534591194968554) );
