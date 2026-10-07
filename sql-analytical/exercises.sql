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

WITH customer_total_spending AS (
    SELECT  
        customer_sk,
        SUM(net_amount) AS total_spent
    FROM
        fact_order
    GROUP BY customer_sk
)
SELECT 
    c.customer_name,
    c.country,
    cts.total_spent
FROM
    dim_customer c 
JOIN        
    customer_total_spending cts ON cts.customer_sk = c.customer_sk
ORDER BY cts.total_spent DESC;


-- ---------------------------------------------------------
-- EXERCISE 12 — Spending classification
-- Difficulty: Intermediate
--
-- Create a CTE containing total spending per customer.
--
-- Then classify customers as:
--
-- total_spent >= 200
--     -> 'High Spender'
--
-- total_spent >= 100
--     -> 'Medium Spender'
--
-- otherwise
--     -> 'Low Spender'
--
-- Display:
-- customer_name
-- country
-- total_spent
-- spending_category
--
-- Sort by total_spent descending.

WITH customer_total_spending AS (
    SELECT  
        customer_sk,
        SUM(net_amount) AS total_spent
    FROM
        fact_order
    GROUP BY customer_sk
)
SELECT 
    c.customer_name,
    c.country,
    cts.total_spent,
    CASE
        WHEN cts.total_spent >= 200 THEN 'High Spender'
        WHEN cts.total_spent >= 100 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_category
FROM
    dim_customer c 
JOIN        
    customer_total_spending cts ON cts.customer_sk = c.customer_sk
ORDER BY cts.total_spent DESC;


-- ---------------------------------------------------------
-- EXERCISE 13 — Product performance
-- Difficulty: Intermediate
--
-- Create a CTE that calculates sales performance for every
-- product that has been ordered.
--
-- The CTE should calculate:
-- product_sk
-- total_quantity
-- total_revenue
--
-- Then join it to dim_product.
--
-- Display:
-- product_name
-- category
-- total_quantity
-- total_revenue
--
-- Sort by total_revenue descending.

WITH product_sales_performance AS (
    SELECT
        product_sk,
        SUM(quantity) AS total_quantity,
        SUM(net_amount) AS total_revenue 
    FROM 
        fact_order 
    GROUP BY product_sk
)
SELECT 
    p.product_name, 
    p.category,
    psp.total_quantity,
    psp.total_revenue
FROM
    product_sales_performance psp
JOIN
    dim_product p ON psp.product_sk = p.product_sk
ORDER BY psp.total_revenue DESC;


-- ---------------------------------------------------------
-- EXERCISE 14 — Multiple CTEs
-- Difficulty: Intermediate / Challenging
--
-- Build a query containing TWO CTEs.
--
-- CTE 1:
-- Calculate total spending per customer.
--
-- CTE 2:
-- Calculate the overall average customer spending.
--
-- Final query:
-- Return only customers whose spending is greater than the
-- overall customer average.
--
-- Display:
-- customer_name
-- country
-- total_spent
-- average_customer_spending
--
-- Sort by total_spent descending.

WITH customer_total_spending AS (
    SELECT
        customer_sk,
        SUM(net_amount) AS total_spent
    FROM
        fact_order
    GROUP BY 
        customer_sk
),
average_customer_spending AS (
    SELECT
        AVG(total_spent) AS avg_spent
    FROM
        customer_total_spending
)
SELECT
    c.customer_name,
    c.country,
    cts.total_spent,
    acs.avg_spent
FROM
    dim_customer c 
JOIN
    customer_total_spending cts ON cts.customer_sk = c.customer_sk
CROSS JOIN
    average_customer_spending acs
WHERE 
    cts.total_spent > acs.avg_spent
ORDER BY cts.total_spent DESC;


-- ---------------------------------------------------------
-- EXERCISE 15 — Country revenue summary
-- Difficulty: Intermediate
--
-- Use a CTE to calculate revenue per customer.
--
-- Then create a final report grouped by country.
--
-- Display:
-- country
-- number_of_customers
-- total_revenue
-- average_revenue_per_customer
--
-- Only include customers who have placed orders.
--
-- Sort by total_revenue descending.

WITH revenue_per_customer AS (
    SELECT
        customer_sk,
        SUM(net_amount) AS customer_revenue
    FROM fact_order
    GROUP BY customer_sk
    HAVING SUM(net_amount) > 0
)
SELECT
    c.country,
    COUNT (c.customer_sk) AS number_of_customers,
    SUM(rpc.customer_revenue) AS total_revenue,
    AVG(rpc.customer_revenue) AS avg_revenue
