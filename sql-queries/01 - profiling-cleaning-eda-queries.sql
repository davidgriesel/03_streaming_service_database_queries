-- ==============================================================
-- Rockbuster Stealth
-- Analyst: David Griesel
-- Date: July 2024
-- Purpose: Initial Data Profiling, Cleaning, and EDA
-- ==============================================================

-- ==============================================================
-- Notes:
-- Assistance received from OpenAI's ChatGPT for query structure
-- and general best practice guidance.
-- All queries reviewed, adapted, and finalised by the analyst.# Acknowledgements
-- Assistance received from OpenAI's ChatGPT on schema querying and selected SQL structuring. Final queries reviewed and finalised by the analyst.
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

-- 1.1 - List all base tables in the public schema.

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

-- 2.1 - Count rows for all base tables in the public schema.

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

-- 3.1 - Get sample rows from all base tables in the public schema.

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

-- 4.1 - Retrieve variable data types for all base tables in the public schema.

SELECT 
    c.table_name,
    c.column_name,
    c.data_type
FROM 
    information_schema.columns AS c
INNER JOIN 
    information_schema.tables AS t
    ON c.table_schema = t.table_schema
    AND c.table_name = t.table_name
WHERE 
    c.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE' 
ORDER BY 
    c.table_name, c.ordinal_position;

-- ==============================================================
-- 5. Primary Key Checks
-- ==============================================================

-- 5.1 - Check if primary keys exist. 

SELECT 
    t.table_name,
    CASE 
        WHEN pk.column_name IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS primary_key_exists,
    pk.column_name AS primary_key_column,
    pk.constraint_name AS primary_key_constraint
FROM 
    information_schema.tables AS t
LEFT JOIN (
    SELECT 
        tc.table_name, 
        kcu.column_name,
        tc.constraint_name
    FROM 
        information_schema.table_constraints AS tc
    INNER JOIN 
        information_schema.key_column_usage AS kcu
    ON 
        tc.constraint_name = kcu.constraint_name
    WHERE 
        tc.constraint_type = 'PRIMARY KEY'
        AND tc.table_schema = 'public'
) AS pk
ON 
    t.table_name = pk.table_name
WHERE 
    t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    t.table_name;

-- 5.2 - Check for NULLs in primary key columns (should be zero if clean).

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

-- 5.3 - Check for duplicates in primary key columns (should be zero if clean).

WITH duplicate_checks AS (
    
    SELECT 1 AS sort_order, 'actor' AS table_name, 'actor_id' AS primary_key, COUNT(*) - COUNT(DISTINCT actor_id) AS duplicate_count FROM actor
    UNION ALL
    SELECT 2, 'address', 'address_id', COUNT(*) - COUNT(DISTINCT address_id) FROM address
    UNION ALL
    SELECT 3, 'category', 'category_id', COUNT(*) - COUNT(DISTINCT category_id) FROM category
    UNION ALL
    SELECT 4, 'city', 'city_id', COUNT(*) - COUNT(DISTINCT city_id) FROM city
    UNION ALL
    SELECT 5, 'country', 'country_id', COUNT(*) - COUNT(DISTINCT country_id) FROM country
    UNION ALL
    SELECT 6, 'customer', 'customer_id', COUNT(*) - COUNT(DISTINCT customer_id) FROM customer
    UNION ALL
    SELECT 7, 'film', 'film_id', COUNT(*) - COUNT(DISTINCT film_id) FROM film
    UNION ALL
    SELECT 8, 'inventory', 'inventory_id', COUNT(*) - COUNT(DISTINCT inventory_id) FROM inventory
    UNION ALL
    SELECT 9, 'language', 'language_id', COUNT(*) - COUNT(DISTINCT language_id) FROM language
    UNION ALL
    SELECT 10, 'payment', 'payment_id', COUNT(*) - COUNT(DISTINCT payment_id) FROM payment
    UNION ALL
    SELECT 11, 'rental', 'rental_id', COUNT(*) - COUNT(DISTINCT rental_id) FROM rental
    UNION ALL
    SELECT 12, 'staff', 'staff_id', COUNT(*) - COUNT(DISTINCT staff_id) FROM staff
    UNION ALL
    SELECT 13, 'store', 'store_id', COUNT(*) - COUNT(DISTINCT store_id) FROM store
)

