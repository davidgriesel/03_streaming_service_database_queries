SELECT -- country_id (country to city) [109 - > 0]
	1 AS sort_order,
	'count' AS result,
	(SELECT COUNT(DISTINCT country_id) FROM country) AS country_table, -- 109
	(SELECT COUNT(DISTINCT country_id) FROM city) AS city_table -- 109
UNION
SELECT 
	2 AS sort_order,
	'country_id' AS result,
	country.country_id AS country_table, -- 0
    city.country_id AS city_table -- 0
FROM country
FULL JOIN city ON country.country_id = city.country_id
WHERE country.country_id IS NULL OR city.country_id IS NULL
ORDER BY sort_order;

SELECT -- city_id (city to address) [600 - > 1]
	1 AS sort_order,
	'count' AS result,
	(SELECT COUNT(DISTINCT city_id) FROM city) AS city_table, -- 600
	(SELECT COUNT(DISTINCT city_id) FROM address) AS address_table -- 599
UNION
SELECT 
	2 AS sort_order,
	'city_id' AS result,
	city.city_id AS city_table,
	address.city_id AS address_table
FROM city
FULL JOIN address ON city.city_id = address.city_id
WHERE city.city_id IS NULL OR address.city_id IS NULL
ORDER BY sort_order;

SELECT -- address_id (addres to customer) [603 - > 4]
	1 AS sort_order,
	'count' AS result,
	(SELECT COUNT(DISTINCT address_id) FROM address) AS address_table, -- 603
	(SELECT COUNT(DISTINCT address_id) FROM customer) AS customer_table -- 599
UNION
SELECT
	2 AS sort_order,
	'address_id' AS result,
	address.address_id AS address_table,
	customer.address_id AS customer_table
FROM address
FULL JOIN customer ON address.address_id = customer.address_id
WHERE address.address_id IS NULL OR customer.address_id IS NULL
ORDER BY sort_order;

SELECT -- customer_id (customer to payment) [599 - > 0]
	1 AS sort_order,
	'count' AS result,
	(SELECT COUNT(DISTINCT customer_id) FROM customer) AS customer_table, -- 599
	(SELECT COUNT(DISTINCT customer_id) FROM payment) AS payment_table -- 599
UNION
SELECT
	2 AS sort_order,
	'customer_id' AS result,
	customer.customer_id AS customer_table,
	payment.customer_id AS payment_table
FROM customer
FULL JOIN payment ON customer.customer_id = payment.customer_id
WHERE customer.customer_id IS NULL OR payment.customer_id IS NULL
ORDER BY sort_order;

-- Top 10 countries ito customer numbers
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

-- Top 10 cities within the top 10 countries
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

-- Top 5 customers within the top 10 cities
SELECT cu.customer_id, 
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