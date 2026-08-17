-- DDL (Data Definition Language) = used to create and modify database objects like tables, 
--                                  indexes, views, and constraints (e.g. CREATE TABLE, ALTER TABLE).


-- CREATE TABLE: you can create a new table with columns. It’ll be empty of values:
CREATE TABLE dim_date (
    date_sk      INTEGER,    -- name of column, and value type
    full_date    DATE,                  
    year         INTEGER,
    month        INTEGER,            
    month_name   VARCHAR(20),
    quarter      INTEGER    
);

-- When creating the table, we need to define CONSTRAINTS:
--                  - PIMARY KEY
--                  - NOT NULL
--                  - UNIQUE
--                  - FOREIGN KEY

CREATE TABLE fact_order IF NOT EXISTS (
    order_id        INTEGER NOT NULL,
    order_date      DATE NOT NULL,
    customer_sk     INTEGER NOT NULL,
    product_sk      INTEGER NOT NULL,
    quantity        INTEGER NOT NULL,
    amount          NUMERIC(10,2) NOT NULL,
    order_year      INTEGER,
    order_month     TEXT,
    discount_amount NUMERIC(10,2),
    net_amount      NUMERIC(10,2),           
    PRIMARY KEY (order_id, customer_sk, product_sk),
    FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
    FOREIGN KEY (product_sk)  REFERENCES dim_product(product_sk)
);
)

-- With “ALTER TABLE”, we can change the structure of a column:
ALTER TABLE  dim_date
ADD  year_name  VARCHAR(20);        					-- to add a column
----
ALTER TABLE  table_name 
RENAME COLUMN  old_name  TO  new_name;        	        -- to rename a column
----
ALTER TABLE  dim_date 
DROP COLUMN  year_name;	         			         -- to delete a column
----

-- With TRUNCATE TABLE, we can delete all the rows from a table:
TRUNCATE TABLE dim_date;

-- With DROP TABLE, we can delete an entire table:
DROP TABLE dim_date;

-------------------------------------------------------------------

-- CREATE VIEW for saved, reusable query logic: 
CREATE VIEW customer_revenue_summary AS
SELECT
    c.customer_sk,
    c.customer_name,
    c.country,
    SUM(f.amount) AS total_revenue,
    COUNT(DISTINCT f.order_id) AS order_count
FROM fact_order AS f
JOIN dim_customer AS c
    ON f.customer_sk = c.customer_sk
GROUP BY
    c.customer_sk,
    c.customer_name,
    c.country;

-- Now, just need to query the view just as you would query a table:
SELECT
    customer_name,
    country,
    total_revenue,
    order_count
FROM customer_revenue_summary  -- the view
ORDER BY total_revenue DESC;

-- ALTER VIEW and DROP VIEW work the same as with tables
DROP VIEW customer_revenue_summary;

---------------------------------------------------------------

-- TABLE SCAN = it's a sequential scan where PostgreSQL reads row by row the entire table 
--              to apply filters.
SELECT *
FROM fact_order
WHERE customer_sk = 10;
--             Without a useful index, PostgreSQL may inspect every row in fact_order to 
--             find rows with customer_sk = 10.


-- INDEX = a separate, sorted structure that lets the database find rows quickly 
--         without scanning the whole table.
CREATE INDEX idx_fact_order_customer_sk
ON fact_order (customer_sk);

--      Trade-off: indexes improve many reads, but consume storage and add work to INSERT, 
--                 UPDATE, and DELETE, because the index must also be updated. 
--                 Create indexes based on actual query patterns, not on every column.


-- How to know what kind of scanning does PostgreSQL apply?
EXPLAIN     -- It does not run the SELECT
SELECT *
FROM fact_order
WHERE customer_sk = 12;

EXPLAIN ANALYZE     -- This actually runs the query
SELECT *
FROM fact_order
WHERE customer_sk = 12;

-- Safety rule:
-- Use plain EXPLAIN freely for any statement. Be cautious with EXPLAIN ANALYZE on INSERT, 
-- UPDATE, or DELETE, because it executes the statement and therefore can modify data. 

-- For a safe test of a data-changing statement, place it in a transaction and finish 
-- with ROLLBACK:

BEGIN;

EXPLAIN ANALYZE
UPDATE dim_product
SET unit_price = 160.00
WHERE product_id = 201;

ROLLBACK;   -- ROLLBACK is the “undo” command for everything done after BEGIN and before COMMIT.

---------------------------------

-- PARTITIONING = dividing the original, big table into smaller tables.

CREATE TABLE fact_order IF NOT EXISTS(
    order_id        INTEGER NOT NULL,
    order_date      DATE NOT NULL,
    customer_sk     INTEGER NOT NULL,
    product_sk      INTEGER NOT NULL,
    quantity        INTEGER NOT NULL,
    amount          NUMERIC(10,2) NOT NULL,
    order_year      INTEGER,
    order_month     TEXT,
    discount_amount NUMERIC(10,2),
    net_amount      NUMERIC(10,2),
    PRIMARY KEY (order_id, customer_sk, product_sk, order_date),
    FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk),
    FOREIGN KEY (product_sk) REFERENCES dim_product(product_sk)
)
PARTITION BY RANGE (order_date);    -- partitioned by date ranges

-- examples:
CREATE TABLE fact_order_2024_12
PARTITION OF fact_order
FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');

CREATE TABLE fact_order_2025_01
PARTITION OF fact_order
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- Main benefits:
--     - Faster date-filtered queries: if you request only December 2024 orders, PostgreSQL can skip partitions for all other months. This is called partition pruning.
--     - Easier cleanup: removing old data can mean dropping one old partition instead of running a slow DELETE across millions of rows; this also avoids the cleanup overhead associated with large deletes.
--     - Smaller indexes: each partition can have smaller indexes, which are often easier to keep in memory and maintain.
--     - Data lifecycle management: recent orders can stay on faster storage while old historical partitions can be archived or moved to less expensive storage.

-- When not to use it:
-- Do not partition merely because a table exists. Your current seeded fact_order has only a few dozen rows, so partitioning would add complexity without a useful performance gain.
