-- QUESTION 1:  Which movies contributed the most/least to revenue gain?

-- 10 films that contributed most to revenue gain
SELECT 
	film.film_id,
	film.title,
	--COUNT(DISTINCT rental.rental_id) AS number_times_rented, -- 16044
	--COUNT(DISTINCT payment.payment_id) AS number_of_payments, -- 14596
	SUM(payment.amount) AS total_payments -- 61312.04
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
LEFT JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY film.film_id
ORDER BY total_payments DESC
LIMIT 10;

-- 10 films that contributed least to revenue gain
SELECT 
	film.film_id,
	film.title,
	--COUNT(DISTINCT rental.rental_id) AS number_times_rented, -- 16044
	--COUNT(DISTINCT payment.payment_id) AS number_of_payments, -- 14596
	SUM(payment.amount) AS total_payments -- 61312.04
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
LEFT JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY film.film_id
ORDER BY total_payments ASC
LIMIT 10;

-- All films including contribution to revenue gain
SELECT 
	film.film_id,
	film.title,
	film.release_year,
	film.language_id,
	film.rental_duration,
	film.rental_rate,
	film.length,
	film.replacement_cost,
	film.rating,
	--COUNT(DISTINCT rental.rental_id) AS number_times_rented, -- 16044
	--COUNT(DISTINCT payment.payment_id) AS number_of_payments, -- 14596
	SUM(payment.amount) AS total_payments -- 61312.04
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
LEFT JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY film.film_id
ORDER BY film.film_id;



-- View to calculate actor contribution to revenue gain
CREATE VIEW payment_by_actor AS
WITH actor_count AS 
	(SELECT 
		fa.film_id,
		COUNT (fa.actor_id)
	FROM film_actor fa
	GROUP BY fa.film_id)
SELECT p.payment_id,
	f.film_id,
	a.actor_id,
	a.first_name,
	a.last_name,
	CASE
		WHEN COALESCE(ac.count, 0) > 0 THEN ROUND(SUM(p.amount) / ac.count, 2)
		ELSE SUM(p.amount)
	END AS amount
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id
LEFT JOIN actor_count ac ON f.film_id = ac.film_id
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
LEFT JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY p.payment_id,
	f.film_id,
	a.actor_id,
	a.first_name,
	a.last_name,
	ac.count;

-- 10 actors that contributed most to revenue gain
SELECT 
	actor_id,
	first_name,
	last_name,
	SUM (amount) as amount
FROM payment_by_actor
WHERE actor_id IS NOT NULL
GROUP BY 
	actor_id,
	first_name,
	last_name
ORDER BY amount DESC
LIMIT 10;

-- 10 actors that contributed least to revenue gain
SELECT 
	actor_id,
	first_name,
	last_name,
	SUM (amount) as amount
FROM payment_by_actor
WHERE actor_id IS NOT NULL
GROUP BY 
	actor_id,
	first_name,
	last_name
ORDER BY amount ASC
LIMIT 10;

-- All actors including contribution to revenue gain
SELECT 
	actor_id,
	first_name,
	last_name,
	payment_id,
	film_id,
	amount
FROM payment_by_actor
ORDER BY 
	actor_id, 
	payment_id, 
	film_id;



-- QUESTION 2: What was the average rental duration for all videos?
-- Summary stats on columns with numeric data type for film table
SELECT 
	'MIN' AS metric, 
	MIN(release_year) AS release_year, 
	MIN(language_id) AS language_id, 
	MIN(rental_duration) AS rental_duration, 
	MIN(rental_rate) AS rental_rate, 
	MIN(length) AS length, 
	MIN(replacement_cost) AS replacement_cost
FROM film
UNION ALL
SELECT 
	'MAX' AS metric, 
	MAX(release_year) AS release_year, 
	MAX(language_id) AS language_id, 
	MAX(rental_duration) AS rental_duration, 
	MAX(rental_rate) AS rental_rate, 
	MAX(length) AS length, 
	MAX(replacement_cost) AS replacement_cost
FROM film
UNION ALL
SELECT 
	'AVG' AS metric, 
	ROUND(AVG(release_year),2) AS release_year, 
	ROUND(AVG(language_id),2) AS language_id, 
	ROUND(AVG(rental_duration),2) AS rental_duration, 
	ROUND(AVG(rental_rate),2) AS rental_rate, 
	ROUND(AVG(length),2) AS length, 
	ROUND(AVG(replacement_cost),2) AS replacement_cost
