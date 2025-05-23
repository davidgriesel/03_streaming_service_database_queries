-- ================================================================================
-- 7. BUSINESS QUESTIONS
-- ================================================================================

-- TABLE OF CONTENTS

-- 7.1 - QUESTION 1
-- 7.2 - QUESTION 2
-- 7.3 - QUESTION 3
-- 7.4 - QUESTION 4
-- 7.5 - QUESTION 5

-- --------------------------------------------------------------------------------
-- 7.1 - QUESTION 1
-- --------------------------------------------------------------------------------

-- Which movies contributed the most/least to revenue gain?

SELECT
    f.title,
    f.film_id,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM film_clean f
    JOIN inventory_clean i ON f.film_id = i.film_id
    JOIN rental_clean r ON i.inventory_id = r.inventory_id
    JOIN payment_clean p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title
ORDER BY total_revenue DESC
LIMIT 10;

-- --------------------------------------------------------------------------------

SELECT
    f.title,
    f.film_id,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM film_clean f
    JOIN inventory_clean i ON f.film_id = i.film_id
    JOIN rental_clean r ON i.inventory_id = r.inventory_id
    JOIN payment_clean p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title
ORDER BY total_revenue ASC
LIMIT 10;

-- --------------------------------------------------------------------------------
-- 7.2 - QUESTION 2
-- --------------------------------------------------------------------------------

-- What was the average rental duration for all videos?

SELECT 'Minimum', MIN(rental_duration)
FROM film_clean

UNION ALL

SELECT 'Maximum', MAX(rental_duration)
FROM film_clean

UNION ALL

SELECT 'Average' AS metric, ROUND(AVG(rental_duration), 2) AS value
FROM film_clean;

-- --------------------------------------------------------------------------------

SELECT 'G' AS rating, ROUND(AVG(rental_duration), 2) AS average_rental_duration
FROM film_clean
WHERE rating = 'G'

UNION ALL

SELECT 'PG', ROUND(AVG(rental_duration), 2)
FROM film_clean
WHERE rating = 'PG'

UNION ALL

SELECT 'PG-13', ROUND(AVG(rental_duration), 2)
FROM film_clean
WHERE rating = 'PG-13'

UNION ALL

SELECT 'R', ROUND(AVG(rental_duration), 2)
FROM film_clean
WHERE rating = 'R'

UNION ALL

SELECT 'NC-17', ROUND(AVG(rental_duration), 2)
FROM film_clean
WHERE rating = 'NC-17';

-- --------------------------------------------------------------------------------
-- 7.3 - QUESTION 3
-- --------------------------------------------------------------------------------

-- Which countries are Rockbuster customers based in?

SELECT DISTINCT
    co.country
FROM customer_clean cu
    JOIN address_clean a ON cu.address_id = a.address_id
    JOIN city_clean ci ON a.city_id = ci.city_id
    JOIN country_clean co ON ci.country_id = co.country_id
ORDER BY co.country;

-- --------------------------------------------------------------------------------

SELECT
    co.country,
    COUNT(*) AS customer_count
FROM customer_clean cu
    JOIN address_clean a ON cu.address_id = a.address_id
    JOIN city_clean ci ON a.city_id = ci.city_id
    JOIN country_clean co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY customer_count DESC
LIMIT 10;

-- --------------------------------------------------------------------------------

SELECT
    co.country,
    ROUND(SUM(p.amount), 0) AS total_revenue
FROM payment_clean p
    JOIN customer_clean cu ON p.customer_id = cu.customer_id
    JOIN address_clean a ON cu.address_id = a.address_id
    JOIN city_clean ci ON a.city_id = ci.city_id
    JOIN country_clean co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY total_revenue DESC
LIMIT 10;

-- --------------------------------------------------------------------------------
-- 7.4 - QUESTION 4
-- --------------------------------------------------------------------------------

-- Where are customers with a high lifetime value based?

WITH customer_lifetime_value AS (
    SELECT
        cu.customer_id,
        SUM(p.amount) AS lifetime_value
    FROM payment_clean p
    JOIN customer_clean cu ON p.customer_id = cu.customer_id
    GROUP BY cu.customer_id
),

customer_location AS (
    SELECT
        clv.customer_id,
        clv.lifetime_value,
        co.country
    FROM customer_lifetime_value clv
    JOIN customer_clean cu ON clv.customer_id = cu.customer_id
    JOIN address_clean a ON cu.address_id = a.address_id
    JOIN city_clean ci ON a.city_id = ci.city_id
    JOIN country_clean co ON ci.country_id = co.country_id
)

SELECT
    country,
    ROUND(AVG(lifetime_value), 2) AS avg_lifetime_value,
    COUNT(*) AS customer_count
FROM customer_location
GROUP BY country
ORDER BY avg_lifetime_value DESC
LIMIT 10;

-- --------------------------------------------------------------------------------
-- 7.5 - QUESTION 5
-- --------------------------------------------------------------------------------

-- Do sales figures vary between geographic regions?

