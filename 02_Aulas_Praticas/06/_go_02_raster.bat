"C:\Program Files\PostgreSQL\14\bin\raster2pgsql" -s 4236 -I -d -M .\raster_ilhaDasFlores_1.tif T_RASTER > out_raster.txt
type .\scripts\_script_CONNECT_INIT_BD.txt out_raster.txt > .\scripts\01_script_POVOAR_T_RASTER.txt
