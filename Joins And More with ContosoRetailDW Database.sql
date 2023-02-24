-- Basic Join exercises 
-- Group By, Sum, Count, Min, MAX, AVG, Subqueries
-- Exploring Microsoft ContosoRetailDW database


--1)Retrieve Products Subcategories
SELECT * FROM DimProduct
SELECT * FROM DimProductSubcategory

SELECT
    dp.ProductKey AS 'Product_ID',
    dp.ProductName AS 'Product_Name',
    dp.ProductDescription AS 'Product_Detail',
    dpsc.ProductSubcategoryName AS 'Product_Subcategory'
FROM
    DimProduct dp
INNER JOIN DimProductSubcategory dpsc
    ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey

--2)Adding Subcategory ID and Subcategory Name columns to DimProduct

SELECT * FROM DimProductSubcategory
SELECT * FROM DimProductCategory

SELECT
    DimProductSubcategory.ProductSubcategoryKey AS 'Subcategory_ID',
    DimProductSubcategory.ProductSubcategoryNAME AS 'Subcategory_Name',
    DimProductCategory.ProductCategoryName AS 'Product_Category'
FROM 
    DimProductSubcategory
LEFT JOIN DimProductCategory
    ON DimProductSubcategory.ProductCategoryKey = DimProductCategory.ProductCategoryKey

--3)Retriving relevant DimStore information by Country and Continent
SELECT * FROM DimStore
SELECT * FROM DimGeography

SELECT 
    DimStore.StoreKey AS 'Store_ID',
    DimStore.StoreName AS 'Store_Name',
    DimStore.EmployeeCount AS 'Employee_Count',
    DimGeography.ContinentName AS 'Continent',
    DimGeography.RegionCountryName AS 'Country'
FROM 
    DimStore
LEFT JOIN DimGeography
    ON DimStore.GeographyKey = DimGeography.GeographyKey
ORDER BY [Employee_Count] DESC

--4) Adding SubcategoryDescription to DimProduct table
SELECT * FROM DimProduct
SELECT * FROM DimProductSubcategory
SELECT * FROM DimProductCategory

SELECT
    dp.ProductKey AS 'Product_ID',
    dp.ProductName AS 'Product_Name',
    dp.ProductDescription AS 'Product_Description',
    dpsc.ProductSubcategoryName AS 'Subcategory',
    dpc.ProductCategoryDescription AS 'Category'
FROM 
    DimProduct dp
LEFT JOIN DimProductSubcategory dpsc
    ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
        LEFT JOIN DimProductCategory dpc
            ON dpsc.PRODUCTCATEGORYKEY = dpc.PRODUCTCATEGORYKEY
    
--5) Exploring FactStrategyPlan table

SELECT TOP(1) * FROM FactStrategyPlan
SELECT TOP(1)* FROM DimAccount
SELECT TOP(1)* FROM DimScenario

SELECT 
    fsp.StrategyPlanKey AS 'Plan_ID',
    fsp.Datekey AS 'Date_ID',
    da.AccountName AS 'Account_Name',
    fsp.Amount AS 'Quantity'
FROM 
    FactStrategyPlan fsp
INNER JOIN DimAccount da
    ON fsp.AccountKey = da.AccountKey

--6) Exploring FactStrategyPlan and DimScneario
SELECT
    fsp.StrategyPlanKey,
    fsp.Datekey,
    ds.ScenarioName,
    fsp.Amount
FROM 
    FactStrategyPlan fsp
INNER JOIN DimScenario ds
    ON fsp.ScenarioKey = ds.ScenarioKey

--7) Identifying DimProduct Subcategory with no products
SELECT TOP(1) * FROM DimProduct
SELECT TOP(1) * FROM DimProductSubcategory

SELECT 
    DimProduct.ProductKey,
    DimProduct.ProductName,
    DimProduct.ProductDescription,
    DimProductSubcategory.ProductSubcategoryName
