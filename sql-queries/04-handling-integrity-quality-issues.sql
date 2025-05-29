-- ==================================================================================
-- 4 - CLEANING
-- ==================================================================================

-- TABLE OF CONTENTS

-- 4.1 - DUPLICATE RECORDS
-- 4.1.1 - VIEW DUPLICATES
-- 4.1.2 - TRACE DUPLICATE ACTORS TO FILM_ACTOR

-- 4.2 - NULLS
-- 4.2.1 - VIEW NULLS

-- 4.3 - MISSING AND PLACEHOLDER VALUES
-- 4.3.1 - VIEW MISSING AND PLACEHOLDER VALUES

-- ----------------------------------------------------------------------------------
-- 4.1 - DUPLICATE RECORDS
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 4.1.1 - VIEW DUPLICATES
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- View previously identified duplicate records to assess whether follow-up actions
-- are required.

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
-- Duplicate records in the inventory table appear valid, as multiple physical copies
-- of the same film exist across different stores for rental.

-- RECOMMENDATIONS
-- Identify which actor_id values are referenced in the film_actor table to
-- determine which of the duplicates can be removed, if any (Refer 4.1.2).
-- Flag the inventory table as containing valid duplicates, which are expected and
-- will be distinguished solely by their unique inventory_id values.

-- ----------------------------------------------------------------------------------
-- 4.1.2 - TRACE DUPLICATE ACTORS TO FILM_ACTOR
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Determine which of the duplicate actor records (Susan Davis: actor_id 101 and 110)
-- are referenced in the film_actor table.

SELECT
    fa.actor_id,
    COUNT(*) AS film_count
FROM film_actor fa
WHERE fa.actor_id IN (101, 110)
GROUP BY fa.actor_id
ORDER BY fa.actor_id;

-- INSIGHTS
-- Both actor_id's are referenced multiple times in the film_actor table.
-- Due to theabsense of additional distinquishable attributes, it is not possible to
-- determine whether these represent the same individual.

-- RECOMMENDATIONS
-- Retain both records to preserve referential integrity, document the presence
-- of name-based duplicates if actor counts are used in future analysis, and adjust
-- for possible overcounts where appropriate.

-- ----------------------------------------------------------------------------------
-- 4.2 - NULLS
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 4.2.1 - VIEW NULLS
-- ----------------------------------------------------------------------------------

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
-- The address.address2 and staff.picture columns contain information that is not
-- required for the analysis.
-- The rental.return_date column contains 183 NULL values, which appear valid and
-- likely indicates rentals that have not yet been returned.

-- RECOMMENDATION
-- Drop the address.address2 column from the cleaned view, as it holds optional
-- secondary details and is not required for the analysis (Refer 6.1).
-- Include the rental.return_date column for logic and business checks (Refer 5.2.1).

-- ----------------------------------------------------------------------------------
-- 4.3 - MISSING AND PLACEHOLDER VALUES
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 4.3.1 - VIEW MISSING AND PLACEHOLDER VALUES
-- ----------------------------------------------------------------------------------

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
-- not required for the analysis (Refer 6.1).
-- Impute empty string values in the postal_code, district, and phone columns with
-- a consistent placeholder (e.g. 'n/a') to ensure clarity and enable reliable
-- grouping and comparison (Refer 6.1).