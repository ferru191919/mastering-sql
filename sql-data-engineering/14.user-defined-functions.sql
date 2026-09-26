-- A User-Defined Function, or UDF, is custom logic you create, name, save in the database, 
-- and call later in SQL just as you would call built-in functions such as LOWER or ROUND. 
-- It takes inputs, applies a rule, and returns a result.

CREATE OR REPLACE FUNCTION public.calculate_net_amount( -- public schema
    p_amount NUMERIC,
    p_discount_amount NUMERIC -- 'p' prefix helps distinguish function parameters from table-column names.
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT p_amount - p_discount_amount; -- logic
$$;

SELECT public.calculate_net_amount(150.00, 10.00);  -- testing the function

SELECT
    order_id,
    amount,
    discount_amount,
    public.calculate_net_amount(amount, discount_amount) AS calculated_net_amount
FROM fact_order;