SELECT 
    table_name, 
    primary_key, 
    duplicate_count
FROM 
    duplicate_checks
ORDER BY 
    sort_order;

-- 5.4 - Check for nulls across composite keys.

SELECT 
    'film_actor' AS table_name, 
    'actor_id, film_id' AS composite_key,
    COUNT(*) AS null_count
FROM 
    film_actor
WHERE 
    actor_id IS NULL
    OR film_id IS NULL

UNION ALL

SELECT 
    'film_category' AS table_name, 
    'film_id, category_id' AS composite_key,
    COUNT(*) AS null_count
FROM 
    film_category
WHERE 
    film_id IS NULL
    OR category_id IS NULL;
    
-- 5.5 - Check for duplicates across composite keys.

SELECT 
    'film_actor' AS table_name, 
    'actor_id, film_id' AS composite_key,
    COUNT(*) - COUNT(DISTINCT actor_id || '-' || film_id) AS duplicate_count
FROM 
    film_actor

UNION ALL

SELECT 
    'film_category', 
    'film_id, category_id' AS composite_key,
    COUNT(*) - COUNT(DISTINCT film_id || '-' || category_id)
FROM 
    film_category;

-- ==============================================================
-- 6. Foreign Key Checks
-- ==============================================================

-- 6.1 - Check foreign key constratints.

SELECT
    t.table_name,
    CASE 
        WHEN fk.child_column IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS foreign_key_exists,
    fk.child_column AS foreign_key_column,
    fk.parent_table,
    fk.parent_column,
    fk.constraint_name AS foreign_key_constraint
FROM 
    information_schema.tables AS t
LEFT JOIN (
    SELECT
        tc.table_name AS child_table,
        kcu.column_name AS child_column,
        ccu.table_name AS parent_table,
        ccu.column_name AS parent_column,
        tc.constraint_name
    FROM 
        information_schema.table_constraints AS tc
    INNER JOIN 
        information_schema.key_column_usage AS kcu
    ON 
        tc.constraint_name = kcu.constraint_name
    INNER JOIN 
        information_schema.constraint_column_usage AS ccu
    ON 
        tc.constraint_name = ccu.constraint_name
    WHERE 
        tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
) AS fk
ON 
    t.table_name = fk.child_table
WHERE 
    t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    t.table_name, fk.child_column;

-- 6.2 - Check if foreign keys link to valid primary keys in parent tables.

-- TABLE: address

SELECT 'address' AS table_name, 'city_id' AS secondary_key, COUNT(*) AS missing_key_count FROM address ad
LEFT JOIN city ci ON ad.city_id = ci.city_id
WHERE ci.city_id IS NULL

UNION ALL

-- TABLE: city

SELECT 'city', 'country_id', COUNT(*) FROM city ci
LEFT JOIN country co ON ci.country_id = co.country_id
WHERE co.country_id IS NULL

UNION ALL

-- TABLE: customer

SELECT 'customer', 'store_id', COUNT(*) FROM customer cu
LEFT JOIN store st ON cu.store_id = st.store_id
WHERE st.store_id IS NULL

UNION ALL

SELECT 'customer', 'address_id', COUNT(*) FROM customer cu
LEFT JOIN address ad ON cu.address_id = ad.address_id
WHERE ad.address_id IS NULL

UNION ALL

-- TABLE: film

SELECT 'film', 'language_id', COUNT(*) FROM film fi
LEFT JOIN language la ON fi.language_id = la.language_id
WHERE la.language_id IS NULL

UNION ALL

-- TABLE: film_actor

SELECT 'film_actor', 'actor_id', COUNT(*) FROM film_actor fa
LEFT JOIN actor ac ON fa.actor_id = ac.actor_id
WHERE ac.actor_id IS NULL

UNION ALL

