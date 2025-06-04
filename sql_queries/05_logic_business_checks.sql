-- ==================================================================================
-- 5 - LOGIC AND BUSINESS CHECKS
-- ==================================================================================

-- TABLE OF CONTENTS

-- 5.1 - MANUAL RULE VALIDATIONS
-- 5.1.1 - UNCONSTRAINED KEYS

-- 5.2 - TEMPORAL CHECKS
-- 5.2.1 - RETURN DATES >= RENTAL DATES
-- 5.2.2 - PAYMENT DATES >= RETURN DATES

-- 5.3 - RENTAL CHECKS
-- 5.3.1 - COUNT OF RENTALS BY PAYMENT AND RETURN STATUS
-- 5.3.2 - PAID, RETURNED ON TIME: VERIFY RENTAL RATE
-- 5.3.3 - PAID, RETURNED LATE: VERIFY RENTAL RATE + LATE FEES
-- 5.3.3.1 - REVIEW LATE RETURN WITH ANOMALOUS PAYMENTS
-- 5.3.4 - PAID, NO RETURN DATE: REVIEW LATE FEES AND RELATED PAYMENT BEHAVIOUR
-- 5.3.4.1 - SUMMARISE PAYMENT STATUS OF MISSING RETURNS
-- 5.3.5 – UNPAID RENTALS: CALCULATE TOTAL ACCRUED REVENUE

-- 5.4 - PAYMENT CHECKS
-- 5.4.1 - ORPHANED PAYMENTS
-- 5.4.2 - OUTLIER PAYMENTS (8 records)
-- 5.4.3 - CUSTOMER ID MATCH BETWEEN RENTAL AND PAYMENT

-- ----------------------------------------------------------------------------------
-- 5.1 - MANUAL RULE VALIDATIONS
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 5.1.1 - UNCONSTRAINED KEYS
-- ----------------------------------------------------------------------------------

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

-- ----------------------------------------------------------------------------------
-- 5.2 - TEMPORAL CHECKS
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 5.2.1 - RETURN DATES >= RENTAL DATES
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Identify and quantify any return dates before rental dates

SELECT COUNT(*) AS returns_before_rental
FROM rental
WHERE return_date <= rental_date;

-- INSIGHTS
-- All return dates follow rental dates.

-- ----------------------------------------------------------------------------------
-- 5.2.2 - PAYMENT DATES >= RETURN DATES
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Identify and quantify any payment dates before return dates

SELECT COUNT(*) AS payments_before_rental
FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
WHERE p.payment_date <= r.return_date;

-- INSIGHTS
-- All payment dates follow return dates.

-- ----------------------------------------------------------------------------------
-- 5.3 - RENTAL CHECKS
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 5.3.1 - COUNT OF RENTALS BY PAYMENT AND RETURN STATUS
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Categorise all rental transactions by payment status and return behaviour,
-- including the total amount paid per group.

WITH rental_flags AS (
    SELECT
        r.rental_id,
        CASE
            WHEN r.return_date IS NULL THEN 'No Return Date'
            WHEN r.return_date > r.rental_date + f.rental_duration * INTERVAL '1 day'
                THEN 'Returned Late'
            ELSE 'Returned On Time'
        END AS return_status,
        COUNT(p.payment_id) > 0 AS reflects_payment,
        SUM(p.amount) AS total_payment
    FROM rental r
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
        LEFT JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY r.rental_id, r.return_date, r.rental_date, f.rental_duration
),

summary AS (
    SELECT
        return_status,
        COUNT(*) FILTER (WHERE reflects_payment) AS paid_rentals,
        COUNT(*) FILTER (WHERE NOT reflects_payment) AS unpaid_rentals,
        ROUND(SUM(total_payment), 2) AS total_amount_paid
    FROM rental_flags
    GROUP BY return_status
),

unioned AS (
    SELECT * FROM summary
    UNION ALL
    SELECT
        'Total',
        SUM(paid_rentals),
        SUM(unpaid_rentals),
        ROUND(SUM(total_amount_paid), 2)
    FROM summary
)

SELECT *
FROM unioned
ORDER BY
    CASE return_status
        WHEN 'Returned On Time' THEN 1
        WHEN 'Returned Late' THEN 2
        WHEN 'No Return Date' THEN 3
        WHEN 'Total' THEN 4
    END;

-- INSIGHTS
-- Of the 16,044 rental transactions, 14,592 were paid, generating a total of
-- ¤61,312.04 in revenue.
-- Among paid rentals, 7,012 (¤20,747.88) were returned on time, 7,397 (¤40,045.99)
-- were returned late, and 183 (¤518.17) had no recorded return date.
-- Among the 1,452 unpaid rentals, 728 were returned on time and 724 were returned late.

-- RECOMMENDATION
-- Confirm revenue recognition logic for paid rentals.
-- Raise accruals for the 1,452 unpaid rentals based on established recognition
-- logic.

-- ----------------------------------------------------------------------------------
-- 5.3.2 - PAID, RETURNED ON TIME: VERIFY RENTAL RATE
-- ----------------------------------------------------------------------------------

