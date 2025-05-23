-- ================================================================================
-- 5. LOGIC AND BUSINESS CHECKS
-- ================================================================================

-- TABLE OF CONTENTS

-- 5.1 MANUAL RULE VALIDATIONS
-- 5.1.1 UNCONSTRAINED KEYS

-- 5.2 PROFILING & QUALITY FOLLOWING UPS
    -- 5.2.1 MISSING RETURN DATES (183 records)
        -- 5.2.1.1 EXPLORE MISSING RETURN DATES
        -- 5.2.1.2 SUMMARISE PAYMENT STATUS FOR MISSING RETURNS
    -- 5.2.3 OUTLIER PAYMENTS (8 records)
        -- 5.2.3.1 EXPLORE OUTLIER PAYMENTS 

-- 5.3 TEMPORAL LOGIC CHECKS
    -- 5.3.1 CONFIRM IF RETURN DATES FOLLOW RENTAL DATES
    -- 5.3.2 CONFIRM IF PAYMENT DATES FOLLOW RENTAL DATES

-- 5.4 BUSINESS RULE CHECKS
    -- 5.4.1 IDENTIFY ORPHANED PAYMENTS
    -- 5.4.2 IDENTIFY RENTALS WITH NO PAYMENTS
    -- 5.4.3 IDENTIFY LATE RETURNS
    -- 5.4.4 EXPLORE LATE RETURNS

-- 5.5 IDENTIFY PAYMENT DISCREPANCIES

-- ================================================================================
-- 5.1 UNCONSTRAINED KEYS
-- ================================================================================
-- ================================================================================
-- ================================================================================

-- --------------------------------------------------------------------------------
-- 5.1 UNCONSTRAINED KEYS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Manually verify whether all store_id values in related tables have a matching 
-- entry in the store table.
--
    SELECT 'customer' AS table_name, 'store_id' AS foreign_key, COUNT(*) AS orphaned_keys
    FROM customer
    LEFT JOIN store ON customer.store_id = store.store_id
    WHERE store.store_id IS NULL
    UNION ALL
    SELECT 'inventory' AS table_name, 'store_id' AS foreign_key, COUNT(*) AS orphaned_keys
    FROM inventory
    LEFT JOIN store ON inventory.store_id = store.store_id
    WHERE store.store_id IS NULL
    UNION ALL
    SELECT 'staff' AS table_name, 'store_id' AS foreign_key, COUNT(*) AS orphaned_keys
    FROM staff
    LEFT JOIN store ON staff.store_id = store.store_id
    WHERE store.store_id IS NULL;

-- INSIGHTS
-- All store_id values in customer, inventory, and staff tables link to valid
-- entries in the store table.

-- --------------------------------------------------------------------------------
-- 5.2.1 EXPLORE MISSING RETURN DATES (183 records)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Explore all rental transactions with missing return dates and associated payment
-- details to assess whether these transactions are incomplete or financially 
-- closed.
--
    SELECT
        r.rental_id,
        f.title AS film_title,
        f.rental_rate,
        f.rental_duration,
        r.rental_date::date,
        (r.rental_date + f.rental_duration * INTERVAL '1 day')::date AS due_date,
        r.return_date::date,
        p.payment_id,
        p.amount AS payment_amount,
        ROUND(p.amount - f.rental_rate, 2) AS amount_difference,
        p.payment_date::date
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE return_date IS NULL
    ORDER BY amount_difference;

-- INSIGHTS
-- Rental transactions with missing return dates show a mix of payment behaviours, 
-- including zero-value payments, full settlement at the rental rate, and 
-- overpayments likely due to late fees.
-- 182 of the 183 transactions with missing return dates correspond to isolated 
-- rental and payment dates previously identified in the frequency distribution 
-- analysis.

-- RECOMMENDATIONS
-- Summarise observed payment behaviours to determine if there are any unresolved
-- transactions with missing return dates.

-- --------------------------------------------------------------------------------
-- 5.2.2 SUMMARISE PAYMENT STATUS FOR MISSING RETURNS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Summarise how rentals without return dates were financially resolved by analysing 
-- payment behaviour, including full payments, zero-value charges, and potential 
-- late fees.
--
    SELECT
        COUNT(*) FILTER (
            WHERE p.amount = 0
        ) AS zero_payment_count,

        COUNT(*) FILTER (
            WHERE ROUND(p.amount, 2) = ROUND(f.rental_rate, 2)
        ) AS full_payment_count,

        COUNT(*) FILTER (
            WHERE ROUND(p.amount, 2) > ROUND(f.rental_rate, 2)
        ) AS overpayment_count
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE r.return_date IS NULL;