SELECT 'film_actor', 'film_id', COUNT(*) FROM film_actor fa
LEFT JOIN film fi ON fa.film_id = fi.film_id
WHERE fi.film_id IS NULL

UNION ALL

-- TABLE: film_category

SELECT 'film_category', 'film_id', COUNT(*) FROM film_category fc
LEFT JOIN film fi ON fc.film_id = fi.film_id
WHERE fi.film_id IS NULL

UNION ALL

SELECT 'film_category', 'category_id', COUNT(*) FROM film_category fc
LEFT JOIN category ca ON fc.category_id = ca.category_id
WHERE ca.category_id IS NULL

UNION ALL

-- TABLE: inventory

SELECT 'inventory', 'film_id', COUNT(*) FROM inventory iv
LEFT JOIN film fi ON iv.film_id = fi.film_id
WHERE fi.film_id IS NULL

UNION ALL

SELECT 'inventory', 'store_id', COUNT(*) FROM inventory iv
LEFT JOIN store st ON iv.store_id = st.store_id
WHERE st.store_id IS NULL

UNION ALL

-- TABLE: payment

SELECT 'payment', 'customer_id', COUNT(*) FROM payment pm
LEFT JOIN customer cu ON pm.customer_id = cu.customer_id
WHERE cu.customer_id IS NULL

UNION ALL

SELECT 'payment', 'staff_id', COUNT(*) FROM payment pm
LEFT JOIN staff sf ON pm.staff_id = sf.staff_id
WHERE sf.staff_id IS NULL

UNION ALL

SELECT 'payment', 'rental_id', COUNT(*) FROM payment pm
LEFT JOIN rental re ON pm.rental_id = re.rental_id
WHERE re.rental_id IS NULL

UNION ALL

-- TABLE: rental

SELECT 'rental', 'inventory_id', COUNT(*) FROM rental re
LEFT JOIN inventory iv ON re.inventory_id = iv.inventory_id
WHERE iv.inventory_id IS NULL

UNION ALL

SELECT 'rental', 'customer_id', COUNT(*) FROM rental re
LEFT JOIN customer cu ON re.customer_id = cu.customer_id
WHERE cu.customer_id IS NULL

UNION ALL

SELECT 'rental', 'staff_id', COUNT(*) FROM rental re
LEFT JOIN staff sf ON re.staff_id = sf.staff_id
WHERE sf.staff_id IS NULL

UNION ALL

-- TABLE: staff

SELECT 'staff', 'address_id', COUNT(*) FROM staff sf
LEFT JOIN address ad ON sf.address_id = ad.address_id
WHERE ad.address_id IS NULL

UNION ALL

SELECT 'staff', 'store_id', COUNT(*) FROM staff sf
LEFT JOIN store st ON sf.store_id = st.store_id
WHERE st.store_id IS NULL

UNION ALL

-- TABLE: store

SELECT 'store', 'manager_staff_id', COUNT(*) FROM store st
LEFT JOIN staff sf ON st.manager_staff_id = sf.staff_id
WHERE sf.staff_id IS NULL

UNION ALL

SELECT 'store', 'address_id', COUNT(*) FROM store st
LEFT JOIN address ad ON st.address_id = ad.address_id
WHERE ad.address_id IS NULL

ORDER BY table_name;

-- ==============================================================
-- 7. Missing Data Checks (Key Variables)
-- ==============================================================

-- 7.1 - Identify columns across key tables that allow NULL values for targeted missing data checks.

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


-- 7.2 - Check key columns that allow NULL values.

SELECT 'customer' AS table_name, 'active' AS column_name, COUNT(*) AS missing_count 
FROM customer 
WHERE active IS NULL

UNION ALL

SELECT 'film', 'length', COUNT(*) 
FROM film 
WHERE length IS NULL

UNION ALL

SELECT 'film', 'rating', COUNT(*) 
FROM film 
WHERE rating IS NULL

UNION ALL

SELECT 'film','release_year',COUNT(*) 
FROM film 
WHERE release_year IS NULL

UNION ALL

SELECT 'rental','return_date', COUNT(*) 
FROM rental 
WHERE return_date IS NULL

