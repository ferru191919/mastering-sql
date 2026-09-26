# Static SQL = table name is fixed.
SELECT *
FROM public.dim_product;

# Dynamic SQL = table name must change at runtime.
CREATE OR REPLACE FUNCTION count_rows(p_table_name TEXT)    #p_table_name is a parameter
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    result_count BIGINT;
BEGIN
    EXECUTE format(
        'SELECT count(*) FROM public.%I',
        p_table_name
    )
    INTO result_count;

    RETURN result_count;
END;
$$;

