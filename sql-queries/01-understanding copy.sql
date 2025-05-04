-- ==============================================================
-- Rockbuster Stealth Data Checks
-- Analyst: David Griesel
-- Date: July 2024
-- Purpose: Initial Data Exploration, Validation, and Preparation
-- ==============================================================

-- ==============================================================
-- TABLE OF CONTENTS:
-- ==============================================================

-- 1. Overview of Tables
-- 2. Row Counts
-- 3. Sample Rows
-- 4. Data Type Validation
-- 5. Foreign Key Checks
-- 6. Missing Data Checks
-- 7. Duplicates Checks
-- 8. Distinct Value Checks
-- 9. Temporal Checks
-- 10. Logic and Dependency Checks
-- 11. Distributions
-- 12. Outlier Detection
-- 13. Basic Summary Stats (Numeric Columns)

-- ==============================================================
-- 1. Overview of Tables
-- ==============================================================

-- Get a list of all tables in the public schema.

    SELECT 
        table_schema, 
        table_type, 
        table_name
    FROM information_schema.tables
    WHERE table_schema = 'public' -- only look at public tables
    AND table_type = 'BASE TABLE' -- exclude views
    ORDER BY table_name;

-- RESULTS: 15 public tables

-- ==============================================================
-- 2. Row Counts
-- ==============================================================

-- Get row counts for all base tables in the public schema.

    SELECT 'actor' AS table_name, COUNT(*) FROM actor
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

-- QUESTION: Why are there 599 customers, but 603 addresses?
-- QUESTION: Why are there 16044 rentals but only 14596 payments?

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

-- NOTE: Displays data type (PostgreSQL & VS Code).
-- NOTE: film_actor table links actor_id with film_id.
-- NOTE: film_category table links film_id with category_id.
-- QUESTION: Why does customer table have activebool & active columns?

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
        --c.table_name, c.ordinal_position;

-- NOTE: Active column in customer table uses integer type.
-- NOTE: Rating column in film table uses user defined type.

-- ==============================================================
-- 5. Foreign Key Checks
-- ==============================================================

-- Check if all foreign keys link to valid primary keys in parent tables.

        SELECT 
            'address' AS table,
            'city_id' AS secondary_key, 
            COUNT(*) AS missing_key
        FROM address a
        LEFT JOIN city c ON a.city_id = c.city_id
        WHERE c.city_id IS NULL

        UNION ALL

        SELECT 
            'city' AS table,
            'country_id' AS secondary_key, 
            COUNT(*) AS missing_key
        FROM city ci
        LEFT JOIN country co ON ci.country_id = co.country_id
        WHERE co.country_id IS NULL;


    -- TABLE: address

        SELECT a.city_id
        FROM address a
        LEFT JOIN city c ON a.city_id = c.city_id
        WHERE c.city_id IS NULL;

    -- TABLE: city

        SELECT ci.country_id
        FROM city ci
        LEFT JOIN country co ON ci.country_id = co.country_id 
        WHERE co.country_id IS NULL;

    -- TABLE: customer

        SELECT cu.store_id
        FROM customer cu
        LEFT JOIN store s ON cu.store_id = s.store_id
        WHERE s.store_id IS NULL;

        SELECT cu.address_id
        FROM customer cu
        LEFT JOIN address a ON cu.address_id = a.address_id
        WHERE a.address_id IS NULL;

    -- TABLE: film

        SELECT f.language_id
        FROM film f
        LEFT JOIN language l ON f.language_id = l.language_id
        WHERE l.language_id IS NULL;

    -- TABLE: film_actor

        SELECT fa.film_id
        FROM film_actor fa
        LEFT JOIN film f ON fa.film_id = f.film_id
        WHERE f.film_id IS NULL;

    -- TABLE: film_category

        SELECT fc.category_id
        FROM film_category fc
        LEFT JOIN category c ON fc.category_id = c.category_id
        WHERE c.category_id IS NULL;

    -- TABLE: inventory

        SELECT i.film_id
        FROM inventory i
        LEFT JOIN film f ON i.film_id = f.film_id
        WHERE f.film_id IS NULL;

        SELECT i.store_id
        FROM inventory i
        LEFT JOIN store s ON i.store_id = s.store_id
        WHERE s.store_id IS NULL;

    -- TABLE: payment

        SELECT p.customer_id
        FROM payment p
        LEFT JOIN customer c ON p.customer_id = c.customer_id
        WHERE c.customer_id IS NULL;

        SELECT p.staff_id
        FROM payment p
        LEFT JOIN staff s ON p.staff_id = s.staff_id
        WHERE s.staff_id IS NULL;

        SELECT p.rental_id
        FROM payment p
        LEFT JOIN rental r ON p.rental_id = r.rental_id
        WHERE r.rental_id IS NULL;

    -- TABLE: rental

        SELECT r.inventory_id
        FROM rental r
        LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
        WHERE i.inventory_id IS NULL;

        SELECT r.customer_id
        FROM rental r
        LEFT JOIN customer c ON r.customer_id = c.customer_id
        WHERE c.customer_id IS NULL;

        SELECT r.staff_id
        FROM rental r
        LEFT JOIN staff s ON r.staff_id = s.staff_id
        WHERE s.staff_id IS NULL;

    -- TABLE: staff

        SELECT s.address_id
        FROM staff s
        LEFT JOIN address a ON s.address_id = a.address_id
        WHERE a.address_id IS NULL;

        SELECT s.store_id
        FROM staff s
        LEFT JOIN store st ON s.store_id = st.store_id
        WHERE st.store_id IS NULL;

    -- TABLE: store

        SELECT s.manager_staff_id
        FROM store s
        LEFT JOIN staff st ON s.manager_staff_id = st.staff_id
        WHERE st.staff_id IS NULL;

        SELECT s.address_id
        FROM store s
        LEFT JOIN address a ON s.address_id = a.address_id
        WHERE a.address_id IS NULL;

