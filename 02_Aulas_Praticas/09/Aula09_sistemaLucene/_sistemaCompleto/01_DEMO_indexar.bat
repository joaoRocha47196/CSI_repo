::________________________
:: Paulo Trigo Silva (PTS)
::________________________



:: [PTS: AJUSTAR]
set lucenePath="D:\Eu\ISEL\MEIC\1_Semestre\CSI\CSI_repo\02_Aulas_Praticas\09\Aula09_sistemaLucene\_sistemaCompleto"


set dataPath=%lucenePath%\z_coleccao_demo

set core=%lucenePath%\lucene-core-7.1.0.jar
set demo=%lucenePath%\lucene-demo-7.1.0.jar
::set queryparser=%lucenePath%\lucene-queryparser-7.1.0.jar
::set analyzers=%lucenePath%\lucene-analyzers-common-7.1.0.jar

java -classpath %core%;%demo%;%analyzers%;%queryparser% org.apache.lucene.demo.IndexFiles -docs %dataPath%\z01_coleccao_paraIndexar -index %dataPath%\z02_coleccao_indexada
:: -update

:: ATENCAO - após executar o script serao criados na pasta "%dataPath%\z02_coleccao_indexada" os indices relativos 'a coleccao que esta' na pasta "%dataPath%\z01_coleccao_paraIndexar"
:: ATENÇÃO - note que a coleccao indexada contém, como documentos, o codigo fonte desta demo!
:: ATENÇÃO - estamos a executar um código DEMO muito elementar; o código mais sofisticado será posteriormente construido