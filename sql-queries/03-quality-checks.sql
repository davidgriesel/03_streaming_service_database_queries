-- ================================================================================
-- 3. QUALITY CHECKS
-- ================================================================================

-- TABLE OF CONTENTS

-- 3.1 - NULL VALUE CHECKS (14 nullable columns)
-- 3.2 - EMPTY STRINGS OR PLACEHOLDER VALUES (Columns with character based types)
-- 3.3 - DUPLICATE RECORD CHECKS (All tables)
-- 3.4 - COUNT DISTINCT VALUES (All tables & columns)
-- 3.5 - FREQUENCY DISTRIBTIONS (Categorical columns) 
-- 3.6 - DESCRIPTIVE STATISTICS (Numeric columns)
-- 3.7 - TEMPORAL COLUMNS
    -- 3.7.1 - COUNT DISTINCT VALUES (System update columns)
    -- 3.7.2 - COUNT DISTINCT VALUES (Transaction date columns)
    -- 3.7.3 - COUNT DISTINCT VALUES (Numeric date columns)
    -- 3.7.4 - FREQUENCY DISTRIBUTIONS (Transaction date columns)

-- --------------------------------------------------------------------------------
-- 3.1 - NULL VALUE CHECKS (14 nullable columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify and quantify NULLs in the 14 columns without NOT NULL constraints.

WITH null_check AS (

    SELECT
        'address' AS table_name,
        'address2' AS column_name,
        COUNT(*) AS null_count
    FROM
        address
    WHERE
        address2 IS NULL

    UNION ALL

    SELECT
        'address' AS table_name,
        'postal_code' AS column_name,
        COUNT(*) AS null_count
    FROM
        address
    WHERE
        postal_code IS NULL

    UNION ALL

    SELECT
        'customer' AS table_name,
        'email' AS column_name,
        COUNT(*) AS null_count
    FROM
        customer
    WHERE
        email IS NULL

    UNION ALL

    SELECT
        'customer' AS table_name,
        'last_update' AS column_name,
        COUNT(*) AS null_count
    FROM
        customer
    WHERE
        last_update IS NULL

    UNION ALL

    SELECT
        'customer' AS table_name,
        'active' AS column_name,
        COUNT(*) AS null_count
    FROM
        customer
    WHERE
        active IS NULL

    UNION ALL

    SELECT
        'film' AS table_name,
        'description' AS column_name,
        COUNT(*) AS null_count
    FROM
        film
    WHERE
        description IS NULL

    UNION ALL

    SELECT
        'film' AS table_name,
        'release_year' AS column_name,
        COUNT(*) AS null_count
    FROM
        film
    WHERE
        release_year IS NULL

    UNION ALL

    SELECT
        'film' AS table_name,
        'length' AS column_name,
        COUNT(*) AS null_count
    FROM
        film
    WHERE
        length IS NULL

    UNION ALL

    SELECT
        'film' AS table_name,
        'rating' AS column_name,
        COUNT(*) AS null_count
    FROM
        film
    WHERE
        rating IS NULL

    UNION ALL

    SELECT
        'film' AS table_name,
        'special_features' AS column_name,
        COUNT(*) AS null_count
    FROM
        film
    WHERE
        special_features IS NULL

    UNION ALL

    SELECT
        'rental' AS table_name,
        'return_date' AS column_name,
        COUNT(*) AS null_count
    FROM
        rental
    WHERE
        return_date IS NULL

    UNION ALL

    SELECT
        'staff' AS table_name,
        'email' AS column_name,
        COUNT(*) AS null_count
    FROM
        staff
    WHERE
        email IS NULL

    UNION ALL

    SELECT
        'staff' AS table_name,
        'password' AS column_name,
        COUNT(*) AS null_count
    FROM
        staff
    WHERE
        password IS NULL

    UNION ALL

    SELECT
        'staff' AS table_name,
        'picture' AS column_name,
        COUNT(*) AS null_count
    FROM
        staff
    WHERE
        picture IS NULL
)
SELECT
    *
FROM
    null_check
WHERE
    null_count > 0
ORDER BY
    table_name,
    column_name;

-- INSIGHTS
-- Nulls are observed address.address2, staff.picture, rental.return_date.

-- RECOMMENDATIONS
-- Remove columns containing NULLs with optional information that are not needed in
-- the analysis (Refer 4.5).
-- Include columns allowing NULLs that contain operational information needed in
-- the analysis for logic and dependency checks (Refer 5.2.1).

-- --------------------------------------------------------------------------------
-- 3.2 - EMPTY STRINGS OR PLACEHOLDER VALUES (Columns with character based types)
-- --------------------------------------------------------------------------------

-- PURPOSE 
-- Identify and quantify empty strings or placeholder values in columns with
-- character based data types.

WITH incomplete_check AS (
    SELECT 
        'actor' AS table_name,
        'first_name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'blank') AS blank_count
    FROM actor

    UNION ALL

    SELECT
        'actor' AS table_name,
        'last_name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'blank') AS blank_count
    FROM actor

    UNION ALL

    SELECT
        'address' AS table_name,
        'address' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address, '')) = 'blank') AS blank_count
    FROM address

    UNION ALL

    SELECT
        'address' AS table_name,
        'address2' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address2, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address2, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address2, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address2, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(address2, '')) = 'blank') AS blank_count
    FROM address

    UNION ALL

    SELECT
        'address' AS table_name,
        'district' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(district, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(district, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(district, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(district, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(district, '')) = 'blank') AS blank_count
    FROM address

    UNION ALL

    SELECT
        'address' AS table_name,
        'postal_code' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(postal_code, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(postal_code, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(postal_code, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(postal_code, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(postal_code, '')) = 'blank') AS blank_count
    FROM address

    UNION ALL

    SELECT
        'address' AS table_name,
        'phone' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(phone, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(phone, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(phone, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(phone, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(phone, '')) = 'blank') AS blank_count
    FROM address

    UNION ALL

    SELECT
        'category' AS table_name,
        'name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'blank') AS blank_count
    FROM category

    UNION ALL

    SELECT
        'city' AS table_name,
        'city' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(city, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(city, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(city, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(city, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(city, '')) = 'blank') AS blank_count
    FROM city

    UNION ALL

    SELECT
        'country' AS table_name,
        'country' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(country, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(country, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(country, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(country, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(country, '')) = 'blank') AS blank_count
    FROM country

    UNION ALL

    SELECT
        'customer' AS table_name,
        'first_name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'blank') AS blank_count
    FROM customer

    UNION ALL

    SELECT
        'customer' AS table_name,
        'last_name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'blank') AS blank_count
    FROM customer

    UNION ALL

    SELECT
        'customer' AS table_name,
        'email' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'blank') AS blank_count
    FROM customer

    UNION ALL

    SELECT
        'film' AS table_name,
        'title' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(title, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(title, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(title, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(title, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(title, '')) = 'blank') AS blank_count
    FROM film

    UNION ALL

    SELECT
        'film' AS table_name,
        'description' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(description, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(description, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(description, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(description, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(description, '')) = 'blank') AS blank_count
    FROM film

    UNION ALL

    SELECT
        'language' AS table_name,
        'name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(name, '')) = 'blank') AS blank_count
    FROM language

    UNION ALL

    SELECT
        'staff' AS table_name,
        'first_name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(first_name, '')) = 'blank') AS blank_count
    FROM staff

    UNION ALL

    SELECT
        'staff' AS table_name,
        'last_name' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(last_name, '')) = 'blank') AS blank_count
    FROM staff

    UNION ALL

    SELECT
        'staff' AS table_name,
        'email' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(email, '')) = 'blank') AS blank_count
    FROM staff

    UNION ALL

    SELECT
        'staff' AS table_name,
        'username' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(username, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(username, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(username, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(username, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(username, '')) = 'blank') AS blank_count
    FROM staff

    UNION ALL

    SELECT
        'staff' AS table_name,
        'password' AS column_name,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(password, '')) = '') AS empty_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(password, '')) = 'n/a') AS na_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(password, '')) = 'unknown') AS unknown_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(password, '')) = 'none') AS none_count,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(password, '')) = 'blank') AS blank_count
    FROM staff
)

