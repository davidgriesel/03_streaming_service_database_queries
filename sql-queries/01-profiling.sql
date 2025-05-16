-- ================================================================================
-- 1. PROFILING
-- ================================================================================

-- PURPOSE
-- Understand the structure and content of the data.

-- --------------------------------------------------------------------------------
-- 1.1 OVERVIEW OF TABLES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Retrieve all tables in the public schema to support database profiling and
-- validate the entity relationship diagram, which suggests a star-like structure
-- with transactional tables linking to descriptive dimension tables, sometimes via
-- join tables.

SELECT table_schema, table_type, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_type;

-- INSIGHTS
-- Structure matches ERD expectations (transactional + dimension + join tables)
-- with 15 base tables and also revealed 7 view tables.

-- --------------------------------------------------------------------------------
-- 1.2 ROW COUNTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Count the number of records in each table to gain an understanding of relative
-- table sizes, and identify any unexpectedly empty or undersized tables.

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
-- The largest tables (rental and payment) are clearly transactional.
-- Join tables (film_actor, film_category) and inventory are relatively large.
-- Dimension tables (e.g. customer, film, address) are of appropriate mid-size.
-- Very small tables (e.g. language, staff, store) are consistent with lookup role.
-- Five view tables appear to represent enriched entity listings.
-- Two view tables suggest summarised sales data by category and by store.

-- RECOMMENDATIONS
-- Flag very small tables like staff and store for possible manual inspection.

-- --------------------------------------------------------------------------------
-- 1.3 SAMPLE ROWS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Review a sample of 5 records from each base table to understand typical content,
-- data formats, and possible irregularities (e.g., NULLs, strange encodings,
-- unexpected field usage) before deeper integrity and quality checks.

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
-- Visible NULLs (address2), and empty strings (phone, postal_code) in address
-- table suggesting optional or inconsistently captured contact data.
-- The customer table contains two fields (active and activebool) that seemingly
-- have a similar function.
-- The film table contain dense columns with non-standard data types (description
-- type text, fulltext type tsvector) and constrained categorical information
-- (rating type ENUM).
-- The film_actor and film_category follow expected join-table structure with
-- composite keys.
-- The inventory table records the physical stock of film copies held at each store,
-- linking inventory_id to both film and store.
-- The payment and rental tables contain transaction records linked to other tables
-- via foreign keys.
-- The staff table contains two staff records with visible nulls in specialised
-- fields (picture type bytea) and duplicates (password).
-- The last_update fields across all tables seeminlgy share the same timestamp.
-- Some inconsistencies (active vs activebool) and ambiguity (cagegory.name vs.
-- city.city)in column names.
-- View tables provide entity listings with foreign keys substituted with
-- descriptive fields, and aggregated sales data per category and store.

-- RECOMMENDATIONS
-- Remove columns with NULLs, optional information, duplicate functions, dense
-- variables, specialised fields, fields containing duplicates, and any other
-- columns not needed in analysis for removal (Refer 4.3).
-- Impute columns with empty strings with placeholder values like 'Unknown'
-- (Refer 4.7).
-- Confirm ENUM values (Refer 2.2.7).
-- Confirm composite key integrity in join tables (Refer 2.2.1).
-- Confirm if inventory table contains duplicate copies of film titles per store
-- distinguished only by inventory_id. (Refer 3.3).
-- Communicate shared passwords to management as potential security issue
-- (Reporting).
-- Confirm if the database has a static last_update date (Refer 3.7.1).
-- Rename columns with inconsistent naming or ambiguous names for standardisation
-- (Refer 4.4).
-- Drop and recreate VIEWs to ensure accuracy and alignment with the schema
-- (Refer 4.1).