SELECT
    CASE
        WHEN co.country IN ('Algeria', 'Angola', 'Cameroon', 'Chad', 'Congo, The Democratic Republic of the', 'Egypt', 'Ethiopia', 'Gambia', 'Kenya', 'Madagascar', 'Malawi', 'Morocco', 'Mozambique', 'Nigeria', 'Senegal', 'South Africa', 'Sudan', 'Tanzania', 'Tunisia', 'Zambia') THEN 'Africa'
        WHEN co.country IN ('Afghanistan', 'Armenia', 'Azerbaijan', 'Bahrain', 'Bangladesh', 'Brunei', 'Cambodia', 'China', 'Hong Kong', 'India', 'Indonesia', 'Iran', 'Iraq', 'Israel', 'Japan', 'Kazakstan', 'Kuwait', 'Malaysia', 'Myanmar', 'Nepal', 'North Korea', 'Oman', 'Pakistan', 'Philippines', 'Saudi Arabia', 'South Korea', 'Sri Lanka', 'Syria', 'Taiwan', 'Thailand', 'Turkey', 'Turkmenistan', 'United Arab Emirates', 'Vietnam', 'Yemen') THEN 'Asia'
        WHEN co.country IN ('Austria', 'Belarus', 'Bulgaria', 'Czech Republic', 'Estonia', 'Faroe Islands', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Italy', 'Latvia', 'Liechtenstein', 'Lithuania', 'Moldova', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Russian Federation', 'Slovakia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom', 'Vatican City', 'Yugoslavia') THEN 'Europe'
        WHEN co.country IN ('Canada', 'Mexico', 'Puerto Rico', 'United States', 'Virgin Islands, U.S.') THEN 'North America'
        WHEN co.country IN ('Argentina', 'Bolivia', 'Brazil', 'Chile', 'Colombia', 'Dominican Republic', 'Ecuador', 'Paraguay', 'Peru', 'Venezuela') THEN 'South America'
        WHEN co.country IN ('Australia', 'American Samoa', 'French Polynesia', 'Nauru', 'New Zealand', 'Tonga', 'Tuvalu') THEN 'Oceania'
        ELSE 'Other'
    END AS continent,
    ROUND(SUM(p.amount), 0) AS total_sales,
    COUNT(DISTINCT cu.customer_id) AS customer_count,
    ROUND(AVG(p.amount), 2) AS avg_payment_amount
FROM payment_clean p
JOIN customer_clean cu ON p.customer_id = cu.customer_id
JOIN address_clean a ON cu.address_id = a.address_id
JOIN city_clean ci ON a.city_id = ci.city_id
JOIN country_clean co ON ci.country_id = co.country_id
GROUP BY continent
ORDER BY total_sales DESC;

-- --------------------------------------------------------------------------------

SELECT
    co.country,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM payment_clean p
JOIN customer_clean cu ON p.customer_id = cu.customer_id
JOIN address_clean a ON cu.address_id = a.address_id
JOIN city_clean ci ON a.city_id = ci.city_id
JOIN country_clean co ON ci.country_id = co.country_id
GROUP BY co.country
ORDER BY total_revenue DESC
LIMIT 10;

-- --------------------------------------------------------------------------------

SELECT
    ci.city,
    co.country,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM payment_clean p
JOIN customer_clean cu ON p.customer_id = cu.customer_id
JOIN address_clean a ON cu.address_id = a.address_id
JOIN city_clean ci ON a.city_id = ci.city_id
JOIN country_clean co ON ci.country_id = co.country_id
GROUP BY ci.city, co.country
ORDER BY total_revenue DESC
LIMIT 10;

-- --------------------------------------------------------------------------------


SELECT 'Total titles in film catalogue' AS metric, COUNT(*)::TEXT AS value FROM film_clean
UNION ALL
SELECT 'Titles with copies in inventory', COUNT(DISTINCT i.film_id)::TEXT
FROM inventory_clean i
UNION ALL
SELECT 'Number of languages', COUNT(DISTINCT language_id)::TEXT FROM film_clean
UNION ALL
SELECT 'Number of release years', COUNT(DISTINCT release_year)::TEXT FROM film_clean
UNION ALL
SELECT 'Number of categories', COUNT(*)::TEXT FROM category_clean
UNION ALL
SELECT 'Number of ratings', COUNT(DISTINCT rating)::TEXT FROM film_clean;

-- --------------------------------------------------------------------------------

SELECT 'Total customers' AS metric, COUNT(*)::TEXT AS value FROM customer_clean
UNION ALL
SELECT 'Countries with customers', COUNT(DISTINCT co.country)::TEXT
FROM customer_clean cu
JOIN address_clean a ON cu.address_id = a.address_id
JOIN city_clean ci ON a.city_id = ci.city_id
JOIN country_clean co ON ci.country_id = co.country_id
UNION ALL
SELECT 'Cities with customers', COUNT(DISTINCT ci.city)::TEXT
FROM customer_clean cu
JOIN address_clean a ON cu.address_id = a.address_id
JOIN city_clean ci ON a.city_id = ci.city_id;