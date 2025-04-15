-- Which actors brought the most revenue?
DROP VIEW payment_share;

CREATE VIEW payment_share AS
WITH actor_count AS 
(
	SELECT fa.film_id,
		COUNT (fa.actor_id)
	FROM film_actor fa
	GROUP BY fa.film_id
)
SELECT p.payment_id,
	f.film_id,
	a.actor_id,
	a.first_name,
	a.last_name,
	CASE
		WHEN COALESCE(ac.count, 0) > 0 THEN ROUND(SUM(p.amount) / ac.count, 2)
		ELSE SUM(p.amount)
	END AS payment_share
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

-- Total payments
SELECT SUM(amount)
FROM payment;
-- 61312.04

-- Total payments by actor assignment
SELECT
	CASE
        WHEN actor_id IS NULL THEN 'no_actor_assigned'
        ELSE 'actor_assigned'
    END AS allocation,
    SUM(payment_share) AS payment_share
FROM payment_share
GROUP BY allocation;
-- actor_assigned = 61159.17
-- no_actor_assigned = 192.62

-- Top 10 Actors
SELECT actor_id,
	first_name,
	last_name,
	SUM (payment_share) as payment_share
FROM payment_share
WHERE actor_id IS NOT NULL
GROUP BY actor_id,
	first_name,
	last_name
ORDER BY payment_share DESC
LIMIT 10;

-- Bottom 10 Actors
SELECT actor_id,
	first_name,
	last_name,
	SUM (payment_share) as payment_share
FROM payment_share
WHERE actor_id IS NOT NULL
GROUP BY actor_id,
	first_name,
	last_name
ORDER BY payment_share ASC
LIMIT 10;

-- Tableau export file
SELECT actor_id,
	first_name,
	last_name,
	payment_id,
	film_id,
	payment_share
FROM payment_share
ORDER BY actor_id, 
	payment_id, 
	film_id;

-- What language are the majority of movies in the collection?
SELECT l.name AS language, 
	COUNT(f.film_id) AS movie_count
FROM language l
LEFT JOIN film f ON l.language_id = f.language_id
GROUP BY l.name
ORDER BY language ASC;