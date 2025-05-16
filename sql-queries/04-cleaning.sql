-- ================================================================================
-- 4. CLEANING
-- ================================================================================

-- PURPOSE 
-- Address issues identified in the quality checks to prepare the data for analysis.

-- --------------------------------------------------------------------------------
-- 4.1 - DROP VIEWS (Refer 1.3)
-- --------------------------------------------------------------------------------

-- Drop and recreate VIEWs to ensure accuracy and alignment with the schema
-- (Refer 3.1).

-- --------------------------------------------------------------------------------
-- 4.2 - REMOVING DUPLICATES
-- --------------------------------------------------------------------------------

-- #.# - View duplicate records: actor table

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

-- #.# - View duplciate records: inventory table

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

-- #.# - Create a clean view of actor table.

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

-- #.# - Validation Check: Row counts actor vs clean_actor

SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor;
SELECT 'clean_actor' AS table_name, COUNT(*) AS row_count FROM clean_actor;


-- #.# - Confirm no duplicates in clean-actor view.


SELECT 'clean_actor' AS table_name, COUNT(*) AS duplicate_count
FROM (
    SELECT first_name, last_name
    FROM clean_actor
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
) AS dup;

-- No cleaning action required for inventory duplicates as they reflect valid 
-- business logic.



-- --------------------------------------------------------------------------------
-- 4.3 - DROPPING COLUMNS 
-- --------------------------------------------------------------------------------

-- Remove columns with NULLs, optional information, duplicate functions, dense
-- variables, specialised fields, fields containing duplicates, and any other
-- columns not needed in analysis for removal (Refer 1.3).
-- Optional information: address.address2
-- Duplicate functions: customer.active
-- Dense variables: film.description, film.fulltext
-- Specialised fields: staff.picture
-- Duplications in fields: staff.password

-- Remove columns using unusual or complex data types if not needed in the analysis
-- (Refer 2.1).

-- Remove if not needed: film.special_features, staff.picture, film.description,
-- film.fulltext

-- Drop field containing NULLs that contain optional data or not be needed for
-- analysis (Refer 3.1). 

-- Drop address2 field containing optional information not needed for the analysis
-- (Refer 3.2).


-- --------------------------------------------------------------------------------
-- 4.4 - ALIASING COLUMNS (Refer 1.3)
-- --------------------------------------------------------------------------------

-- Rename columns with inconsistent naming or ambiguous names for standardisation
-- Refer 1.3).
-- staff.active, category.name, language.name.


-- --------------------------------------------------------------------------------
-- 4.5 - CASTING DATA TYPES (Refer 2.1 | 2.2.8)
-- --------------------------------------------------------------------------------

-- Change fields with type timestamp where time-level precision is not required to
-- date for standardisation (Refer 2.1).
-- Change to date: payment.payment_date, rental.return_date, rental.rental_date

-- Change fields with type character to varchar for standardisation (Refer 2.1).
-- Change to varchar: language.name

-- Transform data type of film.rating to varchar for use in analysis (Refer 2.2.8).

-- payment.payment_date :: date

-- --------------------------------------------------------------------------------
-- 4.6 - HANDLING NULLS
-- --------------------------------------------------------------------------------

-- --------------------------------------------------------------------------------
-- 4.7 - HANDLING MISSING AND PLACEHOLDER VALUES
-- --------------------------------------------------------------------------------

-- Impute columns with empty strings with placeholder values like 'Unknown'
-- (Refer 1.3).

-- Identify specific placeholder or missing values in the remaining 3 fields and
-- impute with more relevant placeholders if applicable (Refer 3.2)








