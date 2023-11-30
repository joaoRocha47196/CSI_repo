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


DROP FUNCTION simular_trajetorias;
DROP FUNCTION update_cinematica;
DROP FUNCTION update_cinematica_perseguidor;


--------------------------------------------
--------------------------------------------
-- Simulacao de trajectorias:
--------------------------------------------
--------------------------------------------


CREATE OR REPLACE FUNCTION simular_trajetorias(id_alvo integer, iteracoes integer)
RETURNS integer
AS $$
DECLARE
    mundo_geo geometry;
    current_row_id_rota int;
    point_record geometry;
    total_rows_rota int;
BEGIN

    SELECT COUNT(*)-1 FROM rota INTO total_rows_rota;

    SELECT geo_terreno INTO mundo_geo FROM terreno WHERE nome = 'Mundo';

    FOR i IN 1..iteracoes LOOP

        -- Keep track of position in rota where id_cinematica last was
        SELECT COUNT(g_posicao) - 1
        FROM cinematica_hist
        WHERE id = id_alvo
        INTO current_row_id_rota;

        -- Ensure current_row_id_rota is non-negative
        IF current_row_id_rota < 0 THEN
            current_row_id_rota := 0;
        END IF;

        -- Fetch the next point from the "rota" table
        SELECT geo_ponto
        FROM rota
        WHERE id = current_row_id_rota
        INTO point_record;

        INSERT INTO cinematica_hist
        SELECT nextval('cinematica_hist_id_hist_seq'), id, orientacao, velocidade , aceleracao, g_posicao
        FROM cinematica;

        -- Move alvo in rota
        UPDATE cinematica
        SET g_posicao = point_record
        WHERE id = id_alvo;

        -- Update cinematica of objetos
        PERFORM update_cinematica(id_alvo);

        -- (C) Update the position of objeto_movel based on cinematica table
        UPDATE objeto_movel om
        SET geo = ST_Translate(om.geo, ST_X(c.g_posicao) - ST_X(ST_Centroid(om.geo)), ST_Y(c.g_posicao) - ST_Y(ST_Centroid(om.geo)))
        FROM cinematica c
        WHERE om.id_cinematica = c.id;

    END LOOP;
RETURN iteracoes;
END
$$ LANGUAGE plpgsql;


-- Função para fazer update à cinematica de um objeto
CREATE OR REPLACE FUNCTION update_cinematica(id_cinematica integer)
RETURNS void
AS $$
DECLARE
    alvo_max_velocidade real;
    alvo_velocidade t_velocidade;
BEGIN
    -- Guarda velocidade maxima da cinematica do alvo em alvo_max_velocidade
    SELECT velocidade_max FROM tipo_objeto t INNER JOIN cinematica c ON t.nome = c.nome WHERE c.id = id_cinematica INTO alvo_max_velocidade;

    -- Determinar velocidade atualizada do alvo
    alvo_velocidade := comparar_velocidade((SELECT novo_velocidade(velocidade, aceleracao, 1) FROM cinematica WHERE id = id_cinematica), alvo_max_velocidade);
    -- =============================
    -- ALVO
    -- =============================
    UPDATE cinematica
    SET 
    velocidade = alvo_velocidade,
    orientacao = novo_orientacao(orientacao , velocidade, 1)
    WHERE id = id_cinematica;


    -- ==================================
    -- SEGUIDOR
    -- ==================================
    -- PERFORM update_cinematica_perseguidor(id_cinematica);
    PERFORM update_cinematica_perseguidor(p.id_perseguidor, id_cinematica) 
    FROM cinematica c 
    INNER JOIN 
    perseguicao p
    ON c.id = p.id_perseguidor;

    /*
    INSERT INTO TAUX_ROTA_OBJETO( g_linha )
    SELECT g_linha
    FROM V_ROTA_OBJETO;
    */

END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_cinematica_perseguidor(_id_perseguidor integer, id_cinematica integer)
RETURNS void
AS $$
DECLARE
    target_pos geometry;
    new_pos geometry;
    mundo_geo geometry;
BEGIN
    -- Get the position of the target (id_cinematica)
    SELECT g_posicao FROM cinematica WHERE id = id_cinematica INTO target_pos;
    -- Save novo_posicao into new_pos variable
    SELECT novo_posicao(g_posicao, velocidade, 1) FROM cinematica WHERE id = _id_perseguidor INTO new_pos;
    -- Save mundo geometry
    SELECT geo_terreno FROM terreno WHERE nome = 'Mundo' INTO mundo_geo;

    -- If new_pos is out of mundo_geo, place it in random coordinate of Mundo
    IF NOT ST_Within(new_pos, mundo_geo) THEN
        SELECT ST_GeometryN(ST_GeneratePoints(mundo_geo, 1), 1) INTO new_pos;
    END IF;

    -- Update aceleracao, velocidade, posicao, and orientacao for all followers where distance is above 10
    UPDATE cinematica AS c
    SET
        aceleracao = obter_aceleracao_perseguidor(_id_perseguidor, id_cinematica, 5),
        -- Get novo_velocidade or max_velocidade, given tipo of objeto
        velocidade = (
            SELECT DISTINCT
            comparar_velocidade(novo_velocidade(c.velocidade, c.aceleracao, 1), v.velocidade_max)
            FROM V_VMAX_AMAX_OBJETO v
            WHERE v.nome = c.nome
        ),
        g_posicao = new_pos,
        orientacao = novo_orientacao(c.orientacao, c.velocidade, 1)
    FROM perseguicao pp
    WHERE c.id = _id_perseguidor
    AND ST_Distance(c.g_posicao, target_pos) > 10;

END;
$$ LANGUAGE plpgsql;


-- Query para saber em que terrenos um determinado id está inserido, com o seu efeito (provavelmente colocar numa view é melhor opção)
-- Caso o mesmo ponto esteja em vários terrenos, retornar o terreno com maior hierarquia
/*
SELECT t.*, ot.efeito
FROM terreno t
INNER JOIN cinematica c ON ST_Within(c.g_posicao, t.geo_terreno)
INNER JOIN objeto_terreno ot ON ot.nome_terreno = t.nome AND ot.nome_objeto = c.nome
WHERE c.id = 2;
*/