SELECT *
FROM incomplete_check
WHERE empty_count + na_count + unknown_count + none_count + blank_count > 0
ORDER BY table_name, column_name;

-- INSIGHTS
-- Empty values were found in the 4 columns in the address table.

-- RECOMMENDATIONS
-- Remove columns containing empty strings with optional information not needed in the
-- analysis (Refer 4.5).
-- Impute empty strings with appropriate placeholder values in columns that will be
-- retained (Refer 4.5).

-- --------------------------------------------------------------------------------
-- 3.3 - DUPLICATE RECORD CHECKS (All tables)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Detect duplicate records.

SELECT
    'actor' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        first_name,
        last_name
    FROM actor
    GROUP BY
        first_name,
        last_name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'address' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        address,
        address2,
        district,
        city_id,
        postal_code,
        phone
    FROM address
    GROUP BY
        address,
        address2,
        district,
        city_id,
        postal_code,
        phone
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'category' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        name
    FROM category
    GROUP BY
        name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'city' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        city,
        country_id
    FROM city
    GROUP BY
        city,
        country_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'country' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        country
    FROM country
    GROUP BY
        country
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'customer' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        store_id,
        first_name,
        last_name,
        email,
        address_id,
        activebool,
        create_date,
        active
    FROM customer
    GROUP BY
        store_id,
        first_name,
        last_name,
        email,
        address_id,
        activebool,
        create_date,
        active
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'film' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
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
        special_features,
        fulltext
    FROM film
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
        special_features,
        fulltext
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'inventory' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        film_id,
        store_id
    FROM inventory
    GROUP BY
        film_id,
        store_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'language' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        name
    FROM language
    GROUP BY
        name
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'payment' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        customer_id,
        staff_id,
        rental_id,
        amount,
        payment_date
    FROM payment
    GROUP BY
        customer_id,
        staff_id,
        rental_id,
        amount,
        payment_date
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'rental' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        rental_date,
        inventory_id,
        customer_id,
        return_date,
        staff_id
    FROM rental
    GROUP BY
        rental_date,
        inventory_id,
        customer_id,
        return_date,
        staff_id
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'staff' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        first_name,
        last_name,
        address_id,
        email,
        store_id,
        active,
        username,
        password,
        picture
    FROM staff
    GROUP BY
        first_name,
        last_name,
        address_id,
        email,
        store_id,
        active,
        username,
        password,
        picture
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT
    'store' AS table_name,
    COUNT(*) AS duplicate_count