ORDER BY table_name, column_name;

-- ==============================================================
-- 8. Duplicates Checks
-- ==============================================================

-- 8.1 - Combined duplicate counts across key tables.

SELECT 'actor' AS table_name, COUNT(*) AS duplicate_count
FROM (
    SELECT first_name, last_name
    FROM actor
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'address', COUNT(*)
FROM (
    SELECT address, address2, district, city_id, postal_code, phone
    FROM address
    GROUP BY address, address2, district, city_id, postal_code, phone
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'category', COUNT(*)
FROM (
    SELECT name
    FROM category
    GROUP BY name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'city', COUNT(*)
FROM (
    SELECT city, country_id
    FROM city
    GROUP BY city, country_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'country', COUNT(*)
FROM (
    SELECT country
    FROM country
    GROUP BY country
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'customer', COUNT(*)
FROM (
    SELECT store_id, first_name, last_name, email, address_id, activebool, create_date, active
    FROM customer
    GROUP BY store_id, first_name, last_name, email, address_id, activebool, create_date, active
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'film', COUNT(*)
FROM (
    SELECT title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext
    FROM film
    GROUP BY title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'inventory', COUNT(*)
FROM (
    SELECT film_id, store_id
    FROM inventory
    GROUP BY film_id, store_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'language', COUNT(*)
FROM (
    SELECT name
    FROM language
    GROUP BY name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'payment', COUNT(*)
FROM (
    SELECT customer_id, staff_id, rental_id, amount, payment_date
    FROM payment
    GROUP BY customer_id, staff_id, rental_id, amount, payment_date
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'rental', COUNT(*)
FROM (
    SELECT rental_date, inventory_id, customer_id, return_date, staff_id
    FROM rental
    GROUP BY rental_date, inventory_id, customer_id, return_date, staff_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'staff', COUNT(*)
FROM (
    SELECT first_name, last_name, address_id, email, store_id, active, username, password, picture
    FROM staff
    GROUP BY first_name, last_name, address_id, email, store_id, active, username, password, picture
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'store', COUNT(*)
FROM (
    SELECT manager_staff_id, address_id
    FROM store
    GROUP BY manager_staff_id, address_id
    HAVING COUNT(*) > 1
) AS dup

ORDER BY table_name;

-- 8.2 - View duplicate records identified (per table).

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

-- TABLE: inventory

SELECT *
FROM inventory
WHERE (film_id, store_id) IN (
    SELECT 
        film_id, 
        store_id
    FROM 
        inventory
    GROUP BY 
        film_id, 
        store_id
    HAVING 
        COUNT(*) > 1
)
LIMIT 10;

-- 8.3 - Create a clean view of tables containing duplicates (with duplicates removed).

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

-- Validation Checks:

-- Row counts before and after duplicate removal.

SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor;
SELECT 'clean_actor' AS table_name, COUNT(*) AS row_count FROM clean_actor;

-- Confirm no duplicates remain in clean-actor view.

SELECT 'clean_actor' AS table_name, COUNT(*) AS duplicate_count
FROM (
    SELECT first_name, last_name
    FROM clean_actor
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
) AS dup;

-- ==============================================================
-- 9. Distinct Value Counts
-- ==============================================================

-- 9.1 - Check the number of distinct values per variable.

-- TABLE: actor

SELECT 'actor_id' AS actor_variable, COUNT(DISTINCT actor_id) AS distinct_count FROM actor
UNION ALL
SELECT 'first_name', COUNT(DISTINCT first_name) FROM actor
UNION ALL
SELECT 'last_name', COUNT(DISTINCT last_name) FROM actor
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM actor;

-- TABLE: address

SELECT 'address_id' AS address_variable, COUNT(DISTINCT address_id) AS distinct_count FROM address
UNION ALL
SELECT 'address', COUNT(DISTINCT address) FROM address
UNION ALL
SELECT 'address2', COUNT(DISTINCT address2) FROM address
UNION ALL
SELECT 'district', COUNT(DISTINCT district) FROM address
UNION ALL
SELECT 'city_id', COUNT(DISTINCT city_id) FROM address
UNION ALL
SELECT 'postal_code', COUNT(DISTINCT postal_code) FROM address
UNION ALL
SELECT 'phone', COUNT(DISTINCT phone) FROM address
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM address;

-- TABLE: category

SELECT 'category_id' AS category_variable, COUNT(DISTINCT category_id) AS distinct_count FROM category
UNION ALL
SELECT 'name', COUNT(DISTINCT name) FROM category
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM category;

-- TABLE: city

SELECT 'city_id' AS city_variable, COUNT(DISTINCT city_id) AS distinct_count FROM city
UNION ALL
SELECT 'city', COUNT(DISTINCT city) FROM city
UNION ALL
SELECT 'country_id', COUNT(DISTINCT country_id) FROM city
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM city;

-- TABLE: country

SELECT 'country_id' AS country_variable, COUNT(DISTINCT country_id) AS distinct_count FROM country
UNION ALL
SELECT 'country', COUNT(DISTINCT country) FROM country
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM country;

-- TABLE: customer

SELECT 'customer_id' AS customer_variable, COUNT(DISTINCT customer_id) AS distinct_count FROM customer
UNION ALL
SELECT 'store_id', COUNT(DISTINCT store_id) FROM customer
UNION ALL
SELECT 'first_name', COUNT(DISTINCT first_name) FROM customer
UNION ALL
SELECT 'last_name', COUNT(DISTINCT last_name) FROM customer
UNION ALL
SELECT 'email', COUNT(DISTINCT email) FROM customer
UNION ALL
SELECT 'address_id', COUNT(DISTINCT address_id) FROM customer
UNION ALL
SELECT 'activebool', COUNT(DISTINCT activebool) FROM customer
UNION ALL
SELECT 'create_date', COUNT(DISTINCT create_date) FROM customer
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM customer
UNION ALL
SELECT 'active', COUNT(DISTINCT active) FROM customer;

-- TABLE: film

SELECT 'film_id' AS film_variable, COUNT(DISTINCT film_id) AS distinct_count FROM film
UNION ALL
SELECT 'title', COUNT(DISTINCT title) FROM film
UNION ALL
SELECT 'description', COUNT(DISTINCT description) FROM film
UNION ALL
SELECT 'release_year', COUNT(DISTINCT release_year) FROM film
UNION ALL
SELECT 'language_id', COUNT(DISTINCT language_id) FROM film
UNION ALL
SELECT 'rental_duration', COUNT(DISTINCT rental_duration) FROM film
UNION ALL
SELECT 'rental_rate', COUNT(DISTINCT rental_rate) FROM film
UNION ALL
SELECT 'length', COUNT(DISTINCT length) FROM film
UNION ALL
SELECT 'replacement_cost', COUNT(DISTINCT replacement_cost) FROM film
UNION ALL
SELECT 'rating', COUNT(DISTINCT rating) FROM film
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM film
UNION ALL
SELECT 'special_features', COUNT(DISTINCT special_features) FROM film
UNION ALL
SELECT 'fulltext', COUNT(DISTINCT fulltext) FROM film;

-- TABLE: film_actor

SELECT 'actor_id' AS film_actor_variable, COUNT(DISTINCT actor_id) AS distinct_count FROM film_actor
UNION ALL
SELECT 'film_id', COUNT(DISTINCT film_id) FROM film_actor
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM film_actor;

-- TABLE: film_category

SELECT 'film_id' AS film_category_variable, COUNT(DISTINCT film_id) AS distinct_count FROM film_category
UNION ALL
SELECT 'category_id', COUNT(DISTINCT category_id) FROM film_category
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM film_category;

-- TABLE: inventory

SELECT 'inventory_id' AS inventory_variable, COUNT(DISTINCT inventory_id) AS distinct_count FROM inventory
UNION ALL
SELECT 'film_id', COUNT(DISTINCT film_id) FROM inventory
UNION ALL
SELECT 'store_id', COUNT(DISTINCT store_id) FROM inventory
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM inventory;

-- TABLE: language

SELECT 'language_id' AS language_variable, COUNT(DISTINCT language_id) AS distinct_count FROM language
UNION ALL
SELECT 'name', COUNT(DISTINCT name) FROM language
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM language;

-- TABLE: payment

SELECT 'payment_id' AS payment_variable, COUNT(DISTINCT payment_id) AS distinct_count FROM payment
UNION ALL
SELECT 'customer_id', COUNT(DISTINCT customer_id) FROM payment
UNION ALL
SELECT 'staff_id', COUNT(DISTINCT staff_id) FROM payment
UNION ALL
SELECT 'rental_id', COUNT(DISTINCT rental_id) FROM payment
UNION ALL
SELECT 'amount', COUNT(DISTINCT amount) FROM payment
UNION ALL
SELECT 'payment_date', COUNT(DISTINCT payment_date) FROM payment;

-- TABLE: rental

SELECT 'rental_id' AS rental_variable, COUNT(DISTINCT rental_id) AS distinct_count FROM rental
UNION ALL
SELECT 'rental_date', COUNT(DISTINCT rental_date) FROM rental
UNION ALL
SELECT 'inventory_id', COUNT(DISTINCT inventory_id) FROM rental
UNION ALL
SELECT 'customer_id', COUNT(DISTINCT customer_id) FROM rental
UNION ALL
SELECT 'return_date', COUNT(DISTINCT return_date) FROM rental
UNION ALL
SELECT 'staff_id', COUNT(DISTINCT staff_id) FROM rental
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM rental;

-- TABLE: staff

SELECT 'staff_id' AS staff_variable, COUNT(DISTINCT staff_id) AS distinct_count FROM staff
UNION ALL
SELECT 'first_name', COUNT(DISTINCT first_name) FROM staff
UNION ALL
SELECT 'last_name', COUNT(DISTINCT last_name) FROM staff
UNION ALL
SELECT 'address_id', COUNT(DISTINCT address_id) FROM staff
UNION ALL
SELECT 'email', COUNT(DISTINCT email) FROM staff
UNION ALL
SELECT 'store_id', COUNT(DISTINCT store_id) FROM staff
UNION ALL
SELECT 'active', COUNT(DISTINCT active) FROM staff
UNION ALL
SELECT 'username', COUNT(DISTINCT username) FROM staff
UNION ALL
SELECT 'password', COUNT(DISTINCT password) FROM staff
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM staff
UNION ALL
SELECT 'picture', COUNT(DISTINCT picture) FROM staff;

-- TABLE: store

SELECT 'store_id' AS store_variable, COUNT(DISTINCT store_id) AS distinct_count FROM store
UNION ALL
SELECT 'manager_staff_id', COUNT(DISTINCT manager_staff_id) FROM store
UNION ALL
SELECT 'address_id', COUNT(DISTINCT address_id) FROM store
UNION ALL
SELECT 'last_update', COUNT(DISTINCT last_update) FROM store;

-- ==============================================================
-- 10. Frequency Distributions
-- ==============================================================

-- 10.1 - Check the frequency distribution of key categorical variables.

-- TABLE:  actor

SELECT
    first_name as actor_first_name,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM actor), 2) AS percentage
FROM actor
GROUP BY first_name
ORDER BY frequency DESC;

SELECT
    last_name as actor_last_name,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM actor), 2) AS percentage
FROM actor
GROUP BY last_name
ORDER BY frequency DESC;

-- TABLE: address

SELECT
    address AS address_address,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
FROM address
GROUP BY address
ORDER BY frequency DESC;

SELECT
    address2 AS address_address2,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
FROM address
GROUP BY address2
ORDER BY frequency DESC;

SELECT
    district AS address_district,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
FROM address
GROUP BY district
ORDER BY frequency DESC;

SELECT
    postal_code AS address_postal_code,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
FROM address
GROUP BY postal_code
ORDER BY frequency DESC;

SELECT
    phone AS address_phone,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
FROM address
GROUP BY phone
ORDER BY frequency DESC;

-- TABLE: category

SELECT
    name AS category_name,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM category), 2) AS percentage
FROM category
GROUP BY name
ORDER BY frequency DESC;

-- TABLE: city

SELECT
    city AS city_city,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM city), 2) AS percentage
FROM city
GROUP BY city
ORDER BY frequency DESC;

-- TABLE: country

SELECT
    country AS country_country,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM country), 2) AS percentage
FROM country
GROUP BY country
ORDER BY frequency DESC;

-- TABLE: customer

SELECT
    first_name AS customer_first_name,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
FROM customer
GROUP BY first_name
ORDER BY frequency DESC;

SELECT
    last_name AS customer_last_name,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
FROM customer
GROUP BY last_name
ORDER BY frequency DESC;

SELECT
    email AS customer_email,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
FROM customer
GROUP BY email
ORDER BY frequency DESC;

SELECT
    activebool AS customer_activebool,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
FROM customer
GROUP BY activebool
ORDER BY frequency DESC;

SELECT
    active AS customer_active,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
FROM customer
GROUP BY active
ORDER BY frequency DESC;

-- TABLE: film

SELECT
    title AS film_title,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
FROM film
GROUP BY title
ORDER BY frequency DESC;

SELECT
    description AS film_description,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
FROM film
GROUP BY description
ORDER BY frequency DESC;

SELECT
    rating AS film_rating,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
FROM film
GROUP BY rating
ORDER BY frequency DESC;

SELECT
    special_features AS film_special_features,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
FROM film
GROUP BY special_features
ORDER BY frequency DESC;

-- TABLE: language

SELECT 
    name AS language_name,  
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM language), 2) AS percentage
FROM language
GROUP BY name
ORDER BY frequency DESC;

