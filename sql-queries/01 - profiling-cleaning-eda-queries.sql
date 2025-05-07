-- ===============================================================================
-- Rockbuster Stealth
-- Analyst: David Griesel
-- Date: July 2024
-- Purpose: Initial Data Profiling, Cleaning, and EDA
-- ===============================================================================

-- ===============================================================================
-- TABLE OF CONTENTS:
-- ===============================================================================

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

-- ===============================================================================
-- 1. Overview of Tables
-- ===============================================================================

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

-- OBSERVATIONS: 
-- THere are 15 tables in the public schema.

-- ===============================================================================
-- 2. Row Counts
-- ===============================================================================

-- 2.1 - Count rows for all base tables in the public schema.

    SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor
    UNION ALL
    SELECT 'address' AS table_name, COUNT(*) AS row_count FROM address
    UNION ALL
    SELECT 'category' AS table_name, COUNT(*) AS row_count FROM category
    UNION ALL
    SELECT 'city' AS table_name, COUNT(*) AS row_count FROM city
    UNION ALL
    SELECT 'country' AS table_name, COUNT(*) AS row_count FROM country
    UNION ALL
    SELECT 'customer' AS table_name, COUNT(*) AS row_count FROM customer
    UNION ALL
    SELECT 'film' AS table_name, COUNT(*) AS row_count FROM film
    UNION ALL
    SELECT 'film_actor' AS table_name, COUNT(*) AS row_count FROM film_actor
    UNION ALL
    SELECT 'film_category' AS table_name, COUNT(*) AS row_count FROM film_category
    UNION ALL
    SELECT 'inventory' AS table_name, COUNT(*) AS row_count FROM inventory
    UNION ALL
    SELECT 'language' AS table_name, COUNT(*) AS row_count FROM language
    UNION ALL
    SELECT 'payment' AS table_name, COUNT(*) AS row_count FROM payment
    UNION ALL
    SELECT 'rental' AS table_name, COUNT(*) AS row_count FROM rental
    UNION ALL
    SELECT 'staff' AS table_name, COUNT(*) AS row_count FROM staff
    UNION ALL
    SELECT 'store' AS table_name, COUNT(*) AS row_count FROM store;

-- OBSERVATIONS:
-- All tables are populated.
-- 603 addresses (599 customers + 2 staff + 2 stores).
-- 16044 rentals vs 14596 payments (likely due to outstanding returns).

-- ===============================================================================
-- 3. Sample Rows
-- ===============================================================================

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

-- OBSERVATIONS:
-- Some expected null values (address2, picture).
-- Some empty values (postal_code, phone).
-- Possible reduntant columns (address.address2, film.special_features, staff.picture).
-- Some ambiguous column names (category.name, language.name).

-- ===============================================================================
-- 4. Data Type Validation
-- ===============================================================================

-- 4.1 - Retrieve data types for all variables across all tables.

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
        c.data_type-- c.table_name, c.ordinal_position;

-- OBSERVATIONS:
-- film.rating is type USER-DEFINED - cast to varchar in queries.
-- staff.active is type boolean - alias to staff.activebool
-- language.name is type character - trim in queries.
-- customer.active of type integer vs customer.activebool of type boolean - compare and flag for ignore.
-- film.release_year of type integer - flag for temporal analysis.
-- rental.return_date | rental.rental_date | payment.payment_date - cast to date in queries.

-- ===============================================================================
-- 5. Primary Key Checks
-- ===============================================================================

-- 5.1 - Check if primary keys exist in the schema.

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

-- OBSERVATIONS: 
-- No primary key constraints exist in the schema.

-- 5.2 - Check for nulls in primary key columns.

    SELECT 'actor' AS table_name, 'actor_id' AS primary_key, COUNT(*) AS null_count FROM actor WHERE actor_id IS NULL
    UNION ALL
    SELECT 'address' AS table_name, 'address_id' AS primary_key, COUNT(*) AS null_count FROM address WHERE address_id IS NULL
    UNION ALL
    SELECT 'category' AS table_name, 'category_id' AS primary_key, COUNT(*) AS null_count FROM category WHERE category_id IS NULL
    UNION ALL
    SELECT 'city' AS table_name, 'city_id' AS primary_key, COUNT(*) AS null_count FROM city WHERE city_id IS NULL
    UNION ALL
    SELECT 'country' AS table_name, 'country_id' AS primary_key, COUNT(*) AS null_count FROM country WHERE country_id IS NULL
    UNION ALL
    SELECT 'customer' AS table_name, 'customer_id' AS primary_key, COUNT(*) AS null_count FROM customer WHERE customer_id IS NULL
    UNION ALL
    SELECT 'film' AS table_name, 'film_id' AS primary_key, COUNT(*) AS null_count FROM film WHERE film_id IS NULL
    UNION ALL
    SELECT 'inventory' AS table_name, 'inventory_id' AS primary_key, COUNT(*) AS null_count FROM inventory WHERE inventory_id IS NULL
    UNION ALL
    SELECT 'language' AS table_name, 'language_id' AS primary_key, COUNT(*) AS null_count FROM language WHERE language_id IS NULL
    UNION ALL
    SELECT 'payment' AS table_name, 'payment_id' AS primary_key, COUNT(*) AS null_count FROM payment WHERE payment_id IS NULL
    UNION ALL
    SELECT 'rental' AS table_name, 'rental_id' AS primary_key, COUNT(*) AS null_count FROM rental WHERE rental_id IS NULL
    UNION ALL
    SELECT 'staff' AS table_name, 'staff_id' AS primary_key, COUNT(*) AS null_count FROM staff WHERE staff_id IS NULL
    UNION ALL
    SELECT 'store' AS table_name, 'store_id' AS primary_key, COUNT(*) AS null_count FROM store WHERE store_id IS NULL;

