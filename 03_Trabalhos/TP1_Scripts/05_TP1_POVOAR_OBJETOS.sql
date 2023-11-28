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
DELETE FROM objeto_terreno;
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
    ('Bicicleta', 60, 10),
    ('Camiao', 140, 20)
;

----------------------------
-- Povoar Dados
----------------------------
-- OBJETO_TERRENO
----------------------------

INSERT INTO objeto_terreno (nome_objeto, nome_terreno, efeito)
VALUES
  ('Carro', 'Mundo', 1),
  ('Carro', 'Montanha', 0.4),
  ('Carro', 'Deserto', 0.3),
  ('Carro', 'Floresta', 0.6),
  ('Carro', 'Vale', 0.5),
  ('Carro', 'Rio', 0.1),
  ('Carro', 'Planicie', 0.5),
  ('Mota', 'Mundo', 1),
  ('Mota', 'Montanha', 0.5),
  ('Mota', 'Deserto', 0.2),
  ('Mota', 'Floresta', 0.7),
  ('Mota', 'Vale', 0.6),
  ('Mota', 'Rio', 0.1),
  ('Mota', 'Planicie', 0.6),
  ('Barco', 'Mundo', 0.5),
  ('Barco', 'Montanha', 0.05),
  ('Barco', 'Deserto', 0.1),
  ('Barco', 'Floresta', 0.1),
  ('Barco', 'Vale', 0.1),
  ('Barco', 'Rio', 1.5),
  ('Barco', 'Planicie', 0.1),
  ('Mota-Agua', 'Mundo', 0.5),
  ('Mota-Agua', 'Montanha', 0.05),
  ('Mota-Agua', 'Deserto', 0.1),
  ('Mota-Agua', 'Floresta', 0.1),
  ('Mota-Agua', 'Vale', 0.1),
  ('Mota-Agua', 'Rio', 2),
  ('Mota-Agua', 'Planicie', 0.1),
  ('Bicicleta', 'Mundo', 1),
  ('Bicicleta', 'Montanha', 1),
  ('Bicicleta', 'Deserto', 0.3),
  ('Bicicleta', 'Floresta', 1),
  ('Bicicleta', 'Vale', 1),
  ('Bicicleta', 'Rio', 0.3),
  ('Bicicleta', 'Planicie', 1),
  ('Camiao', 'Mundo', 1),
  ('Camiao', 'Montanha', 0.4),
  ('Camiao', 'Deserto', 0.2),
  ('Camiao', 'Floresta', 0.5),
  ('Camiao', 'Vale', 0.5),
  ('Camiao', 'Rio', 0.05),
  ('Camiao', 'Planicie', 0.8);

