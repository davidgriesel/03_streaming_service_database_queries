-- ================================================================================
-- Rockbuster Stealth
-- Analyst: David Griesel
-- Date: July 2024
-- Purpose: Initial Data Profiling, Cleaning, and EDA
-- ================================================================================

-- ================================================================================
-- TABLE OF CONTENTS:
-- ================================================================================

-- 1. Overview of Tables (Structure)
-- 2. Row Counts per Table (Structure)
-- 3. Sample Rows (Structure)
-- 4. Data Type Validation (Integrity)
-- 5. Constraint Checks (Integrity)
-- 6. Missing Data Checks (Quality)
-- 7. Duplicates Checks (Quality)
-- 8. Distinct Value Counts (Exploration)
-- 9. Frequency Distributions (Exploration)
-- 10. Descriptive Statistics (Exploration)
-- 11. Temporal Checks (Exploration)
-- 12. Logic and Dependency Checks
-- 13. Addressing Business Questions

-- ================================================================================
-- 1. Overview of Tables
-- ================================================================================

-- 1.1 - List all tables in the public schema for profiling. 

    SELECT 
        table_schema, 
        table_type, 
        table_name
    FROM information_schema.tables
    WHERE table_schema = 'public' 
    ORDER BY
        table_name;

-- OBSERVATIONS: 
-- THere are 15 base tables in the public schema.

-- ================================================================================
-- 2. Row Counts per Table
-- ================================================================================

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
-- The rental and payment tables hold transactional data based on high transaction volumes.
-- Other tables hold supporting descriptive information based on low transaction volumes.
-- This is consistent with the structure depicted in the ERD.

-- ================================================================================
-- 3. Sample Rows
-- ================================================================================

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
-- null values e.g. address.address2, staff.picture.
-- Empty values e.g. address.address2, address.postal_code, address.phone.
-- Ambiguous column names e.g. category.name, language.name. Consider aliasing. 
-- Possible redundant columns e.g. customer.active, customer.activebool likely more reliable.
-- Other possibly redundant colums for analysis e.g. address.address2, film.special_features.

-- ================================================================================
-- 4. Data Type Validation
-- ================================================================================

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
        c.data_type;
        -- c.table_name, c.ordinal_position;

-- OBSERVATIONS:
-- staff.active         type boolean        - > alias to staff.activebool for naming consistency.

-- language.name        type character      - > trim or cast to type varchar.

-- customer.active      type integer vs,
-- customer.activebool  type boolean        - > compare for redundancy.

-- film.release_year    type integer        - > contains year only, flag for temporal analysis.

-- payment.payment_date type timestamp &,
-- rental.rental_date   type timestamp &,
-- rental.return_date   type timestamp      - > precision unnecessary for analysis, cast to date.

-- film.rating      type USER-DEFINED       - > Likely has ENUM constraints. Cast to varchar.

-- Consider standardisation of data types across similar fields in the remainder of the dataset.

-- ================================================================================
-- 5. Constraint Discovery
-- ================================================================================

-- 5.1 - Primary Key Discovery.

    SELECT 
        tc.table_name,
        string_agg(kcu.column_name, ', ') AS primary_key_columns,
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
    GROUP BY 
        tc.table_name, tc.constraint_name
    ORDER BY 
        tc.table_name;

-- OBSERVATIONS: 
-- Primary keys exist across all public tables enforcing unique values.
-- Composite keys exist across two columns in the film_actor, and film_category tables.

-- 5.2 - Foreign Key Discovery.

    SELECT
        fk.child_table AS table_name,
        fk.child_column AS foreign_key_column,
        fk.parent_table,
        fk.parent_column,
        fk.constraint_name
    FROM (
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
            ON tc.constraint_name = kcu.constraint_name
        INNER JOIN 
            information_schema.constraint_column_usage AS ccu
            ON tc.constraint_name = ccu.constraint_name
        WHERE 
            tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_schema = 'public'
    ) AS fk
    ORDER BY 
        fk.child_table, fk.child_column;

-- OBSERVATIONS:
-- Foreign keys exist linking transactional tables and their supporting dimension tables.
-- No constraints for identified for customer.store_id, inventory.store_id, and staff.store_id.

-- 5.2.1 - Check if all store_id's in customer, inventory, and staff tables exist in store.store_id

    SELECT 'customer' AS table_name, 'store_id' AS foreign_key, COUNT(*) AS orphaned_customers FROM customer
    LEFT JOIN store ON customer.store_id = store.store_id
    WHERE store.store_id IS NULL
    UNION ALL
    SELECT 'inventory' AS table_name, 'store_id' AS foreign_key, COUNT(*) AS orphaned_inventory
    FROM inventory
    LEFT JOIN store ON inventory.store_id = store.store_id
    WHERE store.store_id IS NULL
    UNION ALL
    SELECT 'staff' AS table_name, 'store_id' AS foreign_key, COUNT(*) AS orphaned_staff
    FROM staff
    LEFT JOIN store ON staff.store_id = store.store_id
    WHERE store.store_id IS NULL;

