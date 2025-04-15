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