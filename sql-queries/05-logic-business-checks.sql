-- ================================================================================
-- 5 - LOGIC AND BUSINESS CHECKS
-- ================================================================================

-- TABLE OF CONTENTS

-- 5.1 - MANUAL RULE VALIDATIONS
-- 5.1.1 - UNCONSTRAINED KEYS

-- 5.2 - TEMPORAL CHECKS
-- 5.2.1 - RETURN DATES <= RENTAL DATES
-- 5.2.1.1 - IDENTIFY ANY RETURN DATES <= RENTAL DATES

-- 5.2.2 - PAYMENT DATES <= RETURN DATES
-- 5.2.2.1 - IDENTIFY ANY PAYMENT DATES <= RETURN DATES

-- 5.2.3 - LATE RETURNS
-- 5.2.3.1 - IDENTIFY ANY LATE RETURNS
-- 5.2.3.2 - COUNT PAID VS UNPAID LATE RETURNS
-- 5.2.3.3 - EXPLORE LATE RETURNS WITH PAYMENTS
-- 5.2.3.4 - REVIEW LATE RETURN WITH AMOMALOUS PAYMENTS
-- 5.2.3.5 - SUMMARISE PAYMENT STATUS OF LATE RETURNS WITH PAYMENTS

-- 5.2.4 - MISSING RETURN DATES FOLLOW-UP (183 records)
-- 5.2.4.1 - EXPLORE MISSING RETURN DATES
-- 5.2.4.2 - SUMMARISE PAYMENT STATUS OF MISSING RETURNS

-- 5.3 - RENTAL CHECKS
-- 5.3.1 - COUNT PAID VS UNPAID RENTALS
-- 5.3.2 - EXPLORE PAID RENTALS

-- 5.4 - PAYMENT CHECKS
-- 5.4.1 - ORPHANED PAYMENTS
-- 5.4.1.1 - IDENTIFY ORPHANED PAYMENTS

-- 5.4.2 - OUTLIER PAYMENTS (8 records)
-- 5.4.2.1 - EXPLORE OUTLIER PAYMENTS 

-- --------------------------------------------------------------------------------
-- 5.1 - MANUAL RULE VALIDATIONS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.1.1 - UNCONSTRAINED KEYS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Manually verify whether all store_id values in related tables have a matching 
-- entry in the store table.

    SELECT
        'customer' AS table_name,
        'store_id' AS foreign_key,
        COUNT(*) AS orphaned_keys
    FROM customer
        LEFT JOIN store ON customer.store_id = store.store_id
    WHERE store.store_id IS NULL

    UNION ALL
    
    SELECT
        'inventory' AS table_name,
        'store_id' AS foreign_key,
        COUNT(*) AS orphaned_keys
    FROM inventory
        LEFT JOIN store ON inventory.store_id = store.store_id
    WHERE store.store_id IS NULL
    
    UNION ALL
    
    SELECT
        'staff' AS table_name,
        'store_id' AS foreign_key,
        COUNT(*) AS orphaned_keys
    FROM staff
        LEFT JOIN store ON staff.store_id = store.store_id
    WHERE store.store_id IS NULL;

-- INSIGHTS
-- All store_id values in customer, inventory, and staff tables link to valid
-- entries in the store table.

-- --------------------------------------------------------------------------------
-- 5.2 - TEMPORAL CHECKS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.2.1 - RETURN DATES <= RENTAL DATES
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.2.1.1 - IDENTIFY ANY RETURN DATES <= RENTAL DATES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Confirm that all returns occur on or after the corresponding rental date. 

SELECT COUNT(*) AS invalid_return_dates
FROM rental
WHERE return_date <= rental_date;

-- INSIGHTS
-- No invalid return dates were identified.

-- --------------------------------------------------------------------------------
-- 5.2.2 - PAYMENT DATES <= RETURN DATES
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.2.2.1 - IDENTIFY ANY PAYMENT DATES <= RETURN DATES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Confirm that all payments occur on or after the corresponding return date.

SELECT COUNT(*) AS payments_before_rental
FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
WHERE p.payment_date <= r.return_date;

-- INSIGHTS
-- No invalid payments were found.

-- --------------------------------------------------------------------------------
-- 5.2.3 - LATE RETURNS
-- --------------------------------------------------------------------------------
-- 5.2.3.1 - IDENTIFY ANY LATE RETURNS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Determine the number of rentals that were returned after the allowed rental
-- duration, based on the rental start time and the film’s allowed rental period.
-- 
    SELECT COUNT(*) AS late_return_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    WHERE r.return_date IS NOT NULL
        AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day');

-- INSIGHTS
-- A total of 8,121 rentals were returned after their due time, exceeding the 
-- allowed rental duration.

