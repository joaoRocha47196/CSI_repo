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
WHERE ST_Relate( g2.geo, g1.geo, 'FF2101FF2');

-- Obtenha todos os pontos contidos em algum dos lados de um polígono.
SELECT g0.id, g0.cor, g2.id, g2.nome
FROM geo_0d g0, geo_2d g2
WHERE ST_Relate( g2.geo, g0.geo, 'FF20F1FF2');

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
SELECT g0.* FROM geo_0d g0, geo_2d g2
WHERE ST_Relate(g2.geo, g0.geo, 'FF20F1FF2');


-- Obtenha todas as linhas que contêm outras linhas.
SELECT g2.*
FROM geo_1d g1, geo_1d g2
WHERE ST_Relate(g1.geo, g2.geo, '1*1**01**');


--  Considere a figura em “fig_rio_doca.bmp” e obtenha as docas representadas pelas linhas 3, 4, 5 e 6.
SELECT g1.*
FROM geo_1d g1, geo_2d g2
WHERE ST_Relate(g2.geo, g1.geo, '102**1**2');

--  Altere a matriz construída na alínea f de modo a contemplar as linhas adicionadas na alínea anterior (g).
SELECT g1.*
FROM geo_1d g1, geo_2d g2
WHERE ST_Relate(g2.geo, g1.geo, '**2**1**2');

-- Obtenha as matrizes topológicas que relacionam todos os objectos 0d e 1d construídos
SELECT ST_Relate(g0.geo, g1.geo)
FROM geo_0d g0, geo_1d g1;

-- Qual a matriz topológica “mais geral” que permite recuperar todos os objectos 0d e 1d que construiu? Teste essa matriz
-- Para obter matriz
SELECT ST_Relate(g0.geo, g1.geo)
FROM geo_0d g0, geo_1d g1;

-- Teste da matriz
SELECT DISTINCT * FROM geo_0d g0, geo_1d g1
WHERE ST_Relate(g0.geo, g1.geo, 'F**FFF102');

-- Obtenha as matrizes topológicas que relacionam todos os objectos 1d entre si.
SELECT ST_Relate(g.geo, g1.geo)
FROM geo_1d g, geo_1d g1
WHERE g.id != g1.id;

-- Obtenha todas as matrizes topológicas que relacionam os objectos 1d e 2d construídos
SELECT ST_Relate(g1.geo, g2.geo)
FROM geo_1d g1, geo_2d g2;

-- Qual a matriz topológica “mais geral” que permite recuperar todos os objectos 1d e 2d que construiu? Teste essa matriz.
SELECT DISTINCT * FROM geo_1d g1, geo_2d g2
WHERE ST_Relate(g1.geo, g2.geo, '******212');

--  Obtenha todas as geometrias 0d resultantes de intersecções entre linhas
-- duvida