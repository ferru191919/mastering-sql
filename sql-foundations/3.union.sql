-- JOIN combines table horizontally.
-- UNION combines table vertically.


-- UNION:
SELECT
    customer_name AS name
FROM dim_customer

UNION       -- combines the results of two queries and REMOVES DUPLICATES rows. 

SELECT
    product_name AS product
FROM dim_product;


-- UNION ALL:
SELECT
    customer_name AS name
FROM dim_customer

UNION ALL       -- combines the results of two queries and KEEPS DUPLICATES rows. 

SELECT
    product_name AS product
FROM dim_product;

-- this is used, for instance, when I have datasets with the same logical structure 
-- coming from different places, and I need to combine them into one dataset (multiple source system).
