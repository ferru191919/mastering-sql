-- SQL window functions allow performing calculations across a set of rows, 
-- without collapsing the result into a single value.

-- I want to order the products from the most expensive to the least expensive.
SELECT product_name, unit_price
FROM dim_product
ORDER BY unit_price DESC;

-- Now I want to create an "Expensive" column to rank the products.
SELECT product_name, unit_price,
       ROW_NUMBER() OVER (ORDER BY unit_price DESC) AS Expensive
FROM dim_product;

-- The OVER clause defines the “window” of rows for the calculation. It can:
--          - PARTITION BY: It divides the data into groups using PARTITION BY.
--          - ORDER BY: It specifies the order of rows within each group using ORDER BY.
--
-- ROW_NUMBER() is the function. Other functions are:
--                                - RANK()
--                                - DENSE_RANK()

-- Now I want to rank the most espensive products within each category.
SELECT product_name, category, unit_price,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY unit_price DESC) AS Expensive
FROM dim_product;

-- What are the 3 most expensive products in each category?
SELECT * FROM
(SELECT product_name, category, unit_price,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY unit_price DESC) AS Expensive
FROM dim_product) AS ranked_products
WHERE Expensive <= 3;