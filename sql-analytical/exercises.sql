/*
============================================================
MASTERING SQL
PART 2 — ANALYTICAL SQL EXERCISES
============================================================

Purpose:
Practice the concepts covered in the sql-analytical section.

Topics:
- Subqueries
- Correlated subqueries
- Common Table Expressions (CTEs)
- Recursive CTEs
- Window functions
- Ranking functions
- PARTITION BY
- Windowed aggregates
- Combining analytical techniques

Rules:
- Try to solve every exercise without copying previous examples.
- There may be more than one valid solution.
- Prefer readable SQL.
- Use aliases that clearly describe calculated columns.
- Part 1 concepts are expected knowledge and can be used freely.


============================================================
SECTION 1 — SUBQUERIES
============================================================
*/

-- ---------------------------------------------------------
-- EXERCISE 1 — Products above average price
-- Difficulty: Easy
--
-- Find all products whose unit_price is greater than the
-- average price of ALL products.
--
-- Display:
-- product_name
-- category
-- unit_price
--
-- Sort from the most expensive to the least expensive.

SELECT 
    product_name,
    category,
    unit_price
FROM
    dim_product
WHERE 
    unit_price > (
        SELECT
            AVG(unit_price) AS avg_price
        FROM
            dim_product
    )
ORDER BY unit_price DESC;


-- ---------------------------------------------------------
-- EXERCISE 2 — Orders above average
-- Difficulty: Easy
--
-- Find order lines whose net_amount is greater than the
-- average net_amount of all order lines.
--
-- Display:
-- order_id
-- order_date
-- customer_sk
-- product_sk
-- net_amount
--
-- Sort by net_amount descending.

SELECT
    order_id,
    order_date,
    customer_sk,
    product_sk,
    net_amount
FROM
    fact_order
WHERE
    net_amount > (
        SELECT 
            AVG(net_amount)
        FROM 
            fact_order
    )
ORDER BY net_amount DESC;


-- ---------------------------------------------------------
-- EXERCISE 3 — Customers with orders
-- Difficulty: Easy
--
-- Return customers who have placed at least one order.
--
-- Display:
-- customer_id
-- customer_name
-- country
--
-- Requirement:
-- Do not use a JOIN for this exercise.

SELECT
    customer_id,
    customer_name,
    country
FROM 
    dim_customer
WHERE 
    customer_sk IN (
    SELECT 
        customer_sk
    FROM
        fact_order
);

-- ---------------------------------------------------------
-- EXERCISE 4 — Products never ordered
-- Difficulty: Intermediate
--
-- Find products that have never appeared in fact_order.
--
-- Display:
-- product_id
-- product_name
-- category
-- unit_price
--
-- Requirement:
-- Use a subquery.
--
-- Think carefully about whether IN or NOT IN is appropriate
-- and how NULL values could affect the logic.

SELECT 
    product_id,
    product_name,
    category,
    unit_price
FROM
    dim_product
WHERE 
    product_sk NOT IN (
        SELECT product_sk
        FROM fact_order
        WHERE product_id IS NOT NULL
    );


-- ---------------------------------------------------------
-- EXERCISE 5 — Customer spending table
-- Difficulty: Intermediate
--
-- Display:
-- customer_name
-- country
-- total_spent
--
-- Only return customers whose total_spent is greater than 150.
--
-- Sort by total_spent descending.
--
-- Requirement:
-- The aggregation must happen inside a subquery in FROM.

SELECT
    c.customer_name,
    c.country,
    cs.total_spent
FROM (
    SELECT 
        customer_sk,
        SUM(net_amount) AS total_spent
    FROM 
        fact_order
    GROUP BY 
        customer_sk
) AS cs  -- customer_spending
JOIN dim_customer AS c 
ON cs.customer_sk = c.customer_sk
WHERE cs.total_spent > 150
ORDER BY total_spent DESC;


-- ---------------------------------------------------------
-- EXERCISE 6 — Compare every order line with global average
-- Difficulty: Intermediate
--
-- Display every order line together with the average net_amount
-- across the entire fact_order table.
--
-- Display:
-- order_id
-- product_sk
-- net_amount
-- global_average_net_amount
--
-- Requirement:
-- Use a scalar subquery inside SELECT.

