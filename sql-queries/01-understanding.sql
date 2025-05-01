-- ==============================================================
-- Rockbuster Stealth Data Checks
-- Analyst: David Griesel
-- Date: July 2024
-- Purpose: Initial Data Exploration, Validation, and Preparation
-- ==============================================================

-- ==============================================================
-- TABLE OF CONTENTS:
-- ==============================================================

    -- 1. Overview of Tables
    -- 2. Row Counts
    -- 3. Sample Rows
    -- 4. Foreign Key Checks
    -- 5. Missing Data Checks
    -- 6. Basic Summary Statistics

-- ==============================================================
-- 1. Overview of Tables
-- ==============================================================

    -- Get a list of all tables in the public schema
    SELECT 
        table_name, 
        table_type 
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;

-- ==============================================================
-- 2. Row Counts
-- ==============================================================

    -- Get row counts for all tables
    SELECT 'actor' AS table_name, COUNT(*) FROM actor
    UNION ALL
    SELECT 'address', COUNT(*) FROM address
    UNION ALL
    SELECT 'category', COUNT(*) FROM category
    UNION ALL
    SELECT 'city', COUNT(*) FROM city
    UNION ALL
    SELECT 'country', COUNT(*) FROM country
    UNION ALL
    SELECT 'customer', COUNT(*) FROM customer
    UNION ALL
    SELECT 'film', COUNT(*) FROM film
    UNION ALL
    SELECT 'film_actor', COUNT(*) FROM film_actor
    UNION ALL
    SELECT 'film_category', COUNT(*) FROM film_category
    UNION ALL
    SELECT 'inventory', COUNT(*) FROM inventory
    UNION ALL
    SELECT 'language', COUNT(*) FROM language
    UNION ALL
    SELECT 'payment', COUNT(*) FROM payment
    UNION ALL
    SELECT 'rental', COUNT(*) FROM rental
    UNION ALL
    SELECT 'staff', COUNT(*) FROM staff
    UNION ALL
    SELECT 'store', COUNT(*) FROM store;

-- ==============================================================
-- 3. Sample Rows
-- ==============================================================

    -- Get sample rows from each table
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

-- ==============================================================
-- 4. Foreign Key Checks
-- ==============================================================

    -- Check for addresses linked to non-existent cities
    SELECT a.city_id
    FROM address a
    LEFT JOIN city c ON a.city_id = c.city_id
    WHERE c.city_id IS NULL;

    -- Check for cities linked to non-existent countries
    SELECT ci.country_id
    FROM city ci
    LEFT JOIN country co ON ci.country_id = co.country_id 
    WHERE co.country_id IS NULL;

    -- Check for customers linked to non-existent stores
    SELECT cu.store_id
    FROM customer cu
    LEFT JOIN store s ON cu.store_id = s.store_id
    WHERE s.store_id IS NULL;

    -- Check for customers linked to non-existent addresses
    SELECT cu.address_id
    FROM customer cu
    LEFT JOIN address a ON cu.address_id = a.address_id
    WHERE a.address_id IS NULL;

    -- Check for films linked to non-existent languages
    SELECT f.language_id
    FROM film f
    LEFT JOIN language l ON f.language_id = l.language_id
    WHERE l.language_id IS NULL;

    -- Check for actors linked to non-existent films
    SELECT fa.film_id
    FROM film_actor fa
    LEFT JOIN film f ON fa.film_id = f.film_id
    WHERE f.film_id IS NULL;

    -- Check for films linked to non-existent categories
    SELECT fc.category_id
    FROM film_category fc
    LEFT JOIN category c ON fc.category_id = c.category_id
    WHERE c.category_id IS NULL;

    -- Check for inventory linked to non-existent films
    SELECT i.film_id
    FROM inventory i
    LEFT JOIN film f ON i.film_id = f.film_id
    WHERE f.film_id IS NULL;

    -- Check for inventory linked to non-existent stores
    SELECT i.store_id
    FROM inventory i
    LEFT JOIN store s ON i.store_id = s.store_id
    WHERE s.store_id IS NULL;

    -- Check for payments linked to non-existent customers
    SELECT p.customer_id
    FROM payment p
    LEFT JOIN customer c ON p.customer_id = c.customer_id
    WHERE c.customer_id IS NULL;

    -- Check for payments linked to non-existent staff
    SELECT p.staff_id
    FROM payment p
    LEFT JOIN staff s ON p.staff_id = s.staff_id
    WHERE s.staff_id IS NULL;

    -- Check for payments linked to non-existent rentals
    SELECT p.rental_id
    FROM payment p
    LEFT JOIN rental r ON p.rental_id = r.rental_id
    WHERE r.rental_id IS NULL;

    -- Check for rentals linked to non-existent inventory
    SELECT r.inventory_id
    FROM rental r
    LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
    WHERE i.inventory_id IS NULL;

    -- Check for rentals linked to non-existent customers
    SELECT r.customer_id
    FROM rental r
    LEFT JOIN customer c ON r.customer_id = c.customer_id
    WHERE c.customer_id IS NULL;

    -- Check for rentals linked to non-existent staff
    SELECT r.staff_id
    FROM rental r
    LEFT JOIN staff s ON r.staff_id = s.staff_id
    WHERE s.staff_id IS NULL;

    -- Check for staff linked to non-existent addresses
    SELECT s.address_id
    FROM staff s
    LEFT JOIN address a ON s.address_id = a.address_id
    WHERE a.address_id IS NULL;

    -- Check for staff linked to non-existent stores
    SELECT s.store_id
    FROM staff s
    LEFT JOIN store st ON s.store_id = st.store_id
    WHERE st.store_id IS NULL;

    -- Check for stores linked to non-existent managers
    SELECT s.manager_staff_id
    FROM store s
    LEFT JOIN staff st ON s.manager_staff_id = st.staff_id
    WHERE st.staff_id IS NULL;

    -- Check for stores linked to non-existent addresses
    SELECT s.address_id
    FROM store s
    LEFT JOIN address a ON s.address_id = a.address_id
    WHERE a.address_id IS NULL;