-- TABLE: staff

SELECT 
    first_name AS staff_first_name, 
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY first_name
ORDER BY frequency DESC;

SELECT 
    last_name AS staff_last_name, 
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY last_name
ORDER BY frequency DESC;

SELECT 
    email AS staff_email,
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY email
ORDER BY frequency DESC;

SELECT 
    active AS staff_active, 
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY active
ORDER BY frequency DESC;

SELECT 
    username AS staff_username, 
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY username
ORDER BY frequency DESC;

-- ==============================================================
-- 11. Descriptive Statistics (Numeric Variables)
-- ==============================================================

-- 11.1 - Summary statistics and distributions of numeric variables.

SELECT 
    'film' AS table_name,
    'rental_duration' AS column_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN rental_duration IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN rental_duration = 0 THEN 1 ELSE 0 END) AS zero_count,
    MIN(rental_duration) AS min_value,
    MAX(rental_duration) AS max_value,
    ROUND(AVG(rental_duration), 2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rental_duration) AS median_value,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY rental_duration) AS q1_value,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY rental_duration) AS q2_value,
    (MAX(rental_duration) - MIN(rental_duration)) AS range_value,
    ROUND(STDDEV_POP(rental_duration), 2) AS stddev_value,
    ROUND(VAR_POP(rental_duration), 2) AS variance_value
