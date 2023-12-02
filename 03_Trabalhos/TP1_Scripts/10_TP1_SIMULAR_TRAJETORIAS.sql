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


DROP FUNCTION simular_trajetorias_rota;
DROP FUNCTION atualizar_orientação;
DROP FUNCTION simular_trajetorias_orientacao;
--------------------------------------------
--------------------------------------------
-- Simulacao de trajectorias tendo em conta a rota
--------------------------------------------
--------------------------------------------
CREATE OR REPLACE FUNCTION simular_trajetorias_rota(id_alvo integer, iteracoes integer)
RETURNS integer
AS $$
DECLARE
    total_rows_rota int;
BEGIN
    SELECT COUNT(*) FROM rota INTO total_rows_rota;

    FOR i IN 1..iteracoes LOOP

        -- =============================
        -- SAVE CURRENT CINEMATIC IN HITORY
        -- =============================
        INSERT INTO cinematica_hist
        SELECT nextval('cinematica_hist_id_hist_seq'), id, orientacao, velocidade , aceleracao, g_posicao
        FROM cinematica;

        -- =============================
        -- GETS NEW TARGET POSITION
        -- =============================
        PERFORM update_cinematica_sem_orientacao(id_alvo, total_rows_rota);

        -- ==================================
        -- GET NEW PURSUERS POSITIONS
        -- ==================================
        PERFORM update_cinematica_perseguidor(id_alvo);

        -- ====================================================================
        -- CALCULATES NEW POSITIONS OF THE OBJECTS GIVEN NEW CINAMETICA VALUES
        -- ====================================================================
        UPDATE objeto_movel om
        SET geo = ST_Translate(om.geo, ST_X(c.g_posicao) - ST_X(ST_Centroid(om.geo)), ST_Y(c.g_posicao) - ST_Y(ST_Centroid(om.geo)))
        FROM cinematica c
        WHERE om.id_cinematica = c.id;

    END LOOP;
RETURN iteracoes;
END;
$$ LANGUAGE plpgsql;


-- todo create function that allows to change orientacao of cinematica
CREATE OR REPLACE FUNCTION atualizar_orientacao(id_alvo integer, orient real)
RETURNS void
AS $$
BEGIN
    UPDATE cinematica SET orientacao = orient WHERE id = id_alvo;
END;
$$ LANGUAGE plpgsql;



-- before calling this functuion change cinematic orietnatntion, cause other function changes oritentation
CREATE OR REPLACE FUNCTION simular_trajetorias_orientacao(id_alvo integer, iteracoes integer)
RETURNS integer
AS $$
DECLARE
    total_rows_rota int;
BEGIN
    SELECT COUNT(*) FROM rota INTO total_rows_rota;

    FOR i IN 1..iteracoes LOOP

        -- =============================
        -- SAVE CURRENT CINEMATIC IN HITORY
        -- =============================
        INSERT INTO cinematica_hist
        SELECT nextval('cinematica_hist_id_hist_seq'), id, orientacao, velocidade , aceleracao, g_posicao
        FROM cinematica;

        -- =============================
        -- GETS NEW TARGET POSITION
        -- =============================
        PERFORM update_cinematica_com_orientacao(id_alvo, total_rows_rota);

        -- ==================================
        -- GET NEW PURSUERS POSITIONS
        -- ==================================
        PERFORM update_cinematica_perseguidor(id_alvo);

        -- ====================================================================
        -- CALCULATES NEW POSITIONS OF THE OBJECTS GIVEN NEW CINAMETICA VALUES
        -- ====================================================================
        UPDATE objeto_movel om
        SET geo = ST_Translate(om.geo, ST_X(c.g_posicao) - ST_X(ST_Centroid(om.geo)), ST_Y(c.g_posicao) - ST_Y(ST_Centroid(om.geo)))
        FROM cinematica c
        WHERE om.id_cinematica = c.id;

    END LOOP;
RETURN iteracoes;
END;
$$ LANGUAGE plpgsql;