-- OBSERVATIONS:
-- No nullss in primary key columns.

-- 5.3 - Check for duplicates in primary key columns.

    WITH duplicate_checks AS (
        
        SELECT 1 AS sort_order, 'actor' AS table_name, 'actor_id' AS primary_key, COUNT(*) - COUNT(DISTINCT actor_id) AS duplicate_count FROM actor
        UNION ALL
        SELECT 2 AS sort_order, 'address' AS table_name, 'address_id' AS primary_key, COUNT(*) - COUNT(DISTINCT address_id) AS duplicate_count FROM address
        UNION ALL
        SELECT 3 AS sort_order, 'category' AS table_name, 'category_id' AS primary_key, COUNT(*) - COUNT(DISTINCT category_id) AS duplicate_count FROM category
        UNION ALL
        SELECT 4 AS sort_order, 'city' AS table_name, 'city_id' AS primary_key, COUNT(*) - COUNT(DISTINCT city_id) AS duplicate_count FROM city
        UNION ALL
        SELECT 5 AS sort_order, 'country' AS table_name, 'country_id' AS primary_key, COUNT(*) - COUNT(DISTINCT country_id) AS duplicate_count FROM country
        UNION ALL
        SELECT 6 AS sort_order, 'customer' AS table_name, 'customer_id' AS primary_key, COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_count FROM customer
        UNION ALL
        SELECT 7 AS sort_order, 'film' AS table_name, 'film_id' AS primary_key, COUNT(*) - COUNT(DISTINCT film_id) AS duplicate_count FROM film
        UNION ALL
        SELECT 8 AS sort_order, 'inventory' AS table_name, 'inventory_id' AS primary_key, COUNT(*) - COUNT(DISTINCT inventory_id) AS duplicate_count FROM inventory
        UNION ALL
        SELECT 9 AS sort_order, 'language' AS table_name, 'language_id' AS primary_key, COUNT(*) - COUNT(DISTINCT language_id) AS duplicate_count FROM language
        UNION ALL
        SELECT 10 AS sort_order, 'payment' AS table_name, 'payment_id' AS primary_key, COUNT(*) - COUNT(DISTINCT payment_id) AS duplicate_count FROM payment
        UNION ALL
        SELECT 11 AS sort_order, 'rental' AS table_name, 'rental_id' AS primary_key, COUNT(*) - COUNT(DISTINCT rental_id) AS duplicate_count FROM rental
        UNION ALL
        SELECT 12 AS sort_order, 'staff' AS table_name, 'staff_id' AS primary_key, COUNT(*) - COUNT(DISTINCT staff_id) AS duplicate_count FROM staff
        UNION ALL
        SELECT 13 AS sort_order, 'store' AS table_name, 'store_id' AS primary_key, COUNT(*) - COUNT(DISTINCT store_id) AS duplicate_count FROM store
    )

    SELECT 
        table_name, 
        primary_key, 
        duplicate_count
    FROM 
        duplicate_checks
    ORDER BY 
        sort_order;

-- OBSERVATIONS:
-- No duplicates in primary key columns.

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

-- OBSERVATIONS:
-- No nulls across composite keys.
    
-- 5.5 - Check for duplicates across composite keys.

    SELECT 
        'film_actor' AS table_name, 
        'actor_id, film_id' AS composite_key,
        COUNT(*) - COUNT(DISTINCT actor_id || '-' || film_id) AS duplicate_count
    FROM 
        film_actor

    UNION ALL

    SELECT 
        'film_category' AS table_name, 
        'film_id, category_id' AS composite_key,
        COUNT(*) - COUNT(DISTINCT film_id || '-' || category_id) AS duplicate_count
    FROM 
        film_category;

-- OBSERVATIONS:
-- No duplicates across composite keys.

-- ===============================================================================
-- 6. Foreign Key Checks
-- ===============================================================================

-- 6.1 - Check foreign key constraints in the schema.

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

-- OBSERVATIONS:
-- No foreign key constraints exist in the schema.

