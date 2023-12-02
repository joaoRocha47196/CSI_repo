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


DROP FUNCTION get_efeito_terreno;
DROP FUNCTION calcular_velocidade_atualizada;
DROP FUNCTION verify_pos_in_world;
DROP FUNCTION update_cinematica_perseguidor;
DROP FUNCTION update_cinematica_perseguidor_aux;
DROP FUNCTION update_cinematica_sem_orientacao;
DROP FUNCTION update_cinematica_com_orientacao;

-- =================================================
-- CALCULATES EFECT OF GIVING CINEMATICA ON TERRAIN
-- =================================================
CREATE OR REPLACE FUNCTION get_efeito_terreno(_id_cinematica integer)
RETURNS real
AS $$
DECLARE
    efeito real;
BEGIN
    SELECT v.efeito FROM v_efeito_terreno_objeto v WHERE v.id_cinematica = _id_cinematica INTO efeito;
    return efeito;
END 
$$ LANGUAGE plpgsql;

-- =========================================================================
-- APPLIES THE EFFECT OF THE TERRAIN IN THE CINEMATIC AND CHECKS MAX-VELEOCI
-- =========================================================================
CREATE OR REPLACE FUNCTION calcular_velocidade_atualizada(id_cinematica integer)
RETURNS t_velocidade AS $$
DECLARE
    alvo_max_velocidade real;
    alvo_velocidade t_velocidade;
BEGIN
    SELECT velocidade_max FROM tipo_objeto t INNER JOIN cinematica c ON t.nome = c.nome WHERE c.id = id_cinematica INTO alvo_max_velocidade;
    alvo_velocidade := comparar_velocidade((SELECT novo_velocidade(velocidade, aceleracao, 1) FROM cinematica WHERE id = id_cinematica), alvo_max_velocidade);
    alvo_velocidade := alvo_velocidade * get_efeito_terreno(id_cinematica);
    RETURN alvo_velocidade;   
END;
$$ LANGUAGE plpgsql;

-- =========================================================================
-- VERIFYS IF CINEMATICA IS IN THE DIMENSIONS OF WORD
-- =========================================================================
CREATE OR REPLACE FUNCTION verify_pos_in_world(new_pos geometry)
RETURNS geometry AS $$
DECLARE
    mundo_geo geometry;
BEGIN
    
    SELECT geo_terreno FROM terreno WHERE nome = 'Mundo' INTO mundo_geo;

    -- If new_pos is out of mundo_geo, place it in random coordinate of Mundo
    IF NOT ST_Within(new_pos, mundo_geo) THEN
        SELECT ST_GeometryN(ST_GeneratePoints(mundo_geo, 1), 1) INTO new_pos;
    END IF;

    RETURN new_pos;
END;
$$ LANGUAGE plpgsql;

-- =============================
-- update_cinematica_perseguidor 
-- =============================
CREATE OR REPLACE FUNCTION update_cinematica_perseguidor(id_cinematica integer)
RETURNS void
AS $$
BEGIN
    PERFORM update_cinematica_perseguidor_aux(p.id_perseguidor, id_cinematica) 
    FROM cinematica c 
    INNER JOIN 
    perseguicao p
    ON c.id = p.id_perseguidor;

END
$$ LANGUAGE plpgsql;

-- ================================
-- update_cinematica_perseguidor aux
-- =================================
CREATE OR REPLACE FUNCTION update_cinematica_perseguidor_aux(_id_perseguidor integer, id_cinematica integer)
RETURNS void
AS $$
DECLARE
    target_pos geometry;
    new_pos geometry;
BEGIN
    -- OBTAIN CURRENT CIN POS
    SELECT g_posicao FROM cinematica WHERE id = id_cinematica INTO target_pos;
    -- CALCULATES NEW POSITION
    SELECT novo_posicao(g_posicao, velocidade, 1) FROM cinematica WHERE id = _id_perseguidor INTO new_pos;
    new_pos := verify_pos_in_world(new_pos);
    -- UPDATE VALUES OF THE PURSUERS
    UPDATE cinematica AS c
    SET
        aceleracao = obter_aceleracao_perseguidor(_id_perseguidor, id_cinematica, 5),
        velocidade = (
            SELECT DISTINCT
            comparar_velocidade(novo_velocidade(c.velocidade, c.aceleracao, 1), v.velocidade_max) * get_efeito_terreno(_id_perseguidor)
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

-- =================================================
-- UPDATES TARGET GIVEN A POINT FROM THE TABLE "ROTA"
-- =================================================
CREATE OR REPLACE FUNCTION update_cinematica_sem_orientacao(id_cinematica integer, total_rows_rota int)
RETURNS void
AS $$
DECLARE
    current_row_id_rota int;
    point_record geometry;
BEGIN    
    -- Keep track of position in rota where id_cinematica last was
    SELECT COUNT(g_posicao) - 1
    FROM cinematica_hist
    WHERE id = id_cinematica
    INTO current_row_id_rota;

    -- Ensure current_row_id_rota is non-negative
    IF current_row_id_rota < 0 THEN
        current_row_id_rota := 0;
    END IF;

    -- Make sure it loops back the rota
    current_row_id_rota := current_row_id_rota % total_rows_rota;

    -- Fetch the next point from the "rota" table
    SELECT geo_ponto
    FROM rota
    WHERE id = current_row_id_rota
    INTO point_record;

    -- UPDATE VALUES OF THE TARGET
    UPDATE cinematica
    SET 
        velocidade = calcular_velocidade_atualizada(id_cinematica),
        g_posicao = point_record,
        orientacao = novo_orientacao(orientacao , velocidade, 1)
    WHERE id = id_cinematica;
END;
$$ LANGUAGE plpgsql;

-- =================================================
-- UPDATES TARGET GIVEN ORIENTATION
-- =================================================
CREATE OR REPLACE FUNCTION update_cinematica_com_orientacao(id_cinematica integer, total_rows_rota int)
RETURNS void
AS $$
DECLARE
    new_pos geometry;
BEGIN
    -- CALCULATES NEW POSITION
    SELECT novo_posicao_com_orientacao(g_posicao, velocidade, orientacao, 1) FROM cinematica WHERE id = id_cinematica INTO new_pos;
    new_pos := verify_pos_in_world(new_pos);
    -- UPDATE VALUES OF THE TARGET
    UPDATE cinematica AS c
    SET
        velocidade = calcular_velocidade_atualizada(id_cinematica),
        g_posicao = new_pos
    WHERE c.id = id_cinematica;
END;
$$ LANGUAGE plpgsql;