FROM film

UNION ALL

SELECT 
    'film',
    'rental_rate',
    COUNT(*),
    SUM(CASE WHEN rental_rate IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN rental_rate = 0 THEN 1 ELSE 0 END),
    MIN(rental_rate),
    MAX(rental_rate),
    ROUND(AVG(rental_rate), 2),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rental_rate),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY rental_rate),
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY rental_rate),
    (MAX(rental_rate) - MIN(rental_rate)),
    ROUND(STDDEV_POP(rental_rate), 2),
    ROUND(VAR_POP(rental_rate), 2)
FROM film

UNION ALL

SELECT 
    'film',
    'length',
    COUNT(*),
    SUM(CASE WHEN length IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN length = 0 THEN 1 ELSE 0 END),
    MIN(length),
    MAX(length),
    ROUND(AVG(length), 2),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY length),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY length),
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY length),
    (MAX(length) - MIN(length)),
    ROUND(STDDEV_POP(length), 2),
    ROUND(VAR_POP(length), 2)
FROM film

UNION ALL

SELECT 
    'film',
    'replacement_cost',
    COUNT(*),
    SUM(CASE WHEN replacement_cost IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN replacement_cost = 0 THEN 1 ELSE 0 END),
    MIN(replacement_cost),
    MAX(replacement_cost),
    ROUND(AVG(replacement_cost), 2),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY replacement_cost),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY replacement_cost),
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY replacement_cost),
    (MAX(replacement_cost) - MIN(replacement_cost)),
    ROUND(STDDEV_POP(replacement_cost), 2),
    ROUND(VAR_POP(replacement_cost), 2)
