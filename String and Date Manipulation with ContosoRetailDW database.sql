-- String and Dates Manipulation exercises 
-- Replace, Substring, Charindex, Left, Datename, Datediff
-- Exploring Microsoft ContosoRetailDW database


--REPLACE


SELECT * FROM DimCustomer

SELECT 
    FIRSTNAME,
    LASTNAME,
    GENDER,
    REPLACE(GENDER, 'M', 'Male')
FROM
    DimCustomer

--Replacing gender M and F:

SELECT 
    FIRSTNAME,
    LASTNAME,
    GENDER,
    REPLACE(REPLACE(GENDER, 'M', 'Male'), 'F', 'Female')
FROM
    DimCustomer


-- CHARINDEX And SUBSTRING with variables  

DECLARE @VARNAME VARCHAR(100)
SET @VARNAME = 'BERNARDO CAVALCANTI'

SELECT SUBSTRING(@VARNAME, CHARINDEX(' ', @VARNAME) +1, 100) AS 'Last Name'


-- Retrieve first part of email address and day of year that employee was born to build a login and password for IT department 

SELECT  
    FIRSTNAME,
    LASTNAME,
    EMAILADDRESS,
    BirthDate
FROM DimEmployee


SELECT
    FIRSTNAME + ' ' + LASTNAME AS 'Full_Name',
    EMAILADDRESS AS 'Email',
    LEFT(EmailAddress, CHARINDEX('@', EMAILADDRESS) -1) AS 'Email_ID',
    UPPER (FirstName + DATENAME(DAYOFYEAR, BirthDate)) AS 'Email_Password'
FROM
    DimEmployee


-- DimEmployee - Employees info for HR

SELECT
    FIRSTNAME AS 'Name',
    EMAILADDRESS AS 'Email',
    HIREDATE AS 'Hire_Date',
    DAY(HireDate) AS 'Day',
    DATENAME(MONTH, HireDate) AS 'Month',
    YEAR(HireDate) AS 'Year'
FROM DimEmployee


-- DimStore: Store in activity for longer period of time

SELECT
    STORENAME AS 'Store',
    OPENDATE AS 'Open_Date',
    DATEDIFF(DAY, OpenDate, GETDATE()) AS 'Days_In_Activity'
FROM
    DimStore
WHERE STATUS = 'ON'
ORDER BY [Days_In_Activity] DESC