FROM 
    DimProduct
RIGHT JOIN DimProductSubcategory
    ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
WHERE ProductName IS NULL

--8) Brand x Sales Channel 
SELECT TOP(1) * FROM DimProduct
SELECT TOP(1) * FROM FactSales
SELECT TOP(1) * FROM DimChannel

SELECT  
    DISTINCT DimProduct.BrandName,
    DimChannel.ChannelName
FROM
    DimProduct
CROSS JOIN 
    DimChannel
WHERE BrandName IN ('CONTOSO', 'FABRIKAM', 'LITWARE')

--9)FactOnlineSales and DimPromotion: identifying sales with promotion 

SELECT TOP (1) * FROM FactOnlineSales
SELECT TOP (1) * FROM DimPromotion

SELECT 
    fos.OnlineSalesKey,
    fos.DateKey,
    dp.PromotionName,
    fos.SalesAmount
FROM
    FactOnlineSales fos
INNER JOIN DimPromotion dp
    ON fos.PromotionKey = dp.PromotionKey
WHERE NOT PromotionName ='NO DISCOUNT'
ORDER BY DATEKEY 

--10)FactSales x DimProduct x DimChannel Join

SELECT TOP(1) * FROM DimProduct
SELECT TOP(1) * FROM FactSales
SELECT TOP(1) * FROM DimChannel
SELECT TOP(1) * FROM DimStore

SELECT 
    fs.SalesKey,
    dc.ChannelName,
    DimStore.StoreName,
    dp.ProductName,
    fs.SalesAmount
FROM
    FactSales fs
INNER JOIN DimProduct dp
    ON dp.ProductKey = fs.ProductKey
        INNER JOIN DimChannel dc
            ON dc.ChannelKey = fs.channelKey
                INNER JOIN DimStore
                    ON DimStore.StoreKey = fs.StoreKey
ORDER BY SalesAmount DESC

--GROUP BY And JOIN for Total Sales by Year

SELECT TOP (5) * FROM FactSales
SELECT TOP (5) * FROM DimDate

SELECT 
    DimDate.CalendarYear,
    SUM(SALESQUANTITY)
FROM
    FactSales
INNER JOIN DimDate
    ON FactSales.DateKey = DimDate.Datekey
GROUP BY CalendarYear

-- January Sales using HAVING clause

SELECT 
    DimDate.CalendarYear,
    SUM(SALESQUANTITY)
FROM
    FactSales
INNER JOIN DimDate
    ON FactSales.DateKey = DimDate.Datekey
WHERE CalendarMonthLabel = 'JANUARY'
GROUP BY CalendarYear
HAVING SUM(SalesQuantity) > 1200000

--Sales Quantity by Channel

SELECT TOP(10) * FROM FactSales
SELECT TOP(10) * FROM DimDate
SELECT TOP(10) * FROM DimStore
SELECT TOP(10) * FROM DimChannel

SELECT
    DimChannel.ChannelKey AS 'Channel_ID',
    DimChannel.ChannelName AS 'Channel_Name',
    SUM(SALESQUANTITY) AS 'Sales_QTY'
FROM 
    DimChannel
INNER JOIN FactSales
    ON FactSales.channelKey = DimChannel.ChannelKey
GROUP BY DimChannel.ChannelKey, ChannelName
ORDER BY [Sales_QTY] DESC

--B)Total Sales Quantity and Returned Quantity by Store

SELECT
    DimStore.StoreName AS 'Store',
    SUM(SALESQUANTITY) AS 'Sales_Qty',
    SUM(RETURNQUANTITY) AS 'Returned_Qty'
FROM 
    DimStore
INNER JOIN FactSales
    ON FactSales.StoreKey = DimStore.StoreKey
GROUP BY StoreName

--C) Total sales by Month and Year

