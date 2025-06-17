-- ==================================================================================
-- 6 - CLEANING
-- ==================================================================================

-- TABLE OF CONTENTS

-- 6.1 - CREATING CLEAN VIEWS

-- ----------------------------------------------------------------------------------
-- 6.1 - CREATING CLEAN VIEWS
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Consolidate earlier cleaning efforst by creating streamlined, query-ready views
-- for each relevant table by standardising field names, casting data types where
-- necessary, and imputing empty values with appropriate placeholders.

-- TABLE: actor
CREATE OR REPLACE VIEW actor_clean AS
SELECT
    actor_id,
    first_name,
    last_name
FROM actor;
 
-- Check
SELECT *
FROM actor_clean
LIMIT 10;

-- TABLE: address
CREATE OR REPLACE VIEW address_clean AS
SELECT
    address_id,
    address,
    COALESCE(NULLIF(TRIM(district), ''), 'n/a') AS district, -- impute missing values
    city_id,
    COALESCE(NULLIF(TRIM(postal_code), ''), 'n/a') AS postal_code, -- impute missing values
    COALESCE(NULLIF(TRIM(phone), ''), 'n/a') AS phone -- impute missing values
FROM address;

-- Check
SELECT *
FROM address_clean
LIMIT 10;

SELECT *
FROM address_clean
WHERE
    district = 'n/a'
    OR postal_code = 'n/a'
    OR phone = 'n/a';

-- TABLE: category
CREATE OR REPLACE VIEW category_clean AS
SELECT 
    category_id,
    name AS category -- rename column
FROM category;

-- Check
SELECT *
FROM category_clean
LIMIT 10;

-- TABLE: city
CREATE OR REPLACE VIEW city_clean AS
SELECT
    city_id,
    country_id
FROM city;

-- Check
SELECT *
FROM city_clean
LIMIT 10;

-- TABLE: country
CREATE OR REPLACE VIEW country_clean AS
SELECT
    country_id,
    CASE
        WHEN country = 'Runion' THEN 'Réunion' -- correct spelling
        WHEN country = 'Kazakstan' THEN 'Kazakhstan' -- correct spelling
        WHEN country = 'Yugoslavia' THEN 'Serbia' -- update country name to relevant new country
        ELSE country
    END AS country
FROM country;

-- Check
SELECT *
FROM country_clean
LIMIT 10;

SELECT *
FROM country_clean
WHERE country IN ('Réunion', 'Kazakhstan', 'Serbia');

-- TABLE: customer
CREATE OR REPLACE VIEW customer_clean AS
SELECT
    customer_id,
    store_id,
    first_name,
    last_name,
    address_id,
    activebool
FROM customer;

-- Check
SELECT *
FROM customer_clean
LIMIT 10;

-- TABLE: film
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
    rating::varchar -- change data type
FROM film;

-- Check
SELECT *
FROM film_clean
LIMIT 10;

-- TABLE: film_actor
CREATE OR REPLACE VIEW film_actor_clean AS
SELECT
    actor_id,
    film_id
FROM film_actor;

-- Check
SELECT *
FROM film_actor_clean
LIMIT 10;

-- TABLE: film_category
CREATE OR REPLACE VIEW film_category_clean AS
SELECT
    film_id,
    category_id
FROM film_category;

-- Check
SELECT *
FROM film_category_clean
LIMIT 10;

-- TABLE: inventory
CREATE OR REPLACE VIEW inventory_clean AS
SELECT
    inventory_id,
    film_id,
    store_id
FROM inventory;

-- Check
SELECT *
FROM inventory_clean
LIMIT 10;

-- TABLE: language
CREATE OR REPLACE VIEW language_clean AS
SELECT
    language_id,
    name::varchar AS language -- change data type and column name
FROM language;

-- Check
SELECT *
FROM language_clean
LIMIT 10;

-- TABLE: payment
CREATE OR REPLACE VIEW payment_clean AS
SELECT
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date::date -- change data type
FROM payment
WHERE payment_id NOT IN (19518, 25162, 29163, 31834) -- remove 4 misallocated payments
  AND rental_id IN (
      SELECT rental_id
      FROM rental
      WHERE return_date IS NOT NULL -- remove 183 payments linked to rentals with null return dates
  );

-- Check
SELECT *
FROM payment_clean
LIMIT 10;

SELECT *
FROM payment_clean
WHERE payment_id IN (19518, 25162, 29163, 31834);

SELECT COUNT(*),
    SUM(amount)
FROM payment_clean;

-- TABLE: rental
CREATE OR REPLACE VIEW rental_clean AS
SELECT
    rental_id,
    rental_date::date, -- change data type
    inventory_id,
    customer_id,
    return_date::date, -- change data type
    staff_id
FROM rental
WHERE return_date IS NOT NULL; -- remove 183 rentals with null return dates

-- Check
SELECT *
FROM rental_clean
LIMIT 10;

SELECT COUNT(*)
FROM rental_clean;

-- TABLE: staff
CREATE OR REPLACE VIEW staff_clean AS
SELECT
    staff_id,
    first_name,
    last_name,
    address_id,
    store_id,
    active AS activebool -- rename column
FROM staff;

-- Check
SELECT *
FROM staff_clean
LIMIT 10;

-- TABLE: store
CREATE OR REPLACE VIEW store_clean AS
SELECT
    store_id,
    manager_staff_id,
    address_id
FROM store;

-- Check
SELECT *
FROM store_clean
LIMIT 10;

-- INSIGHTS
-- Views successfully created.