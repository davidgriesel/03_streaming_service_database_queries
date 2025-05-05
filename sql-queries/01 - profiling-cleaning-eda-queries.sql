-- ==============================================================
-- Rockbuster Stealth
-- Analyst: David Griesel
-- Date: July 2024
-- Purpose: Initial Data Profiling, Cleaning, and EDA
-- ==============================================================

-- ==============================================================
-- TABLE OF CONTENTS:
-- ==============================================================

-- 1. Overview of Tables
-- 2. Row Counts
-- 3. Sample Rows
-- 4. Data Type Validation
-- 5. Primary Key Checks
-- 6. Foreign Key Checks
-- 7. Missing Data Checks (Key Variables)
-- 8. Duplicates Checks
-- 9. Distinct Value Counts (All Variables)
-- 10. Frequency Distributions (Categorical Variables)
-- 11. Descriptive Statistics (Numeric Variables)
-- 12. Temporal Checks
-- 13. Logic and Dependency Checks

-- ==============================================================
-- 1. Overview of Tables
-- ==============================================================

-- List all base tables in the public schema.

SELECT 
    table_schema, 
    table_type, 
    table_name
FROM information_schema.tables
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
ORDER BY
    table_name;

-- ==============================================================
-- 2. Row Counts
-- ==============================================================

-- Count rows for all base tables in the public schema.

SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor
UNION ALL
SELECT 'address', COUNT(*) FROM address
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'city', COUNT(*) FROM city
UNION ALL
SELECT 'country', COUNT(*) FROM country
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'film', COUNT(*) FROM film
UNION ALL
SELECT 'film_actor', COUNT(*) FROM film_actor
UNION ALL
SELECT 'film_category', COUNT(*) FROM film_category
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'language', COUNT(*) FROM language
UNION ALL
SELECT 'payment', COUNT(*) FROM payment
UNION ALL
SELECT 'rental', COUNT(*) FROM rental
UNION ALL
SELECT 'staff', COUNT(*) FROM staff
UNION ALL
SELECT 'store', COUNT(*) FROM store;

-- ==============================================================
-- 3. Sample Rows
-- ==============================================================

-- Get sample rows from all base tables in the public schema.

SELECT * FROM actor LIMIT 5;
SELECT * FROM address LIMIT 5;
SELECT * FROM category LIMIT 5;
SELECT * FROM city LIMIT 5;
SELECT * FROM country LIMIT 5;
SELECT * FROM customer LIMIT 5;
SELECT * FROM film LIMIT 5;
SELECT * FROM film_actor LIMIT 5;
SELECT * FROM film_category LIMIT 5;
SELECT * FROM inventory LIMIT 5;
SELECT * FROM language LIMIT 5;
SELECT * FROM payment LIMIT 5;
SELECT * FROM rental LIMIT 5;
SELECT * FROM staff LIMIT 5;
SELECT * FROM store LIMIT 5;

-- ==============================================================
-- 4. Data Type Validation 
-- ==============================================================

-- Retrieve data types for all base tables in the public schema.

SELECT 
    c.table_name,
    c.column_name,
    c.data_type
FROM 
    information_schema.columns c
JOIN 
    information_schema.tables t
    ON c.table_schema = t.table_schema
    AND c.table_name = t.table_name
WHERE 
    c.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE' 
ORDER BY 
    c.data_type;

-- ==============================================================
-- 5. Primary Key Checks
-- ==============================================================

-- Check if primary keys exist.

SELECT 
    tc.table_name, 
    kcu.column_name, 
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.key_column_usage AS kcu
ON 
    tc.constraint_name = kcu.constraint_name
WHERE 
    tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
ORDER BY 
    tc.table_name, kcu.column_name;

-- Check for NULLs in primary key columns (should be zero if clean).

