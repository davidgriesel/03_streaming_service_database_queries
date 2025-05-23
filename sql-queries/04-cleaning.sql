-- ================================================================================
-- 4. CLEANING
-- ================================================================================

-- TABLE OF CONTENTS

-- 4.1 - HANDLING DUPLICATE RECORDS
    -- 4.1.1 - VIEW DUPLICATES
    -- 4.1.2 - TRACE DUPLICATE ACTORS TO FILM_ACTOR
-- 4.2 - HANDLING NULLS
    -- 4.2.1 - VIEW NULLS
-- 4.3 - HANDLING MISSING AND PLACEHOLDER VALUES
    -- 4.3.1 - VIEW MISSING AND PLACEHOLDER VALUES
-- 4.4 - CREATING CLEAN VIEWS


-- ================================================================================
-- 4.1 - HANDLING DUPLICATE RECORDS
-- ================================================================================

-- --------------------------------------------------------------------------------
-- 4.1.1 - VIEW DUPLICATES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- View previously identified duplicate records to assess their context and determine 
-- appropriate follow-up actions. 
--
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
    LIMIT 20;

-- INSIGHTS
-- The actor table contains duplicate records with identical first and last names.
-- Duplicate records in the inventory table are valid, as multiple copies of the
-- same film exist across different stores for physical rental.

-- RECOMMENDATIONS
-- Identify which actor_id values are referenced in the film_actor table to
-- determine which duplicates can be removed or consolidated.
-- Flag the inventory table as containing valid duplicates, which are expected and
-- will be distinguished solely by their unique inventory_id values.

-- --------------------------------------------------------------------------------
-- 4.1.2 - TRACE DUPLICATE ACTORS TO FILM_ACTOR
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Determine which of the duplicate actor records (Susan Davis: actor_id 101 and 110)
-- are referenced in the film_actor table, in order to take appropriate actions.
--
    SELECT
        fa.actor_id,
        COUNT(*) AS film_count
    FROM film_actor fa
    WHERE fa.actor_id IN (101, 110)
    GROUP BY fa.actor_id
    ORDER BY fa.actor_id;

-- INSIGHTS
-- Both actor_id's are referenced multiple times in the film_actor table. Due to the
-- ansense of additional distinquishable attributes, it is not possible to determine
-- whether these represent the same individual. 

-- RECOMMENDATIONS
-- Retain both records to preserve referential integrity, document the presence
-- of name-based duplicates if actor counts are used in future analysis, and adjust
-- for possible overcounts where appropriate.


-- ================================================================================
-- 4.2 - HANDLING NULLS
-- ================================================================================

-- --------------------------------------------------------------------------------
-- 4.2.1 - VIEW NULLS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- View identified NULL values in selected columns to determine whether they reflect
-- obsolete, missing, or valid data, and decide on how to handle them.
--
    SELECT *
    FROM address
    WHERE address2 IS NULL;

    SELECT *
    FROM staff
    WHERE picture IS NULL;

    SELECT *
    FROM rental
    WHERE return_date IS NULL;

-- INSIGHTS
-- The address2 and picture columns contain information that is not required for the
-- analysis.
-- The return_date column contains 183 NULL values, which appear valid and indicate
-- rentals that have not yet been returned.

-- RECOMMENDATION
-- Drop the address2 column from the cleaned view, as it holds optional secondary 
-- address details and is not required for the analysis.
-- Retain the return_date column with the NULLs intact to preserve the integrity of
-- open rental records.


-- ================================================================================
-- 4.3 - HANDLING MISSING AND PLACEHOLDER VALUES
-- ================================================================================

-- --------------------------------------------------------------------------------
-- 4.3.1 - VIEW MISSING AND PLACEHOLDER VALUES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- View records where columns contain empty strings to determine how to handle them.
-- 
    SELECT * 
    FROM address 
    WHERE TRIM(COALESCE(address2, '')) = ''
    AND address2 IS NOT NULL -- nulls already addressed
    LIMIT 10;

    SELECT * 
    FROM address 
    WHERE TRIM(COALESCE(district, '')) = ''
    AND district IS NOT NULL; -- nulls already addressed

    SELECT * 
    FROM address 
    WHERE TRIM(COALESCE(postal_code, '')) = ''
    AND postal_code IS NOT NULL; -- nulls already addressed

    SELECT * 
    FROM address 
    WHERE TRIM(COALESCE(phone, '')) = ''
    AND phone IS NOT NULL; -- nulls already addressed

-- INSIGHTS
-- These entries represent incomplete data which could interfere with filtering, 
-- grouping, or downstream logic.

-- RECOMMENDATIONS
-- Drop the address2 column from the cleaned view, as it is mainly empty, and is
-- not required for the analysis.
-- Impute empty string values in the postal_code, district, and phone columns with
-- a consistent placeholder (e.g. 'n/a') to ensure clarity and enable reliable
-- grouping and comparison.

-- --------------------------------------------------------------------------------
-- 4.4 - CREATING CLEAN VIEWS
-- --------------------------------------------------------------------------------

