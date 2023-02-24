-- Loops in SQL exercises 
-- While, Break, Continue
-- Exploring Microsoft ContosoRetailDW database

--Loop While: while < = 10 starting at 1
--A)
DECLARE @VARCONTADOR INT    
    SET @VARCONTADOR = 1

WHILE @VARCONTADOR < = 10
BEGIN 
    PRINT 'O VALOR DO CONTATDOR E: ' + CONVERT(VARCHAR, @VARCONTADOR)  
    SET @VARCONTADOR = @VARCONTADOR + 1
END

--B)
DECLARE @VALORINICIAL INT = 1
DECLARE @VALORFINAL INT = 100

WHILE @VALORINICIAL < = @VALORFINAL
BEGIN 
    PRINT 'O VALOR DO CONTADOR E: ' + CONVERT(VARCHAR, @VALORINICIAL)
    SET @VALORINICIAL +=1 

END


--Printing total employees hired each year from year 1996 to 2003

DECLARE @ANOINICIAL INT = 1996
DECLARE @ANOFINAL INT = 2003


WHILE @ANOINICIAL < = @ANOFINAL
BEGIN 
DECLARE @QDEFUNCIONARIOS INT = (
    SELECT 
        COUNT(*) 
    FROM 
        DimEmployee 
    WHERE YEAR(HireDate) = @ANOINICIAL) 
    PRINT
    CAST (@QDEFUNCIONARIOS AS VARCHAR(4)) + ' CONTRATACOES EM ' + CAST(@ANOINICIAL AS VARCHAR (4)) 
    SET @ANOINICIAL +=1  
END


--Another solution:
GO
DECLARE @ANOINICIAL INT = (SELECT YEAR(MIN(HIREDATE)) FROM DimEmployee)
DECLARE @ANOFINAL INT = (SELECT YEAR(MAX(HireDate)) FROM DimEmployee)
DECLARE @QDECONTRATACOES INT = (SELECT COUNT (*) FROM DimEmployee WHERE YEAR(HireDate) = @ANOINICIAL)

WHILE @ANOINICIAL < = @ANOFINAL
BEGIN
PRINT CONVERT(VARCHAR, @QDECONTRATACOES) + ' CONTRATACOES EM ' + CONVERT(VARCHAR, @ANOINICIAL)
SET @ANOINICIAL += 1 
SET @QDECONTRATACOES = (SELECT COUNT (*) FROM DimEmployee WHERE YEAR(HireDate) = @ANOINICIAL)
END  


--Another Solution:
GO
DECLARE @ANO INT = (SELECT MIN(YEAR(HIREDATE)) FROM DimEmployee)

WHILE @ANO < = (SELECT MAX(YEAR(HIREDATE)) FROM DIMEMPLOYEE)
BEGIN
    DECLARE @QUANTIDADE INT = (SELECT COUNT(*) FROM DimEmployee WHERE YEAR(HireDate) = @ANO)
PRINT CONVERT(VARCHAR, @QUANTIDADE) + ' CONTRATACOES EM: ' + CONVERT(VARCHAR, @ANO)
SET @ANO += 1
END 


--While and Break: Print from 1 to 100, if variable = 15, stop printing

DECLARE @VARCONTADOR INT
SET @VARCONTADOR = 1

WHILE @VARCONTADOR <= 100
BEGIN  
    PRINT 'O VALOR DO CONTADOR E: ' + CONVERT(VARCHAR, @VARCONTADOR)
    IF @VARCONTADOR = 15
    BREAK
    SET @VARCONTADOR = @VARCONTADOR +1
END

--Creating a Calendar from 01/01/2021 to 31/12/2021

GO
CREATE TABLE CALENDARIO (DATA DATE)

DECLARE @DATAINICIAL DATE = '2021/01/01'
DECLARE @DATAFINAL DATE = '2021/12/31'

WHILE @DATAINICIAL < = @DATAFINAL
BEGIN 
    INSERT INTO CALENDARIO (DATA) VALUES (@DATAINICIAL)
    SET @DATAINICIAL = DATEADD(DAY, 1, @DATAINICIAL)

END 

--While and Continue: Print from 1 to 10 skipping 3 and 6 

DECLARE @VARCONTADOR INT
SET @VARCONTADOR = 0

WHILE @VARCONTADOR < 10
BEGIN 
    SET @VARCONTADOR += 1 
    IF @VARCONTADOR = 3 OR @VARCONTADOR = 6
    CONTINUE 
    PRINT 'The Value of the Variable is: ' + CONVERT(VARCHAR, @VARCONTADOR)
END 