-- --------------------------------------------------------------------------------
-- 5.2.3.2 - COUNT PAID VS UNPAID LATE RETURNS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Examine payment records associated with late returns to determine how many rentals
-- were followed by one or more payments, and how many remain unpaid.

WITH payment_summary AS (
    SELECT
        rental_id,
        SUM(amount) AS total_payment
    FROM payment
    GROUP BY rental_id
),

late_rentals AS (
    SELECT
        r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day') AS is_late,
        ps.total_payment
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE r.return_date IS NOT NULL
)

SELECT
    COUNT(*) FILTER (WHERE is_late) AS total_late_returns,
    COUNT(*) FILTER (WHERE is_late AND total_payment IS NULL) AS late_returns_unpaid,
    COUNT(*) FILTER (WHERE is_late AND total_payment IS NOT NULL) AS late_returns_paid
FROM late_rentals;

-- INSIGHTS
-- Of the 8,121 late returns, 7,397 have associated payments, while 724 show no
-- corresponding payment records.

-- --------------------------------------------------------------------------------
-- 5.2.3.3 - EXPLORE LATE RETURNS WITH PAYMENTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Examine late returns followed by on or more payments by recalculating the amount
-- due based on the rental rate and the number of days late, and comparing the
-- results to the amount paid.

WITH payment_summary AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount,
        MIN(payment_date) AS first_payment_date
    FROM payment
    GROUP BY rental_id
),

rental_late_days AS (
    SELECT
        r.rental_id,
        f.rental_rate,
        f.rental_duration,
        r.rental_date,
        r.return_date,
        (r.rental_date + f.rental_duration * INTERVAL '1 day') AS due_date,
        ROUND(EXTRACT(EPOCH FROM (r.return_date - (r.rental_date + f.rental_duration * INTERVAL '1 day'))) / 86400, 2) AS days_late_precise,
        ps.payment_count,
        ps.total_payment_amount,
        ps.first_payment_date
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE
        r.return_date IS NOT NULL
        AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
)

SELECT
    rental_id,
    rental_rate,
    rental_duration,
    rental_date,
    return_date,
    due_date,
    days_late_precise,
    ROUND(days_late_precise) AS days_late_rounded,
    payment_count,
    total_payment_amount,
    rental_rate + ROUND(days_late_precise) AS amount_due,
    ROUND(total_payment_amount - (rental_rate + ROUND(days_late_precise)), 2) AS amount_difference,
    first_payment_date
FROM rental_late_days
WHERE total_payment_amount IS NOT NULL
ORDER BY amount_difference ASC;

-- INSIGHTS
-- One rental is linked to 5 payment transactions and the amount paid exceeds the
-- expected amount due by 8,96.
-- All other payments have one associated payment and fall within one unit of the
-- expected amount due returning a difference of either -1, 0, or 1.
-- This suggests that all late returns have been charged one unit per day late, with
-- the only variation being in how partial days are handled — either rounded up to
-- the next day or ignored unless a full day has elapsed.

-- RECOMMENDATION
-- Review the one late return with five associated payment transactions, which shows
-- an amount paid significantly above the expected total (Refer 5.2.3.4).
-- Summarise observed results (Refer 5.2.3.5).

-- --------------------------------------------------------------------------------
-- 5.2.3.4 - REVIEW LATE RETURN WITH AMOMALOUS PAYMENTS
-- --------------------------------------------------------------------------------

-- PUPOSE
-- Examine the late return with an unusually high number of associated payments.

WITH payment_counts AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count
    FROM payment
    GROUP BY rental_id
    HAVING COUNT(*) > 1
)

SELECT
    r.rental_id,
    f.rental_rate,
    f.rental_duration,
    r.rental_date,
    r.return_date,
    (r.rental_date + f.rental_duration * INTERVAL '1 day') AS due_date,
    ROUND(EXTRACT(EPOCH FROM (r.return_date - (r.rental_date + f.rental_duration * INTERVAL '1 day'))) / 86400, 2) AS days_late_precise,
    ROUND(EXTRACT(EPOCH FROM (r.return_date - (r.rental_date + f.rental_duration * INTERVAL '1 day'))) / 86400) AS days_late_rounded,
    f.rental_rate + ROUND(EXTRACT(EPOCH FROM (r.return_date - (r.rental_date + f.rental_duration * INTERVAL '1 day'))) / 86400) AS amount_due,
    p.payment_id,
    p.amount AS payment_amount,
    p.payment_date

FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    JOIN payment_counts pc ON r.rental_id = pc.rental_id

WHERE r.return_date IS NOT NULL
    AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')

ORDER BY r.rental_id, p.payment_date;

