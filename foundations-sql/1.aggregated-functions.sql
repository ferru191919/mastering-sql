-- Aggregated functions: MAX, MIN, AVG, SUM, COUNT, ...
-- Aggregate functions = take multiple rows and calculate one result from them.

SELECT COUNT(*)     -- calculates the total number of rows in fact table
FROM fact_order; 

SELECT COUNT(DISTINCT order_id)     -- calculates the number of distinct orders (with different order_id)
FROM fact_order;
-----------------------------------

-- To filter results:
--      WHERE filters rows BEFORE aggregation;
--      HAVING filters groups AFTER aggregation;

SELECT
    SUM(net_amount) AS total_revenue
FROM fact_order
WHERE order_date BETWEEN DATE '2024-09-01' AND DATE '2024-12-31' -- non aggregated rows.
HAVING SUM(net_amount) > 100;         -- aggregated rows.