-- 6.2 - Check if foreign keys link to valid primary keys in parent tables.

    -- TABLE: address

    SELECT 'address' AS table_name, 'city_id' AS secondary_key, COUNT(*) AS missing_key_count FROM address ad
    LEFT JOIN city ci ON ad.city_id = ci.city_id
    WHERE ci.city_id IS NULL

    UNION ALL

    -- TABLE: city

    SELECT 'city' AS table_name, 'country_id' AS secondary_key, COUNT(*) AS missing_key_count FROM city ci
    LEFT JOIN country co ON ci.country_id = co.country_id
    WHERE co.country_id IS NULL

    UNION ALL

    -- TABLE: customer

    SELECT 'customer' AS table_name, 'store_id' AS secondary_key, COUNT(*) AS missing_key_count FROM customer cu
    LEFT JOIN store st ON cu.store_id = st.store_id
    WHERE st.store_id IS NULL

    UNION ALL

    SELECT 'customer' AS table_name, 'address_id' AS secondary_key, COUNT(*) AS missing_key_count FROM customer cu
    LEFT JOIN address ad ON cu.address_id = ad.address_id
    WHERE ad.address_id IS NULL

    UNION ALL

    -- TABLE: film

    SELECT 'film' AS table_name, 'language_id' AS secondary_key, COUNT(*) AS missing_key_count FROM film fi
    LEFT JOIN language la ON fi.language_id = la.language_id
    WHERE la.language_id IS NULL

    UNION ALL

    -- TABLE: film_actor

    SELECT 'film_actor' AS table_name, 'actor_id' AS secondary_key, COUNT(*) AS missing_key_count FROM film_actor fa
    LEFT JOIN actor ac ON fa.actor_id = ac.actor_id
    WHERE ac.actor_id IS NULL

    UNION ALL

    SELECT 'film_actor' AS table_name, 'film_id' AS secondary_key, COUNT(*) AS missing_key_count FROM film_actor fa
    LEFT JOIN film fi ON fa.film_id = fi.film_id
    WHERE fi.film_id IS NULL

    UNION ALL

    -- TABLE: film_category

    SELECT 'film_category' AS table_name, 'film_id' AS secondary_key, COUNT(*) AS missing_key_count FROM film_category fc
    LEFT JOIN film fi ON fc.film_id = fi.film_id
    WHERE fi.film_id IS NULL

    UNION ALL

    SELECT 'film_category' AS table_name, 'category_id' AS secondary_key, COUNT(*) AS missing_key_count FROM film_category fc
    LEFT JOIN category ca ON fc.category_id = ca.category_id
    WHERE ca.category_id IS NULL

    UNION ALL

    -- TABLE: inventory

    SELECT 'inventory' AS table_name, 'film_id' AS secondary_key, COUNT(*) AS missing_key_count FROM inventory iv
    LEFT JOIN film fi ON iv.film_id = fi.film_id
    WHERE fi.film_id IS NULL

    UNION ALL

    SELECT 'inventory' AS table_name, 'store_id' AS secondary_key, COUNT(*) AS missing_key_count FROM inventory iv
    LEFT JOIN store st ON iv.store_id = st.store_id
    WHERE st.store_id IS NULL

    UNION ALL

    -- TABLE: payment

    SELECT 'payment' AS table_name, 'customer_id' AS secondary_key, COUNT(*) AS missing_key_count FROM payment pm
    LEFT JOIN customer cu ON pm.customer_id = cu.customer_id
    WHERE cu.customer_id IS NULL

    UNION ALL

    SELECT 'payment' AS table_name, 'staff_id' AS secondary_key, COUNT(*) AS missing_key_count FROM payment pm
    LEFT JOIN staff sf ON pm.staff_id = sf.staff_id
    WHERE sf.staff_id IS NULL

    UNION ALL

    SELECT 'payment' AS table_name, 'rental_id' AS secondary_key, COUNT(*) AS missing_key_count FROM payment pm
    LEFT JOIN rental re ON pm.rental_id = re.rental_id
    WHERE re.rental_id IS NULL

    UNION ALL

    -- TABLE: rental

    SELECT 'rental' AS table_name, 'inventory_id' AS secondary_key, COUNT(*) AS missing_key_count FROM rental re
    LEFT JOIN inventory iv ON re.inventory_id = iv.inventory_id
    WHERE iv.inventory_id IS NULL

    UNION ALL

    SELECT 'rental' AS table_name, 'customer_id' AS secondary_key, COUNT(*) AS missing_key_count FROM rental re
    LEFT JOIN customer cu ON re.customer_id = cu.customer_id
    WHERE cu.customer_id IS NULL

    UNION ALL

    SELECT 'rental' AS table_name, 'staff_id' AS secondary_key, COUNT(*) AS missing_key_count FROM rental re
    LEFT JOIN staff sf ON re.staff_id = sf.staff_id
    WHERE sf.staff_id IS NULL

    UNION ALL

    -- TABLE: staff

    SELECT 'staff' AS table_name, 'address_id' AS secondary_key, COUNT(*) AS missing_key_count FROM staff sf
    LEFT JOIN address ad ON sf.address_id = ad.address_id
    WHERE ad.address_id IS NULL

    UNION ALL

    SELECT 'staff' AS table_name, 'store_id' AS secondary_key, COUNT(*) AS missing_key_count FROM staff sf
    LEFT JOIN store st ON sf.store_id = st.store_id
    WHERE st.store_id IS NULL

    UNION ALL

    -- TABLE: store

    SELECT 'store' AS table_name, 'manager_staff_id' AS secondary_key, COUNT(*) AS missing_key_count FROM store st
    LEFT JOIN staff sf ON st.manager_staff_id = sf.staff_id
    WHERE sf.staff_id IS NULL

    UNION ALL

    SELECT 'store' AS table_name, 'address_id' AS secondary_key, COUNT(*) AS missing_key_count FROM store st
    LEFT JOIN address ad ON st.address_id = ad.address_id
    WHERE ad.address_id IS NULL

    ORDER BY table_name;

-- OBSERVATIONS:
-- All foreign keys link to valid primary keys in parent tables.