-- RESULTS: All foreign keys link to valid primary keys in parent tables.

-- ==============================================================
-- 6. Missing Data Checks (Key Variables)
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
        'rental'
    )
    AND is_nullable = 'YES'
    ORDER BY ordinal_position;

-- RESULTS: 11 Columns that may contain blanks. Most in film table. 

-- Check columns that allow NULL values for missing data

    -- TABLE: actor

        SELECT
            'actor' AS table_name, 
            'actor_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM actor
        WHERE actor_id IS NULL

        UNION ALL

        SELECT 
            'actor' AS table_name, 
            'first_name' AS column_name, 
            COUNT(*) AS missing_count
        FROM actor
        WHERE first_name IS NULL

        UNION ALL

        SELECT 
            'actor' AS table_name, 
            'last_name' AS column_name, 
            COUNT(*) AS missing_count
        FROM actor
        WHERE last_name IS NULL

        UNION ALL

    -- TABLE: address

        SELECT
            'address' AS table_name, 
            'address_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM address
        WHERE address_id IS NULL

        UNION ALL

        SELECT 
            'address' AS table_name, 
            'city_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM address
        WHERE city_id IS NULL

        UNION ALL

    -- TABLE: category

        SELECT 
            'category' AS table_name, 
            'category_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM category
        WHERE category_id IS NULL

        UNION ALL

        SELECT 
            'category' AS table_name, 
            'name' AS column_name, 
            COUNT(*) AS missing_count
        FROM category
        WHERE name IS NULL

        UNION ALL

    -- TABLE: city

        SELECT 
            'city' AS table_name, 
            'city_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM city
        WHERE city_id IS NULL

        UNION ALL

        SELECT 
            'city' AS table_name, 
            'city' AS column_name, 
            COUNT(*) AS missing_count
        FROM city
        WHERE city IS NULL

        UNION ALL

        SELECT 
            'city' AS table_name, 
            'country_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM city
        WHERE country_id IS NULL

        UNION ALL
        
    -- TABLE: country

        SELECT 
            'country' AS table_name, 
            'country_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM country
        WHERE country_id IS NULL

        UNION ALL
        
        SELECT 
            'country' AS table_name, 
            'country' AS column_name, 
            COUNT(*) AS missing_count
        FROM country
        WHERE country IS NULL

        UNION ALL

    -- TABLE: customer

        SELECT 
            'customer' AS table_name, 
            'customer_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM customer
        WHERE customer_id IS NULL

        UNION ALL
        
        SELECT 
            'customer' AS table_name, 
            'store_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM customer
        WHERE store_id IS NULL

        UNION ALL
        
        SELECT 
            'customer' AS table_name, 
            'first_name' AS column_name, 
            COUNT(*) AS missing_count
        FROM customer
        WHERE first_name IS NULL

        UNION ALL

        SELECT 
            'customer' AS table_name, 
            'last_name' AS column_name, 
            COUNT(*) AS missing_count
        FROM customer
        WHERE last_name IS NULL

        UNION ALL

        SELECT 
            'customer' AS table_name, 
            'address_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM customer
        WHERE address_id IS NULL

        UNION ALL

    -- TABLE: film

        SELECT 
            'film' AS table_name, 
            'film_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE film_id IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'title' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE title IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'release_year' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE release_year IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'language_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE language_id IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'rental_duration' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE rental_duration IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'rental_rate' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE rental_rate IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'length' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE length IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'replacement_cost' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE replacement_cost IS NULL

        UNION ALL

        SELECT 
            'film' AS table_name, 
            'rating' AS column_name, 
            COUNT(*) AS missing_count
        FROM film
        WHERE rating IS NULL
        
        UNION ALL

    -- TABLE: film_actor

        SELECT
            'film_actor' AS table_name, 
            'actor_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM film_actor
        WHERE actor_id IS NULL

        UNION ALL

        SELECT 
            'film_actor' AS table_name, 
            'film_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM film_actor
        WHERE film_id IS NULL

        UNION ALL
        
    -- TABLE: film_category

        SELECT 
            'film_category' AS table_name, 
            'film_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM film_category
        WHERE film_id IS NULL

        UNION ALL

        SELECT 
            'film_category' AS table_name, 
            'category_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM film_category
        WHERE category_id IS NULL

        UNION ALL
        
    -- TABLE: inventory

        SELECT 
            'inventory' AS table_name, 
            'inventory_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM inventory
        WHERE inventory_id IS NULL

        UNION ALL

        SELECT 
            'inventory' AS table_name, 
            'film_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM inventory
        WHERE film_id IS NULL

        UNION ALL

        SELECT 
            'inventory' AS table_name, 
            'store_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM inventory
        WHERE store_id IS NULL

        UNION ALL 

    -- TABLE: language

        SELECT 
            'language' AS table_name, 
            'language_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM language
        WHERE language_id IS NULL

        UNION ALL

        SELECT 
            'language' AS table_name, 
            'name' AS table_name,
            COUNT(*) AS missing_count
        FROM language
        WHERE name IS NULL

        UNION ALL 

    -- TABLE: payment

        SELECT 
            'payment' AS table_name,
            'payment_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM payment
        WHERE payment_id IS NULL

        UNION ALL

        SELECT 
            'payment' AS table_name,
            'customer_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM payment
        WHERE customer_id IS NULL

        UNION ALL

        SELECT 
            'payment' AS table_name,
            'staff_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM payment
        WHERE staff_id IS NULL

        UNION ALL

        SELECT 
            'payment' AS table_name,
            'rental_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM payment
        WHERE rental_id IS NULL

        UNION ALL

        SELECT 
            'payment' AS table_name,
            'amount' AS column_name, 
            COUNT(*) AS missing_count
        FROM payment
        WHERE amount IS NULL

        UNION ALL 

        SELECT 
            'payment' AS table_name,
            'payment_date' AS column_name, 
            COUNT(*) AS missing_count
        FROM payment
        WHERE payment_date IS NULL

        UNION ALL 

    -- TABLE: rental

        SELECT 
            'rental' AS table_name,
            'rental_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM rental
        WHERE rental_id IS NULL

        UNION ALL

        SELECT 
            'rental' AS table_name,
            'rental_date' AS column_name, 
            COUNT(*) AS missing_count
        FROM rental
        WHERE rental_date IS NULL

        UNION ALL

        SELECT 
            'rental' AS table_name,
            'inventory_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM rental
        WHERE inventory_id IS NULL

        UNION ALL

        SELECT 
            'rental' AS table_name,
            'customer_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM rental
        WHERE customer_id IS NULL

        UNION ALL

        SELECT 
            'rental' AS table_name,
            'return_date' AS column_name, 
            COUNT(*) AS missing_count
        FROM rental
        WHERE return_date IS NULL

        UNION ALL

        SELECT 
            'rental' AS table_name,
            'staff_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM rental
        WHERE staff_id IS NULL

        UNION ALL

    -- TABLE: staff

        SELECT 
            'staff' AS table_name,
            'staff_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM staff
        WHERE staff_id IS NULL

        UNION ALL

        SELECT 
            'staff' AS table_name,
            'first_name' AS column_name, 
            COUNT(*) AS missing_count
        FROM staff
        WHERE first_name IS NULL

        UNION ALL

        SELECT 
            'staff' AS table_name,
            'last_name' AS column_name, 
            COUNT(*) AS missing_count
        FROM staff
        WHERE last_name IS NULL

        UNION ALL

        SELECT 
            'staff' AS table_name,
            'address_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM staff
        WHERE address_id IS NULL

        UNION ALL

        SELECT 
            'staff' AS table_name,
            'store_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM staff
        WHERE store_id IS NULL

        UNION ALL

    -- TABLE: store

        SELECT 
            'store' AS table_name,
            'store_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM store
        WHERE store_id IS NULL

        UNION ALL

        SELECT 
            'store' AS table_name,
            'manager_staff_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM store
        WHERE manager_staff_id IS NULL

        UNION ALL

        SELECT 
            'store' AS table_name,
            'address_id' AS column_name, 
            COUNT(*) AS missing_count
        FROM store
        WHERE address_id IS NULL
        
