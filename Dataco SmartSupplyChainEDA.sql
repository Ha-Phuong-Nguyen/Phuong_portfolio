-- Show DataCoSupplyChainDataSet & order by date
SELECT TOP 100 * FROM [dbo].[DataCoSupplyChainDataset]
ORDER BY [order date (DateOrders)]
--show the no meaning column 
--Calculate ErrorCustomer Email to remove CustomerEmail column
SELECT ErrorCustomerEmail*100.0/TotalCustomerId AS ErrorEmailRate  FROM 
(SELECT COUNT(DISTINCT( [Customer Id])) ErrorCustomerEmail FROM [dbo].[DataCoSupplyChainDataset] WHERE [Customer Email] LIKE '%XXXXX%') AS A 
CROSS JOIN 
(SELECT COUNT(DISTINCT([Customer Id])) TotalCustomerId FROM [dbo].[DataCoSupplyChainDataset] ) AS B 


--Calculate Error CustomerPassword to remove CustomerPassword column
SELECT ErrorCustomerPassword*100.0/TotalCustomerId AS ErrorPasswordRate  FROM 
(SELECT COUNT(DISTINCT( [Customer Id])) ErrorCustomerPassword FROM [dbo].[DataCoSupplyChainDataset] WHERE [Customer Password] LIKE '%XXXXX%') AS A 
CROSS JOIN 
(SELECT COUNT(DISTINCT([Customer Id])) TotalCustomerId FROM [dbo].[DataCoSupplyChainDataset] ) AS B



-- Build star data schema 
 --Create table factOrder
 DROP TABLE FactOrder
 CREATE TABLE FactOrder
 (
 RecordKey BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
 OrderKey BIGINT NOT NULL,
 OrderDate DATE NOT NULL,
 OrderDateKey varchar(12) NOT NULL,
 OrderProductQuantity INT NOT NULL,
 OrderStatus nvarchar(50) NOT NULL,
 ShipDate DATE NOT NULL,
 ShipDateKey nvarchar(12) NOT NULL,
 ProductKey INT NULL,
 ProductPrice DECIMAL(6,2) NULL,
 ProductDiscountRate DECIMAL(6,5) NULL,
 TotalProductDiscount DECIMAL(6,2) NULL,
 SalesAmount DECIMAL(6,2) NULL,
 Profit DECIMAL(6,2) NULL,
 ProfitRate DECIMAL(6,5) NULL,
 CustomerKey nvarchar(50) NOT NULL,
 DepartmentKey nvarchar(50) NOT NULL
 )


 INSERT INTO FactOrder --(OrderKey,OrderDate, OrderDateKey, OrderProductQuantity, ShipDate, ShipDateKey, ProductKey, ProductPrice,ProductDiscountRate, TotalProductDiscount,SalesAmount,Profit,ProfitRate, CustomerKey)
 SELECT DISTINCT [Order Id], CONVERT(nvarchar(50), [order date (DateOrders)],23), CONVERT(varchar(12),[order date (DateOrders)],112), [Order Item Quantity], [Order Status], CONVERT(nvarchar(50), [shipping date (DateOrders)],23) , CONVERT(varchar(12),[shipping date (DateOrders)],112), [Product Card Id], [Product Price], [Order Item Discount Rate], [Order Item Discount], Sales, [Benefit per order], [Order Item Profit Ratio], [Customer Id], [Department Id] FROM [dbo].[DataCoSupplyChainDataset]

--Create table DimProduct
DROP TABLE DimProduct
CREATE TABLE DimProduct
( 
Product_id INT NOT NULL,
ProductName nvarchar(50) NULL,
ProductPrice INT NULL,
ProductStatus nvarchar(30) NULL,
ProductCategoryid INT NULL
)

TRUNCATE TABLE DimProduct
INSERT INTO DimProduct
SELECT DISTINCT [Product Card Id], [Product Name], CONVERT(numeric, [Product Price]), [Product Status], [Product Category Id] FROM [dbo].[DataCoSupplyChainDataset]
ORDER BY [Product Card Id]

--Create table DimProductCategory
DROP TABLE DimProductCategory
CREATE TABLE DimProductCategory
(
CategoryKey INT NOT NULL PRIMARY KEY, 
CategoryName nvarchar(50) NULL, 
DepartmentKey INT NOT NULL,
DepartmentName nvarchar(50) NULL
)

INSERT INTO DimProductCategory
SELECT DISTINCT CONVERT(INT,[Category Id]), [Category Name], [Department Id], [Department Name] FROM [dbo].[DataCoSupplyChainDataset]

--SELECT * FROM [dbo].[DimProduct] A
--INNER JOIN [dbo].[DimProductCategory] B ON A.ProductCategoryid=B.CategoryId

SELECT * FROM DimDepartment
ORDER BY DepartmentKey

SELECT DISTINCT [Department Id], [Department Name], [Category Id], [Category Name], [Product Card Id],  [Product Name] FROM [dbo].[DataCoSupplyChainDataset]
 ORDER BY [Product Card Id]
