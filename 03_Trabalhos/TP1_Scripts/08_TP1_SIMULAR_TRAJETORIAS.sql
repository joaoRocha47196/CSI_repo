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

-----------------------------
-----------------------------
-- Simulacao de trajectorias:
-- [1] Iniciacao dos dados
-----------------------------
-----------------------------
DELETE FROM cinematica_hist;
DELETE FROM objeto_movel;
DELETE FROM perseguicao;
DELETE FROM cinematica;


DROP FUNCTION simular_trajetorias;
DROP FUNCTION update_cinematica;


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


-- Inserir dados para caracterizacao da perseguicao
--_________________________________________________
INSERT INTO perseguicao( id_perseguidor, id_alvo )
VALUES( 1, 2 );


--------------------------------------------
--------------------------------------------
-- Simulacao de trajectorias:
--------------------------------------------
--------------------------------------------


CREATE OR REPLACE FUNCTION simular_trajetorias(id_alvo integer, iteracoes integer)
RETURNS integer
AS $$
DECLARE
    new_pos geometry;
    mundo_geo geometry;
BEGIN
    SELECT geo_terreno INTO mundo_geo FROM terreno WHERE nome = 'Mundo';

    FOR i IN 1..iteracoes LOOP
        INSERT INTO cinematica_hist
        SELECT nextval('cinematica_hist_id_hist_seq'), id, orientacao, velocidade , aceleracao, g_posicao
        FROM cinematica;

        -- Get the new position based on the updated velocity
        SELECT novo_posicao(g_posicao, velocidade, 1) FROM cinematica WHERE id = id_alvo INTO new_pos;

        -- Check if the new position is within the Mundo geometry
        IF NOT ST_Within(new_pos, mundo_geo) THEN
             -- Place cinematica in a random coordinate of 'Mundo'
             -- Generate one point inside mundo geo with ST_GeneratePoints (returns MULTIPOINT)
             -- And get 1st element with ST_GeometryN
            SELECT ST_GeometryN(ST_GeneratePoints(mundo_geo, 1), 1) INTO new_pos;
        END IF;

        -- Update cinematica of objetos
        PERFORM update_cinematica(id_alvo, new_pos);

    END LOOP;
RETURN iteracoes;
END
$$ LANGUAGE plpgsql;


-- Função auxiliar para fazer update à cinematica de um objeto
CREATE OR REPLACE FUNCTION update_cinematica(id_cinematica integer, new_pos geometry)
RETURNS void
AS $$
DECLARE
    max_velocidade t_velocidade;
BEGIN

    -- Guarda velocidade maxima da cinematica em max_velocidade
    SELECT (velocidade_max).linear, (velocidade_max).angular FROM tipo_objeto t INNER JOIN cinematica c ON t.nome = c.nome WHERE c.id = id_cinematica INTO max_velocidade;

    max_velocidade := comparar_velocidade(max_velocidade, (SELECT novo_velocidade(velocidade, aceleracao, 1) FROM cinematica WHERE id = id_cinematica));
    RAISE NOTICE '%', max_velocidade;
    -- Falta testar comparar_velocidade 
    -- SELECT comparar_velocidade((ROW( ROW( 1, 1 ), 0.3 )), (ROW( ROW( 1, 2 ), 0.3 )));


    -- =============================
    -- ALVO
    -- =============================
    -- Falta verificar se a nova velocidade é superior à velocidade maxima definida
    -- Se sim, estagnar a velocidade na velocidade máxima (não sei como fazer visto que vmax é real)
    UPDATE cinematica
    SET velocidade = novo_velocidade( velocidade, aceleracao, 1 )
    WHERE id = id_cinematica;

    UPDATE cinematica
    SET orientacao = novo_orientacao(orientacao , velocidade, 1)
    WHERE id = id_cinematica;

    -- Update the g_posicao with the new position
    UPDATE cinematica
    SET g_posicao = new_pos
    WHERE id = id_cinematica;

    -- ==================================
    -- SEGUIDOR (N ESTA A FUNCIONAR BEM PQ ELE SAI DO MAPA)
    -- NAO FAÇO IDEIA COMO RESOLVER
    -- ==================================

    INSERT INTO cinematica_hist
    SELECT nextval('cinematica_hist_id_hist_seq'), id, orientacao, velocidade , aceleracao, g_posicao
    FROM cinematica;

    UPDATE cinematica
    SET aceleracao = obter_aceleracao_perseguidor( pp.id_perseguidor, id_cinematica, 2 )
    FROM perseguicao pp
    WHERE id = pp.id_perseguidor;

    UPDATE cinematica
    SET velocidade = novo_velocidade( velocidade, aceleracao, 1 )
    FROM perseguicao pp
    WHERE id = pp.id_perseguidor;


    UPDATE cinematica
    SET g_posicao = novo_posicao( g_posicao, velocidade, 1 )
    FROM perseguicao pp
    WHERE id = pp.id_perseguidor;

    UPDATE cinematica
    SET orientacao = novo_orientacao( orientacao, velocidade, 1 )
    FROM perseguicao pp
    WHERE id = pp.id_perseguidor;

    -- (C) Update the position of objeto_movel based on cinematica table
    UPDATE objeto_movel om
    SET geo = ST_Translate(om.geo, ST_X(c.g_posicao) - ST_X(ST_Centroid(om.geo)), ST_Y(c.g_posicao) - ST_Y(ST_Centroid(om.geo)))
    FROM cinematica c
    WHERE om.id_cinematica = c.id;

END
$$ LANGUAGE plpgsql;



/*
SELECT simular_trajetorias(1, 2);
SELECT simular_trajetorias(2, 2);

*/

/*
Função de teste para modularizar o trabalho
Exemplo:
simular_trajetorias(1) do lider
perseguir_lider()

CREATE OR REPLACE FUNCTION teste()
RETURNS void
AS $$
BEGIN
   PERFORM simular_trajetorias(10);
END
$$ LANGUAGE plpgsql;
*/

-- Query que permite saber se a cinematica está dentro do mundo
-- SELECT ST_Within((SELECT g_posicao FROM cinematica), (SELECT geo_terreno FROM terreno WHERE nome = 'Mundo'));