FROM film
UNION ALL
SELECT 
	'COUNT' AS metric, 
	COUNT(release_year) AS release_year, 
	COUNT(language_id) AS language_id, 
	COUNT(rental_duration) AS rental_duration, 
	COUNT(rental_rate) AS rental_rate, 
	COUNT(length) AS length, 
	COUNT(replacement_cost) AS replacement_cost
FROM film
UNION ALL
SELECT 
	'COUNT_ROWS' AS metric, 
	COUNT(*) AS release_year, 
	COUNT(*) AS language_id, 
	COUNT(*) AS rental_duration, 
	COUNT(*) AS rental_rate, 
	COUNT(*) AS length, 
	COUNT(*) AS replacement_cost
FROM film;

-- Summary stats on rental_rate
SELECT 
	rating, 
	ROUND(AVG(rental_rate),2) AS avg_rental_rate,
	MIN(rental_rate) AS min_rental_rate,
	MAX(rental_rate) AS max_rental_rate
FROM film
GROUP BY rating
ORDER BY rating;

-- Summary stats on rental_duration
SELECT 
	rating, 
	ROUND(AVG(rental_duration),2) AS avg_rental_duration,
	MIN(rental_duration) AS min_rental_duration,
	MAX(rental_duration) AS max_rental_duration
FROM film
GROUP BY rating
ORDER BY rating;

-- Summary stats on replacement_cost
SELECT 
	rating, 
	ROUND(AVG(replacement_cost),2) AS avg_replacement_cost,
	MIN(replacement_cost) AS min_replacement_cost,
	MAX(replacement_cost) AS max_replacement_cost
FROM film
GROUP BY rating
ORDER BY rating;

-- Movie languages
SELECT 
	language.name AS language, 
	COUNT(film.film_id) AS movie_count
FROM language language
LEFT JOIN film film ON language.language_id = film.language_id
GROUP BY language.name
ORDER BY language ASC;

-- Minimum, maxiumum rental_date
SELECT
	MIN(rental_date) AS min_rental_date,
	MAX(rental_date) AS max_rental_date
FROM rental;



-- QUESTION 3: Which countries are Rockbuster customers based in?
-- Top 10 countries with most customers
SELECT 
	co.country_id, 
	co.country,
	COUNT(cu.customer_id) AS customer_count
FROM country co
JOIN city ci ON co.country_id = ci.country_id
JOIN address ad ON ci.city_id = ad.city_id
JOIN customer cu ON ad.address_id = cu.address_id
GROUP BY co.country_id
ORDER BY customer_count DESC
LIMIT 10;

-- Top 10 cities with most customers within top 10 countries
SELECT 
	ci.city_id,
	ci.city,
	COUNT(cu.customer_id) AS customer_count
FROM city ci
JOIN address ad ON ci.city_id = ad.city_id
JOIN customer cu ON ad.address_id = cu.address_id
WHERE ci.country_id IN 
	(SELECT co.country_id
	FROM country co
	JOIN city ci ON co.country_id = ci.country_id
	JOIN address ad ON ci.city_id = ad.city_id
	JOIN customer cu ON ad.address_id = cu.address_id
	GROUP BY co.country_id
	ORDER BY COUNT(cu.customer_id) DESC
	LIMIT 10)
GROUP BY ci.city_id
ORDER BY customer_count DESC
LIMIT 10;

-- Top 5 customers that paid the most within top 10 cities
SELECT 
	cu.customer_id, 
	cu.first_name, 
	cu.last_name, 
	SUM(pm.amount) AS total_paid
FROM payment pm
JOIN customer cu ON pm.customer_id = cu.customer_id
JOIN address ad ON cu.address_id = ad.address_id
WHERE ad.city_id IN
	(SELECT ci.city_id
	FROM city ci
	JOIN address ad ON ci.city_id = ad.city_id
	JOIN customer cu ON ad.address_id = cu.address_id
	WHERE ci.country_id IN 
		(SELECT co.country_id
		FROM country co
		JOIN city ci ON co.country_id = ci.country_id
		JOIN address ad ON ci.city_id = ad.city_id
		JOIN customer cu ON ad.address_id = cu.address_id
		GROUP BY co.country_id
		ORDER BY COUNT(cu.customer_id) DESC
		LIMIT 10)
	GROUP BY ci.city_id
	ORDER BY COUNT(cu.customer_id) DESC
	LIMIT 10)
GROUP BY cu.customer_id
ORDER BY total_paid DESC
LIMIT 5;

