-- A Subquery is a query nested inside another query.
-- Subqueries are great when you need one extra calculation or filter “inside” your main query.


-- Subquery in FROM (top customers by spend)
SELECT
    c.customer_name,
    c.country,
    per_customer.total_spent,
    ROW_NUMBER() OVER (ORDER BY per_customer.total_spent DESC) AS top_customer
FROM (
    SELECT
        customer_sk,
        SUM(amount) AS total_spent
    FROM fact_order
    GROUP BY customer_sk
) AS per_customer
JOIN dim_customer c
ON per_customer.customer_sk = c.customer_sk
WHERE per_customer.total_spent > 160;


-- Subquery in SELECT (AVG without GROUP BY)
SELECT
    order_id,
    customer_sk,
    amount,
    (SELECT AVG(amount) FROM fact_order) AS avg_amount_all_orders
FROM fact_order;


-- Subquery with WHERE IN (customers who placed at least one order)
SELECT
    customer_name,
    country
FROM dim_customer
WHERE customer_sk IN (
    SELECT DISTINCT customer_sk
    FROM fact_order
); -- not alias for subquery in WHERE


-- NULL values and WHERE IN / NOT IN:
--
-- IN:
SELECT
    customer_id,
    customer_name,
    country
FROM 
    dim_customer
WHERE 
    customer_id IN (  
    SELECT 
        customer_id
    FROM
        fact_order
);                      -- in case of NULL values, WHERE IN returns all customers that surely 
                        -- are in fact_order
--
-- NOT IN:
SELECT
    customer_id,
    customer_name,
    country
FROM 
    dim_customer
WHERE 
    customer_id NOT IN (  
    SELECT 
        customer_id
    FROM
        fact_order
);                      -- in case of NULL values, WHERE NOT IN might return no value
                        -- event if there's a customer not in fact_order.

--
-- WHERE IN and NOT IN work differently.
-- 
-- IN        uses OR
-- NOT IN    behaves like AND with <>
--
--
-- For instance:
-- For a customer with customer_id = 1, this:
-- 1 IN (1, 2, NULL)
-- 
-- is effectively:
-- 1 = 1
-- OR 1 = 2
-- OR 1 = NULL

-- which becomes:
-- TRUE
-- OR FALSE
-- OR UNKNOWN
-- 
-- And:
-- TRUE OR UNKNOWN = TRUE
--
-- So customer 1 is returned.
--
--
-- Instead:
-- For a customer with customer_id = 1, this:
-- 1 NOT IN (1, 2, NULL)
-- 
-- is effectively:
-- 1 = 1
-- AND 1 = 2
-- AND 1 = NULL

-- which becomes:
-- FALSE
-- AND TRUE
-- AND UNKNOWN
-- 
-- Therefore:
-- TRUE AND UNKNOWN = UNKNOWN
--
-- So customer 2 is NOT returned.
--
--
-- Correct query:
SELECT
    customer_id,
    customer_name,
    country
FROM 
    dim_customer
WHERE 
    customer_id NOT IN (  
    SELECT 
        customer_id
    FROM
        fact_order
    WHERE customer_id IS NOT NULL   -- IS NOT NULL filter.
); 