-- OBSERVATIONS:
-- All store_id's in customer, inventory, and staff tables exist in store.store_id.

-- 5.3 - Not Null Constraint Discovery.

    SELECT 
        table_name,
        column_name,
        is_nullable
    FROM 
        information_schema.columns
    WHERE 
        table_schema = 'public'
       -- AND is_nullable = 'YES' 
    ORDER BY 
        table_name, column_name;

-- OBSERVATIONS:
-- 14 variables allowing NULLs to be taken forward for NULL checks. Refer 6.1.

-- 5.4 - Unique Constraint Discovery.

    SELECT 
        tc.table_name, 
        kcu.column_name, 
        tc.constraint_name
    FROM 
        information_schema.table_constraints AS tc
    JOIN 
        information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
    WHERE 
        tc.constraint_type = 'UNIQUE'
        AND tc.table_schema = 'public'
    ORDER BY 
        tc.table_name, kcu.column_name;

-- OBSERVATIONS:
-- No UNIQUE constraints identified. 
-- Fields expected to contain unique values e.g. category.name, staff.password may contain duplicates.

-- 5.5 - Default Value Discovery.

    SELECT 
        table_name,
        column_name,
        column_default
    FROM 
        information_schema.columns
    WHERE 
        table_schema = 'public'
    AND column_default IS NOT NULL
    ORDER BY 
        column_default;
        
-- OBSERVATIONS:
-- Defaults set at possible minimum values for film.replacement_cost, film.rental_duration, film.rental_rate.
-- Deafult set at 'G' for film.rating. Refer 5.6.
-- All primary keys default to the next available number.
-- All last_update variables default to current date, time and time zone.
-- create_date default to current date.
-- Boolean values default to true.

-- 5.6 - Enumerated / Domain Constraint Discovery.

    SELECT 
        n.nspname AS schema_name,
        t.typname AS enum_type,
        e.enumlabel AS enum_value
    FROM 
        pg_type t 
    JOIN 
        pg_enum e 
        ON t.oid = e.enumtypid
    JOIN 
        pg_catalog.pg_namespace n 
        ON n.oid = t.typnamespace
    ORDER BY 
        enum_type, enum_value;
        
-- OBSERVATIONS:
-- Enumerated constraints exist.

-- 5.6.1 - Enumerated / Domain Constraint Mapping to Columns.

    SELECT 
        table_name,
        column_name,
        data_type,
        udt_name
    FROM 
        information_schema.columns
    WHERE 
        table_schema = 'public'
    AND data_type = 'USER-DEFINED'
    ORDER BY 
        table_name, column_name;

-- OBSERVATIONS:
-- Enumerated constraints applies to the film.rating column. 

-- 5.7 - Check Constraint (Business Rules) Discovery.

    SELECT 
        tc.table_name, 
        cc.check_clause
    FROM 
        information_schema.table_constraints AS tc
    JOIN 
        information_schema.check_constraints AS cc
        ON tc.constraint_name = cc.constraint_name
    WHERE 
        tc.constraint_type = 'CHECK'
        AND tc.table_schema = 'public'
    ORDER BY 
        tc.table_name;

-- OBSERVATIONS:
-- 72 fields enforce NOT NULL conditions through CHECK constraints in line with the NOT NULL constraints already identified.
-- No other business rules (e.g., value range restrictions) are enforced through CHECK constraints.

-- ================================================================================
-- 6. Missing Data Checks
-- ================================================================================

-- 6.1 - Check forr nulls across 14 variables without constraints.

    WITH null_check AS (

        -- TABLE: address

        SELECT 'address' AS table_name, 'address2' AS column_name, COUNT(*) AS null_count FROM address WHERE address2 IS NULL
        UNION ALL
        SELECT 'address' AS table_name, 'postal_code' AS column_name, COUNT(*) AS null_count FROM address WHERE postal_code IS NULL

        -- TABLE: customer

        UNION ALL
        SELECT 'customer' AS table_name, 'email' AS column_name, COUNT(*) AS null_count FROM customer WHERE email IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'last_update' AS column_name, COUNT(*) AS null_count FROM customer WHERE last_update IS NULL
        UNION ALL
        SELECT 'customer' AS table_name, 'active' AS column_name, COUNT(*) AS null_count FROM customer WHERE active IS NULL

        -- TABLE: film

        UNION ALL
        SELECT 'film' AS table_name, 'description' AS column_name, COUNT(*) AS null_count FROM film WHERE description IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'release_year' AS column_name, COUNT(*) AS null_count FROM film WHERE release_year IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'length' AS column_name, COUNT(*) AS null_count FROM film WHERE length IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'rating' AS column_name, COUNT(*) AS null_count FROM film WHERE rating IS NULL
        UNION ALL
        SELECT 'film' AS table_name, 'special_features' AS column_name, COUNT(*) AS null_count FROM film WHERE special_features IS NULL

        -- TABLE: rental

        UNION ALL
        SELECT 'rental' AS table_name, 'return_date' AS column_name, COUNT(*) AS null_count FROM rental WHERE return_date IS NULL

        -- TABLE: staff

        UNION ALL
        SELECT 'staff' AS table_name, 'email' AS column_name, COUNT(*) AS null_count FROM staff WHERE email IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'password' AS column_name, COUNT(*) AS null_count FROM staff WHERE password IS NULL
        UNION ALL
        SELECT 'staff' AS table_name, 'picture' AS column_name, COUNT(*) AS null_count FROM staff WHERE picture IS NULL

        )
        SELECT *
        FROM null_check
        WHERE null_count > 0
        ORDER BY table_name, column_name;

