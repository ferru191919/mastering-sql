-- Dynamic SQL = a technique where SQL statements are built and executed at runtime
--               instead of being completely fixed.
--               It is useful when SQL identifiers or structure need to change,
--               such as table names or column names.


-- NOTE!
-- Difference between a parameter and an SQL identifier:
--      parameter  = a value supplied at runtime (e.g. 'Sports', 100, 'Italy');
--      identifier = the name of a database object (e.g. table name, column name, schema name).


-- Example Static SQL:
SELECT COUNT(*)
FROM dim_product;


-- Example Dynamic SQL:
CREATE OR REPLACE FUNCTION count_rows(      -- create function
    p_table_name TEXT                       -- function input (not a parameter! It's a SQL identifier!)
)
RETURNS BIGINT
LANGUAGE plpgsql    -- allows the following procedural features (DECLARE, EXECUTE, etc...)
                    -- it's more than a fixed SQL query.
AS $$
DECLARE                                    -- create variables
    v_row_count BIGINT;
BEGIN                                     -- start a block of instructions

    EXECUTE format(                         -- execute dynamically generated SQL
        'SELECT COUNT(*) FROM public.%I',
        p_table_name
    )
    INTO v_row_count;                    -- store a result in a variable

    RETURN v_row_count;                     -- return the variable

END;                                       -- end a block of instructions
$$;

SELECT count_rows('dim_customer');      -- calling the functions.


