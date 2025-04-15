-- Select all columns from 'film' table
SELECT *
FROM film;

-- Select 'film_id' & 'title' columns from 'film' table
SELECT film_id, title
FROM film;

-- Cost query 1
EXPLAIN
SELECT *
FROM film;

-- Cost query 2
EXPLAIN
SELECT film_id, title
FROM film;

-- Select all films from film table and sort by title (asc), release year (desc), rental rate (desc)
SELECT film_id, title, 
	release_year, 
	rental_rate
FROM film
ORDER BY title ASC, 
	release_year DESC, 
	rental_rate DESC;

-- Average, minimum and maximum rental rates for each rating category
SELECT rating, 
	AVG(rental_rate) AS avg_rental_rate,
	MIN(rental_duration) AS min_rental_duration,
	MAX(rental_duration) AS max_rental_duration
FROM film
GROUP BY rating;

-- Minimum and maximum replacement costs for each rating order by rating (G, PG, PG-13, R, NC-17)
SELECT rating,
	MIN(replacement_cost) AS min_replacement_cost,
	MAX(replacement_cost) AS max_replacement_cost
FROM film
GROUP BY rating
ORDER BY CASE
	WHEN rating = 'G' THEN 1
	WHEN rating = 'PG' THEN 2
	WHEN rating = 'PG-13' THEN 3
	WHEN rating = 'R' THEN 4
	WHEN rating = 'NC-17' THEN 5
END;