--Create table DimCustomer
DROP TABLE DimCustomer
CREATE TABLE DimCustomer
(
CustomerID nvarchar(50) NOT NULL PRIMARY KEY,
FirstName nvarchar(50) NULL,
Lastname nvarchar(50) NULL,
[Type] varchar(50) NULL,
ZipCode INT NULL,
CustomerStreet varchar(50) NULL,
CustomerCity varchar(50) NULL,
CustomerState varchar(50) NULL,
CustomerCountry varchar(50) NULL
)

INSERT INTO DimCustomer
SELECT DISTINCT [Customer Id], [Customer Fname], [Customer Lname], [Customer Segment], [Customer Zipcode], [Customer Street] ,[Customer City], [Customer State], [Customer Country] FROM [dbo].[DataCoSupplyChainDataset]

--select [Order Id], [Days for shipment (scheduled)], [Days for shipping (real)], [Delivery Status], Late_delivery_risk, [Shipping Mode], [order date (DateOrders)] from [dbo].[DataCoSupplyChainDataset]
--ORDER BY [Order Id]

--SELECT * FROM [dbo].[DataCoSupplyChainDataset]
--WHERE [Order Id]='10'

--SELECT DISTINCT [Order Id], [Days for shipment (scheduled)], [Days for shipping (real)], [Delivery Status], Late_delivery_risk, [Shipping Mode] FROM [dbo].[DataCoSupplyChainDataset]

--Create table DimDelivery
DROP TABLE DimDelivery
CREATE TABLE DimDelivery
(
OrderID BIGINT NOT NULL,
ScheduledShippingDays INT NULL,
RealShippingDays INT NULL,
DeliveryStatus varchar(50) NULL,
LateRisk INT NULL, 
ShipMode varchar(50) NULL 
)

INSERT INTO DimDelivery
SELECT DISTINCT [order date (DateOrders)] , [Order Id], [Days for shipment (scheduled)], [Days for shipping (real)], [Delivery Status], Late_delivery_risk, [Shipping Mode] FROM [dbo].[DataCoSupplyChainDataset]


--Create table DimOrder
DROP TABLE DimOrder
CREATE TABLE DimOrder
(
OrderID BIGINT NOT NULL,
OrderStatus nvarchar(50) NULL,
TransactionType nvarchar(50) NULL,
OrderCity nvarchar(50) NULL,
OrderState nvarchar(50) NULL,
OrderCountry nvarchar(50) NULL,
OrderRegion nvarchar(50) NULL,
Region nvarchar(50) NULL
)

INSERT INTO DimOrder
SELECT DISTINCT [Order Id], [Order Status], [Type], [Order City], [Order State], [Order Country], [Order Region], Region  FROM [dbo].[DataCoSupplyChainDataset]

--Create table DimDate
SET DATEFIRST  7, -- 1 = Monday, 7 = Sunday
    DATEFORMAT mdy, 
    LANGUAGE   US_ENGLISH



DECLARE @StartDate  date =(SELECT MIN([order date (DateOrders)]) FROM [dbo].[DataCoSupplyChainDataset]), @years int = 4;
;WITH seq(n) AS 
(
  SELECT n = value FROM GENERATE_SERIES(0, 
    DATEDIFF(DAY, @STARTDATE, DATEADD(YEAR, @years, @StartDate))-1)
)
SELECT n FROM seq
ORDER BY n;

DECLARE @StartDate  date = (SELECT MIN([order date (DateOrders)]) FROM [dbo].[DataCoSupplyChainDataset]);

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 4, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
)
SELECT d FROM d
ORDER BY d
OPTION (MAXRECURSION 0);


DECLARE @StartDate  date =(SELECT MIN([order date (DateOrders)]) FROM [dbo].[DataCoSupplyChainDataset]);

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 4, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
)
SELECT CONVERT(varchar(12),TheDate,112) DateKey , LEFT(CONVERT(varchar(12),TheDate,112),6) MonthKey, TheDate, TheDayOfWeek, TheDayName,TheDay AS TheDayOfMonth , TheMonthName,TheDayOfYear, TheWeek, TheQuarter, TheYear INTO [dbo].[DimDate]  FROM src
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);

  --Create Stored Procedure
CREATE PROCEDURE daily_update
@datekey nvarchar(10) =NULL
AS 
BEGIN

DELETE FROM [dbo].[FactOrder] WHERE OrderDateKey=@datekey 
SET @datekey =ISNULL(@datekey,  CONVERT(nvarchar(10), GETDATE(),112))
INSERT INTO [dbo].[FactOrder] (OrderKey, OrderDate, OrderDateKey, OrderProductQuantity, OrderStatus, ShipDate, ShipDateKey, ProductKey, ProductPrice, 
ProductDiscountRate, TotalProductDiscount, SalesAmount, Profit, ProfitRate, CustomerKey, DepartmentKey)

SELECT [Order Id], [order date (DateOrders)], CONVERT(nvarchar(50), [order date (DateOrders)],23), [Order Item Quantity], [Order Status], [shipping date (DateOrders)],
CONVERT(nvarchar(50), [shipping date (DateOrders)],23), [Product Card Id], [Product Price], [Order Item Discount Rate], [Order Item Discount], Sales, [Benefit per order], 
[Order Item Profit Ratio], [Customer Id], [Department Id] FROM [dbo].[DataCoSupplyChainDataset]
WHERE CONVERT(nvarchar(50),[order date (DateOrders)],23) = @datekey 

END 
GO