SELECT
    order_id, 
    product_sk,
    net_amount,
    (
        SELECT AVG(net_amount)
        FROM fact_order
    ) AS global_average_net_amount
FROM
    fact_order;


/*
============================================================
SECTION 2 — CORRELATED SUBQUERIES
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 7 — Products above their category average
-- Difficulty: Intermediate
--
-- Find products whose unit_price is greater than the average
-- unit_price of products in the SAME category.
--
-- Display:
-- product_name
-- category
-- unit_price
--
-- Sort by category and then unit_price descending.
--
-- Requirement:
-- Use a correlated subquery.

SELECT 
    p1.product_name,
    p1.category,
    p1.unit_price
FROM
    dim_product AS p1
WHERE 
    p1.unit_price > (
        SELECT  
            AVG(p2.unit_price)
        FROM
            dim_product AS p2
        WHERE
            p1.category = p2.category
    )
ORDER BY category DESC, unit_price DESC;


-- ---------------------------------------------------------
-- EXERCISE 8 — High-value order lines per customer
-- Difficulty: Intermediate
--
-- Find order lines whose net_amount is greater than the
-- average net_amount for that specific customer.
--
-- Display:
-- order_id
-- customer_sk
-- order_date
-- net_amount
--
-- Sort by customer_sk and net_amount descending.
--
-- Requirement:
-- Use a correlated subquery.

SELECT
    o.order_id,
    o.customer_sk,
    o.order_date,
    o.net_amount
FROM
    fact_order o
WHERE 
    o.net_amount > (
        SELECT
            AVG(o2.net_amount)
        FROM
            fact_order o2
        WHERE
            o2.customer_sk = o.customer_sk
    )
ORDER BY o.customer_sk DESC, o.net_amount DESC;


-- ---------------------------------------------------------
-- EXERCISE 9 — Customers above their country's average
-- Difficulty: Challenging
--
-- Calculate each customer's total spending.
--
-- Return only customers whose total spending is greater than
-- the average customer spending for customers from the SAME
-- country.
--
-- Display:
-- customer_name
-- country
-- total_spent
--
-- Think carefully about which level the average must be
-- calculated at.

SELECT
    c.customer_name,
    c.country,
    SUM(o.net_amount) AS total_spent
FROM    
    dim_customer c 
JOIN
    fact_order o ON o.customer_sk = c.customer_sk
GROUP BY 
    c.customer_name, c.country
HAVING SUM(o.net_amount) > (
    SELECT
        AVG(customer_total) AS average_spending
    FROM (
        SELECT
            c2.customer_sk,
            SUM(o2.net_amount) AS customer_total
        FROM 
            fact_order o2
        JOIN dim_customer c2 
        ON o2.customer_sk = c2.customer_sk
        WHERE c2.country = c.country
        GROUP BY c2.customer_sk
        ) country_customers
    );


-- ---------------------------------------------------------
-- EXERCISE 10 — Most expensive product in each category
-- Difficulty: Intermediate
--
-- Find the most expensive product or products in each category.
--
-- Display:
-- product_name
-- category
-- unit_price
--
-- Important:
-- If two products share the same highest price in a category,
-- both should appear.
--
-- Requirement:
-- Solve this using a correlated subquery.

SELECT 
    product_name,
    category,
    unit_price
FROM
    dim_product p
JOIN 
    fact_order o ON o.product_sk = p.product_sk
WHERE 
    unit_price = (
        SELECT MAX(unit_price)
        FROM fact_order o2
        JOIN dim_product p2 ON o2.product_sk = p2.product_sk
        WHERE p2.category = p.category
        )
GROUP BY
    product_name, category, unit_price;


/*
============================================================
SECTION 3 — COMMON TABLE EXPRESSIONS
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 11 — Customer spending with a CTE
-- Difficulty: Easy / Intermediate
--
-- Create a CTE that calculates:
--
-- customer_sk
-- total_spent
--
-- Then join the CTE to dim_customer.
--
-- Display:
-- customer_name
-- country
-- total_spent
--
-- Sort by total_spent descending.

