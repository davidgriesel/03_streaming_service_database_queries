-- Identify duplicate records (Exluding unique film id)
SELECT title,
	description,
	release_year,
	language_id,
	rental_duration,
	rental_rate,
	length,
	replacement_cost,
	rating, 
	last_update,
	special_features,
	fulltext,
	COUNT(*)
FROM film
GROUP BY title,
	description,
	release_year,
	language_id,
	rental_duration,
	rental_rate,
	length,
	replacement_cost,
	rating, 
	last_update,
	special_features,
	fulltext
HAVING COUNT(*) > 1;

-- View duplicate records on film id
SELECT *
FROM film
WHERE film_id NOT IN 
	(
	SELECT MIN(film_id)
	FROM film
	GROUP BY title, 
		description, 
		release_year, 
		language_id, 
		rental_duration, 
		rental_rate, 
		length, 
		replacement_cost, 
		rating, 
		last_update, 
		special_features, 
		fulltext
	);

-- Delete duplicate records on film id
DELETE
FROM film
WHERE film_id NOT IN 
	(
	SELECT MIN(film_id)
	FROM film
	GROUP BY title,
		description, 
		release_year, 
		language_id, 
		rental_duration, 
		rental_rate, 
		length, 
		replacement_cost, 
		rating, 
		last_update, 
		special_features, 
		fulltext
	);


-- VIEW unique records - keeping lowest film id
CREATE VIEW film_cleaned AS
	SELECT MIN(film_id) AS film_id,
		title,
		description,
		release_year,
		language_id,
		rental_duration,
		rental_rate,
		length,
		replacement_cost,
		rating, 
		last_update,
		special_features,
		fulltext
	FROM film
	GROUP BY title,
		description,
		release_year,
		language_id,
		rental_duration,
		rental_rate,
		length,
		replacement_cost,
		rating, 
		last_update,
		special_features,
		fulltext;

-- VIEW Result
SELECT *
FROM film_cleaned;

DROP VIEW film_cleaned;


-- VIEW unique records - no specification which record to keep
CREATE VIEW film_cleaned AS
	SELECT DISTINCT ON 
		(
		title, 
		description, 
		release_year, 
		language_id, 
		rental_duration, 
		rental_rate, 
		length, 
		replacement_cost, 
		rating, 
		last_update, 
		special_features, 
		fulltext
		)
			film_id, 
			title, 
			description, 
			release_year, 
			language_id, 
			rental_duration, 
			rental_rate, 
			length, 
			replacement_cost, 
			rating, 
			last_update, 
			special_features, 
			fulltext
	FROM film
	ORDER BY title, 
		description, 
		release_year, 
		language_id, 
		rental_duration, 
		rental_rate, 
		length, 
		replacement_cost, 
		rating, 
		last_update, 
		special_features, 
		fulltext;

-- VIEW Result
SELECT *
FROM film_cleaned;

DROP VIEW film_cleaned;


-- To identify non-uniform values.
-- title
SELECT title,
	COUNT(*)
FROM film
GROUP BY title
ORDER BY COUNT(*) DESC;

-- description
SELECT description,
	COUNT(*)
FROM film
GROUP BY description
ORDER BY COUNT(*) DESC;

-- release year
SELECT release_year,
	COUNT(*)
FROM film
GROUP BY release_year
ORDER BY COUNT(*) DESC;

-- language id
SELECT language_id,
	COUNT(*)
FROM film
GROUP BY language_id
ORDER BY COUNT(*) DESC;

-- rental duration
SELECT rental_duration,
	COUNT(*)
FROM film
GROUP BY rental_duration
ORDER BY COUNT(*) DESC;

-- rental rate
SELECT rental_rate,
	COUNT(*)
FROM film
GROUP BY rental_rate
ORDER BY COUNT(*) DESC;

-- length
SELECT length,
	COUNT(*)