-- ==============================================================
-- 5. Missing Data Checks
-- ==============================================================

    -- TABLE: actor

        -- Check for missing actor_id
        SELECT COUNT(*) AS missing_actor_id
        FROM actor
        WHERE actor_id IS NULL;

        -- Check for missing first_name
        SELECT COUNT(*) AS missing_first_name
        FROM actor
        WHERE first_name IS NULL;

        -- Check for missing last_name
        SELECT COUNT(*) AS missing_last_name
        FROM actor
        WHERE last_name IS NULL;

    -- TABLE: address

        -- Check for missing address_id
        SELECT COUNT(*) AS missing_address_id
        FROM address
        WHERE address_id IS NULL;

        -- Check for missing city_id
        SELECT COUNT(*) AS missing_city_id
        FROM address
        WHERE city_id IS NULL;

    -- TABLE: category

        -- Check for missing category_id
        SELECT COUNT(*) AS missing_category_id
        FROM category
        WHERE category_id IS NULL;
        
        -- Check for missing name
        SELECT COUNT(*) AS missing_name
        FROM category
        WHERE name IS NULL;

    -- TABLE: city

        -- Check for missing city_id
        SELECT COUNT(*) AS missing_city_id
        FROM city
        WHERE city_id IS NULL;

        -- Check for missing city
        SELECT COUNT(*) AS missing_city
        FROM city
        WHERE city IS NULL;

        --- Check for missing country_id
        SELECT COUNT(*) AS missing_country_id
        FROM city
        WHERE country_id IS NULL;

    -- TABLE: country

        -- Check for missing country_id
        SELECT COUNT(*) AS missing_country_id
        FROM country
        WHERE country_id IS NULL;
        
        -- Check for missing country
        SELECT COUNT(*) AS missing_country
        FROM country
        WHERE country IS NULL;

    -- TABLE: customer

        -- Check for missing customer_id
        SELECT COUNT(*) AS missing_customer_id
        FROM customer
        WHERE customer_id IS NULL;
        
        -- Check for missing first_name
        SELECT COUNT(*) AS missing_first_name
        FROM customer
        WHERE first_name IS NULL;

        -- Check for missing last_name
        SELECT COUNT(*) AS missing_last_name
        FROM customer
        WHERE last_name IS NULL;

        -- Check for missing address_id
        SELECT COUNT(*) AS missing_address_id
        FROM customer
        WHERE address_id IS NULL;

    -- TABLE: film

        -- Check for missing film_id
        SELECT COUNT(*) AS missing_film_id
        FROM film
        WHERE film_id IS NULL;

        -- Check for missing title
        SELECT COUNT(*) AS missing_title
        FROM film
        WHERE title IS NULL;

        -- Check for missing release_year
        SELECT COUNT(*) AS missing_release_year
        FROM film
        WHERE release_year IS NULL;

        -- Check for missing language_id
        SELECT COUNT(*) AS missing_language_id
        FROM film
        WHERE language_id IS NULL;

        -- Check for missing rental_duration
        SELECT COUNT(*) AS missing_rental_duration
        FROM film
        WHERE rental_duration IS NULL;

        -- Check for missing rental_rate
        SELECT COUNT(*) AS missing_rental_rate
        FROM film
        WHERE rental_rate IS NULL;

        -- Check for missing length
        SELECT COUNT(*) AS missing_length
        FROM film
        WHERE length IS NULL;

        -- Check for missing replacement_cost
        SELECT COUNT(*) AS missing_replacement_cost
        FROM film
        WHERE replacement_cost IS NULL;

        -- Check for missing rating
        SELECT COUNT(*) AS missing_rating
        FROM film
        WHERE rating IS NULL;
        
    -- TABLE: film_actor

        -- Check for missing actor_id
        SELECT COUNT(*) AS missing_actor_id
        FROM film_actor
        WHERE actor_id IS NULL;

        -- Check for missing film_id
        SELECT COUNT(*) AS missing_film_id
        FROM film_actor
        WHERE film_id IS NULL;

    -- TABLE: film_category
        
        -- Check for missing film_id
        SELECT COUNT(*) AS missing_film_id
        FROM film_category
        WHERE film_id IS NULL;

        -- Check for missing category_id
        SELECT COUNT(*) AS missing_category_id
        FROM film_category
        WHERE category_id IS NULL;

    -- TABLE: inventory

        -- Check for missing inventory_id
        SELECT COUNT(*) AS missing_inventory_id
        FROM inventory
        WHERE inventory_id IS NULL;

        -- Check for missing film_id
        SELECT COUNT(*) AS missing_film_id
        FROM inventory
        WHERE film_id IS NULL;

        -- Check for missing store_id
        SELECT COUNT(*) AS missing_store_id
        FROM inventory
        WHERE store_id IS NULL;

    -- TABLE: language

        -- Check for missing language_id
        SELECT COUNT(*) AS missing_language_id
        FROM language
        WHERE language_id IS NULL;

        -- Check for missing name
        SELECT COUNT(*) AS missing_name
        FROM language
        WHERE name IS NULL;

    -- TABLE: payment

        -- Check for missing payment_id
        SELECT COUNT(*) AS missing_payment_id
        FROM payment
        WHERE payment_id IS NULL;

        -- Check for missing customer_id
        SELECT COUNT(*) AS missing_customer_id
        FROM payment
        WHERE customer_id IS NULL;

        -- Check for missing staff_id
        SELECT COUNT(*) AS missing_staff_id
        FROM payment
        WHERE staff_id IS NULL;

        -- Check for missing rental_id
        SELECT COUNT(*) AS missing_rental_id
        FROM payment
        WHERE rental_id IS NULL;

        -- Check for missing amount
        SELECT COUNT(*) AS missing_amount
        FROM payment
        WHERE amount IS NULL;

    -- TABLE: rental
    
        -- Check for missing rental_id
        SELECT COUNT(*) AS missing_rental_id
        FROM rental
        WHERE rental_id IS NULL;

        -- Check for missing inventory_id
        SELECT COUNT(*) AS missing_inventory_id
        FROM rental
        WHERE inventory_id IS NULL;

        -- Check for missing customer_id
        SELECT COUNT(*) AS missing_customer_id
        FROM rental
        WHERE customer_id IS NULL;

        -- Check for missing staff_id
        SELECT COUNT(*) AS missing_staff_id
        FROM rental
        WHERE staff_id IS NULL;

-- ==============================================================
-- Unique Values
-- ==============================================================

-- ==============================================================
-- 6. Basic Summary Stats (Numeric Columns)
-- ==============================================================

-- Average rental duration (days)
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM (return_date - rental_date)) / 86400), 2) AS avg_rental_duration_days
FROM rental
WHERE return_date IS NOT NULL;

-- Total revenue
SELECT 
    ROUND(SUM(amount), 2) AS total_revenue
FROM payment;

-- Number of films per category
SELECT 
    c.name AS category, 
    COUNT(fc.film_id) AS number_of_films
FROM film_category fc
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY number_of_films DESC;

-- Customers per country
SELECT 
    co.country,
    COUNT(c.customer_id) AS num_customers
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY num_customers DESC;