SELECT 'actor' AS table_name, 'actor_id' AS primary_key, COUNT(*) AS null_count FROM actor WHERE actor_id IS NULL
UNION ALL
SELECT 'address', 'address_id', COUNT(*) FROM address WHERE address_id IS NULL
UNION ALL
SELECT 'category', 'category_id', COUNT(*) FROM category WHERE category_id IS NULL
UNION ALL
SELECT 'city','city_id', COUNT(*) FROM city WHERE city_id IS NULL
UNION ALL
SELECT 'country', 'country_id', COUNT(*) FROM country WHERE country_id IS NULL
UNION ALL
SELECT 'customer', 'customer_id', COUNT(*) FROM customer WHERE customer_id IS NULL
UNION ALL
SELECT 'film', 'film_id', COUNT(*) FROM film WHERE film_id IS NULL
UNION ALL
SELECT 'inventory', 'inventory_id', COUNT(*) FROM inventory WHERE inventory_id IS NULL
UNION ALL
SELECT 'language', 'language_id', COUNT(*) FROM language WHERE language_id IS NULL
UNION ALL
SELECT 'payment', 'payment_id', COUNT(*) FROM payment WHERE payment_id IS NULL
UNION ALL
SELECT 'rental', 'rental_id', COUNT(*) FROM rental WHERE rental_id IS NULL
UNION ALL
SELECT 'staff', 'staff_id', COUNT(*) FROM staff WHERE staff_id IS NULL
UNION ALL
SELECT 'store', 'store_id', COUNT(*) FROM store WHERE store_id IS NULL;

-- Check for duplicates in primary key columns (should be zero if clean).

SELECT 1 AS sort_order, 'actor' AS table_name, 'actor_id' AS primary_key, COUNT(*) AS duplicate_count FROM  actor GROUP BY actor_id HAVING COUNT(*) > 1
UNION ALL
SELECT 2, 'address', 'address_id', COUNT(*) FROM address GROUP BY address_id HAVING COUNT(*) > 1
UNION ALL
SELECT 3, 'category', 'category_id', COUNT(*) FROM category GROUP BY category_id HAVING COUNT(*) > 1
UNION ALL
SELECT 4, 'city', 'city_id', COUNT(*) FROM city GROUP BY city_id HAVING COUNT(*) > 1
UNION ALL
SELECT 5, 'country', 'country_id', COUNT(*) FROM country GROUP BY country_id HAVING COUNT(*) > 1
UNION ALL
SELECT 6, 'customer', 'customer_id', COUNT(*) FROM customer GROUP BY customer_id HAVING COUNT(*) > 1
UNION ALL
SELECT 7, 'film', 'film_id', COUNT(*) FROM film GROUP BY film_id HAVING COUNT(*) > 1   
UNION ALL
SELECT 8, 'inventory', 'inventory_id', COUNT(*) FROM inventory GROUP BY inventory_id HAVING COUNT(*) > 1
UNION ALL
SELECT 9, 'language', 'language_id', COUNT(*) FROM language GROUP BY language_id HAVING COUNT(*) > 1
UNION ALL
SELECT 10, 'payment', 'payment_id', COUNT(*) FROM payment GROUP BY payment_id HAVING COUNT(*) > 1
UNION ALL
SELECT 11, 'rental', 'rental_id', COUNT(*) FROM rental GROUP BY rental_id HAVING COUNT(*) > 1
UNION ALL
SELECT 12, 'staff', 'staff_id', COUNT(*) FROM staff GROUP BY staff_id HAVING COUNT(*) > 1
UNION ALL
SELECT 13, 'store', 'store_id', COUNT(*) FROM store GROUP BY store_id HAVING COUNT(*) > 1
ORDER BY sort_order;

-- Check for nulls across composite keys.

SELECT 
    'film_actor' AS table_name, 
    COUNT(*) AS null_count
FROM 
    film_actor
WHERE 
    actor_id IS NULL
    OR film_id IS NULL

UNION ALL

SELECT 
    'film_category' AS table_name, 
    COUNT(*) AS null_count
FROM 
    film_category
WHERE 
    film_id IS NULL
    OR category_id IS NULL;
    
-- Check for duplicates across composite keys.

SELECT 
    'film_actor' AS table_name, 
    COUNT(*) - COUNT(DISTINCT actor_id || '-' || film_id) AS duplicate_count
FROM 
    film_actor

UNION ALL

SELECT 
    'film_category', 
    COUNT(*) - COUNT(DISTINCT film_id || '-' || category_id)
FROM 
    film_category;

-- ==============================================================
-- 6. Foreign Key Checks
-- ==============================================================

-- Check foreign key constratints.

SELECT
    tc.table_name AS child_table,
    kcu.column_name AS child_column,
    ccu.table_name AS parent_table,
    ccu.column_name AS parent_column,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.key_column_usage AS kcu
ON 
    tc.constraint_name = kcu.constraint_name
JOIN 
    information_schema.constraint_column_usage AS ccu
ON 
    ccu.constraint_name = tc.constraint_name
