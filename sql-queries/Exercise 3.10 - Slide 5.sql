-- Keys
SELECT *
FROM customer; -- customer.customer_id, customer.address_id

SELECT *
FROM address; -- address.city_id

SELECT *
FROM city; --  city.city_id, city.city, city_country_id

SELECT *
FROM country; -- country.country_id, country.country



-- Client base
SELECT
	customer.customer_id, 
	customer.first_name, 
	customer.last_name,
	city.city_id, 
	city.city, 
	country.country_id, 
	country.country
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
ORDER BY customer.customer_id;



--Distinct customers
SELECT
	DISTINCT customer.customer_id,
	COUNT(DISTINCT customer.customer_id) AS number_of_customers
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
GROUP BY customer.customer_id
ORDER BY customer.customer_id;



--Distinct countries
SELECT
	DISTINCT country.country,
	COUNT(DISTINCT country.country) AS number_of_countries
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
GROUP BY country.country
ORDER BY country.country;



-- Distinct cities
SELECT
	DISTINCT city.city,
	COUNT(DISTINCT city.city) AS number_of_cities
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
GROUP BY city.city
ORDER BY city.city;



-- Count of distinct values in client base
SELECT
	COUNT(DISTINCT customer.customer_id) AS number_of_customers,
	COUNT(DISTINCT country.country) AS number_of_countries,
	COUNT(DISTINCT city.city) AS number_of_cities
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;