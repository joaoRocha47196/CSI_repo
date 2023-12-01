DELETE FROM cinematica_hist;
DELETE FROM objeto_movel;
DELETE FROM perseguicao;
DELETE FROM cinematica;

DROP VIEW IF EXISTS v_posicionar;
DROP VIEW IF EXISTS V_ROTA_OBJETO;
DROP TABLE IF EXISTS TAUX_ROTA_OBJETO;


--________________________________________________
-- Inserir dados para caracterizacao da cinematica
--________________________________________________
INSERT INTO cinematica( id, nome, orientacao, velocidade, aceleracao, g_posicao ) VALUES(
1,
'Carro',
0.0,
ROW( ROW( 1, 1 ), 1.3 ),
ROW( ROW( 0.5, 3 ), 1.0 ),
ST_GeomFromText( 'POINT( 5 6 )', 3763 )
);


INSERT INTO cinematica( id, nome, orientacao, velocidade, aceleracao, g_posicao ) VALUES(
2,
'Mota',
0.0,
ROW( ROW( 1, 1 ), 0.3 ),
ROW( ROW( 2, 0.5 ), 1.0 ),
ST_GeomFromText( 'POINT( 2 3 )', 3763 )
);

INSERT INTO cinematica( id, nome, orientacao, velocidade, aceleracao, g_posicao ) VALUES(
3,
'Camiao',
0.0,
ROW( ROW( 1, 1 ), 1.3 ),
ROW( ROW( 0.5, 3 ), 1.0 ),
ST_GeomFromText( 'POINT( 5 6 )', 3763 )
);


INSERT INTO objeto_movel( id, id_cinematica, nome, geo ) VALUES (
1,
1,
'Carro',
ST_GeomFromText( 'POLYGON( ( 0 0, 2 0, 2 1, 0 1, 0 0 ) )', 3763 )
);



INSERT INTO objeto_movel( id, id_cinematica, nome, geo ) VALUES (
2,
2,
'Mota',
ST_GeomFromText( 'POLYGON( ( 0 0, 2 0, 2 1, 0 1, 0 0 ) )', 3763 )
);

INSERT INTO objeto_movel( id, id_cinematica, nome, geo ) VALUES (
3,
3,
'Camiao',
ST_GeomFromText( 'POLYGON( ( 0 0, 2 0, 2 1, 0 1, 0 0 ) )', 3763 )
);

-- Inserir dados para caracterizacao da perseguicao
--_________________________________________________
INSERT INTO perseguicao( id_perseguidor, id_alvo )
VALUES( 1, 2 );

INSERT INTO perseguicao( id_perseguidor, id_alvo )
VALUES( 3, 2 );


-- (C) Update the position of objeto_movel based on cinematica table
CREATE OR REPLACE VIEW v_posicionar AS
SELECT
    om.id,
    om.nome,
    ST_Translate(om.geo, ST_X(c.g_posicao) - ST_X(ST_Centroid(om.geo)), ST_Y(c.g_posicao) - ST_Y(ST_Centroid(om.geo))) AS positioned_geo
FROM objeto_movel om
JOIN cinematica c ON om.id_cinematica = c.id;


CREATE VIEW V_ROTA_OBJETO(g_linha, id) AS
    ( SELECT ST_MakeLine( pontos_ordenados.g_posicao ), id::integer 
    FROM ( SELECT g_posicao, id, id_hist 
    FROM cinematica_hist 
    ORDER BY id, id_hist ) AS pontos_ordenados
    GROUP BY id
    ORDER BY id
);

