CREATE DATABASE POS_SYSTEM;
CREATE SCHEMA MY_SCHEMA;

CREATE OR REPLACE TABLE MY_SCHEMA.TRANSACTIONS(
        TransactionID INT,
        Date TIMESTAMP_NTZ,
        ProductID INT,
        Quantity INT,
        Price FLOAT,
        TotalPrice FLOAT,
        StoreID INT,
        CustomerID INT,
        PaymentMethod TEXT
);

CREATE OR REPLACE TABLE MY_SCHEMA.PRODUCTS(
        ProductID INT,
        ProductName TEXT,
        Category TEXT,
        Price FLOAT
);

CREATE OR REPLACE TABLE MY_SCHEMA.STORES(
        StoreID INT,
        StoreName TEXT
);

CREATE OR REPLACE TABLE MY_SCHEMA.CUSTOMERS(
        CustomerID INT,
        Name TEXT,
        LASTNAME TEXT,
        ZIPCODE TEXT,
        SEGMENT TEXT
);

-- Create a file format for CSV
CREATE OR REPLACE FILE FORMAT csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1 -- Skip the header row
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

-- Create the stage
CREATE OR REPLACE STAGE my_s3_stage
URL = 's3://data-analysis'
CREDENTIALS = (AWS_KEY_ID = '' AWS_SECRET_KEY = '')
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1); -- Assumes the first row contains headers

list @my_s3_stage;

COPY INTO TRANSACTIONS
FROM @my_s3_stage/ files=('transactions.csv')
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 );

COPY INTO CUSTOMERS
FROM @my_s3_stage/ files=('customers.csv')
FILE_FORMAT = csv_format;

COPY INTO STORES
FROM @my_s3_stage/ files=('stores.csv')
FILE_FORMAT = csv_format;

COPY INTO PRODUCTS
FROM @my_s3_stage/ files=('products.csv')
FILE_FORMAT = csv_format;

--  SQL QUERY


-- (CATEGORY, STORE, TRANSACTION) BASED TRIVARIENT ANALYSIS
SELECT S.StoreName, S.StoreID , P.CATEGORY, SUM(T.Quantity) AS NUMBER_OF_ITEMS_SOLD, SUM(T.TOTALPRICE) AS Total_Revenue
FROM transactions T  
JOIN PRODUCTS P ON P.ProductID = T.ProductID 
JOIN STORES S ON S.StoreID = T.StoreID
GROUP BY S.StoreName, S.StoreID, P.CATEGORY
ORDER BY S.STORENAME, P.CATEGORY;

--------------------------------------------------------------------------------------------------
------------------------------- STORE-PERFORMANCE_ANALYSIS----------------------------------------
--------------------------------------------------------------------------------------------------
-- Calculate the total revencue of the store
-- Calculate the percentage contribution of each store to the total revenue

CREATE OR REPLACE VIEW STORE_PERFORMANCE_ANALYSIS AS
    With OverallRevenue AS(
    SELECT
        SUM(TotalPrice) as TotalRevenue
    FROM
        Transactions)
    
    SELECT 
        S.StoreName, SUM(T.TotalPrice) AS Store_Revenue, SUM(T.Quantity) AS Total_Products_Sold, ROUND(Store_Revenue/(Select TotalRevenue from        
        OVERALLREVENUE)*100, 2) as Percentage_Contribution
    FROM 
        Transactions T
    JOIN 
        Stores S ON T.StoreID = S.StoreID
    GROUP BY 
        S.StoreName
    ORDER BY 
        Store_Revenue DESC;

CREATE OR REPLACE VIEW Store_Customer_Analysis AS
SELECT
    s.StoreName,
    COUNT(DISTINCT t.TransactionID) AS TransactionCount,
    SUM(t.TotalPrice) AS TotalRevenue,
    SUM(t.Quantity) AS TotalUnitsSold,
    COUNT(DISTINCT t.CustomerID) AS UniqueCustomers,
    ROUND(SUM(t.TotalPrice) / COUNT(DISTINCT t.TransactionID), 2) AS AverageOrderValue,
    ROUND(SUM(t.TotalPrice) / NULLIF(COUNT(DISTINCT t.CustomerID), 0), 2) AS AvgRevenuePerCustomer
FROM Transactions t
JOIN Stores s ON t.StoreID = s.StoreID
GROUP BY s.StoreName
ORDER BY TotalRevenue DESC;

-----------------------------------------------------------------------------
----------------------Product/Category_Analysis---------------------------------------
-----------------------------------------------------------------------------

-- Product_Analysis -- Total Number of sales and 
---------------------- Revenvue of each product and  In which store the product sold most and Revenue and Quantity sold in Topselling Store

