-- Common Table Expressions (CTEs) are temporary, virtual, named result set defined within 
-- an SQL query using the WITH keyword, which is used to simplify complex queries by breaking 
-- them into smaller, more manageable parts.

-- Structure:
--  WITH cte_name AS (
--      SELECT ...
--      FROM ...
--      WHERE ...
--  )

-- When using CTEs instead of subqueries?
--   - Use subquery for quick, one-off logic you use only once.
--   - Use CTEs for more complex or reusable intermediate results.


-- Exercise 1: top customers by spend
WITH per_customer AS(
    SELECT
        customer_sk,
        SUM(amount) AS total_spent
    FROM fact_order
    GROUP BY customer_sk
)
SELECT
    c.customer_name,
    c.country,
    per_customer.total_spent,
    ROW_NUMBER() OVER (ORDER BY per_customer.total_spent DESC) AS top_customer
FROM per_customer
JOIN dim_customer c
ON per_customer.customer_sk = c.customer_sk
WHERE per_customer.total_spent > 160;


-- Exercise 2: segment customers by spend
WITH per_customer AS(
    SELECT
        customer_sk,
        SUM(amount) AS total_spent
    FROM fact_order
    GROUP BY customer_sk
)
SELECT 
    c.customer_name,
    c.country,
    per_customer.total_spent,
        CASE
            WHEN per_customer.total_spent >= 160 THEN 'High spender'
            WHEN per_customer.total_spent >= 100 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spend_segment
FROM per_customer
JOIN dim_customer AS c
ON per_customer.customer_sk = c.customer_sk
ORDER BY per_customer.total_spent DESC;