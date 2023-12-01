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

----------------------------------------------------
----------------------------------------------------
-- Estender o Modelo Relacional com Novas Estruturas
----------------------------------------------------
----------------------------------------------------
DROP TYPE IF EXISTS t_velocidade;
DROP TYPE IF EXISTS t_aceleracao;
DROP OPERATOR IF EXISTS *( t_vector, real );
DROP OPERATOR IF EXISTS *( real, t_vector );
DROP OPERATOR IF EXISTS +( t_vector, t_vector );
DROP FUNCTION IF EXISTS produto_vector_por_escalar( t_vector, real );
DROP FUNCTION IF EXISTS produto_vector_por_escalar_sql( t_vector, real );
DROP FUNCTION IF EXISTS produto_vector_por_escalar_PLGSQL(t_vector, real);
DROP FUNCTION IF EXISTS soma_vector_vector_PLPGSQL(t_vector, t_vector);
DROP FUNCTION IF EXISTS normalizar_PLPGSQL(t_vector);
DROP FUNCTION IF EXISTS soma_vector_vector( t_vector, t_vector );
DROP FUNCTION IF EXISTS normalizar( t_vector );
DROP TYPE IF EXISTS t_vector;


CREATE TYPE t_vector AS (
    x real,
    y real
);

CREATE TYPE t_velocidade AS (
    linear t_vector,
    angular real
);

CREATE TYPE t_aceleracao AS (
    linear t_vector,
    angular real
);


---------------------------------------------------
-- Estender o Modelo Relacional com Novas Funcoes
---------------------------------------------------


--____________________________________
-- Produto de um vector por um escalar
--____________________________________
CREATE OR REPLACE FUNCTION produto_vector_por_escalar_PLGSQL( vec t_vector, v real )
RETURNS t_vector
AS $$
DECLARE
    new_x real;
    new_y real;
BEGIN
    new_x := vec.x * v;
    new_y := vec.y * v;
    RETURN (new_x, new_y);
END;
$$ LANGUAGE plpgsql;

--______________________
-- Soma de dois vectores
--______________________
CREATE OR REPLACE FUNCTION soma_vector_vector_PLPGSQL( vec_a t_vector, vec_b t_vector )
RETURNS t_vector
AS $$
DECLARE
    new_x real;
    new_y real;
BEGIN
    new_x := vec_a.x + vec_b.x;
    new_y := vec_a.y + vec_b.y;
    RETURN (new_x, new_y);
END;
$$ LANGUAGE plpgsql;

--__________________
-- Normalizar vector
--__________________
-- normalizar: dividir cada componente pela norma
-- norma: raiz duadrada da soma dos quadrados de cada componente (x**2 e' x ao quadrado)
CREATE OR REPLACE FUNCTION normalizar_PLPGSQL( vec t_vector )
RETURNS t_vector
AS $$
DECLARE
    norma real;
    new_x real;
    new_y real;
BEGIN
    norma := power(power(vec.x, 2) + power(vec.y, 2) , 0.5);
    new_x := vec.x * power(norma, -1);
    new_y := vec.y * power(norma, -1);
    RETURN (new_x, new_y);
END;
$$ LANGUAGE plpgsql;

--______________________
-- Multiplicar velocidade por escalar
--______________________
CREATE OR REPLACE FUNCTION multiplicar_velocidade_por_escalar(v1 t_velocidade, escalar real)
RETURNS t_velocidade
AS $$
DECLARE
    v_result_linear t_vector;
    v_result t_velocidade;
BEGIN
    v_result_linear := (v1.linear) * escalar;
    v_result_linear.x := TRUNC(v_result_linear.x::numeric,  2);
    v_result_linear.y := TRUNC(v_result_linear.y::numeric, 2);
    v_result := ((v_result_linear), (v1.angular));

    RETURN v_result;
END
$$ LANGUAGE plpgsql;


---------------------------------------------------
-- Definição dos Operadores
---------------------------------------------------
CREATE OPERATOR * (
leftarg = t_vector,
rightarg = real,
procedure = produto_vector_por_escalar_PLGSQL,
commutator = *
);

CREATE OPERATOR * (
leftarg = t_velocidade,
rightarg = real,
procedure = multiplicar_velocidade_por_escalar,
commutator = *
);

CREATE OPERATOR + (
leftarg = t_vector,
rightarg = t_vector,
procedure = soma_vector_vector_PLPGSQL,
commutator = +
);


