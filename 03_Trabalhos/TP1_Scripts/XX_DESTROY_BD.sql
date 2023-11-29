--=============
-- Ligação à BD
--=============
\set dataBase my_gis_world
;
\set userName postgres
;
\connect :dataBase :userName
--==========================
DROP TABLE IF EXISTS objeto_terreno CASCADE;
DROP TABLE IF EXISTS objeto_movel;
DROP TABLE IF EXISTS cinematica CASCADE;
DROP VIEW IF EXISTS V_VMAX_AMAX_OBJETO;
DROP TABLE IF EXISTS tipo_objeto;
DROP VIEW IF EXISTS V_ROTA_CONTORNO;
DROP TABLE IF EXISTS TAUX_LINHA_CONTORNO;
DROP TABLE IF EXISTS rota;
DROP VIEW IF EXISTS V_POLIGONO;
DROP VIEW IF EXISTS V_LINHA_CONTORNO;



DROP TABLE IF EXISTS perseguicao CASCADE;
DROP TABLE IF EXISTS cinematica_hist CASCADE;


DROP FUNCTION IF EXISTS novo_posicao( geometry, t_velocidade, real );
DROP FUNCTION IF EXISTS novo_orientacao( real, t_velocidade, real );
DROP FUNCTION IF EXISTS novo_velocidade( t_velocidade, t_aceleracao, real );
DROP FUNCTION IF EXISTS novo_aceleracao_linear( geometry, geometry, real );
DROP FUNCTION IF EXISTS obter_aceleracao_perseguidor( int, int, real );
DROP FUNCTION IF EXISTS comparar_velocidade(t_velocidade, t_velocidade);

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

DROP FUNCTION IF EXISTS simular_trajetorias;
DROP FUNCTION IF EXISTS update_cinematica;

DROP TABLE IF EXISTS gps_ponto;
DROP TABLE IF EXISTS terreno;
DROP TABLE IF EXISTS tipo_terreno CASCADE;
