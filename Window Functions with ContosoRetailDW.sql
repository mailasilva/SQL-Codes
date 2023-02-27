-- Window Functions exercises 
-- Sum, Count, AVG, Max, Min
-- Row_Number, Rank, Dense_Rank, NTile
-- Partition By
-- Rolling SUM,AVG
-- Offset functions
-- LAG, LEAD
-- NULLIF
-- MoM calculations
-- First_Value, Last_Value
-- Exploring Microsoft ContosoRetailDW database


-- Agregate Functions COUNT, SUM, AVG, MIN, MAX
--Using DimStore, DimGeography, FactSales, DimProduct tables

--Dimproduct table: View - counting total products sold by brand and color and total sales amount
GO
CREATE VIEW vwProducts AS(
SELECT 
    BrandName,
    ColorName,
    COUNT(*) AS 'Sale_Qty',
    ROUND(SUM(SALESAMOUNT), 2) AS 'Sales_Amount'
FROM
    DimProduct
INNER JOIN FactSales
    ON DimProduct.ProductKey = FactSales.ProductKey
GROUP BY BrandName, ColorName
)
GO

--Total units sold 

SELECT
    BrandName,
    ColorName,
    Sale_Qty,
    Sales_Amount,
    SUM(Sale_Qty) OVER () AS 'TTL_Units_Sold'
FROM 
    vwProducts
ORDER BY BrandName


-- Total units sold by brand

 SELECT
    BrandName,
    ColorName,
    Sale_Qty,
    Sales_Amount,
    SUM(Sale_Qty) OVER (PARTITION BY BrandName) AS 'Qty_Sold_By_Brand'
FROM 
    vwProducts
ORDER BY BrandName


--Products participation in company's TTL revenue

 SELECT
    DISTINCT BrandName,
    SUM([Sale_Qty]) OVER () AS 'TTL_Qty_Sold',
    SUM([Sale_Qty]) OVER (PARTITION BY BRANDNAME) AS 'TTL_Qty_Sold__By_Brand',
    FORMAT(CAST(SUM([Sale_Qty]) OVER (PARTITION BY BRANDNAME) AS DECIMAL)/CAST(SUM([Sale_Qty]) OVER () AS DECIMAL),'0.00%') AS 'Perc_Qty_By_Brand',
    SUM([Sales_Amount]) OVER() AS 'Sales_Amount',
    SUM([Sales_Amount]) OVER(PARTITION BY BRANDNAME) AS 'Sales_Amount_By_Brand',
    FORMAT(SUM([Sales_Amount]) OVER(PARTITION BY BRANDNAME)/SUM([Sales_Amount]) OVER(), '0.00%') AS 'Perc_Sales_By_Brand'
FROM 
    vwProducts


--Ranking Contoso products sold by color

SELECT 
    BrandName,
    ColorName,
    [Sale_Qty],
    RANK() OVER(ORDER BY [Sale_Qty] DESC) as 'Ranking'
FROM 
     vwProducts
WHERE BrandName = 'CONTOSO'


--Stores Activity Info
--Creating view
GO
CREATE VIEW vwStoresInfo AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY CalendarMonth) AS 'ID',
    CalendarYear AS 'Year',
    CalendarMonthLabel AS 'Month',
    COUNT(ds.OpenDate) 'Stores'
FROM DimDate dd
LEFT JOIN DimStore ds
    ON dd.Datekey = ds.OpenDate
GROUP BY CalendarYear, CalendarMonthLabel,CalendarMonth

GO

--Rolling SUM for stores opened (ordered by Year/Month)

