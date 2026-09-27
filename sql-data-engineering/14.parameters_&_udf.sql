-- Parameters: values supplied at runtime instead of being hardcoded.
--             They are useful when the SQL structure stays the same,
--             but one or more VALUES need to change.

-- Example: Imagine you need to change the 'category' value...
SELECT
    product_name,
    category,
    unit_price
FROM dim_product
WHERE category = 'Sports'; -- need to change category = 'Nutrition', and then category = 'Recovery'

-- ... instead of hardcoding category = 'Sports', you can parameterized it:
SELECT
    product_name,
    category,
    unit_price
FROM dim_product
WHERE p_category = p_category;  -- at runtime, you can assign whatever value to p_category (e.g. 'Sports', 'Nutrition', etc...)

--------------------------------

-- User-Defined Function (UDF) = custom logic you create, name, save in the database, 
--                               and call later in SQL, just as you would call built-in 
--                               functions such as LOWER() or ROUND(). 

-- Creating the UDF:
CREATE OR REPLACE FUNCTION public.calculate_net_amount(     -- public schema
    p_amount NUMERIC,                         -- function inputs (parameters)
    p_discount_amount NUMERIC 
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT p_amount - p_discount_amount;    -- function logic
$$;


-- Calling the function:
SELECT public.calculate_net_amount(150.00, 10.00);  -- assign values at runtime.


-- Calling the function in a query:
SELECT
    order_id,
    amount,
    discount_amount,
    public.calculate_net_amount(amount, discount_amount)
        AS calculated_net_amount 
FROM fact_order;


-- What happens if 'discount_amount' is NULL? --> The result will be NULL.
--                                  150 - NULL -> NULL
-- If your business rule says:
-- 'A missing discount should be treated as zero' --> then you will use NULL handling

CREATE OR REPLACE FUNCTION public.calculate_net_amount(
    p_amount NUMERIC,
    p_discount_amount NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT p_amount - COALESCE(p_discount_amount, 0); -- NULL handling function
$$;


-- Dropping the function:
DROP FUNCTION public.calculate_net_amount(NUMERIC, NUMERIC);