-- INSIGHTS
-- The distribution confirms that all transactions with missing return dates are
-- financially accounted for and do not represent unresolved rentals.
-- While 135 transactions were paid in full, 24 include overpayments consistent with
-- late fees, and 24 were closed with zero-value charges.

-- RECOMMENDATION
-- In the absence of additional business context, flag all transactions with null 
-- return dates as financially closed. If further investigation is required, 
-- patterns may be explored by comparing payment behaviour across attributes such as 
-- store, staff, customer region, or film category to identify any operational logic.

-- --------------------------------------------------------------------------------
-- 5.3 EXPLORE OUTLIER PAYMENTS (8 records)
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Explore payment records that significantly exceed the average amount to assess 
-- whether they reflect valid charges such as late return penalties or are potential
-- anomalies.
--
    SELECT
        r.rental_id,
        f.title AS film_title,
        f.rental_rate,
        f.rental_duration,
        r.rental_date::date,
        (r.rental_date + f.rental_duration * INTERVAL '1 day')::date AS due_date,
        r.return_date::date,
        (r.return_date::date - (r.rental_date + f.rental_duration * INTERVAL '1 day')::date) AS days_late,
        p.payment_id,
        p.amount AS payment_amount,
        ROUND(p.amount - f.rental_rate, 2) AS amount_difference,
        p.payment_date::date
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE p.amount > (
        SELECT AVG(amount) + 3 * STDDEV_POP(amount)
        FROM payment
    )
    ORDER BY p.amount DESC;

-- INSIGHTS
-- The amount paid in each case equals the rental rate plus a flat fee of 1 unit for
-- each overdue day, confirming that these charges are valid.

-- --------------------------------------------------------------------------------
-- 5.4 CONFIRM IF RETURN DATES FOLLOW RENTAL DATES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Confirm that all returns occur on or after the corresponding rental date. 
-- 
    SELECT COUNT(*) AS invalid_return_dates
    FROM rental
    WHERE return_date < rental_date;

-- INSIGHTS
-- No invalid return dates were identified.

-- --------------------------------------------------------------------------------
-- 5.5 CONFIRM IF PAYMENT DATES FOLLOW RENTAL DATES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Confirm that all payments occur on or after the corresponding rental date.
--
    SELECT COUNT(*) AS payments_before_rental
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    WHERE p.payment_date < r.rental_date;

-- INSIGHTS
-- No invalid payments were found.

-- --------------------------------------------------------------------------------
-- 5.6 IDENTIFY ORPHANED PAYMENTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify payments that are not linked to existing rentals.
--
    SELECT COUNT(*) AS orphaned_payments
    FROM payment p
    LEFT JOIN rental r ON p.rental_id = r.rental_id
    WHERE r.rental_id IS NULL;

-- INSIGHTS
-- No orphaned payments were found.






-- --------------------------------------------------------------------------------
-- 5.7 IDENTIFY RENTALS WITH NO PAYMENTS
-- --------------------------------------------------------------------------------

-- PURPOSE
--


-- INSIGHTS
--

-- --------------------------------------------------------------------------------
-- 5.8 IDENTIFY LATE RETURNS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Determine whether any rentals exceed the allowed rental duration.
-- 
    SELECT COUNT(*) AS late_return_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    WHERE r.return_date IS NOT NULL
        AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day');

-- INSIGHTS
-- A total of 8121 rentals exceeded the allowed rental duration.

-- --------------------------------------------------------------------------------
-- 5.8.1 EXPLORE LATE RETURNS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- 
    SELECT
            r.rental_id,
            f.title AS film_title,
            f.rental_rate,
            f.rental_duration,
            r.rental_date::date,
            (r.rental_date + f.rental_duration * INTERVAL '1 day')::date AS due_date,
            r.return_date::date,
            (r.return_date::date - (r.rental_date + f.rental_duration * INTERVAL '1 day')::date) AS days_late,
            p.payment_id,
            p.amount AS payment_amount,
            ROUND(p.amount - f.rental_rate, 2) AS amount_difference,
            p.payment_date::date
        FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment p ON r.rental_id = p.rental_id -- 14596 payments vs 16044 rentals
        WHERE r.return_date IS NOT NULL
            AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
        LIMIT 10; 


