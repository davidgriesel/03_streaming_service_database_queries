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
	payment.payment_id
ORDER BY customer.customer_id;

-- Total payments per country
SELECT 
	country.country_id,
	country.country,
	COUNT (DISTINCT customer.customer_id) AS number_of_customers,
	SUM (payment.amount) AS total_payments 
FROM customer
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country.country_id
ORDER BY country.country_id;

-- Top 10 countries with most customers
SELECT 
	country.country_id, 
	country.country,
	COUNT(customer.customer_id) AS customer_count
FROM country
JOIN city ON country.country_id = city.country_id
JOIN address ON city.city_id = address.city_id
JOIN customer ON address.address_id = customer.address_id
GROUP BY country.country_id
ORDER BY customer_count DESC
LIMIT 10;

SELECT 
	country.country_id,
	country.country,
	SUM (payment.amount) AS total_payments 
FROM customer
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country.country_id
ORDER BY total_payments DESC
LIMIT 10;

-- Top 10 cities with most customers within top 10 countries
SELECT 
	city.city_id,
	city.city,
	COUNT(customer.customer_id) AS customer_count
FROM city
JOIN address ON city.city_id = address.city_id
JOIN customer ON address.address_id = customer.address_id
WHERE city.country_id IN 
	(SELECT country.country_id
	FROM country
	JOIN city ON country.country_id = city.country_id
	JOIN address ON city.city_id = address.city_id
	JOIN customer ON address.address_id = customer.address_id
	GROUP BY country.country_id
	ORDER BY COUNT(customer.customer_id) DESC
	LIMIT 10)
GROUP BY city.city_id
ORDER BY customer_count DESC
LIMIT 10;


