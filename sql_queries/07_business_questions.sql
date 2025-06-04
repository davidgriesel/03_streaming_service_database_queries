-- ==================================================================================
-- 7. BUSINESS QUESTIONS
-- ==================================================================================

-- TABLE OF CONTENTS

-- 7.1 - QUESTION 1: Which movies contributed the most/least to revenue gain?
-- 7.2 - QUESTION 2: What was the average rental duration for all videos?
-- 7.3 - QUESTION 3: Which countries are customers based in?
-- 7.4 - QUESTION 4: Where are customers with a high lifetime value based?
-- 7.5 - QUESTION 5: Do sales figures vary between geographic regions?
-- 7.6 - CATALOGUE
-- 7.7 - CUSTOMER BASE

-- ----------------------------------------------------------------------------------
-- 7.1 - QUESTION 1: Which movies contributed the most/least to revenue gain?
-- ----------------------------------------------------------------------------------

-- STEP 1: Identify total revenue contribution per movie.

-- PURPOSE
-- Generate a complete list of all films with total revenue calculated on an accrual
-- basis, sorted from highest to lowest performing titles.

    -- Paid revenue
    WITH paid_revenue AS (
        SELECT
            f.film_id,
            f.title,
            p.amount AS revenue
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
            JOIN payment_clean p ON r.rental_id = p.rental_id
        WHERE
            p.amount <> 0 -- exclude 24 records with null return_date that have zero value payments
    ),

    accrued_revenue AS (
        SELECT
            f.film_id,
            f.title,
            f.rental_rate +
                CASE WHEN r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
                    THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
                    ELSE 0
                END AS revenue
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
        WHERE
            r.rental_id NOT IN (SELECT rental_id FROM payment_clean)
    )

    SELECT
        film_id,
        title,
        ROUND(SUM(revenue), 2) AS total_revenue
    FROM (
        SELECT * FROM paid_revenue
        UNION ALL
        SELECT * FROM accrued_revenue
    ) combined
    GROUP BY film_id, title
    ORDER BY total_revenue DESC;

-- INSIGHTS
-- All 958 titles in inventory contributed to revenue (Refer 3.4).
-- There are clear leaders in top 5 revenue positions.
-- The bottom 5 revenue positions are shared amongst 7 titles.

-- ----------------------------------------------------------------------------------

-- STEP 2: Retrieve the top 5 highest grossing movies.

-- PURPOSE
-- Identify the 5 most profitable films by total revenue contribution.

    -- Paid revenue
    WITH paid_revenue AS (
        SELECT
            f.film_id,
            f.title,
            p.amount AS revenue
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
            JOIN payment_clean p ON r.rental_id = p.rental_id
        WHERE
            p.amount <> 0 -- exclude 24 records with null return_date that have zero value payments
    ),

    accrued_revenue AS (
        SELECT
            f.film_id,
            f.title,
            f.rental_rate +
                CASE WHEN r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
                    THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
                    ELSE 0
                END AS revenue
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
        WHERE
            r.rental_id NOT IN (SELECT rental_id FROM payment_clean)
    )

    SELECT
        film_id,
        title,
        ROUND(SUM(revenue), 2) AS total_revenue
    FROM (
        SELECT * FROM paid_revenue
        UNION ALL
        SELECT * FROM accrued_revenue
    ) combined
    GROUP BY film_id, title
    ORDER BY total_revenue DESC
    LIMIT 5;

-- INSIGHTS
-- The top 5 revenue-generating films were:
-- 1. Telegraph Voyage
-- 2. Wife Turn
-- 3. Zorro Ark
-- 4. Goodfellas Salute
-- 5. Saturday Lambs

-- ----------------------------------------------------------------------------------

-- STEP 3: Retrieve the 7 titles contributing to the bottom 5 revenue positions.

-- PURPOSE
-- Identify the 7 least profitable films by total rental revenue contribution that
-- share the bottom 5 positions.

    -- Paid revenue
    WITH paid_revenue AS (
        SELECT
            f.film_id,
            f.title,
            p.amount AS revenue
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
            JOIN payment_clean p ON r.rental_id = p.rental_id
        WHERE
            p.amount <> 0 -- exclude 24 records with null return_date that have zero value payments
    ),

    -- Accrued revenue
    accrued_revenue AS (
        SELECT
            f.film_id,
            f.title,
            f.rental_rate +
                CASE WHEN r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
                    THEN (r.return_date - (r.rental_date + f.rental_duration))
                    ELSE 0
                END AS revenue
        FROM film_clean f
            JOIN inventory_clean i ON f.film_id = i.film_id
            JOIN rental_clean r ON i.inventory_id = r.inventory_id
        WHERE
            r.rental_id NOT IN (SELECT rental_id FROM payment_clean)
    )

    SELECT
        film_id,
        title,
        ROUND(SUM(revenue), 2) AS total_revenue
    FROM (
        SELECT * FROM paid_revenue
        UNION ALL
        SELECT * FROM accrued_revenue
    ) combined
    GROUP BY film_id, title
    ORDER BY total_revenue ASC
    LIMIT 7;