FROM film
GROUP BY length
ORDER BY COUNT(*) DESC;

-- replacement cost
SELECT replacement_cost,
	COUNT(*)
FROM film
GROUP BY replacement_cost
ORDER BY COUNT(*) DESC;

-- rating
SELECT rating,
	COUNT(*)
FROM film
GROUP BY rating
ORDER BY COUNT(*) DESC;

-- last update
SELECT last_update,
	COUNT(*)
FROM film
GROUP BY last_update
ORDER BY COUNT(*) DESC;

-- special features
SELECT special_features,
	COUNT(*)
FROM film
GROUP BY special_features
ORDER BY COUNT(*) DESC;

-- fulltext
SELECT fulltext,
	COUNT(*)
FROM film
GROUP BY fulltext
ORDER BY COUNT(*) DESC;

-- Update any non-uniform values (per column)
UPDATE film
SET title = 'new_title'
WHERE title IN ('incorrect_title1','incorrect_title2');


-- Identify missing values (all columns)
SELECT *, COUNT(*) AS null_count
FROM film
WHERE title IS NULL 
	OR description IS NULL 
	OR release_year IS NULL 
	OR language_id IS NULL 
	OR rental_duration IS NULL 
	OR rental_rate IS NULL 
	OR length IS NULL 
	OR length IS NULL 
	OR replacement_cost IS NULL 
	OR rating IS NULL 
	OR last_update IS NULL 
	OR special_features IS NULL 
	OR fulltext IS NULL
GROUP BY film_id;

-- Summarising data (Numeric columns - one table)
SELECT 'MIN' AS metric, 
	MIN(release_year) AS release_year, 
	MIN(language_id) AS language_id, 
	MIN(rental_duration) AS rental_duration, 
	MIN(rental_rate) AS rental_rate, 
	MIN(length) AS length, 
	MIN(replacement_cost) AS replacement_cost
FROM film
UNION ALL
SELECT 'MAX' AS metric, 
	MAX(release_year) AS release_year, 
	MAX(language_id) AS language_id, 
	MAX(rental_duration) AS rental_duration, 
	MAX(rental_rate) AS rental_rate, 
	MAX(length) AS length, 
	MAX(replacement_cost) AS replacement_cost
FROM film
UNION ALL
SELECT 'AVG' AS metric, 
	AVG(release_year) AS release_year, 
	AVG(language_id) AS language_id, 
	AVG(rental_duration) AS rental_duration, 
	AVG(rental_rate) AS rental_rate, 
	AVG(length) AS length, 
	AVG(replacement_cost) AS replacement_cost
FROM film
UNION ALL
SELECT 'COUNT' AS metric, 
	COUNT(release_year) AS release_year, 
	COUNT(language_id) AS language_id, 
	COUNT(rental_duration) AS rental_duration, 
	COUNT(rental_rate) AS rental_rate, 
	COUNT(length) AS length, 
	COUNT(replacement_cost) AS replacement_cost
FROM film
UNION ALL
SELECT 'COUNT_ROWS' AS metric, 
	COUNT(*) AS release_year, 
	COUNT(*) AS language_id, 
	COUNT(*) AS rental_duration, 
	COUNT(*) AS rental_rate, 
	COUNT(*) AS length, 
	COUNT(*) AS replacement_cost
FROM film;

-- Summarising data (Text columns - one table)
SELECT 
	MODE() WITHIN GROUP (ORDER BY title) AS modal_value_title,
	MODE() WITHIN GROUP (ORDER BY description) AS modal_value_description,
	MODE() WITHIN GROUP (ORDER BY rating) AS modal_value_rating,
	MODE() WITHIN GROUP (ORDER BY last_update) AS modal_value_last_update,
	MODE() WITHIN GROUP (ORDER BY special_features) AS modal_value_special_features,
	MODE() WITHIN GROUP (ORDER BY fulltext) AS modal_value_fulltext
FROM film;