CREATE OR REPLACE VIEW PRODUCT_ANALYSIS_1 AS

    WITH ProductSales AS (
    -- Calculate total revenue and total products sold for each product
        SELECT
            P.ProductID,
            P.CATEGORY,
            P.ProductName,
            SUM(T.TotalPrice) AS TotalRevenue,
            SUM(T.Quantity) AS TotalProductsSold
        FROM 
            Transactions T
        JOIN 
            PRODUCTS P ON P.ProductID = T.ProductID
        GROUP BY 
            P.CATEGORY, P.ProductName, P.PRODUCTID
    ),

    TopSellingStore AS (
    -- Determine the store where each product was sold the most
        SELECT 
            P.ProductID,
            S.StoreName,
            SUM(T.TotalPrice) AS Product_Revenue_in_Top_Selling_Store,
            SUM(T.Quantity) AS Products_Sold_in_Top_Selling_Store,
            ROW_NUMBER() OVER (PARTITION BY P.ProductID ORDER BY SUM(T.Quantity) DESC) AS StoreRank
        FROM 
            Transactions T
        JOIN 
            PRODUCTS P ON P.ProductID = T.ProductID
        JOIN 
            STORES S ON S.StoreID = T.StoreID
        GROUP BY 
            P.ProductID, S.StoreName
    )
    
    -- Combine the results
    SELECT 
        PS.PRODUCTID,
        PS.CATEGORY,
        PS.ProductName,
        PS.TotalRevenue,
        PS.TotalProductsSold,
        TSS.StoreName AS Top_Selling_Store,
        TSS.Product_Revenue_in_Top_SELLING_Store,
        TSS.Products_Sold_in_Top_Selling_Store
    FROM 
        ProductSales PS
    JOIN 
        TopSellingStore TSS ON PS.ProductID = TSS.ProductID
    WHERE 
        TSS.StoreRank = 1
    ORDER BY 
        PS.CATEGORY, PS.ProductName;

-------------------------------------------------------------------------
-----Product_Analysis----- Top selling product in each category

CREATE OR REPLACE VIEW PA_2 AS
    WITH TopProduct AS(
        SELECT 
            P.CATEGORY,
            P.ProductName,
            SUM(T.QUANTITY) AS TOTAL_PRODUCTS_SOLD,
            RANK() OVER (PARTITION BY P.CATEGORY ORDER BY SUM(T.QUANTITY) DESC) AS Product_Rank
        FROM 
            TRANSACTIONS T
        JOIN 
            PRODUCTS P ON P.ProductID = T.ProductID
        GROUP BY
            P.ProductName, P.CATEGORY)
       
    SELECT 
        CATEGORY, 
        ProductName,
        TOTAL_PRODUCTS_SOLD,
        Product_Rank
    FROM 
        TopProduct
    WHERE
        Product_Rank = 1;

------ SHARE of EACH CATEGORY IN TOTAL REVENUE ---
CREATE OR REPLACE VIEW CATEGORY_SHARE AS
    SELECT P.CATEGORY,
        SUM(T.Price) AS TOTAL_REVENUE,
        SUM(T.QUANTITY) AS TOTAL_UNITS,
        ROUND(SUM(T.PRICE)/(SELECT SUM(T.PRICE) FROM TRANSACTIONS T)*100, 2) AS REVENUE_SHARE
    FROM 
        TRANSACTIONS T 
    JOIN 
        PRODUCTS P ON T.PRODUCTID = P.PRODUCTID
    GROUP BY P.CATEGORY    
    ORDER BY REVENUE_SHARE;


------ Products That are bought together -----
CREATE OR REPLACE VIEW PRODUCTS_TOGETHER AS
    WITH ProductPairs AS (
        SELECT 
            T1.ProductID AS Product1,
            T2.ProductID AS Product2,
            COUNT(*) AS PurchaseCount
        FROM 
            Transactions T1
        JOIN 
            Transactions T2 ON T1.TransactionID = T2.TransactionID AND T1.ProductID < T2.ProductID
        GROUP BY 
            T1.ProductID, T2.ProductID
    )
    
    SELECT 
        P1.ProductName AS Product1,
        P2.ProductName AS Product2,
        PP.PurchaseCount
    FROM 
        ProductPairs PP
    JOIN 
        PRODUCTS P1 ON P1.ProductID = PP.Product1
    JOIN 
        PRODUCTS P2 ON P2.ProductID = PP.Product2
    ORDER BY 
        PurchaseCount DESC;

-------------------------------------------------------------------      
---------------- Periodical/Timely Analysis ------------------------------
-------------------------------------------------------------------

---- Daily Growth Rate Calculation -------
CREATE OR REPLACE VIEW DAILY_GROWTH_RATE AS
    SELECT
        DATE_TRUNC('DAY', T.Date) AS Day,
        COUNT(DISTINCT T.TransactionID) AS DailyTransactions,
        SUM(T.Price) AS DailyRevenue,
        SUM(T.Quantity) AS DailyUnitsSold,
        ROUND(SUM(T.Price) / COUNT(DISTINCT T.TransactionID), 2) AS DailyAverageOrderValue,
        ROUND(SUM(T.Price) / SUM(T.Quantity), 2) AS DailyAverageUnitPrice,
        ROUND((SUM(T.Price) - LAG(SUM(T.Price), 1) OVER (ORDER BY DATE_TRUNC('DAY', T.Date))) / 
        NULLIF(LAG(SUM(T.Price), 1) OVER (ORDER BY DATE_TRUNC('DAY', T.Date)), 0) * 100, 2) AS DailyGrowthRate
    FROM Transactions T
    GROUP BY DATE_TRUNC('DAY', T.Date)
    ORDER BY Day DESC;

