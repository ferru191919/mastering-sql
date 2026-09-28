-- DML (Data Manipulation Language) = used to manipulate the data stored in those database 
--                                    objects (e.g. INSERT, RETRIEVE, MODIFY, etc...).


-- SAFETY RULE --
--
-- Remember to use BEGIN TRANSACTION!


-- After creating the table, we need to add records to the table:
BEGIN TRANSACTION;

INSERT INTO fact_order (order_id, order_date, customer_sk, product_sk, quantity, amount)
VALUES 
    (1036, '2024-12-24', 1, 1, 1, 150.00),  -- order_date NOT NULL, so I must insert values
    (1037, '2024-12-24', 12, 6, 1, 35.00);

SELECT *
FROM fact_order
WHERE order_id = 1036 AND order_id = 1037;  -- to check for INSERT result

ROLLBACK;
-----------------------------

-- We can UPDATE the records:
BEGIN TRANSACTION;

UPDATE dim_product
SET product_name = 'Tennis Racket Pro'
WHERE product_name = 'Tennis Racket pro';

SELECT *
FROM fact_order
WHERE product_name = 'Tennis Racket pro';  -- to check for UPDATE result

ROLLBACK;
-----------------------------

-- We can DELETE the records:
BEGIN TRANSACTION;

DELETE FROM dim_product
WHERE unit_price < 0 OR unit_price IS NULL;

SELECT *
FROM fact_order
WHERE unit_price < 0 OR unit_price IS NULL;  -- to check for DELETE result

ROLLBACK;