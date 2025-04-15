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

-- Top 10 customers that paid the most within top 10 cities
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
LIMIT 10;

-- Average amount paid by top 10 customers
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
		LIMIT 10)
SELECT ROUND(AVG (total_paid),2) AS average
FROM top_5_customers;

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
		LIMIT 10),
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