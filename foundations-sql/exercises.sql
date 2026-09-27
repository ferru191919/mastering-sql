/*
============================================================
MASTERING SQL
PART 1 — FOUNDATIONS EXERCISES
============================================================

Purpose:
Practice the concepts covered in the foundations-sql section.

Rules:
- Try to solve every exercise without looking at previous examples.
- Do not modify the original warehouse tables unless an exercise
  explicitly asks you to.
- Read the required output carefully before writing the query.
- There may be more than one valid solution.
- Prefer readable SQL over unnecessarily complicated SQL.
*/


/*
============================================================
SECTION 1 — FILTERING, SORTING AND BASIC QUERIES
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 1 — Italian customers
-- Difficulty: Easy
--
-- Return all customers who live in Italy.
--
-- Display: customer_id, customer_name, city, segment
--
-- Sort the result alphabetically by customer_name.

SELECT
    customer_id,
    customer_name,
    city,
    segment
FROM dim_customer
WHERE country = 'Italy'
ORDER BY customer_name ASC;

-- ---------------------------------------------------------
-- EXERCISE 2 — Expensive products
-- Difficulty: Easy
--
-- Find all products whose unit price is greater than 50.
--
-- Display: product_id, product_name, category, brand, unit_price
--
-- Sort from the most expensive product to the cheapest.

SELECT 
    product_id,
    product_name,
    category,
    brand,
    unit_price
FROM dim_product
WHERE unit_price > 50
ORDER BY unit_price DESC;

-- ---------------------------------------------------------
-- EXERCISE 3 — Selected categories
-- Difficulty: Easy
--
-- Return products belonging to either:
-- 
-- Sports
-- Sportswear
-- Recovery
--
-- Display: product_name, category, sub_category, unit_price
--
-- Sort first by category and then by unit_price descending.

SELECT
    product_name,
    category,
    sub_category,
    unit_price
FROM dim_product
WHERE category = 'Sports' OR category = 'Sportswear' OR category = 'Recovery'
ORDER BY category, unit_price DESC;


/*
============================================================
SECTION 2 — AGGREGATE FUNCTIONS
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 4 — Product price statistics
-- Difficulty: Easy
--
-- Calculate:
--
-- 1. Number of products
-- 2. Cheapest product price
-- 3. Most expensive product price
-- 4. Average product price
--
-- Return all four values in a single row.
--
-- Give each calculated column a meaningful alias.

SELECT 
    COUNT(*) AS number_of_products,
    MIN(unit_price) AS cheapest_product,
    MAX(unit_price) AS most_expensive_product,
    AVG(unit_price) AS avg_product_price
FROM dim_product;

-- ---------------------------------------------------------
-- EXERCISE 5 — Customers by country
-- Difficulty: Easy
--
-- Count how many customers belong to each country.
--
-- Display:
-- country
-- customer_count
--
-- Sort from the country with the most customers to the country
-- with the fewest.

SELECT
    country,
    COUNT(*) AS number_of_customers
FROM dim_customer
GROUP BY country
ORDER BY number_of_customers DESC;

-- ---------------------------------------------------------
-- EXERCISE 6 — Average price by category
-- Difficulty: Easy / Intermediate
--
-- Calculate the average product price for every category.
--
-- Display:
-- category
-- number_of_products
-- average_price
--
-- Sort by average_price descending.

SELECT
    category,
    COUNT(*) AS number_of_products,
    AVG(unit_price) AS avg_product_price
FROM dim_product
GROUP BY category
ORDER BY avg_product_price DESC; 

-- ---------------------------------------------------------
-- EXERCISE 7 — Categories above a threshold
-- Difficulty: Intermediate
--
-- Find product categories whose average unit price is greater
-- than 25.
--
-- Display:
-- category
-- product_count
-- average_price

SELECT
    category,
    COUNT(*) AS product_count,
    AVG(unit_price) AS avg_price
FROM dim_product
GROUP BY category
HAVING AVG(unit_price) > 25
ORDER BY avg_price DESC;


/*
============================================================
SECTION 3 — JOINS
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 8 — Order details
-- Difficulty: Easy / Intermediate
--
-- Produce a readable list of order line items.
--
-- For every line in fact_order, display:
--
-- order_id
-- order_date
-- customer_name
-- product_name
-- quantity
-- net_amount
--
-- Sort by order_date and then order_id.

SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    o.quantity,
    o.net_amount
FROM fact_order o
JOIN dim_customer c
    ON c.customer_sk = o.customer_sk
JOIN dim_product p
    ON p.product_sk = o.product_sk
ORDER BY order_date, order_id;

-- ---------------------------------------------------------
-- EXERCISE 9 — Customer spending
-- Difficulty: Intermediate
--
-- Calculate how much each customer has spent in total.
--
-- Display:
-- customer_id
-- customer_name
-- country
-- total_spent
--
-- Only include customers who have placed orders.
--
-- Sort from the highest spender to the lowest.

SELECT
    c.customer_id,
    c.customer_name,
    c.country,
    SUM(o.net_amount) AS total_spent
FROM fact_order o 
JOIN dim_customer c
    ON o.customer_sk = c.customer_sk
GROUP BY c.customer_id, c.customer_name, c.country
ORDER BY total_spent DESC;

-- ---------------------------------------------------------
-- EXERCISE 10 — Include customers without orders
-- Difficulty: Intermediate
--
-- Create a report containing EVERY customer, including customers
-- who have never placed an order.
--
-- Display:
-- customer_id
-- customer_name
-- number_of_order_lines
--
-- Customers without purchases must still appear in the result.

SELECT 
    customer_id,
    customer_name,
    COUNT(o.order_id) AS number_of_order_lines
FROM dim_customer c 
LEFT JOIN fact_order o 
    ON c.customer_sk = o.customer_sk
GROUP BY customer_id, customer_name;

-- ---------------------------------------------------------
-- EXERCISE 11 — Product sales performance
-- Difficulty: Intermediate
--
-- For every product that has been ordered, calculate:
--
-- product_name
-- category
-- total_quantity_sold
-- total_revenue
--
-- Sort by total_revenue descending.

SELECT
    p.product_name,
    p.category,
    SUM(o.quantity) AS total_quantity_sold,
    SUM(o.net_amount) AS total_revenue
FROM dim_product p 
JOIN fact_order o 
    ON p.product_sk = o.product_sk
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;


/*
============================================================
SECTION 4 — NULL HANDLING
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 12 — Missing customer information
-- Difficulty: Easy
--
-- Find customers whose email, signup date, city, or segment contains NULL.
--
-- Display:
-- customer_id
-- customer_name
-- customer_email
-- signup_date
-- city
-- segment

SELECT
    customer_id,
    customer_name,
    customer_email,
    signup_date,
    city,
    segment
FROM dim_customer 
WHERE customer_email IS NULL 
    OR signup_date IS NULL 
    OR city IS NULL
    OR segment IS NULL;

-- ---------------------------------------------------------
-- EXERCISE 13 — Safe customer report
-- Difficulty: Intermediate
--
-- Create a customer report where NULL values are replaced with
-- readable text.
--
-- Required transformations:
--
-- NULL email   -> 'No email'
-- NULL city    -> 'Unknown city'
-- NULL segment -> 'Unclassified'
--
-- Display:
-- customer_name
-- email
-- city
-- segment

SELECT
    customer_name,
    COALESCE(customer_email, 'No email'),
    COALESCE(city, 'Unkown city'),
    COALESCE(segment, 'Unclassified')
FROM dim_customer;


/*
============================================================
SECTION 5 — CASE STATEMENTS
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 14 — Product price classification
-- Difficulty: Easy
--
-- Classify products into the following groups:
--
-- unit_price < 20
--     -> 'Budget'
--
-- unit_price between 20 and 60
--     -> 'Standard'
--
-- unit_price > 60
--     -> 'Premium'
--
-- Display:
-- product_name
-- unit_price
-- price_category
--
-- Sort by unit_price descending.

SELECT 
    product_name,
    unit_price,
    CASE   
        WHEN unit_price <= 20 THEN 'Budget'
        WHEN unit_price > 20 AND unit_price < 60 THEN 'Standard'
        WHEN unit_price >= 60 then 'Premium'
    END AS price_category
FROM dim_product
ORDER BY unit_price DESC;

-- ---------------------------------------------------------
-- EXERCISE 15 — Customer spending classification
-- Difficulty: Intermediate
--
-- Calculate total spending for each customer who has purchased
-- something.
--
-- Then classify customers as:
--
-- total_spent < 50
--     -> 'Low Value'
--
-- total_spent from 50 to 149.99
--     -> 'Medium Value'
--
-- total_spent >= 150
--     -> 'High Value'
--
-- Display:
-- customer_name
-- total_spent
-- customer_value
--
-- Sort by total_spent descending.

SELECT 
    c.customer_name,
    SUM(o.net_amount) AS total_spent,
    CASE
        WHEN SUM(o.net_amount) < 50 THEN 'Low value'
        WHEN SUM(o.net_amount) >= 50 AND SUM(o.net_amount) <= 149.99 THEN 'Medium value'
        WHEN SUM(o.net_amount) > 149.99 THEN 'High value'
    END AS customer_value
FROM dim_customer c 
JOIN fact_order o 
    ON c.customer_sk = o.customer_sk
GROUP BY c.customer_name
ORDER BY total_spent DESC;


/*
============================================================
SECTION 6 — UNION
============================================================
*/


-- ---------------------------------------------------------
-- EXERCISE 16 — Countries and brands
-- Difficulty: Easy / Intermediate
--
-- Create one result containing:
--
-- all customer countries
-- AND
-- all product brands
--
-- Return one column called:
--
-- name
--
-- Duplicate values should appear only once.
--
-- Sort alphabetically.

SELECT 
    country AS name
FROM dim_customer

UNION

SELECT 
    brand
FROM dim_product

ORDER BY name ASC;

-- ---------------------------------------------------------
-- EXERCISE 17 — Combined names
-- Difficulty: Intermediate
--
-- Create a single list containing:
--
-- customer names
-- product names
--
-- The output should contain two columns:
--
-- name
-- type
--
-- type should contain:
--
-- 'Customer'
--
-- or
--
-- 'Product'
--
-- depending on where the record came from.
--
-- Sort by type and then name.

SELECT
    customer_name AS name,
    'Customer' AS type
FROM dim_customer

UNION ALL

SELECT
    product_name,
    'Product'
FROM dim_product

ORDER BY type, name; 