-- RESULTS: 183 records missing in return_date in rental table.

-- ==============================================================
-- 7. Duplicates Checks
-- ==============================================================

-- Check for duplicate primary keys

    -- TABLE: actor 

        SELECT 
            actor_id,
            COUNT(*) AS duplicate_count
        FROM  actor
        GROUP BY actor_id
        HAVING COUNT(*) > 1;

    -- TABLE: address

        SELECT 
            address_id,
            COUNT(*) AS duplicate_count
        FROM address
        GROUP BY address_id
        HAVING COUNT(*) > 1;

    -- TABLE: category

        SELECT 
            category_id,
            COUNT(*) AS duplicate_count
        FROM category
        GROUP BY category_id
        HAVING COUNT(*) > 1;

    -- TABLE: city

        SELECT 
            city_id,
            COUNT(*) AS duplicate_count
        FROM city
        GROUP BY city_id
        HAVING COUNT(*) > 1;

    -- TABLE: country

        SELECT 
            country_id,
            COUNT(*) AS duplicate_count
        FROM country
        GROUP BY country_id
        HAVING COUNT(*) > 1;

    -- TABLE: customer

        SELECT 
            customer_id,
            COUNT(*) AS duplicate_count
        FROM customer
        GROUP BY customer_id
        HAVING COUNT(*) > 1;

    -- TABLE: film

        SELECT
            film_id,
            COUNT(*) AS duplicate_count
        FROM film
        GROUP BY film_id
        HAVING COUNT(*) > 1;    

    -- TABLE: film_actor

        SELECT 
            actor_id,
            COUNT(*) AS duplicate_count
        FROM film_actor
        GROUP BY actor_id
        HAVING COUNT(*) > 1 ;

    -- TABLE: film_category

        SELECT 
            film_id,
            COUNT(*) AS duplicate_count
        FROM film_category
        GROUP BY film_id
        HAVING COUNT(*) > 1;

    -- TABLE: inventory

        SELECT 
            inventory_id,
            COUNT(*) AS duplicate_count
        FROM inventory
        GROUP BY inventory_id
        HAVING COUNT(*) > 1;

    -- TABLE: language

        SELECT 
            language_id,
            COUNT(*) AS duplicate_count
        FROM language
        GROUP BY language_id
        HAVING COUNT(*) > 1;
            
    -- TABLE: payment

        SELECT 
            payment_id,
            COUNT(*) AS duplicate_count
        FROM payment
        GROUP BY payment_id
        HAVING COUNT(*) > 1;

    -- TABLE: rental

        SELECT 
            rental_id,
            COUNT(*) AS duplicate_count
        FROM rental
        GROUP BY rental_id
        HAVING COUNT(*) > 1;

    -- TABLE: staff

        SELECT 
            staff_id,
            COUNT(*) AS duplicate_count
        FROM staff
        GROUP BY staff_id
        HAVING COUNT(*) > 1;

    -- TABLE: store

        SELECT 
            store_id,
            COUNT(*) AS duplicate_count
        FROM store
        GROUP BY store_id
        HAVING COUNT(*) > 1;

