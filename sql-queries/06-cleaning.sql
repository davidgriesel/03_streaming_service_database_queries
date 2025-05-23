-- ================================================================================
-- 6 - CLEANING
-- ================================================================================

-- TABLE OF CONTENTS

-- 6.1 - CREATING CLEAN VIEWS

-- --------------------------------------------------------------------------------
-- 6.1 - CREATING CLEAN VIEWS
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