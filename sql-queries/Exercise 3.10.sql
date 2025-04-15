--Number of customers in customer table
SELECT COUNT(DISTINCT customer_id)
FROM customer
--599 Customers

--Period
SELECT MIN (payment_date) AS start_date,
	MAX (payment_date) AS end_date
FROM payment;
--2007-02-14 to 2007-05-14

--Total Payments made
SELECT SUM (amount) AS total_payment
FROM payment;
-- 61312.04

--Customer Location by Country
SELECT 
	country.country, 
	COUNT (DISTINCT customer.customer_id) AS number_of_customers,
	SUM (payment.amount) AS total_payments 
FROM customer
JOIN address ON customer.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country.country
ORDER BY number_of_customers DESC;

--Customer Location by Country
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
	payment.payment_id;