FROM (
    SELECT
        manager_staff_id,
        address_id
    FROM store
    GROUP BY
        manager_staff_id,
        address_id
    HAVING COUNT(*) > 1
) AS dup

ORDER BY table_name;

-- INSIGHTS
-- Duplicate records were identified in the actor and inventory tables.
-- Duplicates are expected in the inventory table due to multiple physical
-- copies held per title distinguished by inventory_id.

-- RECOMMENDATIONS
-- Confirm whether duplicates in the actor table reflect true data replication 
-- and remove if appropriate (Refer 4.2).
-- Confirm whether duplicates in the inventory table reflect actual copies held for
-- rental in order to determine whether to remove or retain (Refer 4.2).

-- --------------------------------------------------------------------------------
-- 3.4 - COUNT DISTINCT VALUES (All tables & columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Count unique values per column across all tables to detect columns with
-- unexpected high or low variance, or constant values.

-- TABLE: actor
SELECT 
    'actor_id' AS actor_column, 
    COUNT(DISTINCT actor_id) AS distinct_count 
FROM actor
UNION ALL
SELECT 
    'first_name', 
    COUNT(DISTINCT first_name) 
FROM actor
UNION ALL
SELECT 
    'last_name', 
    COUNT(DISTINCT last_name) 
FROM actor
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM actor;

-- TABLE: address
SELECT 
    'address_id' AS address_column, 
    COUNT(DISTINCT address_id) AS distinct_count 
FROM address
UNION ALL
SELECT 
    'address', 
    COUNT(DISTINCT address) 
FROM address
UNION ALL
SELECT 
    'address2', 
    COUNT(DISTINCT address2) 
FROM address
UNION ALL
SELECT 
    'district', 
    COUNT(DISTINCT district) 
FROM address
UNION ALL
SELECT 
    'city_id', 
    COUNT(DISTINCT city_id) 
FROM address
UNION ALL
SELECT 
    'postal_code', 
    COUNT(DISTINCT postal_code) 
FROM address
UNION ALL
SELECT 
    'phone', 
    COUNT(DISTINCT phone) 
FROM address
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM address;

-- TABLE: category
SELECT 
    'category_id' AS category_column, 
    COUNT(DISTINCT category_id) AS distinct_count 
FROM category
UNION ALL
SELECT 
    'name', 
    COUNT(DISTINCT name) 
FROM category
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM category;

-- TABLE: city
SELECT 
    'city_id' AS city_column, 
    COUNT(DISTINCT city_id) AS distinct_count 
FROM city
UNION ALL
SELECT 
    'city', 
    COUNT(DISTINCT city) 
FROM city
UNION ALL
SELECT 
    'country_id', 
    COUNT(DISTINCT country_id) 
FROM city
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM city;

-- TABLE: country
SELECT 
    'country_id' AS country_column, 
    COUNT(DISTINCT country_id) AS distinct_count 
FROM country
UNION ALL
SELECT 
    'country', 
    COUNT(DISTINCT country) 
FROM country
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM country;

-- TABLE: customer
SELECT 
    'customer_id' AS customer_column, 
    COUNT(DISTINCT customer_id) AS distinct_count 
FROM customer
UNION ALL
SELECT 
    'store_id', 
    COUNT(DISTINCT store_id) 
FROM customer
UNION ALL
SELECT 
    'first_name', 
    COUNT(DISTINCT first_name) 
FROM customer
UNION ALL
SELECT 
    'last_name', 
    COUNT(DISTINCT last_name) 
FROM customer
UNION ALL
SELECT 
    'email', 
    COUNT(DISTINCT email) 
FROM customer
UNION ALL
SELECT 
    'address_id', 
    COUNT(DISTINCT address_id) 
FROM customer
UNION ALL
SELECT 
    'activebool', 
    COUNT(DISTINCT activebool) 
FROM customer
UNION ALL
SELECT 
    'create_date', 
    COUNT(DISTINCT create_date) 
FROM customer
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM customer
UNION ALL
SELECT 
    'active', 
    COUNT(DISTINCT active) 
FROM customer;

-- TABLE: film
SELECT 
    'film_id' AS film_column, 
    COUNT(DISTINCT film_id) AS distinct_count 
FROM film
UNION ALL
SELECT 
    'title', 
    COUNT(DISTINCT title) 
FROM film
UNION ALL
SELECT 
    'description', 
    COUNT(DISTINCT description) 
FROM film
UNION ALL
SELECT 
    'release_year', 
    COUNT(DISTINCT release_year) 
FROM film
UNION ALL
SELECT 
    'language_id', 
    COUNT(DISTINCT language_id) 
FROM film
UNION ALL
SELECT 
    'rental_duration', 
    COUNT(DISTINCT rental_duration) 
FROM film
UNION ALL
SELECT 
    'rental_rate', 
    COUNT(DISTINCT rental_rate) 
FROM film
UNION ALL
SELECT 
    'length', 
    COUNT(DISTINCT length) 
FROM film
UNION ALL
SELECT 
    'replacement_cost', 
    COUNT(DISTINCT replacement_cost) 
FROM film
UNION ALL
SELECT 
    'rating', 
    COUNT(DISTINCT rating) 
FROM film
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM film
UNION ALL
SELECT 
    'special_features', 
    COUNT(DISTINCT special_features) 
FROM film
UNION ALL
SELECT 
    'fulltext', 
    COUNT(DISTINCT fulltext) 
FROM film;

-- TABLE: film_actor
SELECT 
    'actor_id' AS film_actor_column, 
    COUNT(DISTINCT actor_id) AS distinct_count 
FROM film_actor
UNION ALL
SELECT 
    'film_id', 
    COUNT(DISTINCT film_id) 
FROM film_actor
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM film_actor;

-- TABLE: film_category
SELECT 
    'film_id' AS film_category_column, 
    COUNT(DISTINCT film_id) AS distinct_count 
FROM film_category
UNION ALL
SELECT 
    'category_id', 
    COUNT(DISTINCT category_id) 
FROM film_category
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM film_category;

-- TABLE: inventory
SELECT 
    'inventory_id' AS inventory_column, 
    COUNT(DISTINCT inventory_id) AS distinct_count 
FROM inventory
UNION ALL
SELECT 
    'film_id', 
    COUNT(DISTINCT film_id) 
FROM inventory
UNION ALL
SELECT 
    'store_id', 
    COUNT(DISTINCT store_id) 
FROM inventory
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM inventory;

-- TABLE: language
SELECT 
    'language_id' AS language_column, 
    COUNT(DISTINCT language_id) AS distinct_count 
FROM language
UNION ALL
SELECT 
    'name', 
    COUNT(DISTINCT name) 
FROM language
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM language;

-- TABLE: payment
SELECT 
    'payment_id' AS payment_column, 
    COUNT(DISTINCT payment_id) AS distinct_count 
FROM payment
UNION ALL
SELECT 
    'customer_id', 
    COUNT(DISTINCT customer_id) 
FROM payment
UNION ALL
SELECT 
    'staff_id', 
    COUNT(DISTINCT staff_id) 
FROM payment
UNION ALL
SELECT 
    'rental_id', 
    COUNT(DISTINCT rental_id) 
FROM payment
UNION ALL
SELECT 
    'amount', 
    COUNT(DISTINCT amount) 
FROM payment
UNION ALL
SELECT 
    'payment_date', 
    COUNT(DISTINCT payment_date) 
FROM payment;

-- TABLE: rental
SELECT 
    'rental_id' AS rental_column, 
    COUNT(DISTINCT rental_id) AS distinct_count 
FROM rental
UNION ALL
SELECT 
    'rental_date', 
    COUNT(DISTINCT rental_date) 
FROM rental
UNION ALL
SELECT 
    'inventory_id', 
    COUNT(DISTINCT inventory_id) 
FROM rental
UNION ALL
SELECT 
    'customer_id', 
    COUNT(DISTINCT customer_id) 
FROM rental
UNION ALL
SELECT 
    'return_date', 
    COUNT(DISTINCT return_date) 
FROM rental
UNION ALL
SELECT 
    'staff_id', 
    COUNT(DISTINCT staff_id) 
FROM rental
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM rental;

-- TABLE: staff
SELECT 
    'staff_id' AS staff_column, 
    COUNT(DISTINCT staff_id) AS distinct_count 
FROM staff
UNION ALL
SELECT 
    'first_name', 
    COUNT(DISTINCT first_name) 
FROM staff
UNION ALL
SELECT 
    'last_name', 
    COUNT(DISTINCT last_name) 
FROM staff
UNION ALL
SELECT 
    'address_id', 
    COUNT(DISTINCT address_id) 
FROM staff
UNION ALL
SELECT 
    'email', 
    COUNT(DISTINCT email) 
FROM staff
UNION ALL
SELECT 
    'store_id', 
    COUNT(DISTINCT store_id) 
FROM staff
UNION ALL
SELECT 
    'active', 
    COUNT(DISTINCT active) 
FROM staff
UNION ALL
SELECT 
    'username', 
    COUNT(DISTINCT username) 
FROM staff
UNION ALL
SELECT 
    'password', 
    COUNT(DISTINCT password) 
FROM staff
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM staff
UNION ALL
SELECT 
    'picture', 
    COUNT(DISTINCT picture) 
FROM staff;

-- TABLE: store
SELECT 
    'store_id' AS store_column, 
    COUNT(DISTINCT store_id) AS distinct_count 
FROM store
UNION ALL
SELECT 
    'manager_staff_id', 
    COUNT(DISTINCT manager_staff_id) 
FROM store
UNION ALL
SELECT 
    'address_id', 
    COUNT(DISTINCT address_id) 
FROM store
UNION ALL
SELECT 
    'last_update', 
    COUNT(DISTINCT last_update) 
FROM store;

-- INSIGHTS
-- Several columns have extremely low distinct counts relative to total rows 
-- (address.address2 and several columns in the film table).
-- Only 997 of the 1000 film titles are linked to actors (film_actor table).
-- Only 958 of the 1000 film titles are available for rent (inventory table).
-- Timestamp columns all show 1 distinct value supporting earlier observations of
-- uniform update behaviour.
-- Status columns show either 1 or 2 distinct records supporting binary expectation.

-- RECOMMENDATIONS
-- Remove columns with low or no variance, or redundant status columns that add no
-- value to the analysis (Refer 4.5).

-- --------------------------------------------------------------------------------
-- 3.5 - FREQUENCY DISTRIBTIONS (Categorical columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Show frequency of values in categorical columns to assess distribution, overly
-- dominant or repetitive values, or other undetected placeholder values.

-- TABLE:  actor
SELECT
    first_name as actor_first_name,
    COUNT(*) AS frequency
FROM actor
GROUP BY actor_first_name
ORDER BY frequency DESC;

SELECT
    last_name as actor_last_name,
    COUNT(*) AS frequency
FROM actor
GROUP BY actor_last_name
ORDER BY frequency DESC;

-- TABLE: address
SELECT
    address AS address_address,
    COUNT(*) AS frequency
FROM address
GROUP BY address_address
ORDER BY frequency DESC;

SELECT
    address2 AS address_address2,
    COUNT(*) AS frequency
FROM address
GROUP BY address_address2
ORDER BY frequency DESC;

SELECT
    district AS address_district,
    COUNT(*) AS frequency
FROM address
GROUP BY address_district
ORDER BY frequency DESC;

SELECT
    postal_code AS address_postal_code,
    COUNT(*) AS frequency
FROM address
GROUP BY address_postal_code
ORDER BY frequency DESC;

SELECT
    phone AS address_phone,
    COUNT(*) AS frequency
FROM address
GROUP BY address_phone
ORDER BY frequency DESC;

-- TABLE: category
SELECT
    name AS category_name,
    COUNT(*) AS frequency
FROM category
GROUP BY category_name
ORDER BY frequency DESC;

-- TABLE: city
SELECT
    city AS city_city,
    COUNT(*) AS frequency
FROM city
GROUP BY city_city
ORDER BY frequency DESC;

-- TABLE: country
SELECT
    country AS country_country,
    COUNT(*) AS frequency
FROM country
GROUP BY country_country
ORDER BY frequency DESC;

-- TABLE: customer
SELECT
    first_name AS customer_first_name,
    COUNT(*) AS frequency
FROM customer
GROUP BY customer_first_name
ORDER BY frequency DESC;

SELECT
    last_name AS customer_last_name,
    COUNT(*) AS frequency
FROM customer
GROUP BY customer_last_name
ORDER BY frequency DESC;

SELECT
    email AS customer_email,
    COUNT(*) AS frequency
FROM customer
GROUP BY customer_email
ORDER BY frequency DESC;

SELECT
    activebool AS customer_activebool,
    COUNT(*) AS frequency
FROM customer
GROUP BY customer_activebool
ORDER BY frequency DESC;

SELECT
    active AS customer_active,
    COUNT(*) AS frequency
FROM customer
GROUP BY customer_active
ORDER BY frequency DESC;

-- TABLE: film
SELECT
    title AS film_title,
    COUNT(*) AS frequency
FROM film
GROUP BY film_title
ORDER BY frequency DESC;

SELECT
    description AS film_description,
    COUNT(*) AS frequency
FROM film
GROUP BY film_description
ORDER BY frequency DESC;

SELECT
    rating AS film_rating,
    COUNT(*) AS frequency
FROM film
GROUP BY film_rating
ORDER BY frequency DESC;

SELECT
    special_features AS film_special_features,
    COUNT(*) AS frequency
FROM film
GROUP BY film_special_features
ORDER BY frequency DESC;

-- TABLE: language
SELECT 
    name AS language_name,
    COUNT(*) AS frequency
FROM language
GROUP BY language_name
ORDER BY frequency DESC;

-- TABLE: staff
SELECT 
    first_name AS staff_first_name,
    COUNT(*) AS frequency
FROM staff
GROUP BY staff_first_name
ORDER BY frequency DESC;

SELECT 
    last_name AS staff_last_name,
    COUNT(*) AS frequency
FROM staff
GROUP BY staff_last_name
ORDER BY frequency DESC;

SELECT 
    email AS staff_email,
    COUNT(*) AS frequency
FROM staff
GROUP BY staff_email
ORDER BY frequency DESC;

SELECT 
    active AS staff_active,
    COUNT(*) AS frequency
FROM staff
GROUP BY staff_active
ORDER BY frequency DESC;

SELECT 
    username AS staff_username,
    COUNT(*) AS frequency
FROM staff
GROUP BY staff_username
ORDER BY frequency DESC;

SELECT 
    password AS staff_password,
    COUNT(*) AS frequency
FROM staff
GROUP BY staff_password
ORDER BY frequency DESC;

-- INSIGHTS
-- The address.address2 contains only null values (4) and empty strings (599).
-- Empty strings detected in address.district (3), address.phone (2),
-- address.postal_code (4), are consistent with earlier observations.
-- London appears twice in city table but but earlier observations confirmed it
-- links to different countries.
-- Duplicates noted in field expected to hold unique values (staff.password), but
-- others (customer.email, staff.email) all hold unique values.
-- Boolean status columns (customer.activebool, staff.active) contain only one value
-- (true) while status column of type integer contain 0 and 1 (customer.active).

-- RECOMMENDATIONS
-- Remove empty columns (Refer 4.5).
-- Impute empty strings in retained columns with placeholder values e.g. 'n/a'
-- (Refer 4.5).
-- Remove the redundant status column of type integer. The boolean status column
-- indicates that all customers are active, which is supported by the presence of
-- transactions, which provide a more reliable indicator of customer activity
-- (Refer 4.5).
-- Communicate duplicate passwords to management as security risk (Reporting).

-- --------------------------------------------------------------------------------
-- 3.6 - DESCRIPTIVE STATISTICS (Numeric columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Summarise numerical columns using descriptive statistics to assess distributions
-- and skew, detect outliers, or other anomalies.

WITH 
stats_rental_duration AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT rental_duration) AS distinct_count,
        SUM(CASE WHEN rental_duration = 0 THEN 1 ELSE 0 END) AS zero_count,
        MIN(rental_duration) AS min_value,
        MAX(rental_duration) AS max_value,
        ROUND(AVG(rental_duration), 2) AS mean_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rental_duration) AS median_value,
        (MAX(rental_duration) - MIN(rental_duration)) AS range_value,
        ROUND(STDDEV_POP(rental_duration), 2) AS stddev_value
    FROM film
),