-- INSIGHTS
-- Rental 4591 was returned three days late, resulting in an expected charge of 3,99
-- (base rental rate of €0.99 plus three late days at 1.00 per day).
-- This rental is linked to five separate payments, all recorded on the same day: one
-- for 0.99, two for 1.99, and two for 3.99.
-- While the total paid exceeds the expected amount, the presence of split payments
-- in mixed amounts suggests a potential manual billing adjustment or system anomaly.

-- --------------------------------------------------------------------------------
-- 5.2.3.5 - SUMMARISE PAYMENT STATUS OF LATE RETURNS WITH PAYMENTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Summarise late returns followed by one or more payments based on observed payment
-- behaviour.

WITH payment_summary AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount
    FROM payment
    GROUP BY rental_id
),

rental_late_days AS (
    SELECT
        f.rental_rate,
        ROUND(EXTRACT(EPOCH FROM (r.return_date - (r.rental_date + f.rental_duration * INTERVAL '1 day'))) / 86400, 2) AS days_late_precise,
        payment_count,
        ps.total_payment_amount
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE
        r.return_date IS NOT NULL
        AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
)

SELECT
    ROUND(total_payment_amount - (rental_rate + ROUND(days_late_precise)), 2) AS amount_difference,
    payment_count,
    COUNT(*) AS record_count
FROM rental_late_days
WHERE total_payment_amount IS NOT NULL
GROUP BY
    amount_difference,
    payment_count
ORDER BY
    amount_difference,
    payment_count;

-- INSIGHTS
-- Of all late returns followed by payment, all but one involved a single payment
-- transaction.
-- The amount paid in these cases was either exactly equal to (6465), one unit more
-- than (501), or one unit less than the expected amount (430) based on rental rate
-- plus one unit per day late — suggesting a consistent fee structure with minor
-- variation in how partial days are charged.
-- The outlier involved five separate payments and a total amount difference of
-- 8.96, suggesting either a billing anomaly or a possible data entry error.

-- --------------------------------------------------------------------------------
-- 5.2.4 - MISSING RETURN DATES FOLLOW-UP (183 records)
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.2.4.1 - EXPLORE MISSING RETURN DATES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Explore all rental transactions with missing return dates including associated
-- payment details to assess whether these transactions are incomplete or financially
-- closed.

WITH payment_summary AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount,
        MIN(payment_date) AS first_payment_date
    FROM payment
    GROUP BY rental_id
),

overdue_unreturned_rentals AS (
    SELECT
        r.rental_id,
        f.rental_rate,
        f.rental_duration,
        r.rental_date,
        r.return_date,
        (r.rental_date + f.rental_duration * INTERVAL '1 day') AS due_date,
        ps.payment_count,
        ps.total_payment_amount,
        (f.rental_rate - ps.total_payment_amount) AS amount_difference,
        ps.first_payment_date
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE
        r.return_date IS NULL
        AND (r.rental_date + f.rental_duration * INTERVAL '1 day') < NOW()
)

SELECT *

FROM overdue_unreturned_rentals
ORDER BY amount_difference DESC;

-- INSIGHTS
-- All rental transactions have an associated payment that either reflect zero-value
-- payments, full settlement of the rental rate, or payments exceeding the set rate.
-- ALL rental and payment transactions appear to occurr on singular isolated dates
-- identified during frequency distribution analysis under quality checks.

-- RECOMMENDATIONS
-- Summarise observed results (Refer 5.2.4.2).

-- --------------------------------------------------------------------------------
-- 5.2.4.2 - SUMMARISE PAYMENT STATUS OF MISSING RETURNS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Summarise how rentals without return dates were financially resolved based on 
-- prior observations, including full payments, zero-value charges, and charges
-- exceeding set rental rates.

SELECT
    COUNT(DISTINCT r.rental_id) AS total_unreturned_rentals,

    COUNT(*) FILTER (
        WHERE ROUND(p.amount, 2) = ROUND(f.rental_rate, 2)
    ) AS full_payment_count,

    COUNT(*) FILTER (
        WHERE p.amount = 0
    ) AS zero_payment_count,

    COUNT(*) FILTER (
        WHERE ROUND(p.amount, 2) > ROUND(f.rental_rate, 2)
    ) AS overpayment_count

FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    
WHERE r.return_date IS NULL;

-- INSIGHTS
-- Of the 183 rentals with missing return dates, 24 were closed with zero-value
-- payments, 24 were closed with payments that exceed the set rental rate, and the
-- remaining 135 were all closed with full settlement of the rental rate.
-- In the absence of additional business context, flag all transactions as
-- financially closed.
-- If further investigation is required, patterns may be explored by comparing
-- payment behaviour across attributes such as store, staff, customer region, or
-- film category to identify any operational logic.

