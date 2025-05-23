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
-- determine which duplicates can be removed or consolidated (Refer 4.1.2).
-- Flag the inventory table as containing valid duplicates, which are expected and
-- will be distinguished solely by their unique inventory_id values.

-- --------------------------------------------------------------------------------
-- 4.1.2 - TRACE DUPLICATE ACTORS TO FILM_ACTOR
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Determine which of the duplicate actor records (Susan Davis: actor_id 101 and 110)
-- are referenced in the film_actor table, in order to take appropriate actions.

SELECT
    fa.actor_id,
    COUNT(*) AS film_count
FROM film_actor fa
WHERE fa.actor_id IN (101, 110)
GROUP BY fa.actor_id
ORDER BY fa.actor_id;

-- INSIGHTS
-- Both actor_id's are referenced multiple times in the film_actor table. Due to the
-- absense of additional distinquishable attributes, it is not possible to determine
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
-- address details and is not required for the analysis (Refer 4.5).
-- Retain the return_date column with the NULLs intact to preserve the integrity of
-- open rental records and include for logic and business checks (Refer 5.2.1).


-- ================================================================================
-- 4.3 - HANDLING MISSING AND PLACEHOLDER VALUES
-- ================================================================================

-- --------------------------------------------------------------------------------
-- 4.3.1 - VIEW MISSING AND PLACEHOLDER VALUES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- View records where columns contain empty strings to determine how to handle them.

SELECT * 
FROM address 
WHERE TRIM(COALESCE(address2, '')) = ''
AND address2 IS NOT NULL -- nulls already addressed - Refer 4.2
LIMIT 10;

SELECT * 
FROM address 
WHERE TRIM(COALESCE(district, '')) = '';

SELECT * 
FROM address 
WHERE TRIM(COALESCE(postal_code, '')) = '';

SELECT * 
FROM address 
WHERE TRIM(COALESCE(phone, '')) = '';

-- INSIGHTS
-- These entries represent incomplete data which could interfere with filtering, 
-- grouping, or downstream logic.

-- RECOMMENDATIONS
-- Drop the address2 column from the cleaned view, as it is mainly empty, and is
-- not required for the analysis (Refer 4.5).
-- Impute empty string values in the postal_code, district, and phone columns with
-- a consistent placeholder (e.g. 'n/a') to ensure clarity and enable reliable
-- grouping and comparison (Refer 4.5).

-- --------------------------------------------------------------------------------
-- 4.4 - CREATING CLEAN VIEWS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Consolidate earlier cleaning efforst by creating streamlined, query-ready views
-- for each relevant table by standardising field names, casting data types where
-- necessary, and imputing empty values with appropriate placeholders.

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
-- Views successfully created.