SELECT
    dd.CalendarYear AS 'Year',
    dd.CalendarMonthLabel AS 'Month',
    SUM(SalesAmount) AS 'Sales_Amount'
FROM 
    FACTSALES fs
INNER JOIN DimDate dd
    ON fs.DateKey = dd.Datekey
GROUP BY CalendarYear, CalendarMonthLabel, CalendarMonth
ORDER BY CalendarMonth


--2)Sales Analysis by Product: Total Sales Amount by Product
SELECT TOP(5) * FROM FactSales
SELECT TOP(5) * FROM DimProduct

SELECT
    DimProduct.ProductKey AS 'ID PRODUTO',
    DimProduct.ProductName AS 'NOME PRODUTO',
    SUM(FactSales.SalesAmount) AS 'TTL VENDIDO'
FROM
    DimProduct
LEFT JOIN FactSales
    ON FactSales.ProductKey = DimProduct.ProductKey
GROUP BY DIMPRODUCT.ProductKey, DimProduct.ProductName
ORDER BY [TTL VENDIDO] DESC

--A) Best Selling products by color
SELECT
    dp.ColorName AS 'Color',
    SUM (fs.SalesQuantity) AS 'Sales_Qty'
FROM    
    FactSales fs
INNER JOIN DimProduct dp
    ON fs.ProductKey = dp.ProductKey
GROUP BY ColorName
ORDER BY [Sales_Qty] DESC

--B)Which colors had over 3.000.000 sales
SELECT
    DimProduct.ColorName AS 'Color',
    SUM (FactSales.SalesQuantity) AS 'Sale_Qty'
FROM    
    FactSales 
INNER JOIN DimProduct
    ON FactSales.ProductKey = DimProduct.ProductKey
GROUP BY ColorName
HAVING SUM (FactSales.SalesQuantity) >= 3000000
ORDER BY [Sale_Qty] DESC


--3) Sales Quantity by Category
SELECT TOP (1) * FROM FactSales
SELECT TOP (1) * FROM DimProduct
SELECT TOP (1) * FROM DimProductSubcategory
SELECT TOP (1) * FROM DimProductCategory


SELECT
    dpc.ProductCategoryName AS 'Category_Name',
    SUM(fs.SalesQuantity) AS 'Sales_Qty'
FROM FactSales fs
    INNER JOIN DimProduct dp
        ON fs.ProductKey = dp.ProductKey
            INNER JOIN DimProductSubcategory dpsc
                ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
                    INNER JOIN DimProductCategory dpc
                        ON dpsc.ProductCategoryKey = dpc.ProductCategoryKey
GROUP BY dpc.ProductCategoryName
ORDER BY [Sales_Qty] DESC

--4)Finding customer with higher number of online purchases:

SELECT TOP(3) * FROM FactOnlineSales
/*SELECT TOP(3) * FROM DimProduct*/
SELECT TOP(3) * FROM DimCustomer

SELECT
    DimCustomer.CustomerKey AS 'Customer_ID',
    Concat (DimCustomer.FirstName,' ', DimCustomer.MiddleName,' ', DimCustomer.LastName) AS 'Name',
    SUM(FactOnlineSales.SalesQuantity) AS 'Sales_Qty'
FROM 
    FactOnlineSales
INNER JOIN 
    DIMCUSTOMER
ON FactOnlineSales.CustomerKey = DimCustomer.CustomerKey
WHERE NOT FIRSTNAME = 'NULL' --this garantees customer is not a company
GROUP BY DIMCUSTOMER.CustomerKey, FirstName, MiddleName, LastName
ORDER BY [Sales_Qty] DESC

--B) Top 10 purchased products (by Quantity) for customer ID 7665 using subquery 
SELECT TOP(10)
    dp.ProductKey AS 'Product_ID',
    dp.ProductName AS 'Product_Name',
    SUM(SalesQuantity) AS 'Purchased_Qty'
FROM 
    FactOnlineSales fos