FROM film

UNION ALL

SELECT 
    'payment',
    'amount',
    COUNT(*),
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN amount = 0 THEN 1 ELSE 0 END),
    MIN(amount),
    MAX(amount),
    ROUND(AVG(amount), 2),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount),
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount),
    (MAX(amount) - MIN(amount)),
    ROUND(STDDEV_POP(amount), 2),
    ROUND(VAR_POP(amount), 2)
FROM payment;

-- ==============================================================
-- 12. Temporal Checks
-- ==============================================================

-- 12.1 - Validate 'last_update' fields across all tables

SELECT 'actor' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM actor
UNION ALL
SELECT 'address', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM address
UNION ALL
SELECT 'category', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM category
UNION ALL
SELECT 'city', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM city
UNION ALL
SELECT 'country', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM country
UNION ALL
SELECT 'customer', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM customer
UNION ALL
SELECT 'film', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM film
UNION ALL
SELECT 'film_actor', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM film_actor
UNION ALL
SELECT 'film_category', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM film_category
UNION ALL
SELECT 'inventory', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM inventory
UNION ALL
SELECT 'language', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM language
UNION ALL
SELECT 'rental', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM rental
UNION ALL
SELECT 'staff', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM staff
UNION ALL
SELECT 'store', 'last_update', COUNT(DISTINCT last_update), MIN(last_update), MAX(last_update) FROM store
ORDER BY table_name;