-- --------------------------------------------------------------------------------
-- 5.9 IDENTIFY PAYMENT DISCREPANCIES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify payments that deviate from standard rental charges.
--
    SELECT
        COUNT(*) FILTER (WHERE ROUND(p.amount, 2) > ROUND(f.rental_rate, 2)) AS payments_above_rate,
        COUNT(*) FILTER (WHERE ROUND(p.amount, 2) < ROUND(f.rental_rate, 2)) AS payments_below_rate
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE r.return_date IS NOT NULL;




    SELECT
        r.rental_id,
        r.rental_date,
        r.return_date,
        f.rental_rate,
        f.rental_duration,
        p.payment_id,
        p.amount
    FROM rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        JOIN payment p ON r.rental_id = p.rental_id
        WHERE 
            r.return_date IS NOT NULL
            AND 
            p.amount > f.rental_rate;

-- INSIGHTS
-- There are 6,646 payments exceeding the standard rental rate, and 24 falling
-- below it.

-- --------------------------------------------------------------------------------
-- 5.# EXPLORE LATE RETURN CHARGES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Examine late return cases to identify whether a consistent charge pattern is
-- applied when rentals exceed the allowed duration.
--
    SELECT
        r.rental_id,
        r.rental_date,
        r.return_date,
        f.rental_duration,
        (r.rental_date + f.rental_duration * INTERVAL '1 day')::date AS expected_return_date,
        (r.return_date::date - (r.rental_date + f.rental_duration * INTERVAL '1 day')::date) AS days_late,
        f.rental_rate,
        p.amount AS paid_amount,
        ROUND(p.amount - f.rental_rate, 2) AS amount_difference
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
    LIMIT 20;

-- INSIGHTS
-- Each late return appears to incur an additional fee of one unit per day.

-- --------------------------------------------------------------------------------
-- 5.# RE-EVALUATE VALID PAYMENTS TAKING LATE FEES INTO CONSIDERATION
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify payments that deviate from standard rental charges.
--
    SELECT
        COUNT(*) FILTER (
            WHERE ROUND(p.amount, 2) > ROUND(f.rental_rate + GREATEST((r.return_date::date - (r.rental_date + f.rental_duration * INTERVAL '1 day')::date), 0), 2)
        ) AS payments_above_expected,
        
        COUNT(*) FILTER (
            WHERE ROUND(p.amount, 2) < ROUND(f.rental_rate + GREATEST((r.return_date::date - (r.rental_date + f.rental_duration * INTERVAL '1 day')::date), 0), 2)
        ) AS payments_below_expected
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE r.return_date IS NOT NULL;

    SELECT
        COUNT(*) AS matching_late_fee_pattern
    FROM (
        SELECT
            r.rental_id,
            (r.return_date::date - (r.rental_date + f.rental_duration * INTERVAL '1 day')::date) AS days_late,
            ROUND(p.amount - f.rental_rate, 2) AS amount_difference
        FROM rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        JOIN payment p ON r.rental_id = p.rental_id
        WHERE r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
    ) sub
    WHERE amount_difference = days_late;

-- 7398

-- Include columns allowing NULLs with operational information for logic and
-- dependency checks (Refer 3.1).####
-- Validate the zero values and outliers in the payment.amount column (Refer 3.6).####



-- Remove address.address2 and staff.picture
-- Impute empty strings with placeholder values in address.district, address.phone,
-- address.postal_code
-- Remove duplicates in actor table
-- Remove timestamp and status columns
-- Cast timestamp columns tracking operational activity to date.`


--
    SELECT
        r.rental_id,
        f.rental_rate,
        p.amount AS paid_amount
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE ROUND(p.amount, 2) <> ROUND(f.rental_rate, 2)
    LIMIT 10;


    SELECT
        r.rental_id,
        f.title,
        r.rental_date::date,
        r.return_date::date,
        f.rental_duration,
        f.rental_rate,
        p.amount AS paid_amount,
        CASE 
            WHEN r.return_date IS NOT NULL AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day') 
                THEN TRUE ELSE FALSE 
        END AS returned_late,
        CASE 
            WHEN ROUND(p.amount, 2) = ROUND(f.rental_rate, 2) 
                THEN FALSE ELSE TRUE 
        END AS payment_mismatch
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN payment p ON r.rental_id = p.rental_id
    ORDER BY r.rental_id
    LIMIT 10;



    SELECT
        p.payment_id,
        p.rental_id,
        p.amount AS payment_amount,
        f.rental_rate AS expected_rental_rate,
        CASE
            WHEN p.amount = f.rental_rate THEN 'Correct'
            ELSE 'Incorrect'
        END AS payment_status
    FROM
        payment p
    JOIN
        rental r ON p.rental_id = r.rental_id
    JOIN
        inventory i ON r.inventory_id = i.inventory_id
    JOIN
        film f ON i.film_id = f.film_id;

