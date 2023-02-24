-- Conditions exercises 
-- Case, Case When, Case And, Nested Case, IIF, Nested IIF
-- Exploring Microsoft ContosoRetailDW database


--Case When

DECLARE @VARPRICE FLOAT
SET @VARPRICE = 50000

SELECT
    CASE 
        WHEN @VARPRICE >= 40000 THEN 'LUXE'
        WHEN @VARPRICE >=10000 THEN 'ECONOMIC'
        ELSE 'BASIC'
    END

-- Case When:

SELECT
    CUSTOMERKEY,
    FIRSTNAME,
    GENDER,
    CASE
        WHEN GENDER = 'M' THEN 'Male'
        WHEN GENDER ='F' THEN 'Femele'
        ELSE 'Company'
    END
FROM
    DimCustomer


-- Case And:

SELECT  
    PRODUCTNAME,
    BRANDNAME,
    COLORNAME,
    UNITPRICE,
    CASE
        WHEN BRANDNAME = 'CONTOSO' AND COLORNAME = 'RED' THEN (UNITPRICE * 1 - 0.1) -- -10% Off
        ELSE 0
    END AS 'Price_With_Discount'
FROM
    DimProduct

-- Case Or:

SELECT  
    PRODUCTNAME,
    BRANDNAME,
    COLORNAME,
    UNITPRICE,
    CASE
        WHEN BRANDNAME = 'LITWARE' OR BrandName = 'FABRIAKAM' THEN (UNITPRICE * 0.5)--50% Off
        ELSE 0
    END AS 'Price_With_Discount'
FROM
    DimProduct

-- Nested Case: Calculating bonus

SELECT 
    FIRSTNAME,
    LASTNAME,
    TITLE,
    SALARIEDFLAG,
    CASE
        WHEN TITLE = 'SALES GROUP MANAGER' THEN
        CASE
            WHEN SALARIEDFLAG = 1 THEN 0.3 -- 30% bonus
            ELSE 0.2 -- 20% bonus
        END 
        WHEN TITLE = 'SALES REGION MANAGER' THEN 0.15 -- 15% bonus
        WHEN TITLE = 'SALES STATE MANAGER' THEN 0.07 -- 7% bonus
        ELSE 0.02 -- 2% bonus
    END AS 'BONUS'
FROM 
    DimEmployee


-- DimProduct: Additive Case 

SELECT
    PRODUCTKEY,
    PRODUCTNAME,
    PRODUCTCATEGORYNAME,
    PRODUCTSUBCATEGORYNAME,
    UNITPRICE,
    CASE
        WHEN PRODUCTCATEGORYNAME = 'TV AND VIDEO' THEN 0.10 
        ELSE 0
    END 
    +CASE 
        WHEN PRODUCTSUBCATEGORYNAME = 'TELEVISIONS' THEN 0.05
        ELSE 0
    END 
FROM 
    DimProduct dp
INNER JOIN DimProductSubcategory dpsc
    ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
    INNER JOIN DimProductCategory
        ON dpsc.ProductCategoryKey = DimProductCategory.ProductCategoryKey


-- IIF Function:

--A)

DECLARE @VARCLASSIFICACAO INT
SET @VARCLASSIFICACAO = 9

SELECT
    IIF(
        @VARCLASSIFICACAO >= 5,
        'High_Risk',
        'Low_Risk'
    )


--B) IIF: Adding a column with Customer/Company Name

SELECT
    CUSTOMERKEY,
    CUSTOMERTYPE,
    IIF(
        CUSTOMERTYPE = 'PERSON',
        FIRSTNAME,
        COMPANYNAME 
    )
    FROM
        DimCustomer

--C) Nested IIF: assigning stock levels to employees

SELECT * FROM DimProduct

SELECT
    PRODUCTKEY,
    PRODUCTNAME,
    STOCKTYPENAME,
    IIF(
        STOCKTYPENAME = 'HIGH',
        'Jhon',
        IIF(
            STOCKTYPENAME = 'MID',
            'MARIA',
            'LUIS'--ELSE
        ) 
    )AS 'Responsible'
FROM
    DimProduct



--DimProdict - Discount according to product's class: a column with discount value and another column with discount applied to UnitPrice

