SELECT * FROM [Sales Retail]

--To create a Dimcustomer table from the Sales Retail table
SELECT * INTO DimCustomer
FROM
	(SELECT Customer_ID,Customer_Name,  FROM [Sales Retail])
	AS DimC

SELECT * FROM DimCustomer

WITH CTE_DimC 
AS
	(SELECT Customer_ID, Customer_Name, ROW_NUMBER() OVER (PARTITION BY Customer_ID, Customer_Name ORDER BY Customer_ID ASC) AS RowNum
	FROM DimCustomer
	)

DELETE FROM CTE_DimC
WHERE RowNum >1

SELECT * FROM DimCustomer 

--To create a DimLOcation tale from the Sales Retail table
SELECT * INTO Dimlocation
FROM
	(SELECT Postal_code, Country, City, State, Region
	FROM [Sales Retail]
	)
AS DimL

SELECT * FROM Dimlocation

WITH CTE_DimL 
AS
	(SELECT Postal_Code, Country, City, State, Region, ROW_NUMBER() OVER (PARTITION BY Postal_Code, Country, City, State, Region ORDER BY Postal_Code ASC) AS RowNum
		FROM Dimlocation)

DELETE FROM CTE_DimL
WHERE RowNum > 1


--To create the table of product from the Sales Retail Table
SELECT * INTO DimProduct
FROM 
	(SELECT Product_ID, Category,Sub_Category,Product_Name
	FROM [Sales Retail]
	)
AS DimP

SELECT * FROM DimProduct

WITH CTE_DimP
AS 
	(SELECT Product_ID, Category,Sub_Category,Product_Name, ROW_NUMBER() OVER (PARTITION BY Product_ID, Category,Sub_Category,Product_Name ORDER BY Product_ID) AS RowNum
	FROM DimProduct
	)
DELETE FROM CTE_DimP
WHERE RowNum > 1

SELECT * FROM DimProduct

--To create our salesFacttable

SELECT * INTO OrdersFacttable
FROM
	(SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Segment, Postal_Code, Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit
	FROM [Sales Retail]
	)
AS OrderFact

SELECT * FROM OrdersFacttable;

WITH CTE_OrderFact 
AS 
	(SELECT * , 
	ROW_NUMBER() OVER (PARTITION BY 
	Order_ID, 
	Order_Date, 
	Ship_Date, 
	Ship_Mode, 
	Customer_ID, 
	Segment, 
	Postal_Code, 
	Retail_Sales_People, 
	Product_ID, 
	Returned, 
	Sales, 
	Quantity, 
	Discount, 
	Profit  ORDER BY Order_ID ASC
	)
	AS RowNum
	FROM OrdersFacttable
)
DELETE FROM CTE_OrderFact
WHERE RowNum > 1

SELECT * FROM OrdersFacttable

--Exploration Analysis
--What was the Average delivery days for different product subcategory?


SELECT dp.Sub_Category, AVG(DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date)) AS AvgDeliveryDays
	FROM OrdersFacttable AS oft
	LEFT JOIN DimProduct AS dp
ON oft.Product_ID = dp.Product_ID
GROUP BY dp.Sub_Category
/* It takes an average of 32 days to deliver product in the chairs and bookcases sub_category,
an average of 35 days to deliver product in the furnishings sub_category,
an average of 36 days to deliver product in the tables sub_category*/



--What was the Average delivery days for each segment?

SELECT Segment, AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS AvgDeliveryDays
FROM OrdersFacttable
GROUP BY Segment
ORDER BY AvgDeliveryDays DESC

/* It takes an average of 35 days to get products to the corporate Segment,
It takes an average of 34 days to get products to the Consumer Segment,
It takes an average of 31 days to get products to the Home Office Segment*/



--What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?

SELECT TOP 5 (dp.Product_Name), DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date) AS DeliveryDays
	FROM OrdersFacttable AS oft
	LEFT JOIN DimProduct AS dp
ON oft.Product_ID = dp.Product_ID
ORDER BY 2 ASC

/* The top 5 fastest delivered products with 0 delivery days
Sauder Camden County Barrister Bookcase, Planked Cherry Finish
Sauder Inglewood Library Bookcases
O'Sullivan 2-Shelf Heavy-Duty Bookcases
O'Sullivan Plantations 2-Door Library in Landvery Oak
O'Sullivan Plantations 2-Door Library in Landvery Oak 8 */

SELECT TOP 5 (dp.Product_Name), DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date) AS DeliveryDays
	FROM OrdersFacttable AS oft
	LEFT JOIN DimProduct AS dp
ON oft.Product_ID = dp.Product_ID
ORDER BY 2 DESC

/* The top 5 slowest delivered products with 214 delivery days
Bush Mission Pointe Library
Hon Multipurpose Stacking Arm Chairs
Global Ergonomic Managers Chair
Tensor Brushed Steel Torchiere Floor Lamp
Howard Miller 11-1/2" Diameter Brentwood Wall Clock */



--Which product Subcategory generate most profit?
SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit
	FROM OrdersFacttable AS oft
	LEFT JOIN DimProduct AS dp
ON oft.Product_ID = dp.Product_ID
WHERE oft.Profit > 0
GROUP BY dp.Sub_Category
ORDER BY 2 DESC

/* The SubCategory Chairs generate the highest profit with a total of $36471.1
while the least come from table Subcategory*/



--Which segment generates the most profit?
SELECT Segment, ROUND(SUM(Profit),2) AS TotalProfit
FROM OrdersFacttable
WHERE Profit > 0
GROUP BY Segment
ORDER BY 2 DESC

/*The Consumer Segment generates the highest profit 
while the home office generates the least profit*/



--Which Top 5 customers made the most profit?
SELECT TOP 5(dc.Customer_Name), ROUND(SUM(oft.Profit),2) AS TotalProfit
FROM OrdersFacttable AS oft
LEFT JOIN DimCustomer AS dc
ON oft.Customer_ID = dc.Customer_ID
WHERE Profit > 0
GROUP BY Customer_Name
ORDER BY 2 DESC

/*The top 5 customers generating the highest profits are:
Laura Armstrong
Joe Elijah
Seth Vernon
Quincy Jones
Maria Etezadi */



--What is the total number of products by Subcategory
SELECT Sub_Category, COUNT(Product_Name) AS TotalProduct
FROM DimProduct
GROUP BY Sub_Category

/* The total Product for each SubCategory are 48,87,186,34 for Bookcases, chairs, furnishings, tables respectively*/

