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
DELETE FROM cinematica;

--________________________________________________
-- Inserir dados para caracterizacao da cinematica
--________________________________________________
--<COMPLETAR>

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

INSERT INTO cinematica( id, g_posicao, orientacao, velocidade, aceleracao ) VALUES(
2,
ST_GeomFromText( 'POINT( 2 3 )', 3763 ),
0.0,
ROW( ROW( 1, 1 ), 0.3 ),
ROW( ROW( 2, 0.5 ), 1.0 )
);

INSERT INTO objeto_movel( id, id_cinematica, nome, geo ) VALUES (
1,
1,
'Carro',
ST_GeomFromText( 'POLYGON( ( 0 0, 2 0, 2 1, 0 1, 0 0 ) )', 3763 )
);


--------------------------------------------
--------------------------------------------
-- Simulacao de trajectorias:
--------------------------------------------
--------------------------------------------


CREATE OR REPLACE FUNCTION simular_trajetorias(iteracoes integer)
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
        SELECT novo_posicao(cinematica.g_posicao, cinematica.velocidade, 1) FROM cinematica INTO new_pos;

        -- Check if the new position is within the Mundo geometry
        IF NOT ST_Within(new_pos, mundo_geo) THEN

            -- Invert the orientation
            UPDATE cinematica
            SET orientacao = novo_orientacao(orientacao , velocidade, 1) + PI();

            -- (B) Invert velocidade
            UPDATE cinematica c
            SET velocidade = (
                (c.velocidade).linear * -1.0,
                (c.velocidade).angular
            );

            -- Recalculate the new position with the updated orientation
            SELECT novo_posicao(cinematica.g_posicao, cinematica.velocidade, 1) FROM cinematica INTO new_pos;
        -- If within, update velocidade and orientacao
        ELSE
            UPDATE cinematica
            SET velocidade = novo_velocidade( velocidade, aceleracao, 1 );

            UPDATE cinematica
            SET orientacao = novo_orientacao(orientacao , velocidade, 1);
        END IF;

        -- Update the g_posicao with the new position
        UPDATE cinematica
        SET g_posicao = new_pos;

        -- (C) Update the position of objeto_movel based on cinematica table
        UPDATE objeto_movel om
        SET geo = ST_Translate(om.geo, ST_X(c.g_posicao) - ST_X(ST_Centroid(om.geo)), ST_Y(c.g_posicao) - ST_Y(ST_Centroid(om.geo)))
        FROM cinematica c
        WHERE om.id_cinematica = c.id;

    END LOOP;
RETURN iteracoes;
END
$$ LANGUAGE plpgsql;


-- Query que permite saber se a cinematica está dentro do mundo
SELECT ST_Within((SELECT g_posicao FROM cinematica), (SELECT geo_terreno FROM terreno WHERE nome = 'Mundo'));