SELECT * FROM DimProduct

SELECT
    ProductKey,
    ProductName,
    CLASSNAME,
    UNITPRICE,
    CASE 
        WHEN ClassName = 'DELUXE' THEN 0.09
        WHEN ClassName = 'REGULAR' THEN 0.07
        ELSE 0.05
    END AS 'Discount',
    CASE 
        WHEN ClassName = 'DELUXE' THEN UNITPRICE * (1 - 0.09)
        WHEN ClassName = 'REGULAR' THEN UNITPRICE *  (1- 0.07)
        ELSE UNITPRICE * (1 - 0.05)
    END AS 'Discount_Applied'
FROM 
    DimProduct

-- Resolution previous exercise but using variables


DECLARE @VARDELUXE FLOAT = 0.09 , @VARREGULAR FLOAT = 0.07, @VARECONOMY FLOAT = 0.05

SELECT
    ProductKey AS 'Product_ID',
    ProductName AS 'Product_Name',
    CLASSNAME AS 'Class',
    UNITPRICE AS 'Price',
    CASE 
        WHEN ClassName = 'DELUXE' THEN @VARDELUXE
        WHEN ClassName = 'REGULAR' THEN @VARREGULAR
        ELSE @VARECONOMY
    END AS 'Discount',
    CASE 
        WHEN ClassName = 'DELUXE' THEN UNITPRICE * (1 - @VARDELUXE)
        WHEN ClassName = 'REGULAR' THEN UNITPRICE *  (1- @VARREGULAR)
        ELSE UNITPRICE * (1 - @VARECONOMY)
    END AS 'Dicount_Price'
FROM 
    DimProduct


--Iventory study:

SELECT * FROM DimProduct

SELECT TOP(10) * FROM DimProductCategory

SELECT 
    BRANDNAME AS 'Brand',
    COUNT(BrandName) AS 'Products_By_Brand',
    CASE 
        WHEN COUNT(BrandName) >= 500 THEN 'CATEGORY A'
        WHEN COUNT(BrandName) BETWEEN 100 AND 500 THEN 'CATEGORY B'
        ELSE 'CATEGORY C'
    END AS 'CATEGORIES'
FROM 
    DimProduct
GROUP BY BrandName


--DimStore: Breaking stores by employee count

SELECT * FROM DimStore

SELECT 
    StoreName, 
    EmployeeCount,
    CASE 
        WHEN EMPLOYEECOUNT >= 50 THEN '50_Or_More'
        WHEN EMPLOYEECOUNT >= 40 THEN 'Between 40 And 50'
        WHEN EMPLOYEECOUNT >= 30 THEN 'Between 30 And 40'
        WHEN EMPLOYEECOUNT >= 20 THEN 'Between 20 And 30'
        WHEN EMPLOYEECOUNT >= 10 THEN 'Between 10 And 20'
        ELSE 'Less Than 10'
    END AS 'Employee_Count'
FROM 
    DimStore


--Operations: Calculating routes
--Choosing better route to transport packs of 100 products based on their weight
--Route 1: less than 1000kgs
--Route 2: 1000kgs or more 


SELECT
    ProductSubcategoryNAME AS 'Subcategory',
    ROUND(AVG(Weight) * 100, 2) AS 'AVG_Weight', -- 100 UNITS
     CASE 
        WHEN ROUND(AVG(Weight) * 100, 2) >= 1000 THEN 'ROUTE 2'
        ELSE 'ROUTE 1'
    END AS 'ROUTES'
FROM 
    DimProduct
INNER JOIN DimProductSubcategory 
    ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
WHERE Weight IS NOT NULL
GROUP BY ProductSubcategoryName
ORDER BY [AVG_Weight] DESC


--DimStore: Store in activity for longer period of time

SELECT  
    StoreName,
    OpenDate,
    CloseDate,
    CASE 
        WHEN CloseDate IS NULL THEN DATEDIFF(DAY, OpenDate, GETDATE())
        ELSE DATEDIFF(DAY, OpenDate, CloseDate)
        END AS 'Days_IN_Activity'
FROM 
    DimStore
ORDER BY [Days_IN_Activity] DESC 