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
    ('Camiao', 140, 20)
;

