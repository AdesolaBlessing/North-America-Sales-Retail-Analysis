# North America Sales Retail Optimization Analysis


## Project Overview
North America Retail is a leading retail company operating across multiple locations, offering a diverse range of products to various customer segments. Their core focus is on delivering exceptional customer service and ensuring a seamless shopping experience.


## Data Source
The dataset used is a Retail Supply Chain Sales Analysis.csv


## Tools Used
- SQL


## Data Cleaning and Preparation
1. Data importation and Cleaning

2. Spliting into Facts and Dimention Tables, the Dimention table includes;
- DimCustomer
- DimProduct
- DimLocation

## Objectives
1. What was the Average delivery days for different product subcategory?

2. What was the Average delivery days for each segment?
   
3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?

4. Which product Subcategory generate most profit?
   
5. Which segment generates the most profit?
   
6. Which Top 5 customers made the most profit?
   
7. What is the total number of products by Subcategory

## Data Analysis
### 1. What was the Average delivery days for different product subcategory?
```sql
SELECT dp.Sub_Category, AVG(DATEDIFF(DAY, oft.Order_Date, oft.Ship_Date)) AS AvgDeliveryDays
	FROM OrdersFacttable AS oft
	LEFT JOIN DimProduct AS dp
ON oft.Product_ID = dp.Product_ID
GROUP BY dp.Sub_Category

/* It takes an average of 32 days to deliver product in the chairs and bookcases sub_category,
an average of 35 days to deliver product in the furnishings sub_category,
an average of 36 days to deliver product in the tables sub_category*/
```

### 2. What was the Average delivery days for each segment?
```sql
SELECT Segment, AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS AvgDeliveryDays
FROM OrdersFacttable
GROUP BY Segment
ORDER BY AvgDeliveryDays DESC

/* It takes an average of 35 days to get products to the corporate Segment,
It takes an average of 34 days to get products to the Consumer Segment,
It takes an average of 31 days to get products to the Home Office Segment*/
```

### 3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
```sql
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
```

### 4. Which product Subcategory generate most profit?
```sql
SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit
	FROM OrdersFacttable AS oft
	LEFT JOIN DimProduct AS dp
ON oft.Product_ID = dp.Product_ID
WHERE oft.Profit > 0
GROUP BY dp.Sub_Category
ORDER BY 2 DESC

/* The SubCategory Chairs generate the highest profit with a total of $36471.1
while the least come from table Subcategory*/
```

### 5. Which segment generates the most profit?
```sql
SELECT Segment, ROUND(SUM(Profit),2) AS TotalProfit
FROM OrdersFacttable
WHERE Profit > 0
GROUP BY Segment
ORDER BY 2 DESC

/*The Consumer Segment generates the highest profit 
while the home office generates the least profit*/
```

### 6. Which Top 5 customers made the most profit?
```sql
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
```

### 7. What is the total number of products by Subcategory
```sql
SELECT Sub_Category, COUNT(Product_Name) AS TotalProduct
FROM DimProduct
GROUP BY Sub_Category

/* The total Product for each SubCategory are 48,87,186,34 for Bookcases, chairs, furnishings, tables respectively*/
```

## Results/Findings
- Tables took the longest time to be delivered, which may indicate logistics challenges or supplier delays.
- The Home Office segment had the fastest delivery times, while Corporate customers experienced slightly longer wait times.
- Certain furniture and office equipment took significantly longer to be delivered, likely due to supply chain constraints.
- Investing more in the chairs subcategory could maximize profitability, while strategies to improve the profitability of tables should be explored.
- The Consumer segment is the primary revenue driver, indicating a strong preference for individual purchases over business/corporate orders.
- These top customers contributed significantly to revenue, indicating the need to maintain strong relationships with them through personalized marketing or loyalty programs.
- Furnishings have the highest variety, while Tables have the least. Increasing product diversity in the Table category could boost sales.

## Recommendations
### Optimize Delivery Time for High-Demand Products
- Since Tables take the longest time to be delivered (36 days), the company should review its supply chain processes.
- Partnering with faster logistics providers or adjusting inventory levels could reduce delays.
- Prioritize stocking fast-moving products (like chairs and bookcases) to maintain efficiency.

### Improve Corporate Segment Delivery
- Corporate customers experience longer delivery times (35 days), which could affect business relationships.
- Implement express shipping options for corporate clients to enhance satisfaction and loyalty.
- Analyze order fulfillment processes to identify bottlenecks.

### Increase Focus on the Most Profitable Product Subcategories
- Chairs generate the highest profit ($36,471.1). Expanding chair product lines could boost revenue.
- Tables contribute the least profit. Consider price adjustments, marketing campaigns, or bundling strategies to improve profitability.

### Enhance Customer Engagement for High-Value Clients
- The top 5 customers (e.g., Laura Armstrong, Joe Elijah, etc.) generate significant profits.
- The company should introduce a VIP loyalty program to retain them.
- Personalized discounts, early product access, and exclusive offers could encourage repeat purchases.

## Challenges Encountered
- I encountered multiple syntax errors, such as missing commas, incorrect use of parentheses, and forgotten semicolons.
- When creating dimension tables, I noticed that some customer and product records were duplicated in the original dataset. I had to use ROW_NUMBER() to identify duplicates and then remove them while keeping only the first occurrence.