-- PURPOSE:
-- Confirm that rentals returned on time reflect one payment equal to the base rental
-- rate.

-- Note: Timestamps are cast to dates to enable accurate comparison of rental and
-- return dates in calculations.

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
        r.rental_date::date,
        r.return_date::date,
        ps.payment_count,
        ps.total_payment_amount,
        ps.first_payment_date::date
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE
        r.return_date IS NOT NULL
        AND r.return_date <= (r.rental_date + f.rental_duration * INTERVAL '1 day')
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
ORDER BY
    payment_count DESC,
    amount_difference DESC;

-- INSIGHTS
-- All 7,012 rentals that were returned on time reflect one payment equal to the base
-- rental rate.

-- ----------------------------------------------------------------------------------
-- 5.3.3 - PAID, RETURNED LATE: VERIFY RENTAL RATE + LATE FEES
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Confirm that rentals returned late reflect one payment equal to the base rental
-- rate plus ¤1.00 per day late.

-- Note: Timestamps are cast to dates to enable accurate comparison of rental and
-- return dates in calculations.

WITH payment_summary AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount,
        MIN(payment_date::date) AS first_payment_date
    FROM payment
    GROUP BY rental_id
),

rental_late_days AS (
    SELECT
        r.rental_id,
        f.rental_rate,
        f.rental_duration,
        r.rental_date::date,
        r.return_date::date,
        (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date AS due_date,
        (r.return_date::date - (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date) AS days_late,
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
    days_late,
    payment_count,
    total_payment_amount,
    rental_rate + ROUND(days_late) AS amount_due,
    ROUND(total_payment_amount - (rental_rate + days_late), 2) AS amount_difference,
    first_payment_date
FROM rental_late_days
    WHERE total_payment_amount IS NOT NULL
ORDER BY 
    payment_count DESC,
    amount_difference ASC;

-- INSIGHTS
-- Out of the 7,397 that were returned late, one rental transaction reflects five
-- payment transactions, with a total payment of ¤12.95 exceeding the amount due of
-- ¤3.99 by ¤8.96.
-- The other 7,396 late returns were settled in one payment and match the expected
-- amount due.

-- RECOMMENDATION
-- Investigate the rental transaction that reflects five payments further.

-- ----------------------------------------------------------------------------------
-- 5.3.3.1 - REVIEW LATE RETURN WITH ANOMALOUS PAYMENTS
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Review the rental transaction reflecting multiple payments to investigate why the
-- total amount paid exceeds the expected late fee charge.

-- Note: Timestamps are cast to dates to enable accurate comparison of rental and
-- return dates in calculations.

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
    r.customer_id,
    r.rental_date::date,
    r.return_date::date,
    (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date AS due_date,
    (r.return_date::date - (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date) AS days_late,
    f.rental_rate,
    f.rental_duration,
    f.rental_rate + (r.return_date::date - (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date) AS amount_due,
    p.payment_id,
    p.customer_id,
    p.amount AS payment_amount,
    p.payment_date::date

FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    JOIN payment_counts pc ON r.rental_id = pc.rental_id

WHERE r.return_date IS NOT NULL
    AND r.return_date > (r.rental_date + f.rental_duration * INTERVAL '1 day')

ORDER BY r.rental_id, p.payment_date;

-- INSIGHTS
-- Rental #4591 was returned three days late, resulting in a total charge of ¤3.99
-- (base rate ¤0.99 plus ¤1.00 per day late).
-- One of the linked payments matches both the customer number and the expected
-- amount.
-- Payment #19518, 25162, 29163, and 31834 appear misallocated, suggesting potential
-- manual intervention, system errors, or incorrect adjustmenting journals.

-- RECOMMENDATIONS
-- With accruals raised for any unpaid rentals, misallocated payments can be excluded
-- from downstream analysis.
-- Report misallocated payments to management for further investigation (Reporting).
-- Confirm whether customer id's match between remaining linked rentals and payments.

-- ----------------------------------------------------------------------------------
-- 5.3.4 - PAID, NO RETURN DATE: REVIEW LATE FEES AND RELATED PAYMENT BEHAVIOUR
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Review rental transactions with null return dates including related payments, if
-- any, and flag potential operational inconsistencies.

-- Note: Timestamps are cast to dates to enable accurate comparison of rental and
-- return dates in calculations.

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
        r.rental_date::date,
        r.return_date,
        (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date AS due_date,
        ps.payment_count,
        ps.total_payment_amount,
        (ps.total_payment_amount - f.rental_rate) AS amount_difference,
        ps.first_payment_date::date
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
    WHERE
        r.return_date IS NULL
)

SELECT *

FROM overdue_unreturned_rentals
ORDER BY amount_difference DESC;

-- INSIGHTS
-- All rentals with missing return dates reflect one associated payment.
-- Payment amounts fall into three distinct groups: ¤0.00, equal to the rental rate,
-- and greater than the rental rate.
-- Each rental record and each payment record reflects only one timestamp.
-- This suggests potential manual intervention in closing rentals and processing
-- payments.

-- RECOMMENDATIONS
-- Summarise observed patterns to determine how many cases fall into each category.

-- ----------------------------------------------------------------------------------
-- 5.3.4.1 - SUMMARISE PAYMENT STATUS OF MISSING RETURNS
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Quantify how rental transactions with null return dates were financially resolved
-- to guide downstream analyses.

SELECT
    COUNT(DISTINCT r.rental_id) AS total_unreturned_rentals,

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
-- Of the 183 rental transactions with missing return dates: 135 were fully paid and
-- likely returned on time despite missing return records, 24 reflect overpayments
-- consistent with late fees, and 24 show zero value payments, suggesting possible
-- waived fees.

-- RECOMMENDATIONS
-- Exclude these records from downstream analysis sensitive to return dates.
-- Exclude zero-payment rentals from payment-related analysis.
-- Include fully paid and overpaid rentals in payment-related analyses.
-- Report zero-payment rentals to management to confirm validity (Reporting).

-- ----------------------------------------------------------------------------------
-- 5.3.5 – UNPAID RENTALS: CALCULATE TOTAL ACCRUED REVENUE
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Calculate the total revenue to be accrued for rentals with no associated payments
-- for use as control total, allowing cross-checks in downstream analysis.
-- Note: Timestamps are cast to dates to enable accurate comparison of rental and
-- return dates in calculations.

SELECT
    COUNT(*),
    SUM(
        f.rental_rate +
        CASE
            WHEN r.return_date > r.rental_date + f.rental_duration * INTERVAL '1 day'
            THEN (r.return_date::date - (r.rental_date::date + f.rental_duration))
            ELSE 0
        END
    ) AS total_accrual
FROM rental_clean r
    JOIN inventory_clean i ON r.inventory_id = i.inventory_id
    JOIN film_clean f ON i.film_id = f.film_id
WHERE
    r.rental_id NOT IN (SELECT rental_id FROM payment_clean);

-- INSIGHTS
-- The total expected accrual from unpaid rentals is ¤6,103.48.

-- ----------------------------------------------------------------------------------
-- 5.4 - PAYMENT CHECKS
-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
-- 5.4.1 - ORPHANED PAYMENTS
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Identify and quantify payments that are not linked to existing rentals.

SELECT COUNT(*) AS orphaned_payments
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
WHERE r.rental_id IS NULL;

-- INSIGHTS
-- All payments link to existing rental records.

-- ----------------------------------------------------------------------------------
-- 5.4.2 - OUTLIER PAYMENTS (8 records)
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Explore identified payment records that exceed 3 times the standard deviation from
-- the mean to assess whether they reflect valid charges.

-- Note: Timestamps are cast to dates to enable accurate comparison of rental and
-- return dates in calculations.

WITH payment_summary AS (
    SELECT
        rental_id,
        COUNT(*) AS payment_count,
        SUM(amount) AS total_payment_amount,
        MIN(payment_date::date) AS first_payment_date
    FROM payment
    GROUP BY rental_id
),

rental_late_days AS (
    SELECT
        r.rental_id,
        f.rental_rate,
        f.rental_duration,
        r.rental_date::date,
        r.return_date::date,
        (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date AS due_date,
        (r.return_date::date - (r.rental_date::date + f.rental_duration * INTERVAL '1 day')::date) AS days_late,
        ps.payment_count,
        ps.total_payment_amount,
        ps.first_payment_date
    FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment_summary ps ON r.rental_id = ps.rental_id
)

SELECT
    rental_id,
    rental_rate,
    rental_duration,
    rental_date,
    return_date,
    due_date,
    days_late,
    payment_count,
    total_payment_amount,
    rental_rate + days_late AS amount_due,
    ROUND(total_payment_amount - (rental_rate + days_late), 2) AS amount_difference,
    first_payment_date
FROM rental_late_days
WHERE
    payment_count = 1
    AND total_payment_amount > (
        SELECT AVG(amount) + 3 * STDDEV_POP(amount)
        FROM payment
    )
ORDER BY total_payment_amount DESC
LIMIT 10;

-- INSIGHTS
-- The amount paid in each case equals the rental rate plus ¤1.00 for
-- each day overdue, confirming that these are valid charges that include late fees.

-- ----------------------------------------------------------------------------------
-- 5.4.3 - CUSTOMER ID MATCH BETWEEN RENTAL AND PAYMENT
-- ----------------------------------------------------------------------------------

-- PURPOSE
-- Identify rental transactions where the customer recorded on the rental differs
-- from the customer recorded on the related payment, indicating possible
-- misallocation or manual processing errors.


SELECT
    r.rental_id,
    r.customer_id AS rental_customer_id,
    p.customer_id AS payment_customer_id,
    p.payment_id,
    p.amount,
    p.payment_date::date
FROM rental r
    JOIN payment p ON r.rental_id = p.rental_id
WHERE r.customer_id <> p.customer_id
ORDER BY r.rental_id;

-- INSIGHTS
-- All mismatched customer id's align with the previously identified misallocated
-- payments.

-- RECOMMENDATIONS
-- Adjust downstream views to exclude misallocated payments, as accruals will be
-- raised for the corresponding unpaid rentals.
-- Report these misallocated payments to management for further investigation
-- (Reporting).