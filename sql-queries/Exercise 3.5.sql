-- List of films that contain the word 'Uptown' in any position
SELECT film_id, title, description
FROM film
WHERE title LIKE '%Uptown%';

-- List of films with length more than 120 minutes and rental rate more than 2.99
SELECT film_id, 
	title, 
	length, 
	rental_rate, 
	description
FROM film
WHERE length > 120 AND rental_rate > 2.99
ORDER BY film_id;

-- List of films with rental duration between 3 & 7 days (where 3 and 7 aren’t inclusive)
SELECT film_id, 
	title, 
	rental_duration, 
	description
FROM film
WHERE rental_duration > 3 AND rental_duration < 7
ORDER BY film_id;

-- List of films with replacement cost less than 14.99
SELECT film_id, 
	title, 
	replacement_cost,
	description
FROM film
WHERE replacement_cost < 14.99
ORDER BY film_id;

-- List of films with rating either PG or G
SELECT film_id,
	title,
	rating, 
	description
FROM film
WHERE rating IN ('PG', 'G')
ORDER BY film_id;

-- Summary stats: Count of movies, average rental rate, maximum and minimum rental duration of movies in PG & G category
SELECT COUNT(film_id) AS count_of_movies,
	AVG(rental_rate) AS average_rental_rate,
	MIN(rental_duration) AS minimum_rental_duration,
	MAX(rental_duration) AS maximum_rental_duration
FROM film
WHERE rating IN('PG', 'G');

-- Summary stats grouped by rating
SELECT rating,
	COUNT(film_id) AS count_of_movies,
	AVG(rental_rate) AS average_rental_rate,
	MIN(rental_duration) AS minimum_rental_duration,
	MAX(rental_duration) AS maximum_rental_duration
FROM film
WHERE rating IN('PG', 'G')
GROUP BY rating;