-- INSIGHTS
-- The films contributing least to revenue, ordered by revenue bracket, were:
-- 1. Texas Watch, Oklahoma Jumanji
-- 2. Freedom Cleopatra
-- 3. Duffel Apocalypse, Young Language
-- 4. Rebel Airport
-- 5. Cruelty Unforgiven

-- ----------------------------------------------------------------------------------
-- 7.2 - QUESTION 2: What was the average rental duration for all videos?
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Calculate the minimum, maximum, and average actual rental durations for all
-- rentals with recorded return dates.

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
        r.return_date IS NOT NULL; -- exclude 183 rentals with NULL return dates

-- INSIGHTS
-- Among the 15,861 rentals with recorded return dates, the actual rental duration ranged
-- between 0 to 10 days with an overall average of 5.03 days.

-- ----------------------------------------------------------------------------------
-- 7.3 - QUESTION 3: Which countries are customers based in?
-- ----------------------------------------------------------------------------------

-- STEP 1: Calculate the number of customers and total revenue per country.

-- PURPOSE
-- Generate a list of the number of customers by country, along with total revenue,
-- sorted from highest to lowest customer count.
 
    -- Paid revenue
    WITH paid_revenue AS (
        SELECT
            cu.customer_id,
            SUM(p.amount) AS revenue
        FROM payment_clean p
            JOIN customer_clean cu ON p.customer_id = cu.customer_id
        WHERE
            p.amount <> 0 -- 24 rentals with null return dates reflecting zero value payments
        GROUP BY cu.customer_id
    ),

    -- Accrued revenue
    accrued_revenue AS (
        SELECT
            cu.customer_id,
            SUM(
                f.rental_rate +
                CASE
                    WHEN r.return_date > r.rental_date + f.rental_duration * INTERVAL '1 day'
                    THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
                    ELSE 0
                END
            ) AS revenue
        FROM rental_clean r
            JOIN inventory_clean i ON r.inventory_id = i.inventory_id
            JOIN film_clean f ON i.film_id = f.film_id
            JOIN customer_clean cu ON r.customer_id = cu.customer_id
        WHERE
            r.rental_id NOT IN (SELECT rental_id FROM payment_clean)
        GROUP BY cu.customer_id
    ),

    combined_revenue AS (
        SELECT customer_id, revenue FROM paid_revenue
        UNION ALL
        SELECT customer_id, revenue FROM accrued_revenue
    ),

    customer_country AS (
        SELECT
            cr.customer_id,
            SUM(cr.revenue) AS revenue,
            co.country
        FROM combined_revenue cr
            JOIN customer_clean cu ON cr.customer_id = cu.customer_id
            JOIN address_clean a ON cu.address_id = a.address_id
            JOIN city_clean ci ON a.city_id = ci.city_id
            JOIN country_clean co ON ci.country_id = co.country_id
        GROUP BY cr.customer_id, co.country
    )

    SELECT
        country,
        COUNT(*) AS customer_count,
        ROUND(SUM(revenue), 2) AS total_revenue
    FROM customer_country
    GROUP BY country
    ORDER BY customer_count DESC
    LIMIT 10;

-- INSIGHTS
-- Customers are located across 108 countries.
-- The customer base is concentrated in a small number of countries with most having
-- less than 10 customers.
-- Countries with larger customer bases also tend to generate higher total revenue, 
-- suggesting a correlation between customer count and revenue.

-- ----------------------------------------------------------------------------------
-- 7.4 - QUESTION 4: Where are customers with a high lifetime value based?
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Identify the countries associated with the highest average customer lifetime value
-- using the accrual base of accounting.

