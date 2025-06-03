# Schema Definitions for POS Retail Analytics Project

## 📦 Table Definitions

### `MY_SCHEMA.TRANSACTIONS`
| Column Name | Data Type |
|-------------|-----------|
| TransactionID | INT |
| Date | TIMESTAMP_NTZ |
| ProductID | INT |
| Quantity | INT |
| Price | FLOAT |
| TotalPrice | FLOAT |
| StoreID | INT |
| CustomerID | INT |
| PaymentMethod | TEXT |


### `MY_SCHEMA.PRODUCTS`
| Column Name | Data Type |
|-------------|-----------|
| ProductID | INT |
| ProductName | TEXT |
| Category | TEXT |
| Price | FLOAT |


### `MY_SCHEMA.STORES`
| Column Name | Data Type |
|-------------|-----------|
| StoreID | INT |
| StoreName | TEXT |


### `MY_SCHEMA.CUSTOMERS`
| Column Name | Data Type |
|-------------|-----------|
| CustomerID | INT |
| Name | TEXT |
| LASTNAME | TEXT |
| ZIPCODE | TEXT |
| SEGMENT | TEXT |

---

## 👁️ View Output Schemas (Inferred)

### `STORE_PERFORMANCE_ANALYSIS`
| Output Column |
|----------------|
| TotalRevenue |

### `Store_Customer_Analysis`
| Output Column |
|----------------|
| s.StoreName |
| TransactionCount |
| TotalRevenue |
| TotalUnitsSold |
| UniqueCustomers |
| t.TransactionID) |
| AverageOrderValue |
| t.CustomerID) |
| 0) |
| AvgRevenuePerCustomer |

### `PRODUCT_ANALYSIS_1`
| Output Column |
|----------------|
| P.ProductID |
| P.CATEGORY |
| P.ProductName |
| TotalRevenue |
| TotalProductsSold |

### `PA_2`
| Output Column |
|----------------|
| P.CATEGORY |
| P.ProductName |
| TOTAL_PRODUCTS_SOLD |
| Product_Rank |

### `CATEGORY_SHARE`
| Output Column |
|----------------|
| P.CATEGORY |
| TOTAL_REVENUE |
| TOTAL_UNITS |
| SUM(T.PRICE) |

### `PRODUCTS_TOGETHER`
| Output Column |
|----------------|
| Product1 |
| Product2 |
| PurchaseCount |

### `DAILY_GROWTH_RATE`
| Output Column |
|----------------|
| DATE_TRUNC('DAY' |
| Day |
| DailyTransactions |
| DailyRevenue |
| DailyUnitsSold |
| T.TransactionID) |
| DailyAverageOrderValue |
| SUM(T.Quantity) |
| DailyAverageUnitPrice |
| LAG(SUM(T.Price) |
| DATE_TRUNC('DAY' |
| NULLIF(LAG(SUM(T.Price) |
| DATE_TRUNC('DAY' |
| T.Date)) |
| 100 |
| DailyGrowthRate |

### `MONTHLY_Product_SALE`
| Output Column |
|----------------|
| P.CATEGORY |
| P.ProductName |
| EXTRACT(MONTH |

### `QUARTERLY`
| Output Column |
|----------------|
| P.CATEGORY |
| P.ProductName |
| Quarter |
| QuarterlyRevenue |
| QuarterlyQuantitySold |

### `CLV`
| Output Column |
|----------------|
| C.CustomerID |
| Name |
| LifetimeValue |

### `STORE_CATEGORY_PIVOT_ANALYSIS`
| Output Column |
|----------------|
| s.StoreId |
| s.StoreName |
| p.Category |
| CategoryRevenue |
| CategoryUnitsSold |