SELECT 
    ID,
    YEAR,
    Month,
    Stores,
    SUM(Stores) OVER(ORDER BY ID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS 'Stores_Open_Month'
FROM 
    vwStoresInfo 


--Rolling SUM for stores opened ordered by year (Unbounded Preceding)

SELECT 
    ID,
    YEAR,
    [Month],
    Stores,
    SUM(Stores) OVER (ORDER BY YEAR ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 'Stores_Open_Year'
FROM 
    vwStoresInfo

--Rolling SUM for every 12 months

SELECT 
    ID,
    YEAR,
    [Month],
    Stores,
    SUM(Stores) OVER (PARTITION by YEAR ORDER BY ID ROWS BETWEEN 12 PRECEDING AND CURRENT ROW) 'Stores_Open_Year'
FROM 
    vwStoresInfo

--Online store: Customers increase YoY:
--Alter View name in Azure Data Studio: EXEC sp_rename 'vwClients','vwClientsYoY';

GO
CREATE VIEW vwClientsYoY AS(
SELECT DISTINCT
    YEAR(DateFirstPurchase) AS 'YEAR',
    COUNT(*) OVER (PARTITION BY YEAR(DateFirstPurchase)) AS 'Clients_By_Year',
    COUNT(*) OVER () as 'TTL_Clients'
FROM 
    DimCustomer
WHERE CustomerType = 'Person'
)
GO


SELECT  
    [YEAR],
    Clients_By_Year,
    FORMAT((1.0 * Clients_By_Year/LAG(Clients_By_Year,1) OVER (ORDER BY [YEAR])) -1, '0.00%') AS 'Perc_Increase'
FROM 
    vwClientsYoY


--New Clients MoM
GO
CREATE VIEW vwClientsMoM AS (
SELECT 
    YEAR(DateFirstPurchase) AS 'Year',
    MONTH(DateFirstPurchase) AS 'Month',
    CASE 
        WHEN MONTH(DateFirstPurchase) = 1 THEN 'January'
        WHEN MONTH(DateFirstPurchase) = 2 THEN 'February'
        WHEN MONTH(DateFirstPurchase) = 3 THEN 'March'
        WHEN MONTH(DateFirstPurchase) = 4 THEN 'April'
        WHEN MONTH(DateFirstPurchase) = 5 THEN 'May'
        WHEN MONTH(DateFirstPurchase) = 6 THEN 'June'
        WHEN MONTH(DateFirstPurchase) = 7 THEN 'July'
        WHEN MONTH(DateFirstPurchase) = 8 THEN 'August'
        WHEN MONTH(DateFirstPurchase) = 9 THEN 'September'
        WHEN MONTH(DateFirstPurchase) = 10 THEN 'October'
        WHEN MONTH(DateFirstPurchase) = 11 THEN 'November'
        WHEN MONTH(DateFirstPurchase) = 12 THEN 'December'
    END AS 'Month_Name',
    COUNT(*) AS 'New_Clients'
FROM 
    DimCustomer
WHERE CustomerType = 'Person'
GROUP BY YEAR(DateFirstPurchase), Month(DateFirstPurchase)
)
GO

SELECT 
    [Year],
    Month_Name,
    New_Clients,
    FORMAT((1.0* New_Clients/LAG(New_Clients,1) OVER (ORDER BY [Year],[Month])-1), '0.00%') AS 'Clients_Increase_MoM'
FROM 
    vwClientsMoM 
ORDER BY [Year],[Month]




--Stores opened by year

SELECT DISTINCT
    YEAR,
    SUM(Stores) OVER (PARTITION BY YEAR)
FROM 
    vwStoresInfo


--SUM (TTL) Sales Amount for all physical stores in 2007


SELECT DISTINCT
    ds.StoreKey,
    StoreName,
    Status,
    ROUND(SUM(SalesAmount) OVER (),2) AS 'Total_Sales_2007'
FROM    
    DimStore ds
INNER JOIN FactSales fs
    ON ds.StoreKey = fs.StoreKey
WHERE YEAR(DATEKEY) = 2007 AND StoreType = 'Store' 
ORDER BY [Total_Sales_2007] DESC


--SUM + Partition BY: Sales Amount by physical stores in 2007 

SELECT DISTINCT
    ds.StoreKey,
    StoreName,
    Status,
    ROUND(SUM(SalesAmount) OVER (),2) AS 'TTL_Revenue_2007', --TTL Sales in 2077
    ROUND(SUM(SalesAmount) OVER (PARTITION BY STORENAME),2) AS 'TTL_Revenue_Store' -- TTL Sales by store in 2007
FROM    
    DimStore ds
INNER JOIN FactSales fs
    ON ds.StoreKey = fs.StoreKey
WHERE YEAR(DATEKEY) = 2007 AND StoreType = 'Store' 
ORDER BY [TTL_Revenue_Store] DESC


--Percentage to total (by store)

--Creating view to better manipulate results
GO
CREATE VIEW vw_Stores_Sales_2007 AS(
SELECT DISTINCT
    ds.StoreKey,
    StoreName,
    Status,
    ROUND(SUM(SalesAmount) OVER (PARTITION BY Storename),2) AS 'TTL_Revenue_Store',
    ROUND(SUM(SalesAmount) OVER (),2) AS 'TTL_Revenue_2007'
FROM    
    DimStore ds
INNER JOIN FactSales fs
    ON ds.StoreKey = fs.StoreKey
WHERE YEAR(DateKey) = 2007 AND StoreType = 'Store' 
)
GO


--Participation: TTL revenue for all stores / TTL Revenue by store
GO
SELECT
    StoreKey,
    StoreName,
    [Status],
    TTL_REVENUE_STORE,
    TTL_REVENUE_2007,
    FORMAT((TTL_REVENUE_STORE/TTL_REVENUE_2007), '0.000%') AS 'Perc_TTL_Revenue'
FROM 
    vw_Stores_Sales_2007
ORDER BY Perc_TTL_Revenue DESC
GO


--Counting stores in activity by country

SELECT * FROM DimGeography --RegionCountryName
SELECT * FROM DimStore --GeographyKey


GO
SELECT
    StoreKey,
    StoreName,
    RegionCountryName,
    COUNT(*) OVER(PARTITION BY RegionCountryName) AS 'TTL_Stores_Country',
    COUNT(*) OVER() as 'TTL_Stores'
FROM
    DimStore DS
    INNER JOIN DimGeography DG
        ON DS.GeographyKey = DG.GeographyKey
WHERE [Status] = 'On'
ORDER BY TTL_Stores_Country


--Percentage of stores in activity by country

GO
SELECT
    StoreKey,
    StoreName,
    RegionCountryName,
    COUNT(*) OVER(PARTITION BY RegionCountryName) AS 'TTL_Stores_Country',
    COUNT(*) OVER() as 'TTL_Stores',
    FORMAT(CAST(COUNT(*) OVER(PARTITION BY RegionCountryName) AS DECIMAL (10,2))/ CAST(COUNT(*) OVER() AS DECIMAL (10,2)), '0.00%') AS 'PERC_STORES_COUNTRY'
FROM
    DimStore DS
    INNER JOIN DimGeography DG
        ON DS.GeographyKey = DG.GeographyKey
WHERE [Status] = 'On'
ORDER BY TTL_Stores_Country



