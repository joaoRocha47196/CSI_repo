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


-- mais informa��o sobre "client_encoding" em:
-- http://www.postgresql.org/docs/8.1/static/multibyte.html
\encoding WIN1250;


--=================================
-- Interrogar com Matriz Topologica
--=================================

-- Obtenha todas as linhas contidas, ou iguais, a lados de polígonos.
SELECT g1.id, g1.nome, g2.id, g2.nome
FROM geo_1d g1, geo_2d g2
WHERE ST_Relate( g2.geo, g1.geo, '102**1**2');

-- Obtenha todos os pontos contidos em algum dos lados de um polígono.
SELECT g.id, cor, ST_AsText(g.geo) FROM geo_0d g, geo_2d gg
WHERE ST_Touches(gg.geo, g.geo);

SELECT g0.id, g0.cor, g2.id, g2.nome
FROM geo_0d g0, geo_2d g2
WHERE ST_Relate( g2.geo, g0.geo, '*F2*F10F2');

-- Acrescente, à base de dados, pontos sobre as linhas contidas num dos lados de um polígono.
INSERT INTO geo_0d (id, cor, geo)
SELECT
    -1 * generate_series(1, ST_NumPoints(ST_Boundary(geo_2d.geo))) AS id,
    'Vermelho' AS cor,
    ST_PointN(ST_Boundary(geo_2d.geo), generate_series(1, ST_NumPoints(ST_Boundary(geo_2d.geo))))
FROM
geo_2d;

-- Obtenha os pontos que estão sobre as linhas contidas num dos lados de um polígono.
-- duvida
SELECT g0.id, ST_AsText(g0.geo)
FROM geo_0d g0
WHERE ST_Touches(g0.geo, 
    (SELECT g1.id, ST_AsText(g1.geo) FROM geo_1d g1, geo_2d g2
    WHERE ST_Within(g1.geo, ST_Boundary(g2.geo)))
);


-- Obtenha todas as linhas que contêm outras linhas.
-- g1.id != g2.id garante que não estamos a comparar a mesma linha
SELECT g1.*
FROM geo_1d g1, geo_1d g2
WHERE ST_Contains(g1.geo, g2.geo) AND g1.id != g2.id;