WITH combined_revenue AS (
    -- Paid revenue
    SELECT
        cu.customer_id,
        SUM(p.amount) AS revenue
    FROM payment_clean p
    JOIN customer_clean cu ON p.customer_id = cu.customer_id
    WHERE p.amount <> 0
    GROUP BY cu.customer_id

    UNION ALL

    -- Accrued Revenue
    SELECT
        cu.customer_id,
        SUM(
            f.rental_rate +
            CASE
                WHEN r.return_date > r.rental_date + f.rental_duration * INTERVAL '1 day'
                THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
                ELSE 0
            END
        ) AS revenue
    FROM rental_clean r
        JOIN inventory_clean i ON r.inventory_id = i.inventory_id
        JOIN film_clean f ON i.film_id = f.film_id
        JOIN customer_clean cu ON r.customer_id = cu.customer_id
    WHERE r.rental_id NOT IN (SELECT rental_id FROM payment_clean)
    GROUP BY cu.customer_id
),

country_revenue AS (
    SELECT
        co.country,
        COUNT(DISTINCT cr.customer_id) AS customer_count,
        SUM(cr.revenue) AS total_revenue
    FROM combined_revenue cr
        JOIN customer_clean cu ON cr.customer_id = cu.customer_id
        JOIN address_clean a ON cu.address_id = a.address_id
        JOIN city_clean ci ON a.city_id = ci.city_id
        JOIN country_clean co ON ci.country_id = co.country_id
    GROUP BY co.country
)

SELECT
    country,
    customer_count,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_revenue / customer_count, 2) AS avg_lifetime_value
FROM country_revenue
ORDER BY avg_lifetime_value DESC
LIMIT 10;

-- INSIGHTS
-- The top-ranking countries by average customer lifetime value were:
-- 1. Reunion
-- 2. Holy See (Vatican City State)
-- 3. Nauru
-- 4. Sweden
-- 5. Hong Kong

-- ----------------------------------------------------------------------------------
-- 7.5 - QUESTION 5: Do sales figures vary between geographic regions?
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Compare revenue performance across geographic regions by aggregating customer 
-- lifetime value per continent using the accrual basis of accounting.

    WITH combined_revenue AS (
        -- Paid revenue
        SELECT
            cu.customer_id,
            SUM(p.amount) AS revenue
        FROM payment_clean p
            JOIN customer_clean cu ON p.customer_id = cu.customer_id
        WHERE p.amount <> 0
        GROUP BY cu.customer_id

        UNION ALL

        -- Accrued Revenue
        SELECT
            cu.customer_id,
            SUM(
                f.rental_rate +
                CASE
                    WHEN r.return_date > r.rental_date + f.rental_duration * INTERVAL '1 day'
                    THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
                    ELSE 0
                END
            ) AS revenue
        FROM rental_clean r
            JOIN inventory_clean i ON r.inventory_id = i.inventory_id
            JOIN film_clean f ON i.film_id = f.film_id
            JOIN customer_clean cu ON r.customer_id = cu.customer_id
        WHERE r.rental_id NOT IN (SELECT rental_id FROM payment_clean)
        GROUP BY cu.customer_id
    ),

    country_revenue AS (
        SELECT
            co.country,
            COUNT(DISTINCT cr.customer_id) AS customer_count,
            SUM(cr.revenue) AS total_revenue
        FROM combined_revenue cr
            JOIN customer_clean cu ON cr.customer_id = cu.customer_id
            JOIN address_clean a ON cu.address_id = a.address_id
            JOIN city_clean ci ON a.city_id = ci.city_id
            JOIN country_clean co ON ci.country_id = co.country_id
        GROUP BY co.country
    )

    SELECT
        continent,
        ROUND(SUM(revenue), 0) AS total_revenue,
        COUNT(*) AS customer_count,
        ROUND(AVG(revenue), 0) AS avg_lifetime_value
    FROM (
        SELECT
            cr.customer_id,
            SUM(cr.revenue) AS revenue,
    CASE
        WHEN co.country IN ('Canada', 'Mexico', 'United States', 'Puerto Rico', 'Virgin Islands, U.S.', 'Saint Vincent and the Grenadines', 'Anguilla') THEN 'North America'
        WHEN co.country IN ('Argentina', 'Bolivia', 'Brazil', 'Chile', 'Colombia', 'Dominican Republic', 'Ecuador', 'Paraguay', 'Peru', 'Venezuela', 'French Guiana') THEN 'Latin America'
        WHEN co.country IN ('Austria', 'Belarus', 'Bulgaria', 'Czech Republic', 'Estonia', 'Faroe Islands', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Italy', 'Latvia', 'Liechtenstein', 'Lithuania', 'Moldova', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Russian Federation', 'Slovakia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom', 'Vatican City', 'Holy See (Vatican City State)', 'Greenland', 'Serbia') THEN 'Europe'
        WHEN co.country IN ('Afghanistan', 'Bahrain', 'Iran', 'Iraq', 'Israel', 'Kuwait', 'Oman', 'Saudi Arabia', 'Syria', 'Turkey', 'United Arab Emirates', 'Yemen', 'Algeria', 'Angola', 'Cameroon', 'Chad', 'Congo, The Democratic Republic of the', 'Egypt', 'Ethiopia', 'Gambia', 'Kenya', 'Madagascar', 'Malawi', 'Morocco', 'Mozambique', 'Nigeria', 'Senegal', 'South Africa', 'Sudan', 'Tanzania', 'Tunisia', 'Zambia', 'Réunion') THEN 'Middle East and Africa'
        WHEN co.country IN ('Armenia', 'Azerbaijan', 'Bangladesh', 'Brunei', 'Cambodia', 'China', 'Hong Kong', 'India', 'Indonesia', 'Japan', 'Kazakhstan', 'Malaysia', 'Myanmar', 'Nepal', 'North Korea', 'Pakistan', 'Philippines', 'South Korea', 'Sri Lanka', 'Taiwan', 'Thailand', 'Turkmenistan', 'Vietnam', 'American Samoa', 'French Polynesia', 'Nauru', 'New Zealand', 'Tonga', 'Tuvalu', 'Australia') THEN 'Asia-Pacific'
        ELSE 'Other'
    END AS region
        END AS continent
        FROM combined_revenue cr
            JOIN customer_clean cu ON cr.customer_id = cu.customer_id
            JOIN address_clean a ON cu.address_id = a.address_id
            JOIN city_clean ci ON a.city_id = ci.city_id
            JOIN country_clean co ON ci.country_id = co.country_id
        GROUP BY cr.customer_id, co.country
    ) regional
    GROUP BY continent
    ORDER BY total_revenue DESC;

