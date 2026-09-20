# Data Catalog

The Gold layer follows a **star schema** designed for reporting and business intelligence. It contains customer and product dimensions connected to a central sales fact table.

## gold.dim_customers

Stores customer identification and demographic information.

| Column          | Data Type    | Description                          | Example    |
| --------------- | ------------ | ------------------------------------ | ---------- |
| customer_key    | INT          | Surrogate key for the customer       | 1          |
| customer_id     | INT          | Source system customer ID            | 11000      |
| customer_number | NVARCHAR(50) | Customer reference code              | AW00011000 |
| first_name      | NVARCHAR(50) | Customer first name                  | Elizabeth  |
| last_name       | NVARCHAR(50) | Customer last name                   | Johnson    |
| country         | NVARCHAR(50) | Customer's country                   | Germany    |
| marital_status  | NVARCHAR(50) | Marital status                       | Married    |
| gender          | NVARCHAR(50) | Gender classification                | Female     |
| birthdate       | DATE         | Customer date of birth               | 1985-06-15 |
| create_date     | DATE         | Date the customer record was created | 2025-10-06 |

## gold.dim_products

Stores product details and classification information.

| Column         | Data Type    | Description                     | Example    |
| -------------- | ------------ | ------------------------------- | ---------- |
| product_key    | INT          | Surrogate key for the product   | 1          |
| product_id     | INT          | Source system product ID        | 101        |
| product_number | NVARCHAR(50) | Product reference code          | BK-R93R-62 |
| category_id    | NVARCHAR(50) | Product category identifier     | 1          |
| category       | NVARCHAR(50) | Main product category           | Bikes      |
| subcategory    | NVARCHAR(50) | Product subcategory             | Road Bikes |
| maintenance    | NVARCHAR(50) | Whether maintenance is required | Yes        |
| cost           | INT          | Standard product cost           | 3578       |
| product_line   | NVARCHAR(50) | Product line                    | Road       |
| start_date     | DATE         | Date the product became active  | 2010-12-29 |

## gold.fact_sales

Contains sales transactions and their associated measures.

| Column        | Data Type    | Description                | Example    |
| ------------- | ------------ | -------------------------- | ---------- |
| order_number  | NVARCHAR(50) | Sales order identifier     | SO43697    |
| product_key   | INT          | Links to `dim_products`    | 101        |
| customer_key  | INT          | Links to `dim_customers`   | 25         |
| order_date    | DATE         | Date the order was placed  | 2010-12-29 |
| shipping_date | DATE         | Date the order was shipped | 2011-01-05 |
| due_date      | DATE         | Payment due date           | 2011-01-10 |
| sales_amount  | INT          | Total sales amount         | 3578       |
| quantity      | INT          | Number of units sold       | 1          |
| price         | INT          | Selling price per unit     | 3578       |