------Monthly sale trend of each Category---
CREATE OR REPLACE VIEW MONTHLY_Product_SALE AS
    SELECT 
        P.CATEGORY,
        P.ProductName,
        EXTRACT(MONTH FROM T.Date) AS Month,
        SUM(T.TotalPrice) AS MonthlyRevenue,
        SUM(T.Quantity) AS MonthlyQuantitySold
    FROM 
        Transactions T
    JOIN 
        Products P ON P.ProductID = T.ProductID
    GROUP BY 
         P.ProductName, P.CATEGORY, EXTRACT(MONTH FROM T.Date)
    ORDER BY 
        Month, P.CATEGORY, P.ProductName;

------- Quartarly Analysis of Each Category----

Create or Replace VIEW QUARTERLY AS
    SELECT 
        P.CATEGORY,
        P.ProductName,
        QUARTER(T.Date) AS Quarter,
        SUM(T.TotalPrice) AS QuarterlyRevenue,
        SUM(T.Quantity) AS QuarterlyQuantitySold
    FROM 
        Transactions T
    JOIN 
        PRODUCTS P ON P.ProductID = T.ProductID
    GROUP BY 
        P.ProductName, P.CATEGORY, QUARTER(T.Date)
    ORDER BY 
        P.CATEGORY, P.ProductName, Quarter;

        
--------------------------------------------------------------------------
--------------------- Customer Analysis-----------------------------------
--------------------------------------------------------------------------

---------  Customer Lifetime Value -------
CREATE OR REPLACE VIEW CLV AS 
    SELECT 
        C.CustomerID,
        C.Name AS Name,
        SUM(T.TotalPrice) AS LifetimeValue
    FROM 
        Transactions T
    JOIN 
        CUSTOMERS C ON C.CustomerID = T.CustomerID
    GROUP BY 
        C.CustomerID, C.Name
    ORDER BY 
        LifetimeValue DESC;

--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW STORE_CATEGORY_PIVOT_ANALYSIS AS
WITH StoreCategorySales AS (
    SELECT 
        s.StoreId,
        s.StoreName,
        p.Category,
        SUM(t.TotalPrice) AS CategoryRevenue,
        SUM(t.Quantity) AS CategoryUnitsSold
    FROM 
        Transactions t
    JOIN 
        Stores s ON t.StoreID = s.StoreID
    JOIN 
        Products p ON t.ProductID = p.ProductID
    GROUP BY 
        s.StoreID, s.StoreName, p.Category
),
StoreTotals AS (
    SELECT 
        StoreID,
        StoreName,
        SUM(CategoryRevenue) AS TotalRevenue,
        SUM(CategoryUnitsSold) AS TotalUnitsSold
    FROM 
        StoreCategorySales
    GROUP BY 
        StoreID, StoreName
)
SELECT 
    st.StoreID,
    st.StoreName,
    st.TotalRevenue,
    st.TotalUnitsSold,
    -- Dynamically create columns for each category's revenue
    MAX(CASE WHEN scs.Category = 'Electronics' THEN scs.CategoryRevenue ELSE 0 END) AS Electronics_Revenue,
    MAX(CASE WHEN scs.Category = 'Clothing' THEN scs.CategoryRevenue ELSE 0 END) AS Clothing_Revenue,
    MAX(CASE WHEN scs.Category = 'Grocery' THEN scs.CategoryRevenue ELSE 0 END) AS Groceries_Revenue
FROM 
    StoreTotals st
LEFT JOIN 
    StoreCategorySales scs ON st.StoreID = scs.StoreID
GROUP BY 
    st.StoreID, st.StoreName, st.TotalRevenue, st.TotalUnitsSold
ORDER BY 
    st.TotalRevenue DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * from STORE_PERFORMANCE_ANALYSIS;
SELECT * FROM PRODUCT_ANALYSIS_1;
SELECT * FROM PA_2;
SELECT * FROM CATEGORY_SHARE;
SELECT * FROM CLV;
SELECT * FROM QUARTERLY;
SELECT * FROM MONTHLY_Product_SALE;
SELECT * FROM CSA;
SELECT * FROM PRODUCTS_TOGETHER;
SELECT * FROM STORE_CATEGORY_PIVOT_ANALYSIS;
SELECT * FROM Store_Customer_Analysis;

SELECT 
        s.StoreId,
        s.StoreName,
        p.Category,
        SUM(t.TotalPrice) AS CategoryRevenue,
        SUM(t.Quantity) AS CategoryUnitsSold
    FROM 
        Transactions t
    JOIN 
        Stores s ON t.StoreID = s.StoreID
    JOIN 
        Products p ON t.ProductID = p.ProductID
    GROUP BY 
        s.StoreID, s.StoreName, p.Category
    ORDER BY
        S.STOREID, P.CATEGORY