-- 12.2 - Temporal analysis of key event date or timestamp fields

SELECT 
    'customer' AS table_name, 
    'create_date' AS column_name, 
    COUNT(DISTINCT create_date) AS distinct_dates, 
    MIN(create_date) AS min_date, 
    MAX(create_date) AS max_date 
FROM customer
UNION ALL
SELECT
    'payment' AS table_name, 
    'payment_date' AS column_name, 
    COUNT(DISTINCT payment_date) AS distinct_dates, 
    MIN(payment_date) AS min_date,
    MAX(payment_date) AS max_date 
FROM payment
UNION ALL
SELECT
    'rental' AS table_name, 
    'rental_date' AS column_name, 
    COUNT(DISTINCT rental_date) AS distinct_dates, 
    MIN(rental_date) AS min_date,
    MAX(rental_date) AS max_date 
FROM rental
UNION ALL
SELECT
    'rental' AS table_name, 
    'return_date' AS column_name, 
    COUNT(DISTINCT return_date) AS distinct_dates, 
    MIN(return_date) AS min_date,
    MAX(return_date) AS max_date 
FROM rental;

-- 12.3 - Temporal analysis of numeric date fields

SELECT
    'film' AS table_name, 
    'release_year' AS column_name, 
    COUNT(DISTINCT release_year) AS distinct_dates, 
    MIN(release_year) AS min_date,
    MAX(release_year) AS max_date 
FROM film;

-- 12.4 - Frequency distribution of key date or timestamp fields

SELECT 
    'rental' AS table_name,
    rental_date::date AS rental_date,
    COUNT(*) AS frequency_count
FROM rental
GROUP BY rental_date::date
ORDER BY rental_date::date;

SELECT 
    'rental' AS table_name,
    return_date::date AS return_date,
    COUNT(*) AS frequency_count
FROM rental
GROUP BY return_date::date
ORDER BY return_date::date;

SELECT 
    'payment' AS table_name,
    payment_date::date AS payment_date,
    COUNT(*) AS frequency_count
FROM payment
GROUP BY payment_date::date
ORDER BY payment_date::date;

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