WHERE 
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY 
    child_table, child_column;

-- Check if foreign keys link to valid primary keys in parent tables.

-- TABLE: address

SELECT 
    1 AS sort_order,
    'address' AS table_name,
    'city_id' AS secondary_key, 
    COUNT(*) AS missing_key_count
FROM address a
LEFT JOIN city c ON a.city_id = c.city_id
WHERE c.city_id IS NULL

UNION ALL

-- TABLE: city

SELECT 
    2,
    'city',
    'country_id', 
    COUNT(*)
FROM city ci
LEFT JOIN country co ON ci.country_id = co.country_id
WHERE co.country_id IS NULL

UNION ALL

-- TABLE: customer

SELECT 
    3,
    'customer',
    'store_id',
    COUNT(*)
FROM customer cu
LEFT JOIN store s ON cu.store_id = s.store_id
WHERE s.store_id IS NULL

UNION ALL

SELECT 
    4,
    'customer',
    'address_id',
    COUNT(*)
FROM customer cu
LEFT JOIN address a ON cu.address_id = a.address_id
WHERE a.address_id IS NULL

UNION ALL

-- TABLE: film

SELECT 
    5,
    'film',
    'language_id',
    COUNT(*)
FROM film f
LEFT JOIN language l ON f.language_id = l.language_id
WHERE l.language_id IS NULL

UNION ALL

-- TABLE: film_actor

SELECT 
6,
'film_actor',
'actor_id',
COUNT(*)
FROM film_actor fa
LEFT JOIN actor a ON fa.actor_id = a.actor_id
WHERE a.actor_id IS NULL

UNION ALL

SELECT 
7,
'film_actor',
'film_id',
COUNT(*)
FROM film_actor fa
LEFT JOIN film f ON fa.film_id = f.film_id
WHERE f.film_id IS NULL

UNION ALL

-- TABLE: film_category

SELECT 
    8,
    'film_category',
    'film_id',
    COUNT(*)
FROM film_category fc
LEFT JOIN film f ON fc.film_id = f.film_id
WHERE f.film_id IS NULL

UNION ALL

SELECT 
    9,
    'film_category',
    'category_id',
    COUNT(*)
FROM film_category fc
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE c.category_id IS NULL

UNION ALL

-- TABLE: inventory

SELECT 
    10,
    'inventory',
    'film_id',
    COUNT(*)
FROM inventory i
LEFT JOIN film f ON i.film_id = f.film_id
WHERE f.film_id IS NULL

UNION ALL

SELECT 
    11,
    'inventory',
    'store_id',
    COUNT(*)
FROM inventory i
LEFT JOIN store s ON i.store_id = s.store_id
WHERE s.store_id IS NULL

UNION ALL

-- TABLE: payment

SELECT 
    12,
    'payment',
    'customer_id',
    COUNT(*)
FROM payment p
LEFT JOIN customer c ON p.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 
    13,
    'payment',
    'staff_id',
    COUNT(*)
FROM payment p
LEFT JOIN staff s ON p.staff_id = s.staff_id
WHERE s.staff_id IS NULL

UNION ALL

SELECT 
    14,
    'payment',
    'rental_id',
    COUNT(*)
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
WHERE r.rental_id IS NULL

UNION ALL

-- TABLE: rental

SELECT
    15,
    'rental',
    'inventory_id',
    COUNT(*)
FROM rental r
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
WHERE i.inventory_id IS NULL

UNION ALL

SELECT 
    16,
    'rental',
    'customer_id',
    COUNT(*)
FROM rental r
LEFT JOIN customer c ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 
    17,
    'rental',
    'staff_id',
    COUNT(*)
FROM rental r
LEFT JOIN staff s ON r.staff_id = s.staff_id
WHERE s.staff_id IS NULL

UNION ALL

-- TABLE: staff

SELECT 
    18,
    'staff',
    'address_id',
    COUNT(*)
FROM staff s
LEFT JOIN address a ON s.address_id = a.address_id
WHERE a.address_id IS NULL

UNION ALL

SELECT 
    19,
    'staff',
    'store_id',
    COUNT(*)
FROM staff s
LEFT JOIN store st ON s.store_id = st.store_id
WHERE st.store_id IS NULL

UNION ALL

-- TABLE: store

SELECT 
    20,
    'store',
    'manager_staff_id',
    COUNT(*)
