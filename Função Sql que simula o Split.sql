--cria função para split 
CREATE FUNCTION dbo.fnSplit(
    @frase VARCHAR(max)
  , @delimitador VARCHAR(max) = ','
) RETURNS @result TABLE (item VARCHAR(8000)) 

BEGIN
DECLARE @parte VARCHAR(8000)
WHILE CHARINDEX(@delimitador,@frase,0) <> 0
BEGIN
SELECT
  @parte=RTRIM(LTRIM(
          SUBSTRING(@frase,1,
        CHARINDEX(@delimitador,@frase,0)-1))),
  @frase=RTRIM(LTRIM(SUBSTRING(@frase,
          CHARINDEX(@delimitador,@frase,0)
        + LEN(@delimitador), LEN(@frase))))
IF LEN(@parte) > 0
  INSERT INTO @result SELECT @parte
END 

IF LEN(@frase) > 0
INSERT INTO @result SELECT @frase
RETURN
END
GO


 SELECT * FROM dbo.fnSplit('separar, por espaço em branco', ',')
 ---------------------------
 --apenas com tabela temporaria
 SET NOCOUNT ON  

DECLARE @ARRAY VARCHAR(8000), @DELIMITADOR VARCHAR(100), @S VARCHAR(8000)  

SELECT @ARRAY = 'separar|por|espaço|em|branco'
SELECT @DELIMITADOR = '|'  

IF LEN(@ARRAY) > 0 SET @ARRAY = @ARRAY + @DELIMITADOR   
CREATE TABLE #ARRAY(ITEM_ARRAY VARCHAR(8000))  

WHILE LEN(@ARRAY) > 0  
BEGIN  
    SELECT @S = LTRIM(SUBSTRING(@ARRAY, 1, 
    CHARINDEX(@DELIMITADOR, @ARRAY) - 1))  
    INSERT INTO #ARRAY (ITEM_ARRAY) VALUES (@S)  
    SELECT @ARRAY = SUBSTRING(@ARRAY, 
    CHARINDEX(@DELIMITADOR, @ARRAY) + 1, LEN(@ARRAY))  
END  

-- MOSTRANDO O RESULTADO JÁ POPULADO NA TABELA TEMPORÁRIA  
SELECT * FROM #ARRAY  
DROP TABLE #ARRAY  
SET NOCOUNT OFF