stats_rental_rate AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT rental_rate) AS distinct_count,
        SUM(CASE WHEN rental_rate = 0 THEN 1 ELSE 0 END) AS zero_count,
        MIN(rental_rate) AS min_value,
        MAX(rental_rate) AS max_value,
        ROUND(AVG(rental_rate), 2) AS mean_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rental_rate) AS median_value,
        (MAX(rental_rate) - MIN(rental_rate)) AS range_value,
        ROUND(STDDEV_POP(rental_rate), 2) AS stddev_value
    FROM film
),

stats_length AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT length) AS distinct_count,
        SUM(CASE WHEN length = 0 THEN 1 ELSE 0 END) AS zero_count,
        MIN(length) AS min_value,
        MAX(length) AS max_value,
        ROUND(AVG(length), 2) AS mean_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY length) AS median_value,
        (MAX(length) - MIN(length)) AS range_value,
        ROUND(STDDEV_POP(length), 2) AS stddev_value
    FROM film
),

stats_replacement_cost AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT replacement_cost) AS distinct_count,
        SUM(CASE WHEN replacement_cost = 0 THEN 1 ELSE 0 END) AS zero_count,
        MIN(replacement_cost) AS min_value,
        MAX(replacement_cost) AS max_value,
        ROUND(AVG(replacement_cost), 2) AS mean_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY replacement_cost) AS median_value,
        (MAX(replacement_cost) - MIN(replacement_cost)) AS range_value,
        ROUND(STDDEV_POP(replacement_cost), 2) AS stddev_value
    FROM film
),

