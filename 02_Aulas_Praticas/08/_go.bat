@ECHO OFF
:: [PTS: AJUSTAR]


set psqlPath="D:\Eu\ISEL\MEIC\1_Semestre\CSI\PostgreSQL\bin"


:: Base de Dados e nome do utilizador
SET dataBase=postgres
SET userName=postgres

:: psql -h host -p port -d database -U user -f psqlFile
%psqlPath%\psql -h localhost -p 5432 -d %dataBase% -U %userName% -f %1



