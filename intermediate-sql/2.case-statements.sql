-- CASE statement is SQL's way of handling if/then logic.

-- Structure:
--  CASE
--    WHEN condition1 THEN result1
--    WHEN condition2 THEN result2
--    ...
--    ELSE default_result
--  END AS new_column


-- Example: 
-- Segment products into price bands: “Budget”, “Mid‑range”, “Premium” based on unit_price.

SELECT
    product_name, category, unit_price,
    CASE
        WHEN unit_price < 20 THEN 'Budget'
        WHEN unit_price < 60 THEN 'Mid-range'
        ELSE 'Premium'
    END AS price_segment  -- cretaed a new column without changing table structure
FROM dim_product;  


-- CASE statements can also be placed outside of SELECT
-- Example: ORDER BY with CASE
SELECT product_name, category, unit_price
FROM dim_product
ORDER BY
    CASE
        WHEN category = 'Sportswear' THEN 1
        ELSE 2
    END,
    unit_price DESC;

