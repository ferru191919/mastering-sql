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
);