-- ===============================================================================
-- 7. Missing Data Checks (Key Variables)
-- ===============================================================================

-- 7.1 - Check forr nulls in all variables across all tables.

    WITH null_check AS (

        -- TABLE: actor

        SELECT 'actor' AS table_name, 'actor_id' AS column_name, COUNT(*) AS null_count FROM actor WHERE actor_id IS NULL
        UNION ALL
        SELECT 'actor' AS table_name, 'first_name' AS column_name, COUNT(*) AS null_count FROM actor WHERE first_name IS NULL
        UNION ALL
        SELECT 'actor' AS table_name, 'last_name' AS column_name, COUNT(*) AS null_count FROM actor WHERE last_name IS NULL
        UNION ALL
        SELECT 'actor' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM actor WHERE last_update IS NULL

        -- TABLE: address

        UNION ALL
        SELECT 'address' AS table_name, 'address_id' AS column_name, COUNT(*) AS null_count FROM address WHERE address_id IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'address' AS column_name, COUNT(*) AS null_count FROM address WHERE address IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'address2' AS column_name, COUNT(*) AS null_count FROM address WHERE address2 IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'district' AS column_name, COUNT(*) AS null_count FROM address WHERE district IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'city_id' AS column_name, COUNT(*) AS null_count FROM address WHERE city_id IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'postal_code' AS column_name, COUNT(*) AS null_count FROM address WHERE postal_code IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'phone' AS column_name, COUNT(*) AS null_count FROM address WHERE phone IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM address WHERE last_update IS NULL

        -- TABLE: category

        UNION ALL
        SELECT 'category' AS table_name, 'category_id' AS column_name, COUNT(*) AS null_count FROM category WHERE category_id IS NULL
        UNION ALL
        SELECT 'category' AS table_name, 'name' AS column_name, COUNT(*) AS null_count FROM category WHERE name IS NULL
        UNION ALL
        SELECT 'category' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM category WHERE last_update IS NULL

        -- TABLE: city

        UNION ALL
        SELECT 'city' AS table_name, 'city_id' AS column_name, COUNT(*) AS null_count FROM city WHERE city_id IS NULL
        UNION ALL
        SELECT 'city' AS table_name, 'city' AS column_name, COUNT(*) AS null_count FROM city WHERE city IS NULL
        UNION ALL
        SELECT 'city' AS table_name, 'country_id' AS column_name, COUNT(*) AS null_count FROM city WHERE country_id IS NULL
        UNION ALL
        SELECT 'city' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM city WHERE last_update IS NULL

        -- TABLE: country

        UNION ALL
        SELECT 'country' AS table_name, 'country_id' AS column_name, COUNT(*) AS null_count FROM country WHERE country_id IS NULL
        UNION ALL
        SELECT 'country' AS table_name, 'country' AS column_name, COUNT(*) AS null_count FROM country WHERE country IS NULL
        UNION ALL
        SELECT 'country' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM country WHERE last_update IS NULL

        -- TABLE: customer

        UNION ALL
        SELECT 'customer' AS table_name, 'customer_id' AS column_name, COUNT(*) AS null_count FROM customer WHERE customer_id IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'store_id' AS column_name, COUNT(*) AS null_count FROM customer WHERE store_id IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'first_name' AS column_name, COUNT(*) AS null_count FROM customer WHERE first_name IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'last_name' AS column_name, COUNT(*) AS null_count FROM customer WHERE last_name IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'email' AS column_name, COUNT(*) AS null_count FROM customer WHERE email IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'address_id' AS column_name, COUNT(*) AS null_count FROM customer WHERE address_id IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'activebool' AS column_name, COUNT(*) AS null_count FROM customer WHERE activebool IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'create_date' AS column_name, COUNT(*) AS null_count FROM customer WHERE create_date IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM customer WHERE last_update IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'active' AS column_name, COUNT(*) AS null_count FROM customer WHERE active IS NULL

        -- TABLE: film

        UNION ALL
        SELECT 'film' AS table_name, 'film_id' AS column_name, COUNT(*) AS null_count FROM film WHERE film_id IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'title' AS column_name, COUNT(*) AS null_count FROM film WHERE title IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'description' AS column_name, COUNT(*) AS null_count FROM film WHERE description IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'release_year' AS column_name, COUNT(*) AS null_count FROM film WHERE release_year IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'language_id' AS column_name, COUNT(*) AS null_count FROM film WHERE language_id IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'rental_duration' AS column_name, COUNT(*) AS null_count FROM film WHERE rental_duration IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'rental_rate' AS column_name, COUNT(*) AS null_count FROM film WHERE rental_rate IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'length' AS column_name, COUNT(*) AS null_count FROM film WHERE length IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'replacement_cost' AS column_name, COUNT(*) AS null_count FROM film WHERE replacement_cost IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'rating' AS column_name, COUNT(*) AS null_count FROM film WHERE rating IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM film WHERE last_update IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'special_features' AS column_name, COUNT(*) AS null_count FROM film WHERE special_features IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'fulltext' AS column_name, COUNT(*) AS null_count FROM film WHERE fulltext IS NULL

        -- TABLE: film_actor

        UNION ALL
        SELECT 'film_actor' AS table_name, 'actor_id' AS column_name, COUNT(*) AS null_count FROM film_actor WHERE actor_id IS NULL
        UNION ALL
        SELECT 'film_actor' AS table_name, 'film_id' AS column_name, COUNT(*) AS null_count FROM film_actor WHERE film_id IS NULL
        UNION ALL
        SELECT 'film_actor' AS table_name, 'last_update' AS column_name, COUNT(*) AS missing_count FROM film_actor WHERE last_update IS NULL

        -- TABLE: film_category

        UNION ALL
        SELECT 'film_category' AS table_name, 'film_id' AS column_name, COUNT(*) AS null_count FROM film_category WHERE film_id IS NULL
        UNION ALL
        SELECT 'film_category' AS table_name, 'category_id' AS column_name, COUNT(*) AS null_count FROM film_category WHERE category_id IS NULL
        UNION ALL
        SELECT 'film_category' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM film_category WHERE last_update IS NULL

        -- TABLE: inventory

        UNION ALL
        SELECT 'inventory' AS table_name, 'inventory_id' AS column_name, COUNT(*) AS null_count FROM inventory WHERE inventory_id IS NULL
        UNION ALL
        SELECT 'inventory' AS table_name, 'film_id' AS column_name, COUNT(*) AS null_count FROM inventory WHERE film_id IS NULL
        UNION ALL
        SELECT 'inventory' AS table_name, 'store_id' AS column_name, COUNT(*) AS null_count FROM inventory WHERE store_id IS NULL
        UNION ALL
        SELECT 'inventory' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM inventory WHERE last_update IS NULL

        -- TABLE: language

        UNION ALL
        SELECT 'language' AS table_name, 'language_id' AS column_name, COUNT(*) AS null_count FROM language WHERE language_id IS NULL
        UNION ALL
        SELECT 'language' AS table_name, 'name' AS column_name, COUNT(*) AS null_count FROM language WHERE name IS NULL
        UNION ALL
        SELECT 'language' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM language WHERE last_update IS NULL

        -- TABLE: payment

        UNION ALL
        SELECT 'payment' AS table_name, 'payment_id' AS column_name, COUNT(*) AS null_count FROM payment WHERE payment_id IS NULL
        UNION ALL
        SELECT 'payment' AS table_name, 'customer_id' AS column_name, COUNT(*) AS null_count FROM payment WHERE customer_id IS NULL
        UNION ALL
        SELECT 'payment' AS table_name, 'staff_id' AS column_name, COUNT(*) AS null_count FROM payment WHERE staff_id IS NULL
        UNION ALL
        SELECT 'payment' AS table_name, 'rental_id' AS column_name, COUNT(*) AS null_count FROM payment WHERE rental_id IS NULL
        UNION ALL
        SELECT 'payment' AS table_name, 'amount' AS column_name, COUNT(*) AS null_count FROM payment WHERE amount IS NULL
        UNION ALL
        SELECT 'payment' AS table_name, 'payment_date' AS column_name, COUNT(*) AS null_count FROM payment WHERE payment_date IS NULL

        -- TABLE: rental

        UNION ALL
        SELECT 'rental' AS table_name, 'rental_id' AS column_name, COUNT(*) AS null_count FROM rental WHERE rental_id IS NULL
        UNION ALL
        SELECT 'rental' AS table_name, 'rental_date' AS column_name, COUNT(*) AS null_count FROM rental WHERE rental_date IS NULL
        UNION ALL
        SELECT 'rental' AS table_name, 'inventory_id' AS column_name, COUNT(*) AS null_count FROM rental WHERE inventory_id IS NULL
        UNION ALL
        SELECT 'rental' AS table_name, 'customer_id' AS column_name, COUNT(*) AS null_count FROM rental WHERE customer_id IS NULL
        UNION ALL
        SELECT 'rental' AS table_name, 'return_date' AS column_name, COUNT(*) AS null_count FROM rental WHERE return_date IS NULL
        UNION ALL
        SELECT 'rental' AS table_name, 'staff_id' AS column_name, COUNT(*) AS null_count FROM rental WHERE staff_id IS NULL
        UNION ALL
        SELECT 'rental' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM rental WHERE last_update IS NULL

        -- TABLE: staff

        UNION ALL
        SELECT 'staff' AS table_name, 'staff_id' AS column_name, COUNT(*) AS null_count FROM staff WHERE staff_id IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'first_name' AS column_name, COUNT(*) AS null_count FROM staff WHERE first_name IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'last_name' AS column_name, COUNT(*) AS null_count FROM staff WHERE last_name IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'address_id' AS column_name, COUNT(*) AS null_count FROM staff WHERE address_id IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'email' AS column_name, COUNT(*) AS null_count FROM staff WHERE email IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'store_id' AS column_name, COUNT(*) AS null_count FROM staff WHERE store_id IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'active' AS column_name, COUNT(*) AS null_count FROM staff WHERE active IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'username' AS column_name, COUNT(*) AS null_count FROM staff WHERE username IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'password' AS column_name, COUNT(*) AS null_count FROM staff WHERE password IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM staff WHERE last_update IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'picture' AS column_name, COUNT(*) AS null_count FROM staff WHERE picture IS NULL

        -- TABLE: store

        UNION ALL
        SELECT 'store' AS table_name, 'store_id' AS column_name, COUNT(*) AS null_count FROM store WHERE store_id IS NULL
        UNION ALL
        SELECT 'store' AS table_name, 'manager_staff_id' AS column_name, COUNT(*) AS null_count FROM store WHERE manager_staff_id IS NULL
        UNION ALL
        SELECT 'store' AS table_name, 'address_id' AS column_name, COUNT(*) AS null_count FROM store WHERE address_id IS NULL
        UNION ALL
        SELECT 'store' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM store WHERE last_update IS NULL
        )
        SELECT *
        FROM null_check
        WHERE null_count > 0
        ORDER BY table_name, column_name;

