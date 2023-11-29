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

-------------------------------------------------------
-- Obter valores de 'cinematica' para uma 'perseguicao'
-------------------------------------------------------
DROP VIEW IF EXISTS v_novo_cinematica;
DROP FUNCTION IF EXISTS novo_aceleracao_linear( geometry, geometry, real );
DROP FUNCTION IF EXISTS obter_aceleracao_perseguidor( int, int, real );
DROP FUNCTION IF EXISTS comparar_velocidade(t_velocidade, t_velocidade)


--______________________________________________________________________________________________
-- Obter a nova aceleracao linear do objecto para realizar uma perseguicao
-- Formulacao:
-- aceleracao = normalizar( g_posicao_alvo - g_posicao_perseguidor ) * velocidade_a_perseguir
--______________________________________________________________________________________________
CREATE OR REPLACE FUNCTION novo_aceleracao_linear(
    g_posicao_perseguidor geometry,
    g_posicao_alvo geometry,
    velocidade_a_perseguir real
)
RETURNS t_vector
AS $$
DECLARE
    vector t_vector;
    aceleracao t_vector;
BEGIN
    vector := cast((ST_X($2) - ST_X($1), ST_Y($2) - ST_Y($1)) as t_vector) ;
    aceleracao := normalizar_PLPGSQL(vector) * velocidade_a_perseguir;

    RETURN aceleracao;
END
$$ LANGUAGE plpgsql;


--______________________________________________________________________________________________
-- Obter a nova aceleracao (linear e angular) do 'id_perseguidor' a perseguir 'id_alvo'
-- (invocar novo_aceleracao_linear e manter a aceleracao angular do 'id_alvo'
--______________________________________________________________________________________________
CREATE OR REPLACE FUNCTION obter_aceleracao_perseguidor( id_perseguidor int,
                                                         id_alvo int,
                                                         velocidade_a_perseguir real )
RETURNS t_aceleracao
AS $$
SELECT novo_aceleracao_linear( c_perseguidor.g_posicao, c_alvo.g_posicao, $3 ), (c_perseguidor.aceleracao).angular
FROM cinematica c_perseguidor, cinematica c_alvo
WHERE c_perseguidor.id = $1 and c_alvo.id = $2;
$$ LANGUAGE 'sql';

--______________________________________________________________________________________________
-- Comparar duas velocidades
--______________________________________________________________________________________________
CREATE OR REPLACE FUNCTION comparar_velocidade(v1 t_velocidade, v2 t_velocidade)
RETURNS t_velocidade
AS $$
DECLARE
    v_norm1 real;
    v_norm2 real;
    v_result t_velocidade;
BEGIN
    v_norm1 := power(power((v1.linear).x, 2) + power((v1.linear).y, 2) , 0.5);
    v_norm2 := power(power((v2.linear).x, 2) + power((v2.linear).y, 2) , 0.5);

    -- Compare the norms of the vectors
    IF v_norm1 < v_norm2 THEN
        -- Set v_result to v1 if v1 has a smaller norm
        v_result := v1;
    ELSE
        -- Set v_result to v2 if v2 has a smaller norm or equal norm
        v_result := v2;
    END IF;

    RETURN v_result;
END
$$ LANGUAGE plpgsql;

