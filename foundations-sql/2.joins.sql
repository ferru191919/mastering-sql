-- The JOIN clause is used to combine rows from two or more tables, 
-- based ON a related column between them.

-- INNER JOIN (or just JOIN): Keep only the common rows between left and right table.
FROM fact_order AS f
JOIN dim_customer AS c
    ON f.customer_sk = c.customer_sk

fact_order              dim_customer

customer_sk             customer_sk
-----------             -----------
1  ───────────────────► 1
2  ───────────────────► 2
3                       4

-- The result contains customers 1 and 2.

-------------------------------------

-- LEFT JOIN: Keep every row from the left table, even if the right table has no match.
FROM dim_customer AS c
LEFT JOIN fact_order AS f
    ON c.customer_sk = f.customer_sk;

dim_customer                 fact_order
     │
     │ LEFT JOIN
     ▼

-- KEEP ALL CUSTOMERS. If a customer does not have an order:

customer_name     order_id
-------------     --------
Alice Rossi       1001
Marco Bianchi     1002
New Customer      NULL

-------------------------------------

-- RIGHT JOIN: basically the opposite of left join. Keeps only the rows of right table.

-------------------------------------

-- CROSS JOIN: Takes on single row from a table, and attaches it to every row of another table.
--             Unlike INNER, LEFT or RIGHT JOIN, there's usually no ON condition.
--             Useful especially when joining tables with aggregated functions.

-- Example (see lesson 11.common-table-expression):
WITH customer_total_spending AS (       -- calculating total_spent per customer
    SELECT
        customer_sk,
        SUM(net_amount) AS total_spent
    FROM
        fact_order
    GROUP BY 
        customer_sk
),
average_customer_spending AS (           -- calculating avg_spent across all customers
    SELECT
        AVG(total_spent) AS avg_spent
    FROM
        customer_total_spending
)
SELECT
    c.customer_name,
    c.country,
    cts.total_spent,
    acs.avg_spent
FROM
    dim_customer c 
JOIN
    customer_total_spending cts ON cts.customer_sk = c.customer_sk
CROSS JOIN
    average_customer_spending acs       -- CROSS JOIN: taking avg_spent row and attach it to every customer row (same value aCROSS all the rows)
WHERE 
    cts.total_spent > acs.avg_spent
ORDER BY cts.total_spent DESC;