stats_amount AS (
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT amount) AS distinct_count,
        SUM(CASE WHEN amount = 0 THEN 1 ELSE 0 END) AS zero_count,
        MIN(amount) AS min_value,
        MAX(amount) AS max_value,
        ROUND(AVG(amount), 2) AS mean_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_value,
        (MAX(amount) - MIN(amount)) AS range_value,
        ROUND(STDDEV_POP(amount), 2) AS stddev_value
    FROM payment
),

outliers_rental_duration AS (
    SELECT 
        COUNT(*) FILTER (WHERE rental_duration < (mean_value - 3 * stddev_value)) AS lower_outlier_count,
        COUNT(*) FILTER (WHERE rental_duration > (mean_value + 3 * stddev_value)) AS upper_outlier_count
    FROM film, stats_rental_duration
),

outliers_rental_rate AS (
    SELECT 
        COUNT(*) FILTER (WHERE rental_rate < (mean_value - 3 * stddev_value)) AS lower_outlier_count,
        COUNT(*) FILTER (WHERE rental_rate > (mean_value + 3 * stddev_value)) AS upper_outlier_count
    FROM film, stats_rental_rate
),

outliers_length AS (
    SELECT 
        COUNT(*) FILTER (WHERE length < (mean_value - 3 * stddev_value)) AS lower_outlier_count,
        COUNT(*) FILTER (WHERE length > (mean_value + 3 * stddev_value)) AS upper_outlier_count
    FROM film, stats_length
),
outliers_replacement_cost AS (
    SELECT 
        COUNT(*) FILTER (WHERE replacement_cost < (mean_value - 3 * stddev_value)) AS lower_outlier_count,
        COUNT(*) FILTER (WHERE replacement_cost > (mean_value + 3 * stddev_value)) AS upper_outlier_count
    FROM film, stats_replacement_cost
),