FROM
    dim_customer c 
JOIN
    revenue_per_customer rpc ON rpc.customer_sk = c.customer_sk
GROUP BY c.country
ORDER BY total_revenue DESC;


/*
============================================================
SECTION 4 — RECURSIVE CTEs
============================================================

These warehouse tables do not naturally contain hierarchical
parent/child data.

For this reason, the exercises about this section will be skipped
============================================================
*/



/*
============================================================
SECTION 5 — WINDOW FUNCTIONS
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 20 — Product price ranking
-- Difficulty: Easy
--
-- Rank all products from most expensive to least expensive.
--
-- Display:
-- product_name
-- category
-- unit_price
-- price_position
--
-- Requirement:
-- Use ROW_NUMBER().

SELECT 
    product_name,
    category,
    unit_price,
    ROW_NUMBER() OVER (ORDER BY unit_price DESC) AS price_position
FROM    
    dim_product;


-- ---------------------------------------------------------
-- EXERCISE 21 — Rank within category
-- Difficulty: Easy / Intermediate
--
-- Rank products by unit_price within each category.
--
-- The ranking must restart from 1 for every category.
--
-- Display:
-- product_name
-- category
-- unit_price
-- category_position

SELECT
    product_name,
    category,
    unit_price,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY unit_price DESC) AS category_position
FROM dim_product;


-- ---------------------------------------------------------
-- EXERCISE 22 — ROW_NUMBER vs RANK vs DENSE_RANK
-- Difficulty: Intermediate
--
-- Display every product with THREE ranking columns:
--
-- row_number_position
-- rank_position
-- dense_rank_position
--
-- Rank products by unit_price descending.
--
-- Display:
-- product_name
-- unit_price
-- row_number_position
-- rank_position
-- dense_rank_position
--
-- Examine what happens when multiple products have the
-- same unit_price.
--

SELECT
    product_name,
    unit_price,
    ROW_NUMBER() OVER (ORDER BY unit_price DESC) AS row_number_position,
    RANK() OVER (ORDER BY unit_price DESC) AS rank_position,
    DENSE_RANK() OVER (ORDER BY unit_price DESC) AS dense_rank_position
FROM dim_product;


-- ---------------------------------------------------------
-- EXERCISE 23 — Top 3 products per category
-- Difficulty: Intermediate
--
-- Return the three most expensive products from each category.
--
-- Display:
-- product_name
-- category
-- unit_price
-- category_position
--
-- Think about why a window function cannot normally be filtered
-- directly in the WHERE clause of the same SELECT.

SELECT *
FROM (
    SELECT
        product_name,
        category,
        unit_price,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY unit_price DESC) AS category_position
    FROM
        dim_product)
WHERE category_position <= 3;


-- ---------------------------------------------------------
-- EXERCISE 24 — Order total on every line
-- Difficulty: Intermediate
--
-- For every order line, display:
--
-- order_id
-- product_sk
-- quantity
-- net_amount
-- total_order_value
--
-- total_order_value should represent the total value of the
-- entire order, while still keeping every individual order
-- line visible.
--
-- Requirement:
-- Do not use GROUP BY.

SELECT  
    order_id,
    product_sk,
    quantity,
    net_amount,
    SUM(net_amount) OVER (PARTITION BY order_id) AS total_order_value
FROM fact_order;


-- ---------------------------------------------------------
-- EXERCISE 25 — Customer lifetime spending
-- Difficulty: Intermediate
--
-- For every order line, display:
--
-- customer_sk
-- order_id
-- order_date
-- net_amount
-- customer_total_spending
--
-- customer_total_spending must show the customer's total
-- spending across all their order lines without collapsing
-- the rows.

SELECT 
    customer_sk,
    order_id,
    order_date,
    net_amount,
    SUM(net_amount) OVER (PARTITION BY customer_sk) AS customer_total_spending
FROM fact_order;


-- ---------------------------------------------------------
-- EXERCISE 26 — Percentage of order value
-- Difficulty: Intermediate / Challenging
--
-- For every order line, calculate what percentage of the
-- complete order value that line represents.
--
-- Display:
-- order_id
-- product_sk
-- net_amount
-- total_order_value
-- percentage_of_order
--
-- Example idea:
--
-- If an order total's 200 and one line is worth 50,
-- that line represents 25% of the order.
--
-- Keep every order line visible.

SELECT
    order_id,
    product_sk,
    net_amount,
    SUM(net_amount) OVER (PARTITION BY order_id) AS total_order_value,
    100.0 * net_amount / SUM(net_amount) OVER (PARTITION BY order_id) 
        AS percentage_of_order
FROM fact_order;


-- ---------------------------------------------------------
-- EXERCISE 27 — Percentage of customer spending
-- Difficulty: Challenging
--
-- Calculate total spending for every customer.
--
-- Then calculate what percentage of ALL customer spending
-- belongs to each customer.
--
-- Display:
-- customer_name
-- total_spent
-- overall_spending
-- percentage_of_total
--
-- Sort by percentage_of_total descending.
--
-- Requirement:
-- Try to solve this using a CTE together with a window
-- aggregate.

WITH spending_per_customer AS (
    SELECT 
        customer_sk,
        SUM(net_amount) AS total_spent
    FROM 
        fact_order
    GROUP BY
        customer_sk
),
overall_total_spending AS (
    SELECT
        SUM(total_spent) AS overall_spending
    FROM
        spending_per_customer
)
SELECT 
    c.customer_name,
    spc.total_spent,
    ots.overall_spending,
    100 * spc.total_spent / ots.overall_spending AS percentage_of_total_spending
FROM
    dim_customer c
JOIN
    spending_per_customer spc ON c.customer_sk = spc.customer_sk
CROSS JOIN
    overall_total_spending ots
ORDER BY percentage_of_total_spending DESC;


/*
============================================================
SECTION 7 — COMBINED ANALYTICAL CHALLENGES
============================================================

From this point onward, the exercise does NOT tell you exactly
which analytical technique to use.

Choose between:
- subqueries
- correlated subqueries
- CTEs
- window functions
- combinations of them
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 28 — Best customer in each country
-- Difficulty: Challenging
--
-- Find the highest-spending customer in each country.
--
-- Display:
-- country
-- customer_name
-- total_spent
--
-- If two customers tie for first place, decide whether your
-- report should include both and choose the appropriate ranking
-- behavior.
-- ---------------------------------------------------------





-- ---------------------------------------------------------
-- EXERCISE 29 — Top 2 products per category by revenue
-- Difficulty: Challenging
--
-- Calculate total revenue generated by each product.
--
-- Then return the two highest-revenue products within each
-- product category.
--
-- Display:
-- category
-- product_name
-- total_quantity
-- total_revenue
-- category_position
--
-- Sort by category and category_position.
-- ---------------------------------------------------------





-- ---------------------------------------------------------
-- EXERCISE 30 — Customers above country average
-- Difficulty: Challenging
--
-- Calculate total spending per customer.
--
-- For every customer, compare their spending with the average
-- customer spending in their country.
--
-- Return only customers whose total spending is above their
-- country's average.
--
-- Display:
-- customer_name
-- country
-- total_spent
-- country_average
-- difference_from_country_average
--
-- Sort by difference_from_country_average descending.
-- ---------------------------------------------------------





-- ---------------------------------------------------------
-- EXERCISE 31 — Category revenue contribution
-- Difficulty: Challenging
--
-- Calculate revenue for each product.
--
-- For each product, display:
--
-- product_name
-- category
-- product_revenue
-- category_revenue
-- percentage_of_category_revenue
--
-- This tells you how much each product contributes to the
-- revenue of its own category.
--
-- Sort by category and percentage_of_category_revenue
-- descending.
-- ---------------------------------------------------------





-- ---------------------------------------------------------
-- EXERCISE 32 — Global product revenue ranking
-- Difficulty: Challenging
--
-- Calculate:
--
-- product_name
-- category
-- total_quantity_sold
-- total_revenue
-- global_revenue_rank
-- category_revenue_rank
--
-- global_revenue_rank:
-- rank against every product.
--
-- category_revenue_rank:
-- rank only against products from the same category.
--
-- Produce both rankings in the same result.
-- ---------------------------------------------------------





-- ---------------------------------------------------------
-- EXERCISE 33 — Customer summary dashboard
-- Difficulty: Challenging
--
-- Produce one analytical report containing one row per
-- customer who has ordered.
--
-- Display:
--
-- customer_name
-- country
-- number_of_orders
-- total_quantity
-- total_spent
-- global_spending_rank
-- country_spending_rank
--
-- Remember:
-- fact_order contains order lines, so number_of_orders must
-- represent distinct actual orders.
--
-- Sort by global_spending_rank.
-- ---------------------------------------------------------