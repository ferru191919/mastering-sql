-- HAVING clause is used to filter results of aggregted rows (SUM; AVG; etc...).
-- WHERE clause is used to filter non-aggregated rows.


-- Orders where one product generated more than 100 dollars (WHERE clause)
SELECT 
    order_id,
    product_sk,
    amount
FROM fact_order
WHERE amount > 100;


-- Orders with more than 3 items of the same product (HAVING clause)
SELECT
    order_id,
    product_sk,
    SUM(quantity) AS items_number
FROM fact_order
GROUP BY order_id, product_sk
HAVING SUM(quantity) > 3;
