-- ================================================================================
-- 3. QUALITY CHECKS
-- ================================================================================

-- PURPOSE
-- Evaluate the quality and reliability of data through content-level checks across 
-- fields.

-- --------------------------------------------------------------------------------
-- 3.1 NULL CHECKS (14 nullable fields)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify and quantify missing values in 14 fields that allow NULLs that may
-- affect the analysis or business logic.

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
-- Three of the flagged fields contain NULLs.
-- Nulls are limited to optional data, information not needed in analysis, and 
-- operational fields where it could be valid.

-- RECOMMENDATIONS
-- Drop field containing NULLs that contain optional data or not be needed for
-- analysis (Refer 4.3). 
-- Include return_date for logic and dependency checks (Refer 3.8).

-- --------------------------------------------------------------------------------
-- 3.2 MISSING RECORDS AND PLACEHOLDERS (Character-based data types)
-- --------------------------------------------------------------------------------

-- PURPOSE 
-- Identify fields in character-based columns where values are missing or 
-- replaced with placeholders such as empty strings, "unknown", or "n/a".

WITH missing_check AS (

    SELECT
        'actor' AS table_name,
        'first_name' AS column_name,
        COUNT(*) AS missing_count
    FROM actor
    WHERE LOWER(COALESCE(first_name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'actor' AS table_name,
        'last_name' AS column_name,
        COUNT(*) AS missing_count
    FROM actor
    WHERE LOWER(COALESCE(last_name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'address' AS table_name,
        'address' AS column_name,
        COUNT(*) AS missing_count
    FROM address
    WHERE LOWER(COALESCE(address, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'address' AS table_name,
        'address2' AS column_name,
        COUNT(*) AS missing_count
    FROM address
    WHERE LOWER(COALESCE(address2, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'address' AS table_name,
        'district' AS column_name,
        COUNT(*) AS missing_count
    FROM address
    WHERE LOWER(COALESCE(district, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'address' AS table_name,
        'postal_code' AS column_name,
        COUNT(*) AS missing_count
    FROM address
    WHERE LOWER(COALESCE(postal_code, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'address' AS table_name,
        'phone' AS column_name,
        COUNT(*) AS missing_count
    FROM address
    WHERE LOWER(COALESCE(phone, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'category' AS table_name,
        'name' AS column_name,
        COUNT(*) AS missing_count
    FROM category
    WHERE LOWER(COALESCE(name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'city' AS table_name,
        'city' AS column_name,
        COUNT(*) AS missing_count
    FROM city
    WHERE LOWER(COALESCE(city, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'country' AS table_name,
        'country' AS column_name,
        COUNT(*) AS missing_count
    FROM country
    WHERE LOWER(COALESCE(country, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'customer' AS table_name,
        'first_name' AS column_name,
        COUNT(*) AS missing_count
    FROM customer
    WHERE LOWER(COALESCE(first_name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'customer' AS table_name,
        'last_name' AS column_name,
        COUNT(*) AS missing_count
    FROM customer
    WHERE LOWER(COALESCE(last_name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'customer' AS table_name,
        'email' AS column_name,
        COUNT(*) AS missing_count
    FROM customer
    WHERE LOWER(COALESCE(email, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'film' AS table_name,
        'title' AS column_name,
        COUNT(*) AS missing_count
    FROM film
    WHERE LOWER(COALESCE(title, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'film' AS table_name,
        'description' AS column_name,
        COUNT(*) AS missing_count
    FROM film
    WHERE LOWER(COALESCE(description, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'film' AS table_name,
        'rating' AS column_name,
        COUNT(*) AS missing_count
    FROM film
    WHERE LOWER(COALESCE(CAST(rating AS VARCHAR), ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank') -- note data type USER-DEFINED

    UNION ALL

    SELECT
        'language' AS table_name,
        'name' AS column_name,
        COUNT(*) AS missing_count
    FROM language
    WHERE LOWER(COALESCE(name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'staff' AS table_name,
        'first_name' AS column_name,
        COUNT(*) AS missing_count
    FROM staff
    WHERE LOWER(COALESCE(first_name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'staff' AS table_name,
        'last_name' AS column_name,
        COUNT(*) AS missing_count
    FROM staff
    WHERE LOWER(COALESCE(last_name, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'staff' AS table_name,
        'email' AS column_name,
        COUNT(*) AS missing_count
    FROM staff
    WHERE LOWER(COALESCE(email, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'staff' AS table_name,
        'username' AS column_name,
        COUNT(*) AS missing_count
    FROM staff
    WHERE LOWER(COALESCE(username, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')

    UNION ALL

    SELECT
        'staff' AS table_name,
        'password' AS column_name,
        COUNT(*) AS missing_count
    FROM staff
    WHERE LOWER(COALESCE(password, ''))
        IN ('', 'n/a', 'unknown', 'none', 'blank')
)

SELECT *
FROM missing_check
WHERE missing_count > 0
ORDER BY table_name, column_name;

-- INSIGHTS
-- Placeholder or empty values were found in 4 address-related fields, particularly
-- secondary address lines and contact fields.

-- RECOMMENDATIONS
-- Drop address2 field containing optional information not needed for the analysis
-- (Refer 4.3).

-- Identify specific placeholder or missing values in the remaining 3 fields and
-- impute with more relevant placeholders if applicable (Refer 4.7).

-- --------------------------------------------------------------------------------
-- 3.3 DUPLICATE CHECKS (All tables)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Detect duplicates on the combination of non-key fields to assess uniqueness and
-- ensure data integrity where constraints are absent.

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
-- Duplicate rows were limited to two fields.
-- In the case of inventory, repeated combinations may be valid due to multiple
-- copies of the same film titles per store.

-- RECOMMENDATIONS
-- Confirm whether duplicates in the actor table reflect true data replication 
-- and drop if appropriate (Refer 4.2).

-- --------------------------------------------------------------------------------
-- 3.4 COUNT DISTINCT VALUES (All tables | columns)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Count unique values per column across all tables to detect low-variance fields, 
-- constant values, or columns that may be redundant in analysis.

-- TABLE: actor
SELECT 
    'actor_id' AS actor_variable, 
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
    'address_id' AS address_variable, 
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
    'category_id' AS category_variable, 
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
    'city_id' AS city_variable, 
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
    'country_id' AS country_variable, 
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
    'customer_id' AS customer_variable, 
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
    'film_id' AS film_variable, 
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
    'actor_id' AS film_actor_variable, 
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
    'film_id' AS film_category_variable, 
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
    'inventory_id' AS inventory_variable, 
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
    'language_id' AS language_variable, 
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
    'payment_id' AS payment_variable, 
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
    'rental_id' AS rental_variable, 
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
    'staff_id' AS staff_variable, 
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
    'store_id' AS store_variable, 
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
-- Several fields have extremely low distinct counts relative to total rows,
-- including last_update, status flags, the ENUM-type field, as well as some
-- fields across staff, store, language, and category tables.
-- Some ID or key fields have identical counts to row totals and descriptions,
-- confirming their uniqueness.
-- There is one more city_id values than city values in city table. 
-- Not all film titles are linked actors, and not all titles are available for 
-- rent. 
-- Timestamps show no variance, supporting earlier observations of uniform 
-- update behaviour.

-- RECOMMENDATIONS
-- Remove low-variance or constant fields from the analysis view that add no
-- value to the analysis.

-- --------------------------------------------------------------------------------
-- 3.5 FREQUENCY DISTRIBTIONS (Categorical Variables) 
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Show the most common values for selected categorical variables to detect skew,
-- repetitive entries, or overly dominant values.

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

SELECT
    activebool AS customer_activebool,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
FROM customer
GROUP BY customer_activebool
ORDER BY frequency DESC;

SELECT
    active AS customer_active,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 2) AS percentage
FROM customer
GROUP BY customer_active
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

SELECT
    special_features AS film_special_features,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM film), 2) AS percentage
FROM film
GROUP BY film_special_features
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
    active AS staff_active,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY staff_active
ORDER BY frequency DESC;

SELECT 
    username AS staff_username,
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY staff_username
ORDER BY frequency DESC;

SELECT 
    password AS staff_password,
    COUNT(*) AS frequency, 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM staff), 2) AS percentage
FROM staff
GROUP BY staff_password
ORDER BY frequency DESC;

-- INSIGHTS
-- Some categorical fields show small number of uniform values (e.g. active, 
-- activebool, address2).
-- Fields such as names, cities, and emails display healthy distribution with 
-- limited repetition — London appear twice in city table.
-- ENUMs and structured arrays (e.g. rating, special_features) follow standardised 
-- patterns as expected.
-- Some fields (e.g. password) reflect duplicate values.

-- Some fields show nearly complete absence or repetition of a single value.
-- activebool is uniform across all customers — expected, but confirms it’s a redundant field for analysis.
-- change to boolean or removal if redundant

-- Customer names are distributed with modest repetition; no dominant entries, indicating diverse inputs.
-- activebool is uniform across all customers — expected, but confirms it’s a redundant field for analysis.
-- active shows limited variation and inconsistent typing — flagged earlier as unreliable.
-- Film ratings and special features are categorised into a small number of standard values, aligning with known ENUM and ARRAY structures.
-- Language names are well-controlled, with six defined options as per earlier ENUM review.

-- RECOMMENDATIONS
-- Drop fields that are constant or carry no analytical value (e.g. activebool, address2, active in staff).
-- Exclude technical fields (e.g. password, username) from business views unless required.
-- Retain well-distributed identifiers and descriptive fields that support segmentation or joins.
-- Standardise handling of ENUMs and ARRAYs during view creation if used in grouping or filtering.

-- Drop categorical fields with uniform or near-uniform distributions
-- (e.g. address2, last_update) from analytical views.
--  Drop customer.activebool and consider excluding or renaming customer.active after resolving type ambiguity.
-- Retain film.rating and special_features but standardise their handling in views (e.g., cast ENUMs and flatten ARRAYs).

-- --------------------------------------------------------------------------------
-- 3.6 DESCRIPTIVE STATISTICS (Numeric Variables)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Summarise numerical fields (min, max, mean, std, etc.) to detect outliers and skew.

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

-- INSIGHTS
-- No NULL values were found across any numeric fields.
-- All values fall within reasonable expected ranges — no outliers or unexpected spikes.
-- Only one field (payment.amount) includes zero values, which may represent special transactions.

-- RECOMMENDATIONS
-- Review zero amounts in the payment table for validity — may indicate system errors or test records.

-- --------------------------------------------------------------------------------
-- 3.7.1 - COUNT DISTINCT VALUES (Timestamp Variables)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Assess the number of distinct update and creation timestamps across all base 
-- tables to evaluate whether these fields reflect real activity or static/default 
-- values.

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
-- Most last_update fields contain only a single distinct timestamp — suggesting default values or initial load timestamps rather than true update tracking.
-- rental.last_update is the exception, with multiple distinct values — possibly reflecting genuine activity or system processes.

-- RECOMMENDATIONS
-- Remove static last_update fields from analytical views.
    
-- --------------------------------------------------------------------------------
-- 3.7.2 - COUNT DISTINCT VALUES (Transaction Date Variables) 
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Evaluate the distribution and coverage of transaction-related timestamps to 
-- confirm the presence of realistic activity periods and identify gaps or irregularities.

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
-- Distinct transaction dates are present across all fields, indicating operational activity over time.
-- The date ranges for rentals, returns, and payments appear coherent, suggesting logical sequencing.

-- --------------------------------------------------------------------------------
-- 3.7.3 - COUNT DISTINCT VALUES (Numeric date fields)
-- --------------------------------------------------------------------------------
    
-- PURPOSE
-- Verify that numeric date fields such as `release_year` hold plausible values 
-- and fall within a consistent, analysable range.

SELECT
    'film' AS table_name, 
    'release_year' AS column_name, 
    COUNT(DISTINCT release_year) AS distinct_dates,
    MIN(release_year) AS min_date,
    MAX(release_year) AS max_date 
FROM film;

--
-- INSIGHTS
-- Only one unique release_year value was found confirming single release year 
-- catalogue.

-- RECOMMENDATIONS
-- Treat release_year as a fixed attribute for context, not as a timeline for 
-- trend analysis.
    
-- --------------------------------------------------------------------------------
-- 3.7.4 - FREQUENCY DISTRIBUTIONS (Transaction Date Variables)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Assess the daily distribution of transaction events to identify irregular 
-- patterns, gaps, or system-generated activity that may require cleaning or 
-- explanation.

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

--
-- INSIGHTS
-- All three date fields (rental_date, return_date, payment_date) span continuous timeframes with varying frequency.
-- Noticeable dips in frequency occur at semi-regular intervals — potentially reflecting system cycles or business logic.

-- RECOMMENDATIONS
-- Flag recurring dips for further context — may represent batch processing or planned system downtimes.

-- --------------------------------------------------------------------------------
-- 3.8.1 - LOGIC CHECK FOR UNCONSTRAINED KEYS
-- --------------------------------------------------------------------------------


-- Include return_date for logic and dependency checks (Refer 3.1).


-- PURPOSE
-- Manually verify whether all store_id values in related tables have a matching 
-- entry in the store table.

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

--
-- INSIGHTS
-- All store_id values in customer, inventory, and staff tables are valid — no 
-- orphan records found.

-- --------------------------------------------------------------------------------
-- 3.8.2 - BUSINESS CHECK - ORPHANED PAYMENTS
-- --------------------------------------------------------------------------------

-- PURPOSE

SELECT COUNT(*) AS payments_without_rental
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
WHERE r.rental_id IS NULL;

--
-- INSIGHTS

-- --------------------------------------------------------------------------------
-- 3.8.3 - BUSINESS CHECK - RETURN DATES BEFORE RENTAL DATES
-- --------------------------------------------------------------------------------

-- PURPOSE

SELECT COUNT(*) AS invalid_return_dates
FROM rental
WHERE return_date < rental_date;

--
-- INSIGHTS

-- --------------------------------------------------------------------------------
-- 3.8.4 - BUSINESS CHECK - RENTAL WITHOUT RENTURN DATES
-- --------------------------------------------------------------------------------

-- PURPOSE

SELECT COUNT(*) AS rentals_without_return
FROM rental
WHERE return_date IS NULL;

--
-- INSIGHTS

-- --------------------------------------------------------------------------------
-- 3.8.5 - BUSINESS CHECK - PAYMENTS BEFORE RENTAL DATE
-- --------------------------------------------------------------------------------

-- PURPOSE

SELECT COUNT(*) AS payments_before_rental
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
WHERE p.payment_date < r.rental_date;

--
-- INSIGHTS