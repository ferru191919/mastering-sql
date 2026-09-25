-- NULL = The value is unknown or missing.
--      10 = 10      → TRUE
--      10 = 20      → FALSE
--      10 = NULL    → UNKNOWN

-- NULL HANDLING = functions that allows to handle NULL values
--                    - COALESCE(value1, 0): If value1 has a value, use it. Otherwise use 0.
--                    - NULLIF(value1, value2): If the two values are equal, return NULL. Otherwise return value1.

-- COALESCE():
SELECT
    customer_name,
    COALESCE(city, 'Unknown') AS location  -- if city has a value, use it. Otherwise use 'Unknown'
FROM dim_customer;

SELECT
    customer_name,
    COALESCE(city, country, 'Unknown') AS location -- if city has a value, use it. Otherwise check for and use country value. If not available, use 'Unknown'
FROM dim_customer;


-- NULLIF():
SELECT  
    order_id,
    NULLIF(discount_amount, 0) -- if discount_amount =! 0, then use it. Otherwise is NULL.
FROM fact_order;


-- NULL after a LEFT JOIN:
SELECT
    c.customer_name,
    f.order_id
FROM dim_customer AS c
LEFT JOIN fact_order AS f
    ON c.customer_sk = f.customer_sk;

-- if a customer does not have an order, order_id will be NULL for that customer.