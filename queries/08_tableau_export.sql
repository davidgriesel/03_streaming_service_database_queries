-- ==================================================================================
-- 8. TABLEAU EXPORT
-- ==================================================================================

-- TABLE OF CONTENTS

-- 8.1 - ENRICHED TRANSACTIONAL TABLE

-- ----------------------------------------------------------------------------------
-- 8.1 - ENRICHED TRANSACTIONAL TABLE
-- ----------------------------------------------------------------------------------

CREATE OR REPLACE VIEW enriched_transactional_dataset AS

SELECT
    r.rental_id,
    r.rental_date,
    r.return_date,
    p.payment_id,
    p.amount AS payment_amount,
    p.payment_date,
    
    -- Accrual logic
    CASE
        WHEN p.payment_id IS NOT NULL THEN 'paid'
        ELSE 'accrual'
    END AS payment_status,

    CASE
        WHEN p.payment_id IS NULL THEN
            f.rental_rate +
            CASE
                WHEN r.return_date > r.rental_date + f.rental_duration * INTERVAL '1 day'
                THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
                ELSE 0
            END
        ELSE 0
    END AS accrual_amount,

    COALESCE(p.amount, 0) +
    CASE
        WHEN p.payment_id IS NULL THEN
            f.rental_rate +
            CASE
                WHEN r.return_date > r.rental_date + f.rental_duration * INTERVAL '1 day'
                THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
                ELSE 0
            END
        ELSE 0
    END AS total_revenue,

    -- Customer details
    cu.customer_id,
    cu.first_name AS customer_first_name,
    cu.last_name AS customer_last_name,
    a.address AS customer_address,
    co.country AS customer_country,

    -- Region allocation
CASE
    WHEN co.country IN ('Canada', 'Mexico', 'United States', 'Puerto Rico', 'Virgin Islands, U.S.', 'Saint Vincent and the Grenadines', 'Anguilla') THEN 'North America'
    WHEN co.country IN ('Argentina', 'Bolivia', 'Brazil', 'Chile', 'Colombia', 'Dominican Republic', 'Ecuador', 'Paraguay', 'Peru', 'Venezuela', 'French Guiana') THEN 'Latin America'
    WHEN co.country IN ('Austria', 'Belarus', 'Bulgaria', 'Czech Republic', 'Estonia', 'Faroe Islands', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Italy', 'Latvia', 'Liechtenstein', 'Lithuania', 'Moldova', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Russian Federation', 'Slovakia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom', 'Vatican City', 'Holy See (Vatican City State)', 'Greenland', 'Serbia') THEN 'Europe'
    WHEN co.country IN ('Afghanistan', 'Bahrain', 'Iran', 'Iraq', 'Israel', 'Kuwait', 'Oman', 'Saudi Arabia', 'Syria', 'Turkey', 'United Arab Emirates', 'Yemen', 'Algeria', 'Angola', 'Cameroon', 'Chad', 'Congo, The Democratic Republic of the', 'Egypt', 'Ethiopia', 'Gambia', 'Kenya', 'Madagascar', 'Malawi', 'Morocco', 'Mozambique', 'Nigeria', 'Senegal', 'South Africa', 'Sudan', 'Tanzania', 'Tunisia', 'Zambia', 'Réunion') THEN 'Middle East and Africa'
    WHEN co.country IN ('Armenia', 'Azerbaijan', 'Bangladesh', 'Brunei', 'Cambodia', 'China', 'Hong Kong', 'India', 'Indonesia', 'Japan', 'Kazakhstan', 'Malaysia', 'Myanmar', 'Nepal', 'North Korea', 'Pakistan', 'Philippines', 'South Korea', 'Sri Lanka', 'Taiwan', 'Thailand', 'Turkmenistan', 'Vietnam', 'American Samoa', 'French Polynesia', 'Nauru', 'New Zealand', 'Tonga', 'Tuvalu', 'Australia') THEN 'Asia-Pacific'
    ELSE 'Other'
END AS region,    

    -- Film details
    f.film_id,
    f.title,
    f.release_year,
    f.rental_duration AS rental_term,
    f.rental_rate,
    f.rating,
    l.language,

    -- Category
    cat.category,

    -- Store and staff
    s.store_id,
    st.staff_id,
    st.first_name AS staff_first_name,
    st.last_name AS staff_last_name

FROM rental_clean r
    LEFT JOIN payment_clean p ON r.rental_id = p.rental_id
    LEFT JOIN customer_clean cu ON r.customer_id = cu.customer_id
    LEFT JOIN address_clean a ON cu.address_id = a.address_id
    LEFT JOIN city_clean ci ON a.city_id = ci.city_id
    LEFT JOIN country_clean co ON ci.country_id = co.country_id

    LEFT JOIN inventory_clean i ON r.inventory_id = i.inventory_id
    LEFT JOIN film_clean f ON i.film_id = f.film_id
    LEFT JOIN language_clean l ON f.language_id = l.language_id
    LEFT JOIN film_category_clean fc ON f.film_id = fc.film_id
    LEFT JOIN category_clean cat ON fc.category_id = cat.category_id

    LEFT JOIN store_clean s ON i.store_id = s.store_id
    LEFT JOIN staff_clean st ON r.staff_id = st.staff_id;

-- ----------------------------------------------------------------------------------

-- Check
SELECT COUNT(*),
    SUM(payment_amount) AS paid_revenue,
    SUM(accrual_amount) AS accrued_revenue
FROM enriched_transactional_dataset;

-- INSIGHTS 
-- The number of transactions (15 861), paid revenue (60 784,91) and accrued revenue
-- (6 103,48) agrees to expected values.

-- ----------------------------------------------------------------------------------

-- Export to Tableau
SELECT *
FROM enriched_transactional_dataset;