-- PURPOSE
--
    CREATE OR REPLACE VIEW actor_clean AS
    SELECT
        actor_id,
        first_name,
        last_name
    FROM actor;

    SELECT *
    FROM actor_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW address_clean AS
    SELECT
        address_id,
        address,
        COALESCE(NULLIF(TRIM(district), ''), 'n/a') AS district,
        city_id,
        COALESCE(NULLIF(TRIM(postal_code), ''), 'n/a') AS postal_code,
        COALESCE(NULLIF(TRIM(phone), ''), 'n/a') AS phone
    FROM address;

    SELECT *
    FROM address_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW category_clean AS
    SELECT 
        category_id,
        name AS category
    FROM category;

    SELECT *
    FROM category_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW city_clean AS
    SELECT
        city_id,
        city,
        country_id
    FROM city;

    SELECT *
    FROM city_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW country_clean AS
    SELECT
        country_id,
        country
    FROM country;

    SELECT *
    FROM country_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW customer_clean AS
    SELECT
        customer_id,
        store_id,
        first_name,
        last_name,
        address_id,
        activebool
    FROM customer;

    SELECT *
    FROM customer_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW film_clean AS
    SELECT
        film_id,
        title,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        length,
        replacement_cost,
        rating::varchar
    FROM film;

    SELECT *
    FROM film_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW film_actor_clean AS
    SELECT
        actor_id,
        film_id
    FROM film_actor;

    SELECT *
    FROM film_actor_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW film_category_clean AS
    SELECT
        film_id,
        category_id
    FROM film_category;

    SELECT *
    FROM film_category_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW inventory_clean AS
    SELECT
        inventory_id,
        film_id,
        store_id
    FROM inventory;

    SELECT *
    FROM inventory_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW language_clean AS
    SELECT
        language_id,
        name::varchar AS language
    FROM language;

    SELECT *
    FROM language_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW payment_clean AS
    SELECT
        payment_id,
        customer_id,
        staff_id,
        rental_id,
        amount,
        payment_date::date
    FROM payment;

    SELECT *
    FROM payment_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW rental_clean AS
    SELECT
        rental_id,
        rental_date::date,
        inventory_id,
        customer_id,
        return_date::date,
        staff_id
    FROM rental;

    SELECT *
    FROM rental_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW staff_clean AS
    SELECT
        staff_id,
        first_name,
        last_name,
        address_id,
        store_id,
        active AS activebool
    FROM staff;

    SELECT *
    FROM staff_clean
    LIMIT 10;

    CREATE OR REPLACE VIEW store_clean AS
    SELECT
        store_id,
        manager_staff_id,
        address_id
    FROM store;

    SELECT *
    FROM store_clean
    LIMIT 10;

-- INSIGHTS
--

-- --------------------------------------------------------------------------------
-- #.# DROPPING COLUMNS 
-- --------------------------------------------------------------------------------

-- Remove any unnecessary columns containing NULLs, optional information, duplicate
-- functions, dense or specialised metadata, duplicate values (Refer 1.3).
-- Remove columns with unusual or complex data types not needed in the analysis
-- (Refer 2.1).
-- Drop fields containing NULLs with optional data or information not needed in the
-- analysis (Refer 3.1). 
-- Drop address2 containing optional information not needed for the analysis
-- (Refer 3.2).
-- Remove static timestamp columns or binary status columns that are not needed in
-- the analysis (Refer 3.4).
-- Drop fields that are constant or carry duplicates that has no analytical value
-- (Refer 3.5).

-- --------------------------------------------------------------------------------
-- #.# ALIASING COLUMNS (Refer 1.3)
-- --------------------------------------------------------------------------------

-- Standardise column names that are inconsistent or ambiguous (Refer 1.3).

-- --------------------------------------------------------------------------------
-- #.# CASTING DATA TYPES (Refer 2.1 | 2.2.8)
-- --------------------------------------------------------------------------------

-- Cast retained fields of type timestamp to date where time-level precision is
-- not required (Refer 2.1).
-- Cast fields of type character to varchar to standardise formats for analysis
-- (Refer 2.1).
-- Transform data type of film.rating to varchar for use in analysis (Refer 2.2.8).

-- FROM PROFILING
-- Nulls: address.address2, staff.picture
-- Empty strings: address.phone, address,postal_code
-- Shared functions: customer.active(integer), customer.activebool(boolean)
-- Dense columns: film.description(text), film.fulltext(tsvector)
-- Unusual data types: film.fulltext(tsvector), film.rating(mpaa_rating)
-- Duplicate values: staff.password
-- Static timestamp: last_update column appears static for each table
-- Inconsistent column names: customer.active vs customer,activebool
-- Ambiguous column names: category.name, language.name vs city.city
-- Join tables: film_actor, film_category
-- Stock table: inventory
-- Transactional tables: payment, rental

-- FROM INTEGRITY CHECKS
-- Cast timestamp columns to date
-- Cast character column to character varying
-- Remove customer.active if similar to customer.activebool
-- Remove film.special_features, film.full_text, staff.picture