-- OBSERVATIONS:
-- address.address2 - 4 nulls.
-- rental.return_date - 183 nulls.
-- staff.picture - 1 nulls.

-- 6.3 - Check for missing values across variables with character-based data types.

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
    
-- ================================================================================
-- 7. Duplicates Checks
-- ================================================================================

-- 7.1 - Combined duplicate counts across key tables.

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

-- 7.2.1 - View duplicate records: actor table.

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

-- 7.2.1 - View duplciate records: inventory table.

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

-- ===============================================================================
-- 8. Distinct Value Counts
-- ===============================================================================

-- 8.1 - Check the number of distinct values per variable across all tables.

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

-- ================================================================================
-- 9. Frequency Distributions
-- ================================================================================

-- 9.1 - Check the frequency distribution of key categorical variables.

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

-- ================================================================================
-- 10. Descriptive Statistics (Numeric Variables)
-- ================================================================================

-- 10.1 - Summary statistics and distributions of numeric variables.

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
    
-- ================================================================================
-- 11. Temporal Checks
-- ================================================================================

-- 11.1 - Validate 'last_update' and 'create_date' fields across all tables

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

-- 11.2 - Temporal analysis of key event date or timestamp fields

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
-- 15815 rental dates
-- 15836 return dates
-- 14365 payment_dates

-- 11.3 - Temporal analysis of numeric date fields

    SELECT
        'film' AS table_name, 
        'release_year' AS column_name, 
        COUNT(DISTINCT release_year) AS distinct_dates,
        MIN(release_year) AS min_date,
        MAX(release_year) AS max_date 
    FROM film;

-- OBSERVATIONS:
-- 1 release year = 2006

-- 11.4 - Frequency distribution of key date or timestamp fields

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

-- ================================================================================
-- 12. Logic and Dependency Checks
-- ================================================================================

-- 1. Check that every payment links to an existing rental

-- Check for orphaned payments (payments without a matching rental)

SELECT COUNT(*) AS payments_without_rental
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
WHERE r.rental_id IS NULL;

-- 2. Check that return dates are after rental dates

-- Check rentals where return_date is before rental_date (bad logic)
SELECT COUNT(*) AS invalid_return_dates
FROM rental
WHERE return_date < rental_date;

-- 3. Check rentals without return dates

-- Check rentals with NULL return_date (could be unreturned rentals)
SELECT COUNT(*) AS rentals_without_return
FROM rental
WHERE return_date IS NULL;

-- 4. Check for payments before rental date

-- Payments made before rental date (business logic error)

SELECT COUNT(*) AS payments_before_rental
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
WHERE p.payment_date < r.rental_date;

-- 5. Optional advanced: future rentals

-- Rentals dated in the future compared to current timestamp
SELECT COUNT(*) AS rentals_in_future
FROM rental
WHERE rental_date > NOW();






-- Results columns with 'valid"/"invalid"
-- error summary tables




-- ================================================================================
-- 13. Cleaning 
-- ================================================================================


-- 7.3 - Create a clean view of actor table.

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

-- 7.4.1 - Validation Check: Row counts actor vs clean_actor

    SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor;
    SELECT 'clean_actor' AS table_name, COUNT(*) AS row_count FROM clean_actor;

-- OBSERVATIONS:
-- One duplicate record successfully removed.

-- 7.4.2 - Confirm no duplicates in clean-actor view.

    SELECT 'clean_actor' AS table_name, COUNT(*) AS duplicate_count
    FROM (
        SELECT first_name, last_name
        FROM clean_actor
        GROUP BY first_name, last_name
        HAVING COUNT(*) > 1
    ) AS dup;

-- OBSERVATIONS:
-- Duplciate successfully removed from clean_actor VIEW.