-- JOIN combines table horizontally.
-- UNION combines table vertically.


-- UNION:
SELECT
    customer_name AS name
FROM dim_customer

UNION       -- combines the results of two queries and REMOVES DUPLICATES rows. 

SELECT
    product_name
FROM dim_product

ORDER BY name DESC
LIMIT 15;


-- UNION ALL:
SELECT
    customer_name AS name
    'Customer' AS type
FROM dim_customer

UNION ALL       -- combines the results of two queries and KEEPS DUPLICATES rows. 

SELECT
    product_name
    'Product'
FROM dim_product

ORDER BY name DESC
LIMIT 15;

-- this is used, for instance, when I have datasets with the same logical structure 
-- coming from different places, and I need to combine them into one dataset (multiple source system).