outliers_amount AS (
    SELECT 
        COUNT(*) FILTER (WHERE amount < (mean_value - 3 * stddev_value)) AS lower_outlier_count,
        COUNT(*) FILTER (WHERE amount > (mean_value + 3 * stddev_value)) AS upper_outlier_count
    FROM payment, stats_amount
)

SELECT 
    'film' AS table_name,
    'rental_duration' AS column_name,
    * 
FROM stats_rental_duration CROSS JOIN outliers_rental_duration

UNION ALL

SELECT 
    'film',
    'rental_rate',
    * 
FROM stats_rental_rate CROSS JOIN outliers_rental_rate

UNION ALL

SELECT 
    'film',
    'length',
    * 
FROM stats_length CROSS JOIN outliers_length

UNION ALL

SELECT 
    'film',
    'replacement_cost',
    * 
FROM stats_replacement_cost CROSS JOIN outliers_replacement_cost

UNION ALL

SELECT 
    'payment',
    'amount',
    * 
FROM stats_amount CROSS JOIN outliers_amount;

-- INSIGHTS
-- One column (payment.amount) contains 24 unexpected zero values.
-- The mean and median are relatively close across all columns, indicating only a
-- slight right skew in the payment.amount column.
-- The query identified 8 upper outliers in the payment.amount column, each
-- exceeding three standard deviations above the mean.

