-- Correlated Subqueries = The inner query depends on a value from the outer query.

-- Example:
-- Find products that cost more than the average product in their own category.

SELECT
    p.product_name,
    p.category,
    p.unit_price
FROM dim_product AS p
WHERE p.unit_price > (
    SELECT AVG(p2.unit_price)
    FROM dim_product AS p2
    WHERE p2.category = p.category  -- 'p' refers to the outer query
);


-- Example 2:
-- Find order lines whose amount is greater than the average order-line amount 
-- for that customer.

SELECT
    f.order_id,
    f.customer_sk,
    f.amount
FROM fact_order AS f
WHERE f.amount > (
    SELECT AVG(f2.amount)
    FROM fact_order AS f2
    WHERE f2.customer_sk = f.customer_sk
);