-- INSIGHTS
-- Sales figures vary significantly by region with Asia having generated the highest
-- total revenue at ¤30,719.32.
-- Despite significantly lower total revenue, Africa showed the highest average
-- customer lifetime  value at ¤114.76, indicating fewer but potentially more engaged
-- or higher-spending customers.
-- Oceania had the lowest customer count and total revenue.

-- ----------------------------------------------------------------------------------
-- 7.6 - CATALOGUE
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Summarise the diversity of titles available in active inventory by counting
-- distinct values across key catalogue dimensions.

SELECT 'Total titles in inventory' AS metric, COUNT(DISTINCT f.film_id)::TEXT AS value
FROM film_clean f
    JOIN inventory_clean i ON f.film_id = i.film_id

UNION ALL

SELECT 'Number of languages', COUNT(DISTINCT f.language_id)::TEXT
FROM film_clean f
    JOIN inventory_clean i ON f.film_id = i.film_id

UNION ALL

SELECT 'Number of release years', COUNT(DISTINCT f.release_year)::TEXT
FROM film_clean f
    JOIN inventory_clean i ON f.film_id = i.film_id

UNION ALL

SELECT 'Number of categories', COUNT(DISTINCT fc.category_id)::TEXT
FROM film_clean f
    JOIN inventory_clean i ON f.film_id = i.film_id
    JOIN film_category fc ON f.film_id = fc.film_id

UNION ALL

SELECT 'Number of ratings', COUNT(DISTINCT f.rating)::TEXT
FROM film_clean f
    JOIN inventory_clean i ON f.film_id = i.film_id;

-- INSIGHTS
-- The film catalogue consists of 958 titles in inventory, all in one language and
-- released in the same year, spanning 16 categories, and with 5 ratings.

-- ----------------------------------------------------------------------------------
-- 7.7 - CUSTOMER BASE
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Quantify the size and geographical spread of the customer base.

SELECT
    'Total customers' AS metric,
    COUNT(*)::TEXT AS value
FROM customer_clean

UNION ALL

SELECT
    'Number of Countries',
    COUNT(DISTINCT co.country)::TEXT
FROM customer_clean cu
    JOIN address_clean a ON cu.address_id = a.address_id
    JOIN city_clean ci ON a.city_id = ci.city_id
    JOIN country_clean co ON ci.country_id = co.country_id

UNION ALL

SELECT
    'Nuber of Cities',
    COUNT(DISTINCT ci.city)::TEXT
FROM customer_clean cu
    JOIN address_clean a ON cu.address_id = a.address_id
    JOIN city_clean ci ON a.city_id = ci.city_id;

-- INSIGHTS
-- The customer base consists of 599 customers, across 108 countries, and in 597
-- different cities.