-- ================================================================================
-- 1 - PROFILING
-- ================================================================================

-- TABLE OF CONTENTS

-- 1.1 - OVERVIEW OF TABLES
-- 1.2 - ROW COUNTS
-- 1.3 - SAMPLE ROWS

-- --------------------------------------------------------------------------------
-- 1.1 - OVERVIEW OF TABLES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Retrieve all tables in the public schema to profile the database and validate
-- the entity relationship diagram, which suggests a star-like structure with
-- transactional tables linking to descriptive dimension tables, and in some cases
-- via join tables.

SELECT table_schema, table_type, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_type;

-- INSIGHTS
-- Structure matched ERD expectations (transactional + dimension + join tables)
-- with 15 base tables.
-- Seven view tables were also revealed.

-- --------------------------------------------------------------------------------
-- 1.2 - ROW COUNTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Count the number of records in each table to identify any unexpectedly empty or
-- undersized tables.

-- BASE Tables
SELECT
    'actor' AS table_name,
    COUNT(*) AS row_count
FROM
    actor
UNION ALL
SELECT
    'address' AS table_name,
    COUNT(*) AS row_count
FROM
    address
UNION ALL
SELECT
    'category' AS table_name,
    COUNT(*) AS row_count
FROM
    category
UNION ALL
SELECT
    'city' AS table_name,
    COUNT(*) AS row_count
FROM
    city
UNION ALL
SELECT
    'country' AS table_name,
    COUNT(*) AS row_count
FROM
    country
UNION ALL
SELECT
    'customer' AS table_name,
    COUNT(*) AS row_count
FROM
    customer
UNION ALL
SELECT
    'film' AS table_name,
    COUNT(*) AS row_count
FROM
    film
UNION ALL
SELECT
    'film_actor' AS table_name,
    COUNT(*) AS row_count
FROM
    film_actor
UNION ALL
SELECT
    'film_category' AS table_name,
    COUNT(*) AS row_count
FROM
    film_category
UNION ALL
SELECT
    'inventory' AS table_name,
    COUNT(*) AS row_count
FROM
    inventory
UNION ALL
SELECT
    'language' AS table_name,
    COUNT(*) AS row_count
FROM
    language
UNION ALL
SELECT
    'payment' AS table_name,
    COUNT(*) AS row_count
FROM
    payment
UNION ALL
SELECT
    'rental' AS table_name,
    COUNT(*) AS row_count
FROM
    rental
UNION ALL
SELECT
    'staff' AS table_name,
    COUNT(*) AS row_count
FROM
    staff
UNION ALL
SELECT
    'store' AS table_name,
    COUNT(*) AS row_count
FROM
    store;

 -- VIEWS
SELECT
    'actor_info' AS table_name,
    COUNT(*) AS row_count
FROM
    actor_info
UNION ALL
SELECT
    'customer_list' AS table_name,
    COUNT(*) AS row_count
FROM
    customer_list
UNION ALL
SELECT
    'film_list' AS table_name,
    COUNT(*) AS row_count
FROM
    film_list
UNION ALL
SELECT
    'nicer_but_slower_film_list' AS table_name,
    COUNT(*) AS row_count
FROM
    nicer_but_slower_film_list
UNION ALL
SELECT
    'sales_by_film_category' AS table_name,
    COUNT(*) AS row_count
FROM
    sales_by_film_category
UNION ALL
SELECT
    'staff_list' AS table_name,
    COUNT(*) AS row_count
FROM
    staff_list
UNION ALL
SELECT
    'sales_by_store' AS table_name,
    COUNT(*) AS row_count
FROM
    sales_by_store;

-- INSIGHTS
-- No empty tables found.
-- Transactional tables (payment, rental) are the largest as expected.
-- Join and dimension tables range from small to mid size.
-- Five view tables appear to represent enriched entity listings.
-- Two view tables suggest summarised sales data by store and category.

-- --------------------------------------------------------------------------------
-- 1.3 - SAMPLE ROWS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Review a sample of 5 records from each base table to understand typical content,
-- preview data formats, and identify possible irregularities (e.g., NULLs, strange
-- encodings, unexpected column usage) before deeper integrity and quality checks.

-- BASE Tables
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

-- VIEWs
SELECT * FROM actor_info LIMIT 5;
SELECT * FROM customer_list LIMIT 5;
SELECT * FROM film_list LIMIT 5;
SELECT * FROM nicer_but_slower_film_list LIMIT 5;
SELECT * FROM sales_by_film_category LIMIT 5;
SELECT * FROM staff_list LIMIT 5;
SELECT * FROM sales_by_store LIMIT 5;

-- INSIGHTS
-- No structural anomalies were detected.
-- Visible NULLs (address2) and empty strings (phone, postal_code) in address table.
-- The customer table contains two columns of different data types with seemingly
-- similar functions (active and activebool).
-- The film table contains dense categorical columns with non-standard data types
-- (description of type text, fulltext of type tsvector, rating of type mpaa_rating)
-- The film_actor and film_category tables contain only composite keys functioning
-- purely as join tables.
-- The inventory table records physical stock per store with duplicate titles
-- expected.
-- The payment and rental tables contain transaction records linked to information
-- in dimension tables via foreign keys.
-- The staff table contains two staff records with a visible null in picture
-- (type bytea) and duplicate values in password.
-- The last_update columns across all tables seemingly have a static timestamp.
-- Some inconsistencies (active vs activebool) and ambiguity (category.name vs.
-- city.city) in column names.
-- View tables provide entity listings substituting foreign keys with descriptive
-- values, and aggregated sales data per category and store.

-- RECOMMENDATIONS
-- Remove any unnecessary columns containing NULLs, optional information, duplicate
-- functions, dense or specialised metadata, duplicate values (Refer 4.5).
-- Impute empty strings in retained columns with placeholder values e.g. 'n/a'
-- (Refer 4.5).
-- Confirm the actual user-defined data type of mpaa_rating columns (Refer 2.3).
-- Confirm composite key integrity in join tables (Refer 2.2.1).
-- Flag inventory table as likely to contain duplicates (Refer 3.3).
-- Communicate shared passwords to management as security risk (Reporting).
-- Confirm if the database has a static timestamp (Refer 3.7.1).
-- Standardise inconsistent or ambiguous column names (Refer 4.5).
-- View tables will not be used in the analysis and can be ignored going forward.