-- RECOMMENDATIONS
-- Validate the zero values and outliers in the payment.amount column (Refer 5.2.1 &
-- 5.3).


-- ================================================================================
-- 3.7 - TEMPORAL COLUMNS
-- ================================================================================

-- --------------------------------------------------------------------------------
-- 3.7.1 - COUNT DISTINCT VALUES (System update columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Assess the number of distinct values in timestamp columns across all base tables
-- that track system updates to evaluate whether they track real activity or
-- indicate static metadata.

SELECT 
    'actor' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update) AS distinct_dates, 
    MIN(last_update) AS min_date, 
    MAX(last_update) AS max_date 
FROM actor

UNION ALL

SELECT 
    'address' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM address

UNION ALL

SELECT 
    'category' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM category

UNION ALL

SELECT 
    'city' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM city

UNION ALL

SELECT 
    'country' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM country

UNION ALL

SELECT 
    'customer' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM customer

UNION ALL

SELECT 
    'customer' AS table_name, 
    'create_date' AS column_name, 
    COUNT(DISTINCT create_date), 
    MIN(create_date), 
    MAX(create_date) 
FROM customer

UNION ALL

SELECT 
    'film' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM film

UNION ALL

SELECT 
    'film_actor' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM film_actor

UNION ALL

SELECT 
    'film_category' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM film_category