-- OBSERVATIONS:
-- address.address2 - 4 nulls.
-- rental.return_date - 183 nulls - > key variable!
-- staff.picture - 1 nulls.

-- 7.3 - Check for missing values across variables with character-based data types.

    WITH missing_check AS (

        -- TABLE: actor

        SELECT 'actor' AS table_name, 'first_name' AS column_name, COUNT(*) AS missing_count 
        FROM actor WHERE LOWER(COALESCE(first_name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'actor', 'last_name', COUNT(*) AS missing_count  
        FROM actor WHERE LOWER(COALESCE(last_name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        
        -- TABLE: address

        UNION ALL
        SELECT 'address', 'address', COUNT(*) AS missing_count  
        FROM address WHERE LOWER(COALESCE(address, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'address', 'address2', COUNT(*) AS missing_count  
        FROM address WHERE LOWER(COALESCE(address2, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'address', 'district', COUNT(*) AS missing_count  
        FROM address WHERE LOWER(COALESCE(district, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'address', 'postal_code', COUNT(*) AS missing_count  
        FROM address WHERE LOWER(COALESCE(postal_code, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'address', 'phone', COUNT(*) AS missing_count  
        FROM address WHERE LOWER(COALESCE(phone, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        
        -- TABLE: category

        UNION ALL
        SELECT 'category', 'name', COUNT(*) AS missing_count  
        FROM category WHERE LOWER(COALESCE(name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')

        -- TABLE: city

        UNION ALL
        SELECT 'city', 'city', COUNT(*) AS missing_count  
        FROM city WHERE LOWER(COALESCE(city, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL

        -- TABLE: country

        SELECT 'country', 'country', COUNT(*) AS missing_count  
        FROM country WHERE LOWER(COALESCE(country, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL

        -- TABLE: customer

        SELECT 'customer', 'first_name', COUNT(*) AS missing_count  
        FROM customer WHERE LOWER(COALESCE(first_name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'customer', 'last_name', COUNT(*) AS missing_count  
        FROM customer WHERE LOWER(COALESCE(last_name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'customer', 'email', COUNT(*) AS missing_count  
        FROM customer WHERE LOWER(COALESCE(email, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')

        -- TABLE: film

        UNION ALL
        SELECT 'film', 'title', COUNT(*) AS missing_count  
        FROM film WHERE LOWER(COALESCE(title, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'film', 'description', COUNT(*) AS missing_count  
        FROM film WHERE LOWER(COALESCE(description, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'film', 'rating', COUNT(*) AS missing_count  
        FROM film WHERE LOWER(COALESCE(CAST(rating AS VARCHAR), '')) IN ('', 'n/a', 'unknown', 'none', 'blank') -- note data type USER-DEFINED

        -- TABLE: language
        
        UNION ALL
        SELECT 'language', 'name', COUNT(*) AS missing_count  
        FROM language WHERE LOWER(COALESCE(name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        
        -- TABLE: staff
        
        UNION ALL
        SELECT 'staff', 'first_name', COUNT(*) AS missing_count  
        FROM staff WHERE LOWER(COALESCE(first_name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'staff', 'last_name', COUNT(*) AS missing_count  
        FROM staff WHERE LOWER(COALESCE(last_name, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'staff', 'email', COUNT(*) AS missing_count  
        FROM staff WHERE LOWER(COALESCE(email, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'staff', 'username', COUNT(*) AS missing_count  
        FROM staff WHERE LOWER(COALESCE(username, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
        UNION ALL
        SELECT 'staff', 'password', COUNT(*) AS missing_count  
        FROM staff WHERE LOWER(COALESCE(password, '')) IN ('', 'n/a', 'unknown', 'none', 'blank')
    )

    SELECT *
    FROM missing_check
    WHERE missing_count > 0
    ORDER BY table_name, column_name;

-- OBSERVATIONS:
-- address.address2 - 603 missing values.
-- address.district - 3 missing values.
-- address.phone - 2 missing values.
-- address.postal_code - 4 missing values.
    
-- ===============================================================================
-- 8. Duplicates Checks
-- ===============================================================================

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

-- OBSERVATIONS:
-- actor table - 1 duplicate records!
-- inventory table - 1521 duplicate records!

-- 8.2.1 - View duplicate records: actor table.

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

-- OBSERVATIONS:
-- 1 record flagged for cleaning!

-- 8.2.1 - View duplciate records: inventory table.

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

-- OBSERVATIONS:
-- More than one title per store - > expected.

-- 8.3 - Create a clean view of actor table.

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

-- OBSERVATIONS:
-- Table successfully created.

-- 8.4.1 - Validation Check: Row counts actor vs clean_actor

    SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor;
    SELECT 'clean_actor' AS table_name, COUNT(*) AS row_count FROM clean_actor;

-- OBSERVATIONS:
-- One duplicate record successfully removed.

-- 8.4.2 - Confirm no duplicates in clean-actor view.

    SELECT 'clean_actor' AS table_name, COUNT(*) AS duplicate_count
    FROM (
        SELECT first_name, last_name
        FROM clean_actor
        GROUP BY first_name, last_name
        HAVING COUNT(*) > 1
    ) AS dup;

-- OBSERVATIONS:
-- Duplciate successfully removed from clean_actor VIEW.

-- ===============================================================================
-- 9. Distinct Value Counts
-- ===============================================================================

-- 9.1 - Check the number of distinct values per variable across all tables.

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

-- OBSERVATIONS:
-- actor table
    -- 200 actors with shared or missing names.
    -- All records updated on the same date.

-- address table
    -- 603 address with 4 missing cities - > store & staff?.
    -- All records updated on the same date.

-- category table
    -- 16 categories.
    -- All records updated on the same date.

-- city table
    -- 600 ids & 599 cities - > 1 missing?.
    -- All records updated on the same date.

-- country table
    -- 109 countries.
    -- All records updated on the same date.

-- customer table
    -- 599 customers across 2 stores with 1 value in activebool - > all active?
    -- Two values in active with type integer - unreliable?
    -- All records created and updated on the same date

-- film table
    -- 1000 titles with 5 ratings released in the same year in one language.
    -- 5 standardised renting periods?
    -- 3 standardised rates.
    -- 21 cost prices. 
    -- All records updated on the same date.

-- film_actor table
    -- Combination of all 200 actors across only 997 film titles - > missing information for 3 titles?.
    -- All records updated on the same date.

-- film_category table
    -- Combination of all 1000 film titles across all 16 categories.
    -- All records updated on the same date.

-- inventory table
    -- 4581 copies of only 958 titles across two stores - > film table contains old titles?.
    -- All records updated on the same date.

-- language table
    -- 6 languages
    -- All records updated on the same date.

-- payment table
    -- 14596 payments made across 14592 rental ids - > 4 split payments?.
    -- 14365 payment dates/times - > high number due to timestamp.
    -- 19 different amounts - > standardised rates & number of videos allowed.
    -- All transactions processed by one of 2 staff members.
    -- All customers (599) made payments in the period.

-- rental table
    -- 16044 rental ids - > less payments due to outstanding returns?
    -- 15815 rental dates/times - > high number due to timestamp.
    -- 15836 return dates/times - > high number due to timestamp.
    -- All transactions processed by one of 2 staff members.
    -- 4580 out of 458§ copies in inventory were rented out.
    -- All customers (599) rented videos in the period.
    -- All records updated across 3 dates.

-- staff table
    -- 2 staff members with distinct names, addresses and emails working at both stores. 
    -- 2 usernames but one password!
    -- Only one in active variable - > both active?
    -- Only one staff member uploaded a picture.
    -- All records updated on the same date.

-- store table
    -- 2 stores with 2 managers at 2 locations.     
    -- All records updated on the same date.

-- ===============================================================================
-- 10. Frequency Distributions
-- ===============================================================================

-- 10.1 - Check the frequency distribution of key categorical variables.

    -- TABLE:  actor

    SELECT
        first_name as actor_first_name,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM actor), 2) AS percentage
    FROM actor
    GROUP BY actor_first_name
    ORDER BY frequency DESC;

    SELECT
        last_name as actor_last_name,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM actor), 2) AS percentage
    FROM actor
    GROUP BY actor_last_name
    ORDER BY frequency DESC;

    -- TABLE: address

    SELECT
        address AS address_address,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
    FROM address
    GROUP BY address_address
    ORDER BY frequency DESC;

    SELECT
        address2 AS address_address2,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
    FROM address
    GROUP BY address_address2
    ORDER BY frequency DESC;

    SELECT
        district AS address_district,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
    FROM address
    GROUP BY address_district
    ORDER BY frequency DESC;

    SELECT
        postal_code AS address_postal_code,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
    FROM address
    GROUP BY address_postal_code
    ORDER BY frequency DESC;

    SELECT
        phone AS address_phone,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM address), 2) AS percentage
    FROM address
    GROUP BY address_phone
    ORDER BY frequency DESC;

    -- TABLE: category

    SELECT
        name AS category_name,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM category), 2) AS percentage
    FROM category
    GROUP BY category_name
    ORDER BY frequency DESC;

    -- TABLE: city

    SELECT
        city AS city_city,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM city), 2) AS percentage
    FROM city
    GROUP BY city_city
    ORDER BY frequency DESC;

    -- TABLE: country

    SELECT
        country AS country_country,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM country), 2) AS percentage
    FROM country
    GROUP BY country_country
    ORDER BY frequency DESC;

    -- TABLE: customer

    SELECT
        first_name AS customer_first_name,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
    FROM customer
    GROUP BY customer_first_name
    ORDER BY frequency DESC;

    SELECT
        last_name AS customer_last_name,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
    FROM customer
    GROUP BY customer_last_name
    ORDER BY frequency DESC;

    SELECT
        email AS customer_email,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
    FROM customer
    GROUP BY customer_email
    ORDER BY frequency DESC;

    -- TABLE: film

    SELECT
        title AS film_title,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
    FROM film
    GROUP BY film_title
    ORDER BY frequency DESC;

    SELECT
        description AS film_description,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
    FROM film
    GROUP BY film_description
    ORDER BY frequency DESC;

    SELECT
        rating AS film_rating,
        COUNT(*) AS frequency,
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
    FROM film
    GROUP BY film_rating
    ORDER BY frequency DESC;

    -- TABLE: language

    SELECT 
        name AS language_name,  
        COUNT(*) AS frequency, 
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM language), 2) AS percentage
    FROM language
    GROUP BY language_name
    ORDER BY frequency DESC;

    -- TABLE: staff

    SELECT 
        first_name AS staff_first_name, 
        COUNT(*) AS frequency, 
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
    FROM staff
    GROUP BY staff_first_name
    ORDER BY frequency DESC;

    SELECT 
        last_name AS staff_last_name, 
        COUNT(*) AS frequency, 
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
    FROM staff
    GROUP BY staff_last_name
    ORDER BY frequency DESC;

    SELECT 
        email AS staff_email,
        COUNT(*) AS frequency, 
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
    FROM staff
    GROUP BY staff_email
    ORDER BY frequency DESC;

    SELECT 
        password AS staff_password, 
        COUNT(*) AS frequency, 
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
    FROM staff
    GROUP BY staff_password
    ORDER BY frequency DESC;
    
    SELECT 
        username AS staff_username, 
        COUNT(*) AS frequency, 
        ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
    FROM staff
    GROUP BY staff_username
    ORDER BY frequency DESC;

-- OBSERVATIONS:
-- address.address2 - whole variable is empty.
-- address.district - 3 missing values.
-- address.phone - 2 missing values.
-- address.postal_code - 4 missing values.
-- customer.activebool - all customers are active.
-- customer.active - 1 x 584 & 0 x 15 unexpected type and inconsistent - > consider unreliable. 
-- staff.active - both staff members are active.


-- ===============================================================================
-- 11. Descriptive Statistics (Numeric Variables)
-- ===============================================================================

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

-- OBSERVATIONS:
-- film.rental_duration
    -- No nulls or zero values.
    -- Range - > 4 (3 to 7).
    -- Mean and median - > 4,99/5. 
    -- Standard deviation - > 1,41.

-- film.rental_rate
    -- No nulls or zero values.
    -- Range - > 4,00 (0,99 to 4,99).
    -- Mean and median - > 2,98/2,99.
    -- Standard deviation - > 1,65.

-- film.length
    -- No nulls or zero values.
    -- Range - > 139 (46 to 185).
    -- Mean and median - > 115,27/114.
    -- Standard deviation - > 40,41.

-- film.replacement_cost
    -- No nulls or zero values.
    -- Range - > 20,00 (9,99 to 29,99).
    -- Mean and median - > 19,98/19,99.
    -- Standard deviation - > 6,05.

-- payment.amount
    -- No nulls but 24 zero values! 
    -- Range - > 11,99 (0 to 11,99).
    -- Mean and median - > 4,2/3,99.
    -- Standard deviation - > 2,37.
    
-- ===============================================================================
-- 12. Temporal Checks
-- ===============================================================================

-- 12.1 - Validate 'last_update' and 'create_date' fields across all tables

    SELECT 'actor' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM actor
    UNION ALL
    SELECT 'address' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM address
    UNION ALL
    SELECT 'category' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM category
    UNION ALL
    SELECT 'city' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM city
    UNION ALL
    SELECT 'country' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM country
    UNION ALL
    SELECT 'customer' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM customer
    UNION ALL
    SELECT 'customer' AS table_name, 'create_date' AS column_name, COUNT(DISTINCT create_date) AS distinct_dates, MIN(create_date) AS min_date, MAX(create_date) AS max_date FROM customer
    UNION ALL
    SELECT 'film' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM film
    UNION ALL
    SELECT 'film_actor' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM film_actor
    UNION ALL
    SELECT 'film_category' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM film_category
    UNION ALL
    SELECT 'inventory' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM inventory
    UNION ALL
    SELECT 'language' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM language
    UNION ALL
    SELECT 'rental' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM rental
    UNION ALL
    SELECT 'staff' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM staff
    UNION ALL
    SELECT 'store' AS table_name, 'last_update' AS column_name, COUNT(DISTINCT last_update) AS distinct_dates, MIN(last_update) AS min_date, MAX(last_update) AS max_date FROM store
    ORDER BY table_name;

-- OBSERVATIONS:
-- All returned 1 single date except for rental.last_update. 
-- Database created on one date with minor updates?

-- 12.2 - Temporal analysis of key event date or timestamp fields

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

-- OBSERVATIONS:
-- 15815 retnal dates
-- 15836 return dates
-- 14365 payment_dates

-- 12.3 - Temporal analysis of numeric date fields

    SELECT
        'film' AS table_name, 
        'release_year' AS column_name, 
        COUNT(DISTINCT release_year) AS distinct_dates, 
        MIN(release_year) AS min_date,
        MAX(release_year) AS max_date 
    FROM film;

-- OBSERVATIONS:
-- 1 release year = 2006

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

-- OBSERVATIONS:
-- Dips in frequency across does not follow expected temporal patterns.
-- rental_date generally increase in frequency over time, but drops every 8 days.
-- return_date follows a similar pattern but dips every 17 days.
-- payment-date also show intermittant dips in frequency but at less regular intervals ranging between 5 and 10 days.