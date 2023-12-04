--_____________________________________
-- Variaveis na ferramenta psql
-- Afectar varivel foo com valor foo_value
-- \set foo foo_value
-- Obter valor da variavel foo
-- \echo :foo
--_____________________________________

-------------------
-- Dados da Conexao
-------------------
\set userName postgres
\set hostName localhost
\set portNumber 5432



-------------
-- Nome da BD
-------------
\set dataBase my_gis_world
;


--_____________________________________
-- Remover a BD
-- DROP DATABASE [ IF EXISTS ] name
-- (cf. postgresql-9.3-A4.pdf)
--_____________________________________
\echo
\echo "Remover Base de Dados" :dataBase
;
DROP DATABASE IF EXISTS my_gis_world
;


--_____________________________________
-- Criar a BD
-- CREATE DATABASE name [ TEMPLATE [=] template ]
-- (cf. postgresql-9.4-A4.pdf)
--_____________________________________
\echo
\echo "Criar Base de Dados" :dataBase
;
CREATE DATABASE :dataBase
;


\echo
\echo "Estabelecer Conexao com a Base de Dados" :dataBase
;
\c :dataBase :userName :hostName :portNumber
;


\echo
\echo "Aplicar o Extensor "postgis" � Base de Dados" :dataBase
;
CREATE EXTENSION postgis;
;