FROM store s
LEFT JOIN staff st ON s.manager_staff_id = st.staff_id
WHERE st.staff_id IS NULL

UNION ALL

SELECT 
    21,
    'store',
    'address_id',
    COUNT(*)
FROM store s
LEFT JOIN address a ON s.address_id = a.address_id
WHERE a.address_id IS NULL

ORDER BY sort_order;

-- ==============================================================
-- 7. Missing Data Checks (Key Variables)
-- ==============================================================

-- Identify columns across key tables that allow NULL values for targeted missing data checks.

SELECT 
    table_name,
    column_name, 
    is_nullable 
FROM information_schema.columns
WHERE table_name IN(
    'actor', 
    'address', 
    'category', 
    'city', 
    'country', 
    'customer', 
    'film', 
    'film_actor', 
    'film_category', 
    'inventory', 
    'language', 
    'payment', 
    'rental',
    'staff',
    'store'
)
AND is_nullable = 'YES'
ORDER BY table_name, column_name;


-- Check key columns that allow NULL values.

-- TABLE: customer

SELECT 
    'customer' AS table_name, 
    'active' AS column_name, 
    COUNT(*) AS missing_count
FROM customer
WHERE active IS NULL

UNION ALL

-- TABLE: film

SELECT 
    'film', 
    'length', 
    COUNT(*)
FROM film
WHERE length IS NULL

UNION ALL

SELECT 
    'film', 
    'rating', 
    COUNT(*)
FROM film
WHERE rating IS NULL

UNION ALL

SELECT 
    'film',
    'release_year',
    COUNT(*)
FROM film
WHERE release_year IS NULL

UNION ALL

-- TABLE: rental

SELECT 
    'rental',
    'return_date', 
    COUNT(*)
FROM rental
WHERE return_date IS NULL

ORDER BY table_name, column_name;

-- ==============================================================
-- 8. Duplicates Checks
-- ==============================================================

-- Combined duplicate counts across key tables.