-- --------------------------------------------------------------------------------
-- 5.3 - RENTAL CHECKS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.3.1 - COUNT PAID VS UNPAID RENTALS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Examine payment records associated with rentals to determine how many rentals
-- were followed by one or more payments, and how many remain unpaid.

SELECT
    COUNT(*) AS total_rentals,
    COUNT(*) FILTER (WHERE p.payment_id IS NOT NULL) AS rentals_with_payments,
    COUNT(*) FILTER (WHERE p.payment_id IS NULL) AS rentals_without_payments
FROM rental r
    LEFT JOIN payment p ON r.rental_id = p.rental_id;

-- INSIGHTS
-- Out of 16,048 rental transactions, 14,596 have corresponding payments, while
-- 1,452 cannot be linked to any payment records.
-- Of the 14,596 paid rentals, 7,397 are linked to late returns (Refer 5.2.3.2), and
-- 183 are linked to null return dates (Refer 5.2.4.2).

-- RECOMMENDATIONS
-- Remove those transactions already explored from further exploration.

-- --------------------------------------------------------------------------------
-- 5.3.2 - EXPLORE PAID RENTALS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify and evaluate rental transactions that were returned on time and have
-- associated payment records. 

WITH payment_summary AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount,
        MIN(payment_date) AS first_payment_date
    FROM payment
    GROUP BY rental_id
),

rental_late_days AS (
    SELECT
        r.rental_id,
        f.rental_rate,
        f.rental_duration,
        r.rental_date,
        r.return_date,
        ps.payment_count,
        ps.total_payment_amount,
        ps.first_payment_date
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE
        r.return_date IS NOT NULL -- filter out 183 transactions with null return dates (refer 5.2.4)
        AND r.return_date <= (r.rental_date + f.rental_duration * INTERVAL '1 day') -- filter out 7,397 transactions returned late (refer 5.2.3.2)
)

SELECT
    rental_id,
    rental_rate,
    rental_duration,
    rental_date,
    return_date,
    payment_count,
    total_payment_amount,
    ROUND(total_payment_amount - rental_rate, 2) AS amount_difference,
    first_payment_date
FROM rental_late_days
WHERE total_payment_amount IS NOT NULL
ORDER BY amount_difference DESC;

-- INSIGHTS
-- All rentals that were returned on time were fully paid, with no outstanding
-- amounts. 

-- --------------------------------------------------------------------------------
-- 5.4 - PAYMENT CHECKS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.4.1 - ORPHANED PAYMENTS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.4.1.1 - IDENTIFY ORPHANED PAYMENTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify payments that are not linked to existing rentals.

SELECT COUNT(*) AS orphaned_payments
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
WHERE r.rental_id IS NULL;

-- INSIGHTS
-- No orphaned payments were found.

-- --------------------------------------------------------------------------------
-- 5.4.2 - OUTLIER PAYMENTS (8 records)
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 5.4.2.1 - EXPLORE OUTLIER PAYMENTS 
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Explore payment records that exceed 3 times the standard deviation from the mean
-- to assess whether they reflect valid charges such as late return penalties or are
-- potential anomalies.

WITH payment_summary AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount,
        MIN(payment_date) AS first_payment_date
    FROM payment
    GROUP BY rental_id
),

rental_late_days AS (
    SELECT
        r.rental_id,
        f.rental_rate,
        f.rental_duration,
        r.rental_date,
        r.return_date,
        (r.rental_date + f.rental_duration * INTERVAL '1 day') AS due_date,
        ROUND(EXTRACT(EPOCH FROM (r.return_date - (r.rental_date + f.rental_duration * INTERVAL '1 day'))) / 86400, 2) AS days_late_precise,
        ps.payment_count,
        ps.total_payment_amount,
        ps.first_payment_date
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE
        r.return_date IS NOT NULL
        AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')
)

SELECT
    rental_id,
    rental_rate,
    rental_duration,
    rental_date,
    return_date,
    due_date,
    days_late_precise,
    ROUND(days_late_precise) AS days_late_rounded,
    payment_count,
    total_payment_amount,
    rental_rate + ROUND(days_late_precise) AS amount_due,
    ROUND(total_payment_amount - (rental_rate + ROUND(days_late_precise)), 2) AS amount_difference,
    first_payment_date
FROM rental_late_days
WHERE
    total_payment_amount IS NOT NULL
    AND payment_count = 1
    AND total_payment_amount > (
        SELECT AVG(amount) + 3 * STDDEV_POP(amount)
        FROM payment
    )
ORDER BY total_payment_amount DESC
LIMIT 10;

-- INSIGHTS
-- The amount paid in each case equals the rental rate plus the sum of 1 unit for
-- each overdue day, suggesting that these are valid and include late fees.