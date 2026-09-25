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

-- FULL OUTER JOIN: keeps every row.