-- Average amount paid by top 5 customers
WITH top_10_countries AS
		(SELECT co.country_id
		FROM country co
		JOIN city ci ON co.country_id = ci.country_id
		JOIN address ad ON ci.city_id = ad.city_id
		JOIN customer cu ON ad.address_id = cu.address_id
		GROUP BY co.country_id
		ORDER BY COUNT(cu.customer_id) DESC
		LIMIT 10),
	top_10_cities AS
		(SELECT ci.city_id
		FROM city ci
		JOIN address ad ON ci.city_id = ad.city_id
		JOIN customer cu ON ad.address_id = cu.address_id
		WHERE ci.country_id IN 
			(SELECT country_id
			FROM top_10_countries)
		GROUP BY ci.city_id
		ORDER BY COUNT(cu.customer_id)  DESC
		LIMIT 10),
	top_5_customers AS
		(SELECT cu.customer_id,
		SUM(pm.amount) AS total_paid
		FROM payment pm
		JOIN customer cu ON pm.customer_id = cu.customer_id
		JOIN address ad ON cu.address_id = ad.address_id
		WHERE ad.city_id IN
			(SELECT city_id
			FROM top_10_cities)
		GROUP BY cu.customer_id
		ORDER BY SUM(pm.amount) DESC
		LIMIT 5)
SELECT ROUND(AVG (total_paid),2) AS average
FROM top_5_customers;



-- QUESTION 4: Where are customers with a high lifetime value based?
-- Countries were top 5 customers are based
WITH top_10_countries AS
		(SELECT co.country_id
		FROM country co
		JOIN city ci ON co.country_id = ci.country_id
		JOIN address ad ON ci.city_id = ad.city_id
		JOIN customer cu ON ad.address_id = cu.address_id
		GROUP BY co.country_id
		ORDER BY COUNT(cu.customer_id) DESC
		LIMIT 10),
	top_10_cities AS
		(SELECT ci.city_id
		FROM city ci
		JOIN address ad ON ci.city_id = ad.city_id
		JOIN customer cu ON ad.address_id = cu.address_id
		WHERE ci.country_id IN 
			(SELECT country_id
			FROM top_10_countries)
		GROUP BY ci.city_id
		ORDER BY COUNT(cu.customer_id)  DESC
		LIMIT 10),
	top_5_customers AS
		(SELECT 
			cu.customer_id, 
			cu.first_name, 
			cu.last_name, 
			SUM(pm.amount),
			co.country_id
		FROM payment pm
		JOIN customer cu ON pm.customer_id = cu.customer_id
		JOIN address ad ON cu.address_id = ad.address_id
		JOIN city ci ON ad.city_id = ci.city_id					
		JOIN country co ON co.country_id = ci.country_id
		WHERE ad.city_id IN
			(SELECT city_id
			FROM top_10_cities)
		GROUP BY 
			cu.customer_id,
			co.country_id
		ORDER BY SUM(pm.amount) DESC
		LIMIT 5),
	all_customers AS
		(SELECT 
			co.country_id,
			co.country,
			cu.customer_id
		FROM country co
		JOIN city ci ON co.country_id = ci.country_id
		JOIN address ad ON ci.city_id = ad.city_id
		JOIN customer cu ON ad.address_id = cu.address_id
		GROUP BY 
			co.country_id,
			cu.customer_id
		ORDER BY cu.customer_id)
SELECT 
	all_customers.country_id, 
	all_customers.country,
	COUNT(DISTINCT all_customers.customer_id) AS all_customer_count,
	COUNT(DISTINCT top_5_customers.customer_id) AS top_customer_count
FROM all_customers
LEFT JOIN top_5_customers ON all_customers.country_id = top_5_customers.country_id
GROUP BY all_customers.country_id, all_customers.country
ORDER BY all_customer_count DESC;



-- QUESTION 5: Do sales figures vary between geographic regions?
-- Total payments per country
SELECT 
	country.country, 
	COUNT (DISTINCT customer.customer_id) AS number_of_customers,
	SUM (payment.amount) AS total_payments 
FROM customer
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country.country
ORDER BY number_of_customers DESC;

-- Total payments per country (detail)
SELECT 
	customer.customer_id,
	customer.first_name,
	customer.last_name,
	country.country_id,
	country.country,
	city.city_id,
	city.city,
	payment.payment_id,
	payment.amount
FROM customer
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY 
	customer.customer_id,
	country.country_id, 
	city.city_id,
	payment.payment_id;


THINK ABOUT ADDING GENRE TO THE VIZZIE

