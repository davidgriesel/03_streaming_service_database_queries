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



-- Late returns contributed the majority of revenue. 
-- How is revenue from late returns spread across rental terms? 





SELECT DISTINCT rental_rate
FROM film_clean
ORDER BY rental_rate;

SELECT
    rental_duration,
    MAX(CASE WHEN rental_rate = 0.99 THEN 1 ELSE 0 END) AS has_0_99,
    MAX(CASE WHEN rental_rate = 1.99 THEN 1 ELSE 0 END) AS has_2_99,
    MAX(CASE WHEN rental_rate = 2.99 THEN 1 ELSE 0 END) AS has_4_99
FROM film_clean
GROUP BY rental_duration
ORDER BY rental_duration;



-- ----------------------------------------------------------------------------------
-- 7.2 - QUESTION 2: What was the average rental duration for all videos?
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Calculate the minimum, maximum, and average actual rental durations for all
-- rentals with recorded return dates, grouped by contractual rental terms and
-- summarised across all durations.

    WITH rental_stats AS (
        SELECT
            f.rental_duration::TEXT AS rental_duration,
            COUNT(*) AS rental_count,
            MIN(r.return_date - r.rental_date) AS min_duration,
            MAX(r.return_date - r.rental_date) AS max_duration,
            ROUND(AVG(r.return_date - r.rental_date), 2) AS avg_duration
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
        WHERE
            r.return_date IS NOT NULL -- exclude 183 rentals with NULL return dates
        GROUP BY
            f.rental_duration
    ),

    total_stats AS (
        SELECT
            'Total' AS rental_duration,
            COUNT(*) AS rental_count,
            MIN(r.return_date - r.rental_date) AS min_duration,
            MAX(r.return_date - r.rental_date) AS max_duration,
            ROUND(AVG(r.return_date - r.rental_date), 2) AS avg_duration
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
        WHERE
            r.return_date IS NOT NULL -- exclude 183 rentals with NULL return dates
    )

    SELECT *
    FROM (
        SELECT * FROM rental_stats
        UNION ALL
        SELECT * FROM total_stats
    ) AS combined
    ORDER BY
        CASE 
            WHEN rental_duration = 'Total' THEN 999
            ELSE rental_duration::int
        END;

-- INSIGHTS
-- Among 15,861 rentals with recorded return dates, the actual rental duration ranged
-- between 0 to 10 days across all contractual rental terms, with an overall average
-- of 5.03 days.
-- The average duration per term ranged between 4.97 to 5.05 days, suggesting that
-- customer return behaviour was largely consistent regardless of the contractual
-- period.

-- RECOMMENDATION
-- Since the contractual rental rental term shows limited influence n customer
-- behaviour, consider standardising the rental terms to 5 days to simplify policy, or
-- alternatively, introduce a pay-per-day pricing model to better align revenue with
-- actual usage.


