-- Subqueries & CTE's exercises 
-- Exploring Microsoft ContosoRetailDW database


--Filtering DimProduct by Subcategory Televisions

SELECT * FROM DimProduct
WHERE ProductSubcategoryKey =
    (SELECT ProductSubcategoryKey FROM DimProductSubcategory
        WHERE ProductSubcategoryName = 'TELEVISIONS')



-- DimStore: display only stores with 100 or more employees

SELECT * FROM DimStore
WHERE STOREKEY IN (
    SELECT 
        STOREKEY 
    FROM 
        DimStore
    WHERE EmployeeCount >= 100
)


--Finding all products with Price > than ProductKey 1893 price

GO
SELECT
    ProductKey,
    ProductName,
    ProductDescription,
    UnitPrice,
    (SELECT 
        UNITPRICE 
    FROM 
        DimProduct
    WHERE ProductKey = 1893) AS 'ProductKey 1893 Price'
FROM 
    DimProduct
WHERE UnitPrice > (
    SELECT 
        UnitPrice
    FROM 
        DimProduct
    WHERE ProductKey = 1893
)
GO


--DimCustomer - Finding Clients with salaries above AVG
SELECT 
    CustomerKey,
    FirstName,
    LastName,
    EmailAddress,
    YearlyIncome
FROM 
    DimCustomer
WHERE YearlyIncome > (
    SELECT 
        AVG(YearlyIncome)
    FROM 
        DimCustomer
    WHERE CustomerType = 'PERSON'
) AND CustomerType = 'PERSON'


--DimCustomer - Finding customers that made a purchase using Promotion 'Asian Holiday Promotion'

SELECT  
    *
FROM 
    DimCustomer
WHERE CustomerKey IN (
    SELECT 
        CustomerKey
    FROM 
        FactOnlineSales
    WHERE PromotionKey IN (
        SELECT PromotionKey FROM DimPromotion
        WHERE PromotionName = 'ASIAN HOLIDAY PROMOTION'
    )
)

--Loyalty Program for wholesale: discount for clients that bought > 3000 of a single product

SELECT
    CustomerKey,
    CompanyName
FROM 
    DimCustomer
WHERE CustomerKey IN (
    SELECT 
        CustomerKey
    FROM  
        FactOnlineSales
    GROUP BY CustomerKey, ProductKey
    HAVING COUNT (*) > = 3000
)

--Info on products for Sale Department:

GO 
SELECT 
    ProductKey,
    ProductName,
    BrandName,
    UnitPrice,
    ROUND ((
        SELECT 
        AVG(UnitPrice)
        FROM 
        DimProduct
    ), 2) AS 'AVG_Price'
FROM 
    DimProduct
GROUP BY ProductKey, ProductName,UnitPrice, BrandName
GO


--Info on products: MIN,MAX,AVG pricing by brand

GO
SELECT 
    MAX(Quantity) AS 'MAX',
    MIN(Quantity) AS 'MIN',
    AVG(Quantity) AS 'AVG'
FROM (
    SELECT 
        BrandName,
        COUNT(*) AS 'Quantity'
    FROM DimProduct
    GROUP BY BrandName
) AS T --table name
GO



-- Exists
-- DimProduct: bring information of all products with sale on 01/01/07 date

SELECT 
    ProductKey,
    ProductName
FROM 
    DimProduct
WHERE EXISTS(
    SELECT DISTINCT
        ProductKey
    FROM 
        FactSales
    WHERE DATEKEY = '01/01/2007'
    AND FactSales.ProductKey = DimProduct.ProductKey
)

--Solution using ANY

SELECT 
    ProductKey,
    ProductName
FROM 
    DimProduct
WHERE PRODUCTKEY = ANY(
    SELECT DISTINCT
        ProductKey
    FROM 
        FactSales
    WHERE DATEKEY = '01/01/2007'
)

--DimProduct - Adding coluns to a table (bringing Count result)

SELECT 
    PRODUCTKEY,
    PRODUCTNAME,
    (SELECT 
        COUNT (ProductKey) 
    FROM 
        FactSales 
    WHERE FactSales.ProductKey = DimProducT.ProductKey
    )
FROM 
    DimProduct


--Nested Subqueries
--Find employyes with MAX Yearly Income 

SELECT  
    CustomerKey,
    FirstName,
    LastName,
    YearlyIncome
FROM 
    DimCustomer
WHERE YearlyIncome = (
    SELECT 
        MAX (YearlyIncome)
    FROM 
        DimCustomer
    WHERE CustomerType = 'PERSON'
)

--Finding the second highest Yearly Income


SELECT  
    CustomerKey,
    FirstName,
    LastName,
    YearlyIncome
FROM 
    DimCustomer
WHERE YearlyIncome = (
    SELECT 
        MAX (YearlyIncome)
    FROM 
        DimCustomer
    WHERE YearlyIncome < (
        SELECT 
            MAX (YearlyIncome)
        FROM 
            DimCustomer
        WHERE CustomerType = 'PERSON'
    )
)

--Bringing all salaries below MAX salary


SELECT  
    CustomerKey,
    FirstName,
    LastName,
    YearlyIncome
FROM 
    DimCustomer
WHERE YearlyIncome < (
    SELECT 
        MAX (YearlyIncome)
    FROM 
        DimCustomer
    WHERE CustomerType = 'PERSON'
)


--CTE's

WITH CONSULTActe AS (
    SELECT 
        ProductKey,
        ProductName,
        BrandName,
        ColorName,
        UnitPrice
    FROM 
        DimProduct
    WHERE BrandName = 'CONTOSO'
)

SELECT COUNT(*) FROM CONSULTActe

--Nested CTE's

GO
WITH CONTOSO_PRODUCTS AS (
    SELECT 
    ProductKey,
    ProductName,
    BrandName
    FROM 
        DimProduct
    WHERE 
        BrandName = 'CONTOSO'
), 
TOP100_SALES AS (
    SELECT TOP (100)
        SalesKey,
        ProductKey,
        DateKey,
        SalesQuantity
    FROM 
        FactSales
    ORDER BY DateKey DESC 
)

SELECT * FROM TOP100_SALES
INNER JOIN CONTOSO_PRODUCTS
    ON TOP100_SALES.PRODUCTKEY = CONTOSO_PRODUCTS.PRODUCTKEY

GO

--DimProduct and DimproductSubcategory
--Produtcts from brand Adventure Works by Subcategory in Televisions and Monitors

GO
WITH CTE_AdventureWorksProducts AS (
    SELECT 
        ProductKey AS 'ID PRODUTO',
        ProductName AS 'NOME PRODUTO',
        ProductSubcategoryKey,
        BrandName AS 'MARCA',
        UnitPrice AS 'PRECO'
    FROM 
        DimProduct
    WHERE BrandName = 'ADVENTURE WORKS'
),
CTE_TelevisionRadioCategory AS (
    SELECT 
        ProductSubcategoryKey,
        ProductSubcategoryName AS 'Subcategory'
    FROM 
        DimProductSubcategory
    WHERE ProductSubcategoryName IN ('TELEVISIONS', 'MONITORS')
)
SELECT * FROM CTE_AdventureWorksProducts
    INNER JOIN CTE_TelevisionRadioCategory
        ON CTE_AdventureWorksProducts.ProductSubcategoryKey = CTE_TelevisionRadioCategory.ProductSubcategoryKey
    GO





