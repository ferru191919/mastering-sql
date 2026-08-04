-- My queries are running on VS Code, using DBCode extension for SQLite.

-- Included learning topics: aggregations, joins, window functions, case statements,
--                           subqueries, CTEs.

-- Exercise 1: # Find the top 3 customers by total net revenue.
SELECT
    o.customer_sk,
    c.customer_name, 
    c.country,
    SUM(net_amount) AS per_customer_net_revenue
FROM fact_order AS o
JOIN dim_customer AS c
ON c.customer_sk = o.customer_sk
GROUP BY o.customer_sk, c.customer_name, c.country
ORDER BY per_customer_net_revenue DESC
LIMIT 3;


-- Exercise 2: # For each country, find the top 3 customers by total net revenue.
SELECT * 
FROM
    (
    SELECT
        o.customer_sk,
        c.customer_name, 
        c.country,
        SUM(net_amount) AS per_customer_net_revenue,
        ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY SUM(net_amount) DESC) AS top_customer
    FROM fact_order AS o
    JOIN dim_customer AS c
    ON c.customer_sk = o.customer_sk
    GROUP BY o.customer_sk, c.customer_name, c.country
    ) AS revenue
WHERE top_customer <= 3;


