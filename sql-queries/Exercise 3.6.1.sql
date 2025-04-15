-- Identify duplicate records (Exluding unique customer id)
SELECT store_id,
	first_name,
	last_name,
	email,
	address_id,
	activebool,
	create_date,
	last_update,
	active,
	COUNT(*)
FROM customer
GROUP BY store_id,
	first_name,
	last_name,
	email,
	address_id,
	activebool,
	create_date,
	last_update,
	active
HAVING COUNT(*) > 1;

-- View duplicate records on customer id
SELECT *
FROM customer
WHERE customer_id NOT IN 
	(
	SELECT MIN(customer_id)
	FROM customer
	GROUP BY store_id,
		first_name,
		last_name,
		email,
		address_id,
		activebool,
		create_date,
		last_update,
		active
	);

-- Delete duplicate records on customer id
DELETE
FROM customer
WHERE customer_id NOT IN 
	(
	SELECT MIN(customer_id)
	FROM customer
	GROUP BY store_id,
		first_name,
		last_name,
		email,
		address_id,
		activebool,
		create_date,
		last_update,
		active
	);


-- VIEW unique records - keeping lowest customer id
CREATE VIEW customer_cleaned AS
	SELECT MIN(customer_id) AS customer_id,
		store_id,
		first_name,
		last_name,
		email,
		address_id,
		activebool,
		create_date,
		last_update,
		active
	FROM customer
	GROUP BY store_id,
		first_name,
		last_name,
		email,
		address_id,
		activebool,
		create_date,
		last_update,
		active;

-- VIEW Result
SELECT *
FROM customer_cleaned;

DROP VIEW customer_cleaned;


-- VIEW unique records - no specification which record to keep
CREATE VIEW customer_cleaned AS
	SELECT DISTINCT ON 
		(
		store_id,
		first_name,
		last_name,
		email,
		address_id,
		activebool,
		create_date,
		last_update,
		active
		)
			customer_id, store_id,
			first_name,
			last_name,
			email,
			address_id,
			activebool,
			create_date,
			last_update,
			active
	FROM customer
	ORDER BY store_id,
		first_name,
		last_name,
		email,
		address_id,
		activebool,
		create_date,
		last_update,
		active;

-- VIEW Result
SELECT *
FROM customer_cleaned;

DROP VIEW customer_cleaned;


-- To identify non-uniform values.
-- store_id
SELECT store_id,
	COUNT(*)
FROM customer
GROUP BY store_id
ORDER BY COUNT(*) DESC;

-- first name
SELECT first_name,
	COUNT(*)
FROM customer
GROUP BY first_name
ORDER BY COUNT(*) DESC;

-- last name
SELECT last_name,
	COUNT(*)
FROM customer
GROUP BY last_name
ORDER BY COUNT(*) DESC;

-- email
SELECT email,
	COUNT(*)
FROM customer
GROUP BY email
ORDER BY COUNT(*) DESC;

-- address_id
SELECT address_id,
	COUNT(*)
FROM customer
GROUP BY address_id
ORDER BY COUNT(*) DESC;

-- activebool
SELECT activebool,
	COUNT(*)
FROM customer
GROUP BY activebool
ORDER BY COUNT(*) DESC;

-- create date
SELECT create_date,
	COUNT(*)
FROM customer
GROUP BY create_date
ORDER BY COUNT(*) DESC;

-- last update
SELECT last_update,
	COUNT(*)
FROM customer
GROUP BY last_update
ORDER BY COUNT(*) DESC;

-- active 
SELECT active,
	COUNT(*)
FROM customer
GROUP BY active
ORDER BY COUNT(*) DESC;


-- Update any non-uniform values (per column)
UPDATE customer
SET last_name = 'new_last_name'
WHERE last_name IN ('incorrect_last_name1','incorrect_last_name2');


-- Identify missing values (all columns)
SELECT *, COUNT(*) AS null_count
FROM customer
WHERE store_id IS NULL 
	OR first_name IS NULL 
	OR last_name IS NULL 
	OR email IS NULL 
	OR address_id IS NULL 
	OR activebool IS NULL 
	OR create_date IS NULL 
	OR last_update IS NULL 
	OR active IS NULL 
GROUP BY customer_id;

-- Summarising data (Numeric columns - one table)
SELECT 'MIN' AS metric, 
	MIN(store_id) AS store_id, 
	MIN(address_id) AS address_id, 
	MIN(active) AS active
FROM customer
UNION ALL
SELECT 'MAX' AS metric, 
	MAX(store_id) AS store_id, 
	MAX(address_id) AS address_id, 
	MAX(active) AS active
FROM customer
UNION ALL
SELECT 'AVG' AS metric, 
	AVG(store_id) AS store_id, 
	AVG(address_id) AS address_id, 
	AVG(active) AS active
FROM customer
UNION ALL
SELECT 'COUNT' AS metric, 
	COUNT(store_id) AS store_id, 
	COUNT(address_id) AS address_id, 
	COUNT(active) AS active
FROM customer
UNION ALL
SELECT 'COUNT_ROWS' AS metric, 
	COUNT(*) AS store_id, 
	COUNT(*) AS address_id, 
	COUNT(*) AS active
FROM customer;

-- Summarising data (Text columns - one table)
SELECT 
	MODE() WITHIN GROUP (ORDER BY first_name) AS modal_value_first_name,
	MODE() WITHIN GROUP (ORDER BY last_name) AS modal_value_last_name,
	MODE() WITHIN GROUP (ORDER BY email) AS modal_value_email,
	MODE() WITHIN GROUP (ORDER BY activebool) AS modal_value_activebool,
	MODE() WITHIN GROUP (ORDER BY create_date) AS modal_value_create_date,
	MODE() WITHIN GROUP (ORDER BY last_update) AS modal_value_last_update
FROM customer;