UNION ALL

SELECT 
    'inventory' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM inventory

UNION ALL

SELECT 
    'language' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM language

UNION ALL

SELECT 
    'rental' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM rental

UNION ALL

SELECT 
    'staff' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM staff

UNION ALL

SELECT 
    'store' AS table_name, 
    'last_update' AS column_name, 
    COUNT(DISTINCT last_update), 
    MIN(last_update), 
    MAX(last_update) 
FROM store

ORDER BY 
    table_name;

-- INSIGHTS
-- All but one last_update columns contain a single distinct timestamp which 
-- suggests singular creation rather than true update tracking.

-- RECOMMENDATIONS
-- Remove last_update and create_date columns for analysis (Refer 4.5).

-- --------------------------------------------------------------------------------
-- 3.7.2 - COUNT DISTINCT VALUES (Transaction date columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Assess the number of distinct values in timestamp columns that track transactions
-- to assess whether these columns reflect realistic temporal patterns or static
-- entries.

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

-- INSIGHTS
-- A wide range of distinct values is present across all columns, indicating
-- temporal variation in transaction activity, including time components.

-- RECOMMENDATIONS
-- Cast retained timestamp columns tracking operational activity to date as
-- time-level detail is not required in the analysis (Refer 4.5).

-- --------------------------------------------------------------------------------
-- 3.7.3 - COUNT DISTINCT VALUES (Numeric date columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Verify that the numeric date column holds plausible values for time-based
-- interpretation. 

SELECT
    'film' AS table_name, 
    'release_year' AS column_name, 
    COUNT(DISTINCT release_year) AS distinct_dates,
    MIN(release_year) AS min_date,
    MAX(release_year) AS max_date 
FROM film;

-- INSIGHTS
-- Only one unique value was found confirming a single release year for the
-- cataloque.

-- RECOMMENDATIONS
-- Flag film.release_year as a fixed attribute for contextual reference, not as a
-- timeline for temporal analysis.
    
-- --------------------------------------------------------------------------------
-- 3.7.4 - FREQUENCY DISTRIBUTIONS (Transaction date columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Assess the daily distribution of transaction events to identify irregular 
-- patterns, gaps, or system-generated activity. All timestamps are cast to date.

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

-- INSIGHTS

-- The transactional date columns (rental_date, return_date, and payment_date) show
-- five distinct periods of activity, each followed by a period of inactivity.
-- Both rental_date and payment_date conclude with a single isolated entry.
-- The return_date column includes 184 null values.
-- The activity patterns do not reflect typical weekly, monthly, or seasonal trends.
-- Return activity typically begins one day after the first rentals which start in
-- late May 2005, but return cycles span nearly twice the duration of rental
-- periods.
-- Payment activity starts much later, in mid-February 2007 with each cycle lasting
-- around seven days.

-- RECOMMENDATIONS
-- Confirm that return_date is later than or equal to rental_date (Refer 5.4).
-- Confirm that payment_date is later than or equal to rental_date (Refer 5.5).