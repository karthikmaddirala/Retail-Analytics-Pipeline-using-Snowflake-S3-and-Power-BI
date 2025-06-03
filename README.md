# 🛒 Retail Analytics Pipeline using Snowflake, S3, and Power BI

This project presents an end-to-end retail analytics pipeline that simulates a Point of Sale (POS) data flow. It leverages Amazon S3 for data storage, Snowflake for warehousing and semantic modeling, and Power BI for real-time dashboarding. The goal is to deliver business insights from structured sales and customer data without a traditional transformation layer.

---

## 📌 Project Overview

The pipeline ingests clean, structured POS-style CSV files from Amazon S3, loads them into Snowflake using external stages, and exposes modeled data via SQL views. These views are directly queried from Power BI to build dynamic dashboards.

> ⚠️ This project intentionally omits a transformation layer — assuming data arrives analytics-ready — as is common in many real-world systems that rely on upstream cleansing (e.g., vendor-delivered flat files, POS exports).


---

## ⚙Technologies Used

- **Amazon S3** – Object storage for source data (`transactions`, `customers`, `products`, `stores`)
- **Snowflake** – Cloud data warehouse for modeling, querying, and hosting SQL views
- **SQL Views** – Semantic layer for reusable logic (e.g., sales trends, CLV, store rankings)
- **Power BI** – Real-time data visualization using DirectQuery
- **Git & GitHub** – Version control and collaboration

---


## 📁 Project Structure

```
Retail-Analytics-Snowflake/
├── Dashboard Images/
│ ├── Overview.png
│ ├── Product Performance.png
│ └── Store Performance.png
│
├── Reports/
│ ├── 01_Overview_Dashboard.pdf
│ ├── 02_Store_Performance_Report.pdf
│ ├── 03_Product_Performance_Report.pdf
│ └── 04_POS_System_Analytics_Dashboard.pdf
│
├── Snowflake SQL/
│ ├── Snowflake_SQL.sql
│ └── tables_and_stage_definitions.md
│
├── Dashboard.pbix
└── README.md
```

---
## Schema Design

The data is modeled in a **star schema** structure with one central fact table and supporting dimension tables:

- **Fact Table:**
  - `fact_transactions` — each row represents a POS transaction, with references to store, product, and customer

- **Dimension Tables:**
  - `dim_customers` — enriched customer data
  - `dim_products` — product catalog and categories
  - `dim_stores` — store locations and attributes

---
### SQL Views

Reusable SQL views were created to enable semantic modeling, including:

The project includes several SQL views designed to support modular, reusable analytics logic. These views are used in Power BI to power store performance, customer behavior, category trends, and time-based reporting.

| View Name                         | Purpose                                                                 |
|----------------------------------|-------------------------------------------------------------------------|
| `STORE_PERFORMANCE_ANALYSIS`     | Store-wise revenue, items sold, and % contribution to overall sales     |
| `Store_Customer_Analysis`        | Store-wise transaction volume, unique customers, avg revenue per order  |
| `PRODUCT_ANALYSIS_1`             | Product-wise total sales, top-selling store, and performance metrics    |
| `PA_2`                            | Identifies the top-selling product in each category                     |
| `CATEGORY_SHARE`                 | Shows each category’s share in total revenue and units sold             |
| `CLV`                             | Calculates lifetime value of each customer                              |
| `STORE_CATEGORY_PIVOT_ANALYSIS`  | Pivoted analysis of category-wise sales across stores                   |
| `PRODUCTS_TOGETHER`              | Market basket-style view of products often bought together              |
| `DAILY_GROWTH_RATE`              | Daily revenue, unit sales, order value, and growth rate                 |
| `MONTHLY_Product_SALE`           | Monthly revenue and quantity sold per product and category              |
| `QUARTERLY`                      | Quarterly revenue and units sold by product and category                |

These views form the **semantic layer** and abstract complex aggregations and joins, making it easy to build flexible and interactive dashboards in Power BI.

📄 Full SQL: [`Snowflake_SQL.sql`](Snowflake%20SQL/Snowflake_SQL.sql)  
📘 Detailed schema: [`tables_and_stage_definitions.md`](Snowflake%20SQL/tables_and_stage_definitions.md)


Each view encapsulates complex logic for Power BI dashboards, enabling quick iteration and consistent business metrics.

---

## 📊 Dashboards Preview

| Overview                           | Product Performance                 | Store Performance                   |
|-----------------------------------|-------------------------------------|-------------------------------------|
| ![Overview](Dashboard%20Images/Overview.png) | ![Product](Dashboard%20Images/Product%20Performance.png) | ![Store](Dashboard%20Images/Store%20%20Performance.png) |

---

## 📄 Reports

- [Overview Dashboard Report](Reports/Overview%20DashBoard.pdf)  
- [Store Performance Report](Reports/01_Store%20Performance%20Report.pdf)  
- [Product Performance Report](Reports/02_Product%20Performance%20Report.pdf)  
- [POS System Analytics Dashboard Summary](Reports/POS%20System%20Analytics%20Dashboard%20Report.pdf)

---

## 📂 Snowflake SQL Assets

- [Snowflake SQL Code](Snowflake%20SQL/Snowflake_SQL.sql)
- [Table & Stage Definitions](Snowflake%20SQL/tables_and_stage_definitions.md)

---

## 🚀 Features

- Cloud-native data pipeline using **S3 and Snowflake**
- Interactive dashboards powered by **Power BI**
- Reusable **SQL views** for consistent business logic
- Clean **star schema modeling**
- Modular and scalable structure — ready for real-world deployment

---

## 🛠 Future Enhancements

- Add transformation logic using **dbt**, **Spark**, or **Airflow**
- Schedule automatic S3 → Snowflake loads using **Snowpipe** or **Lambda**
- Integrate **streaming data** from Kafka or Kinesis for real-time updates

---

## 🙋‍♂️ Author

**Sai Karthik Maddirala**  
🔗 [LinkedIn](https://www.linkedin.com/in/sai-karthik-maddirala-916058196/)
🔗 [GitHub Profile](https://github.com/karthikmaddirala)

---

## 📜 License

This project is open for educational and portfolio purposes. Feel free to clone, explore, and enhance it!