-- NOTE: Expecting duplicates in film_actor table which links actor_id with film_id.
-- RESULTS: Only film_actor table returned 200 rows.

-- Check for duplicate record

    -- TABLE: actor 

        SELECT 
            first_name, 
            last_name, 
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            actor
        GROUP BY 
            first_name, 
            last_name, 
            last_update
        HAVING 
            COUNT(*) > 1;

    -- RESULTS: Duplicate record found!!!

        SELECT *
        FROM actor
        WHERE actor_id IN (101,110);

    -- TABLE: address

        SELECT 
            address, 
            address2, 
            district,
            city_id,
            postal_code,
            phone,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            address
        GROUP BY 
            address, 
            address2, 
            district,
            city_id,
            postal_code,
            phone,
            last_update
        HAVING 
            COUNT(*) > 1;

    -- TABLE: category

        SELECT 
            name,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            category
        GROUP BY 
            name,
            last_update
        HAVING 
            COUNT(*) > 1;

    -- TABLE: city

        SELECT 
            city,
            country_id,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            city
        GROUP BY 
            city,
            country_id,
            last_update
        HAVING 
            COUNT(*) > 1;

    -- TABLE: country

        SELECT 
            country,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            country
        GROUP BY 
            country,
            last_update
        HAVING 
            COUNT(*) > 1;

    -- TABLE: customer

        SELECT 
            store_id,
            first_name,
            last_name,
            email,
            address_id,
            activebool,
            create_date,
            last_update,
            active,
            COUNT(*) AS duplicate_count
        FROM 
            customer
        GROUP BY 
            store_id,
            first_name,
            last_name,
            email,
            address_id,
            activebool,
            create_date,
            last_update,
            active
        HAVING 
            COUNT(*) > 1;
        
    -- TABLE: film

        SELECT 
            title,
            description,
            release_year,
            language_id,
            rental_duration,
            rental_rate,
            length,
            replacement_cost,
            rating,
            last_update,
            special_features,
            fulltext,
            COUNT(*) AS duplicate_count
        FROM 
            film
        GROUP BY 
            title,
            description,
            release_year,
            language_id,
            rental_duration,
            rental_rate,
            length,
            replacement_cost,
            rating,
            last_update,
            special_features,
            fulltext
        HAVING 
            COUNT(*) > 1;        

    -- TABLE: film_actor

        SELECT 
            film_id,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            film_actor
        GROUP BY 
            film_id,
            last_update
        HAVING 
            COUNT(*) > 1;
            
    -- TABLE: film_category

        SELECT 
            category_id,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            film_category
        GROUP BY 
            category_id,
            last_update
        HAVING 
            COUNT(*) > 1;

    -- TABLE: inventory

        SELECT 
            film_id,
            store_id,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            inventory
        GROUP BY 
            film_id,
            store_id,
            last_update
        HAVING 
            COUNT(*) > 1; 

    -- TABLE: language

        SELECT 
            name,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            language
        GROUP BY 
            name,
            last_update
        HAVING 
            COUNT(*) > 1;

    -- TABLE: payment

        SELECT 
            customer_id,
            staff_id,
            rental_id,
            amount,
            payment_date,
            COUNT(*) AS duplicate_count
        FROM 
            payment
        GROUP BY 
            customer_id,
            staff_id,
            rental_id,
            amount,
            payment_date
        HAVING 
            COUNT(*) > 1; 

    -- TABLE: rental

        SELECT 
            rental_date,
            inventory_id,
            customer_id,
            return_date,
            staff_id,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            rental
        GROUP BY 
            rental_date,
            inventory_id,
            customer_id,
            return_date,
            staff_id,
            last_update
        HAVING 
            COUNT(*) > 1;

    -- TABLE: staff

        SELECT 
            first_name,
            last_name,
            address_id,
            email,
            store_id,
            active,
            username,
            password,
            last_update,
            picture,
            COUNT(*) AS duplicate_count        
        FROM 
            staff
        GROUP BY 
            first_name,
            last_name,
            address_id,
            email,
            store_id,
            active,
            username,
            password,
            last_update,
            picture
        HAVING 
            COUNT(*) > 1;      

    -- TABLE: store

        SELECT 
            manager_staff_id,
            address_id,
            last_update,
            COUNT(*) AS duplicate_count
        FROM 
            store
        GROUP BY 
            manager_staff_id,
            address_id,
            last_update
        HAVING 
            COUNT(*) > 1;
      
-- NOTE: Expecting duplicates in film_actor table which links actor_id with film_id.
-- NOTE: Expecting duplicates in film_category table which links film_id with category_id.
-- NOTE: Expecting duplicates in inventory table - each copy of a film in the same store.
-- RESULTS: film_actor table returned 976 rows.
-- RESULTS: film_category table returned 16 rows.
-- RESULTS: inventory tables returned 1521 rows.

-- ==============================================================
-- 8. Distinct Value Checks
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
-- 9. Temporal Checks
-- ==============================================================
    
    SELECT MIN(rental_date), MAX(rental_date) FROM rental;

-- ==============================================================
-- 10. Logic and Dependency Checks
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

-- ==============================================================
-- 11. Distributions
-- ==============================================================

    SELECT country, COUNT(*) 
    FROM country
    GROUP BY country
    ORDER BY COUNT(*) DESC;

-- ==============================================================
-- 12. Outlier Detection
-- ==============================================================
    
    SELECT rental_id, return_date, rental_date
    FROM rental
    WHERE EXTRACT(EPOCH FROM (return_date - rental_date)) / 86400 > 100;

-- ==============================================================
-- 13. Basic Summary Stats (Numeric Columns)
-- ==============================================================

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