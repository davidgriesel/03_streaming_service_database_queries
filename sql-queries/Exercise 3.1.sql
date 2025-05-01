-- 1. Count the number of actors with first name 'Ed'
SELECT COUNT(*) AS actor_count
FROM actor
WHERE first_name = 'Ed';


-- 2. Display first 10 rows from the payment table
SELECT *
FROM payment
LIMIT 10;


-- 3. List all base tables in the public schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- 4. Number of films by rental duration
SELECT 
    rental_duration, 
    COUNT(*) AS number_of_films
FROM film
GROUP BY rental_duration
ORDER BY number_of_films DESC;


-- 5. Tableau export: film ID and rental duration
SELECT 
    film_id, 
    rental_duration
FROM film
ORDER BY film_id;