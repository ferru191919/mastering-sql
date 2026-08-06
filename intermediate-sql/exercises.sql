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


-- Exercise 3: Identify customers whose total revenue is greater than the average revenue
--             of all customers in the same country.
WITH customer_revenue AS (
    SELECT
        c.customer_sk,
        c.customer_name,
        c.country,
        SUM(o.amount) AS per_customer_revenue
    FROM fact_order o
    JOIN dim_customer c
    ON o.customer_sk = c.customer_sk
    GROUP BY c.customer_sk, c.customer_name, c.country
),
avg_amount AS (
    SELECT
        country,
        AVG(per_customer_revenue) AS avg_revenue
    FROM customer_revenue
    GROUP BY country
)
SELECT
    cr.customer_sk,
    cr.customer_name,
    cr.country,
    cr.per_customer_revenue,
    a.avg_revenue
FROM customer_revenue cr
JOIN avg_amount a
ON a.country = cr.country
WHERE cr.per_customer_revenue > a.avg_revenue;


-- Exercise 4: Show monthly net revenue by country and calculate a cumulative revenue total 
--             over time for each country.
WITH m_net_revenue AS(
    SELECT
        c.country,
        o.order_month,
        SUM(o.net_amount) AS monthly_net_revenue
    FROM dim_customer c
    JOIN fact_order o
    ON c.customer_sk = o.customer_sk
    GROUP BY c.country, o.order_month
    ORDER BY c.country, o.order_month ASC
)
SELECT 
    country,
    order_month,
    monthly_net_revenue,
    SUM(monthly_net_revenue) OVER ( 
        PARTITION BY country 
        ORDER BY order_month ASC 
        ) AS cum_revenue          -- cumulative total
FROM m_net_revenue;


-- Exercise 5: Classify customers into revenue bands such as low, medium, and high value 
--             based on their total net revenue.
WITH customer_revenue AS (
    SELECT
        c.customer_sk,
        c.customer_name,
        c.country,
        SUM(o.net_amount) AS per_customer_net_revenue
    FROM fact_order o
    JOIN dim_customer c
    ON o.customer_sk = c.customer_sk
    GROUP BY c.customer_sk, c.customer_name, c.country
) -- I'm reusing previous CTEs
SELECT 
    customer_sk,
    per_customer_net_revenue,
    CASE 
        WHEN per_customer_net_revenue < 60 THEN 'low_value'
        WHEN per_customer_net_revenue < 120 THEN 'medium_value'
        ELSE 'high_value'
    END AS customer_bands
FROM customer_revenue;


-- Exercise 6: For each month, find the top 2 product categories by total revenue.
SELECT *
FROM (
    SELECT 
        p.category,
        o.order_month,
        SUM(o.amount) AS total_revenue,
        RANK() OVER (PARTITION BY o.order_month ORDER BY SUM(o.amount) DESC) AS top_category
    FROM dim_product p
    JOIN fact_order o
    ON p.product_sk = o.product_sk
    GROUP BY p.category, o.order_month
)
WHERE top_category <= 2; 


-- Exercise 7: Find customers who placed more than one order and rank them by total number 
--             of orders within each country.
WITH customer_orders AS (
    SELECT
        customer_sk,
        COUNT(order_id) AS order_per_customer
    FROM fact_order
    GROUP BY customer_sk
    HAVING COUNT(order_id) >= 2
)
SELECT 
    co.customer_sk,
    c.country,
    co.order_per_customer,
    DENSE_RANK() OVER (PARTITION BY c.country ORDER BY co.order_per_customer DESC) AS top_customer
FROM dim_customer c 
JOIN customer_orders co 
    ON c.customer_sk = co.customer_sk;


-- Exercise 8: For each country, calculate how much of total country revenue is contributed 
--             by each customer, then return only customers contributing more than 10%.
WITH nation_revenue AS (
    SELECT
        c.country,
        SUM(o.amount) AS total_country_revenue
    FROM dim_customer AS c
    JOIN fact_order AS o
        ON c.customer_sk = o.customer_sk
    GROUP BY c.country
),
customer_revenue AS (
    SELECT
        c.customer_sk,
        c.customer_name,
        c.country,
        SUM(o.amount) AS total_customer_revenue
    FROM fact_order AS o
    JOIN dim_customer AS c
        ON o.customer_sk = c.customer_sk
    GROUP BY
        c.customer_sk,
        c.customer_name,
        c.country
)
SELECT
    cr.customer_sk,
    cr.customer_name,
    cr.country,
    cr.total_customer_revenue,
    nr.total_country_revenue,
    cr.total_customer_revenue / nr.total_country_revenue * 100.0 AS contribution_percentage
FROM customer_revenue AS cr
JOIN nation_revenue AS nr
    ON cr.country = nr.country
WHERE cr.total_customer_revenue / nr.total_country_revenue * 100.0 > 10
ORDER BY contribution_percentage DESC;

    