SELECT 1 AS sort_order, 'actor' AS table_name, COUNT(*) AS duplicate_count
FROM (
    SELECT first_name, last_name
    FROM actor
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 2, 'address', COUNT(*)
FROM (
    SELECT address, address2, district, city_id, postal_code, phone
    FROM address
    GROUP BY address, address2, district, city_id, postal_code, phone
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 3, 'category', COUNT(*)
FROM (
    SELECT name
    FROM category
    GROUP BY name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 4, 'city', COUNT(*)
FROM (
    SELECT city, country_id
    FROM city
    GROUP BY city, country_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 5, 'country', COUNT(*)
FROM (
    SELECT country
    FROM country
    GROUP BY country
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 6, 'customer', COUNT(*)
FROM (
    SELECT store_id, first_name, last_name, email, address_id, activebool, create_date, active
    FROM customer
    GROUP BY store_id, first_name, last_name, email, address_id, activebool, create_date, active
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 7, 'film', COUNT(*)
FROM (
    SELECT title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext
    FROM film
    GROUP BY title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 8, 'inventory', COUNT(*)
FROM (
    SELECT film_id, store_id
    FROM inventory
    GROUP BY film_id, store_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 9, 'language', COUNT(*)
FROM (
    SELECT name
    FROM language
    GROUP BY name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 10, 'payment', COUNT(*)
FROM (
    SELECT customer_id, staff_id, rental_id, amount, payment_date
    FROM payment
    GROUP BY customer_id, staff_id, rental_id, amount, payment_date
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 11, 'rental', COUNT(*)
FROM (
    SELECT rental_date, inventory_id, customer_id, return_date, staff_id
    FROM rental
    GROUP BY rental_date, inventory_id, customer_id, return_date, staff_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 12, 'staff', COUNT(*)
FROM (
    SELECT first_name, last_name, address_id, email, store_id, active, username, password, picture
    FROM staff
    GROUP BY first_name, last_name, address_id, email, store_id, active, username, password, picture
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 13, 'store', COUNT(*)
FROM (
    SELECT manager_staff_id, address_id
    FROM store
    GROUP BY manager_staff_id, address_id
    HAVING COUNT(*) > 1
) AS dup

ORDER BY sort_order;

-- View duplicate records identified in the actor table.

-- TABLE: actor 

SELECT *
FROM actor
WHERE (first_name, last_name) IN (
    SELECT 
        first_name, 
        last_name
    FROM 
        actor
    GROUP BY 
        first_name, 
        last_name
    HAVING 
        COUNT(*) > 1
);

-- Create a clean view of tables with duplicates with duplicates removed.

-- TABLE: actor 

CREATE OR REPLACE VIEW clean_actor AS
SELECT *
FROM actor
WHERE actor_id NOT IN (
    SELECT actor_id
    FROM (
        SELECT actor_id,
            ROW_NUMBER() OVER (PARTITION BY first_name, last_name ORDER BY actor_id) AS rn
        FROM actor
    ) AS numbered
    WHERE rn > 1
);

-- Validation checks: 

-- TABLE: actor 

-- Row counts before and after duplicate removal.

    SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor;
    SELECT 'clean_actor' AS table_name, COUNT(*) AS row_count FROM clean_actor;

-- Confirm no duplicates remain in clean-actor view.

    SELECT 1 AS sort_order, 'clean_actor' AS table_name, COUNT(*) AS duplicate_count
    FROM (
        SELECT first_name, last_name
        FROM clean_actor
        GROUP BY first_name, last_name
        HAVING COUNT(*) > 1
    ) AS dupYes

-- ==============================================================
-- 9. Distinct Value Counts (All Variables)
-- ==============================================================

-- Check the number of distinct values per variable.

-- TABLE: actor

SELECT 'actor_id' AS variable, COUNT(DISTINCT actor_id) AS distinct_count FROM actor
UNION ALL
SELECT 'first_name' AS variable, COUNT(DISTINCT first_name) FROM actor
UNION ALL
SELECT 'last_name' AS variable, COUNT(DISTINCT last_name) FROM actor
UNION ALL
SELECT 'last_update' AS variable, COUNT(DISTINCT last_update) FROM actor;

-- Check the frequency distribution of each variable in the table.

-- TABLE:  actor

SELECT
first_name AS value,
COUNT(*) AS frequency,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM actor), 2) AS percentage
FROM
actor
GROUP BY
first_name
ORDER BY
frequency DESC;


-- Check for distinct values across key variables.

-- Distinct countries
SELECT DISTINCT country FROM country;

-- Distinct languages
SELECT DISTINCT name FROM language;

-- Distinct ratings (assuming 'rating' field in film table)
SELECT DISTINCT rating FROM film;

-- Which film genres exist in the category table
SELECT category_id, name
FROM category;

SELECT COUNT(DISTINCT country_id) FROM country;
SELECT COUNT(DISTINCT name) FROM language;
SELECT COUNT(DISTINCT rating) FROM film;


SELECT
first_name AS value,
COUNT(*) AS frequency,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM actor), 2) AS percentage
FROM
actor
GROUP BY
first_name
ORDER BY
frequency DESC;

-- ==============================================================
-- 10. Frequency Distributions (Categorical Variables)
-- ==============================================================

-- Distributions 

SELECT country, COUNT(*) 
FROM country
GROUP BY country
ORDER BY COUNT(*) DESC;


-- ==============================================================
-- 11. Descriptive Statistics (Numeric Variables)
-- ==============================================================

-- ==============================================================
-- 12. Temporal Checks
-- ==============================================================

SELECT MIN(rental_date), MAX(rental_date) FROM rental;

-- ==============================================================
-- 13. Logic and Dependency Checks
-- ==============================================================
    
SELECT rental_id
FROM rental
WHERE return_date < rental_date;

-- Do all payments match to rentals etc
-- i.e. If a rental has no return date → Maybe it should have no payment yet?
-- Compare the number of unique descriptions for key variables and compare to the number of unique key ids
-- Are all customers active?
-- 599 customers but 603 addresses & 600 cities
-- 16044 rentals but only 14596 payments. Difference not returned videos?


    
SELECT rental_id, return_date, rental_date
FROM rental
WHERE EXTRACT(EPOCH FROM (return_date - rental_date)) / 86400 > 100;






-- Average rental duration (days)
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM (return_date - rental_date)) / 86400), 2) AS avg_rental_duration_days
FROM rental
WHERE return_date IS NOT NULL;


-- Total revenue
SELECT 
    ROUND(SUM(amount), 2) AS total_revenue
FROM payment;



-- Number of films per category
SELECT 
    c.name AS category, 
    COUNT(fc.film_id) AS number_of_films
FROM film_category fc
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY number_of_films DESC;



-- Customers per country
SELECT 
    co.country,
    COUNT(c.customer_id) AS num_customers
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY num_customers DESC;





