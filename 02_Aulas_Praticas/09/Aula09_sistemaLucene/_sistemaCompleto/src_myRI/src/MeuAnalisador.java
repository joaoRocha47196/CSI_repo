/**
 * @author Paulo Trigo Silva (PTS)
 */



import java.io.Reader;
import java.io.File;
import java.io.FileReader;
import java.util.Set;

import org.apache.lucene.analysis.CharArraySet;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.core.LowerCaseFilter;
import org.apache.lucene.analysis.core.StopFilter;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.Tokenizer;
import org.apache.lucene.analysis.WordlistLoader;
import org.apache.lucene.analysis.standard.StandardFilter;
import org.apache.lucene.analysis.standard.StandardTokenizer;
import org.apache.lucene.util.Version;
import org.apache.lucene.analysis.miscellaneous.ASCIIFoldingFilter;


public class MeuAnalisador
extends Analyzer
{
   //PTS-2015 private final Version _VERSION = Version.LUCENE_46;
   private CharArraySet _conjunto_stopWords = null;

   
   public MeuAnalisador( String a_nomeFicheiro_stopWords )
   {
      super();      
      File ficheiro_stopWords = new File( a_nomeFicheiro_stopWords );
      
      if( ficheiro_stopWords.exists() && ( ! ficheiro_stopWords.isDirectory() ) )
      {
         try
         {
            //PTS-2015 _conjunto_stopWords = WordlistLoader.getWordSet( new FileReader( ficheiro_stopWords ), _VERSION );
            _conjunto_stopWords = WordlistLoader.getWordSet( new FileReader( ficheiro_stopWords ) );

            System.out.println( "MeuAnalisador:: ficheiro com stopWords carregado com sucesso" );
         }
         catch( Exception e )
         {
            System.out.println( "MeuAnalisador - erro a carregar ficheiro com stopWords" );
         }
      }      
   }


   // Método abstracto em "Analyzer"
   @Override
   //PTS-2015 protected TokenStreamComponents createComponents( String nomeDoCampo, Reader leitorIO )
   protected TokenStreamComponents createComponents( String nomeDoCampo )
   {
      //PTS-2015 Tokenizer fonte = new StandardTokenizer( _VERSION, leitorIO );
      Tokenizer fonte = new StandardTokenizer();
      TokenStream resultado = null;

      //resultado = new StandardFilter( fonte );
      // Máximo length = 1, ou seja, termos com menos de 2 caracteres são excluidos
      resultado = new LengthFilter(resultado, 0, 1);

      // Stemming lingua portuguesa
      resultado = PortugueseStemFilter(resultado);

      // para tratar caracteres acentuados usar o ASCIIFoldingFilter
      resultado = new ASCIIFoldingFilter( resultado );
      resultado = new LowerCaseFilter( resultado );
      resultado = new StopFilter( resultado, _conjunto_stopWords );

      return new TokenStreamComponents( fonte, resultado );
    }
}