INNER JOIN DimProduct dp
    ON fos.ProductKey = dp.ProductKey
WHERE CustomerKey = (
    SELECT TOP (1)
    dc.CustomerKey
FROM 
    FactOnlineSales fos
INNER JOIN 
    DIMCUSTOMER dc
ON fos.CustomerKey = dc.CustomerKey
WHERE NOT FIRSTNAME = 'NULL'
GROUP BY dc.CustomerKey, FirstName, MiddleName, LastName
ORDER BY SUM(fos.SalesQuantity) DESC
)
GROUP BY dp.ProductKey, ProductName
ORDER BY [Purchased_Qty] DESC



--5) Sales quantity by Customer Gender

SELECT 
    DimCustomer.Gender AS 'Gender',
    SUM(FactOnlineSales.SalesQuantity) AS 'Sales_Qty'
FROM 
    FactOnlineSales
INNER JOIN DimCustomer
    ON FactOnlineSales.CustomerKey = DimCustomer.CustomerKey
WHERE CustomerType ='Person'
GROUP BY Gender
ORDER BY [Sales_Qty] DESC 



--6) Averange of Exchange Rate beteween 10 and 100
SELECT TOP(5) * FROM DimCurrency
SELECT TOP(5) * FROM FactExchangeRate

SELECT 
    dc.CurrencyDescription AS 'Currency',
    AVG(fer.AverageRate) AS 'AVG_Rate'
FROM 
    FactExchangeRate fer
INNER JOIN DimCurrency dc
    ON fer.CurrencyKey = dc.CurrencyKey
GROUP BY CurrencyDescription
HAVING AVG(fer.AverageRate) BETWEEN 10 AND 100


--7) FactStrategyPlan: Finding total amount $$ destinated to Actual and Budget Scenarios
SELECT TOP (5) * FROM FactStrategyPlan
SELECT TOP(5) * FROM DimDate
SELECT TOP (5) * FROM DimScenario

SELECT 
    DimScenario.ScenarioName AS 'Scenario',
    SUM(FactStrategyPlan.Amount) AS 'Total_Amount'
FROM 
    FactStrategyPlan
INNER JOIN DimScenario
    ON FactStrategyPlan.ScenarioKey = DimScenario.ScenarioKey
WHERE ScenarioName IN ('ACTUAL', 'BUDGET')
GROUP BY ScenarioName
ORDER BY [Total_Amount] DESC

--8) Table bringing results for Strategy Plan by year

SELECT 
    DimDate.CalendarYear AS 'Year',
    ROUND(SUM(FactStrategyPlan.Amount),2) AS 'Amount'
FROM 
    FactStrategyPlan
INNER JOIN DimDate
    ON FactStrategyPlan.Datekey = DimDate.Datekey
GROUP BY CalendarYear
ORDER BY Amount DESC

--9) Product Quantity by Subcategory for brand Contoso and color silver
SELECT TOP(5) * FROM DimProduct
SELECT TOP(5) * FROM DimProductSubcategory

SELECT 
    DimProductSubcategory.ProductSubcategoryName AS 'Subcategory_Name',
    COUNT(*) AS 'Total_Products'
FROM 
    DimProduct
INNER JOIN DimProductSubcategory
    ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
WHERE BrandName = 'CONTOSO' AND ColorName = 'SILVER'
GROUP BY ProductSubcategoryName
ORDER BY [Total_Products] DESC 

--10) Grouping products by Brand and Subcategory
SELECT
    dp.BrandName AS 'Brand',
    dpsc.ProductSubcategoryName AS 'Subcategory_Name',
    COUNT(*) AS 'Qty_By_Subcategories'
FROM 
    DimProduct dp
INNER JOIN DimProductSubcategory dpsc
    ON dp.ProductSubcategoryKey = dpsc.ProductSubcategoryKey
GROUP BY BrandName, ProductSubcategoryName
ORDER BY Brand