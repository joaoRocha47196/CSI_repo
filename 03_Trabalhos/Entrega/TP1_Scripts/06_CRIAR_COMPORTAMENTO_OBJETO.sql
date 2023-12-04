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

----------------------------------------------------------
-- Obter valores de 'objeto' para um instante do tempo
----------------------------------------------------------
DROP FUNCTION IF EXISTS novo_posicao( geometry, t_velocidade, real );
DROP FUNCTION IF EXISTS novo_posicao_com_orientacao;
DROP FUNCTION IF EXISTS novo_orientacao( real, t_velocidade, real );
DROP FUNCTION IF EXISTS novo_velocidade( t_velocidade, t_aceleracao, real );
DROP FUNCTION IF EXISTS novo_posicao_com_orientacao( t_velocidade, t_aceleracao, real );

--____________________________________________________
-- Obter a nova posicao do objecto no instante 'tempo'
-- Formulacao:
-- return g_posicao + velocidade.linear * tempo
--____________________________________________________
CREATE OR REPLACE FUNCTION novo_posicao( g_posicao geometry, velocidade t_velocidade, tempo real )
RETURNS geometry
AS $$
SELECT 
ST_Translate( $1,
              (($2).linear * $3 ).x,
              (($2).linear * $3 ).y )
$$ LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION novo_posicao_com_orientacao(
    g_posicao geometry,
    velocidade t_velocidade,
    orientacao real,
    tempo real
)
RETURNS geometry AS $$
DECLARE
    novo_posicao_x real;
    novo_posicao_y real;
BEGIN
    -- Calcula as componentes x e y da velocidade linear com base na orientação
    novo_posicao_x := (velocidade.linear * TRUNC(cos(orientacao)::numeric, 2) * tempo).x;
    novo_posicao_y := (velocidade.linear * TRUNC(sin(orientacao)::numeric, 2) * tempo).y;

    -- Realiza a translação com as componentes calculadas da velocidade linear
    RETURN ST_Translate(
        $1,
        novo_posicao_x,
        novo_posicao_y
    );
END;
$$ LANGUAGE plpgsql;





--_______________________________________________________
-- Obter a nova orientacao do objecto no instante 'tempo'
-- Formulacao:
-- return orientacao + velocidade.angular * tempo
--_______________________________________________________
CREATE OR REPLACE FUNCTION novo_orientacao( orientacao real, velocidade t_velocidade, tempo real )
RETURNS real
AS $$
DECLARE
    new_orientacao real;
BEGIN
    new_orientacao := orientacao + velocidade.angular * tempo;

    RETURN new_orientacao; 
END
$$ LANGUAGE plpgsql;


--_______________________________________________________
-- Obter a nova velocidade do objecto no instante 'tempo'
-- Formulacao:
-- velocidade.linear + aceleracao.linear * tempo
-- velocidade.angular + aceleracao.angular * tempo
--_______________________________________________________
CREATE OR REPLACE FUNCTION novo_velocidade( velocidade t_velocidade, aceleracao t_aceleracao, tempo real )
RETURNS t_velocidade
AS $$
SELECT
    ($1).linear + ($2).linear * ($3),
    ($1).angular + ($2).angular * ($3)
$$ LANGUAGE 'sql';
