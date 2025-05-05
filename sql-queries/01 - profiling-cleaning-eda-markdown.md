# Profiling, Cleaning and EDA

Comprehensive data profiling, structural validation, and basic exploration of the Rockbuster Stealth database.

## Project Files

- [ERD Diagram](./path-to-your-erd-file.png) — Entity Relationship Diagram providing an overview of the database structure.
- [SQL Queries](./profiling-cleaning-eda-queries.sql) — Full SQL script for data validation and profiling.
- [Results (.csv)](./profiling-cleaning-eda-results.csv) — Output tables exported from SQL queries.
- [Report (.xls)](./profiling-cleaning-eda.xlsx) — Consolidated results and observations compiled in Excel.

---

# Table of Contents

1. [Overview of Tables](#1-overview-of-tables)  
2. [Row Counts](#2-row-counts)  
3. [Sample Rows](#3-sample-rows)  
4. [Data Type Validation](#4-data-type-validation)  
5. [Primary Key and Sequence Checks](#5-primary-key-and-sequence-checks)  
6. [Foreign Key Checks](#6-foreign-key-checks)  
7. [Missing Data Checks (Key Variables)](#7-missing-data-checks)  
8. [Duplicates Checks](#8-duplicates-checks)  
9. [Distinct Value Counts (All Variables)](#9-distinct-value-counts-all-variables)  
10. [Frequency Distributions (Categorical Variables)](#10-frequency-distributions-categorical-variables)  
11. [Descriptive Statistics (Numeric Variables)](#11-descriptive-statistics-numeric-variables)  
12. [Temporal Checks](#12-temporal-checks)  
13. [Logic and Dependency Checks](#13-logic-and-dependency-checks)

---

# 1. Overview of Tables

## Objective
Establish the initial structure of the database by identifying all base tables in the `public` schema.
Exclude irrelevant objects such as system tables or views.

## Query
Refer to section 1 of [profiling-cleaning-eda-queries.sql](./profiling-cleaning-eda-queries.sql).

```sql
SELECT 
    table_schema, 
    table_type, 
    table_name
FROM information_schema.tables
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
ORDER BY
    table_name;
```

## Results
15 base tables identified in the public schema.

number|table_schema | table_type | table_name
|:---:|:---:|:---:|:---
|1|public|BASE TABLE|actor
|2|public|BASE TABLE|address
|3|public|BASE TABLE|category
|4|public|BASE TABLE|city
|5|public|BASE TABLE|country
|6|public|BASE TABLE|customer
|7|public|BASE TABLE|film
|8|public|BASE TABLE|film_actor
|9|public|BASE TABLE|film_category
|10|public|BASE TABLE|inventory
|11|public|BASE TABLE|language
|12|public|BASE TABLE|payment
|13|public|BASE TABLE|rental
|14|public|BASE TABLE|staff
|15|public|BASE TABLE|store

*(For full results, see profiling-cleaning-eda-results.csv)*

## Observations
- The table list aligns with the ERD.
- Database structure suggests operational processes centered around rentals, inventory, and customer management.
- Full schema pattern (e.g., star or galaxy schema).

[⬆️ Back to Top](#)

---

# 2. Row Counts

## Objective
Assess the volume of records across all base tables in the `public` schema.  
This provides an initial view of data presence, highlights potential missing data scenarios, and helps prioritise further profiling.

## Query
Refer to Section 2 of [profiling-cleaning-eda-queries.sql](./profiling-cleaning-eda-queries.sql).

```sql
    SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor
    UNION ALL
    SELECT 'address', COUNT(*) FROM address
    UNION ALL
    SELECT 'category', COUNT(*) FROM category
    UNION ALL
    SELECT 'city', COUNT(*) FROM city
    UNION ALL
    SELECT 'country', COUNT(*) FROM country
    UNION ALL
    SELECT 'customer', COUNT(*) FROM customer
    UNION ALL
    SELECT 'film', COUNT(*) FROM film
    UNION ALL
    SELECT 'film_actor', COUNT(*) FROM film_actor
    UNION ALL
    SELECT 'film_category', COUNT(*) FROM film_category
    UNION ALL
    SELECT 'inventory', COUNT(*) FROM inventory
    UNION ALL
    SELECT 'language', COUNT(*) FROM language
    UNION ALL
    SELECT 'payment', COUNT(*) FROM payment
    UNION ALL
    SELECT 'rental', COUNT(*) FROM rental
    UNION ALL
    SELECT 'staff', COUNT(*) FROM staff
    UNION ALL
    SELECT 'store', COUNT(*) FROM store;
```

## Results
- 15 tables counted:

table_name|row_count
:---:|:---:
actor|200
address|603
category|16
city|600
country|109
customer|599
film|1000
film_actory|5462
film_category|1000
inventory|4581
language|6
payment|14596
rental|16044
staff|2
store|2

*(Full results also exported to profiling-cleaning-eda-results.csv.)*

## Observations
- **Customer vs Address mismatch:**  
  There are 599 customers but 603 addresses — a difference of 4 records.  
  A likely explanation is that the two stores and two staff members also have address records linked to them.  
  This will be confirmed in later dependency checks (Section 13).

- **Rental vs Payment mismatch:**  
  There are 16,044 rentals but only 14,596 payments.  
  This suggests that some rentals were not paid for — potentially due to late returns, lost rentals, or operational delays.

- **Small dimension tables:**  
  Staff and Store tables each contain only 2 records, indicating a small operational footprint or a sample dataset.

- **Reference (lookup) tables:**  
  Language (6 rows) and Category (16 rows) contain small, static lists, typical for reference data.

## Notes
- No tables were found empty — confirming that all listed tables are populated with operational data.
- High volume tables (e.g., film_actor, rental) will require extra care during profiling for performance.

[⬆️ Back to Top](#)

---

# 3. Sample Rows

## Objective
Retrieve a small sample of records from each base table in the `public` schema.  
This helps to:
- Familiarise with table structures and field types.
- Spot obvious anomalies (e.g., unexpected NULLs, strange formats).
- Identify early potential quality issues before deeper profiling.

## Query
Refer to Section 3 of [profiling-cleaning-eda-queries.sql](./profiling-cleaning-eda-queries.sql).

```sql
SELECT * FROM actor LIMIT 5;
SELECT * FROM address LIMIT 5;
SELECT * FROM category LIMIT 5;
SELECT * FROM city LIMIT 5;
SELECT * FROM country LIMIT 5;
SELECT * FROM customer LIMIT 5;
SELECT * FROM film LIMIT 5;
SELECT * FROM film_actor LIMIT 5;
SELECT * FROM film_category LIMIT 5;
SELECT * FROM inventory LIMIT 5;
SELECT * FROM language LIMIT 5;
SELECT * FROM payment LIMIT 5;
SELECT * FROM rental LIMIT 5;
SELECT * FROM staff LIMIT 5;
SELECT * FROM store LIMIT 5;
```

## Results
Sampled 5 rows from each table.

*(For full results, see profiling-cleaning-eda-results.csv)*

## Observations
- Sample rows confirm that tables are structured according to the ERD with appropriate data types and field names.
- No unexpected corruption or format issues observed in the samples.
- Some expected NULL values were noted in optional fields (`address2` in `address`, `picture` in `staff`).
- Field naming conventions (snake_case) are consistent across all tables.
- Business patterns appear logical (e.g., 2 staff and 2 stores support previous hypotheses about address counts).
- Special types (`special_features` array, `fulltext` tsvector) exist but are as expected.

## Notes
- Further profiling will verify missing data, sequence integrity, and value distributions in detail.
- Temporal fields (`last_update`) seem populated mostly with 2006 dates — timeline coherence will be checked in temporal validations.

[⬆️ Back to Top](#)

---

# 4. Data Type Validation

## Objective
Formally validate the data types assigned to all columns in the `public` schema tables.  
Although data types are visible during casual queries, this structured extraction ensures:
- Systematic documentation,
- Quality control against unexpected type mismatches,
- Easier future audits and version tracking.

## Query
Refer to Section 4 of [profiling-cleaning-eda-queries.sql](./profiling-cleaning-eda-queries.sql).

```sql
SELECT 
    c.table_name,
    c.column_name,
    c.data_type
FROM 
    information_schema.columns c
JOIN 
    information_schema.tables t
    ON c.table_schema = t.table_schema
    AND c.table_name = t.table_name
WHERE 
    c.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    c.data_type;
```

## Results
- 86 columns validated across 15 tables.
- Data types include integers, smallints, character varying (varchar), text, boolean, numeric, timestamps, arrays, user-defined types, and tsvector fields.
- Full details exported to profiling-cleaning-eda-results.csv.

Example of returned columns:
table_name|column_name|data_type
:---:|:---:|:---
film|special_features|ARRAY
film|rating|USER-DEFINED
customer|activebool|boolean
staff|active|boolean
staff|picture|bytea
language|name|character
address|postal_code|character varying
payment|amount|numeric
rental|return_date|timestamp without time zone

*(Full list available in linked CSV.)*

## Observations
- **Standard types dominate:**
  Most columns use conventional types such as integer, smallint, character varying, and timestamp.
- **Special types noted:**
  special_features field in film table uses an ARRAY — expected for storing multiple feature tags.
  rating field in film table is USER-DEFINED — likely due to a custom enum for MPAA ratings.
  fulltext field in film uses tsvector — internally supports text search functionality.
  picture field in staff uses bytea — supports storing binary image data.
- **Data type consistency:**
  No major anomalies observed (e.g., no unexpected casting of IDs to strings, or missing types).

## Notes
- The presence of non-standard types (ARRAY, USER-DEFINED, tsvector) will require minor special handling when profiling contents or exporting datasets.
- timestamp without time zone is consistently used across date/time fields, suggesting local time zone settings apply — worth noting for any future time zone-sensitive analyses.

[⬆️ Back to Top](#)

---

# 5. Primary Key and Sequence Checks

# 5. Primary Key Checks

## Objective
Confirm that all expected primary key fields are structurally sound by checking:
- Presence (no NULLs)
- Uniqueness (no duplicates)
- Proper relational linking in composite key tables

## Approach
- Queried the information schema to detect formally declared primary keys.
- Manually validated NULLs and duplicates for all key candidate fields.
- Validated composite key integrity for link tables (`film_actor`, `film_category`).

### Query
Refer to Section 5 of [SQL query here](./profiling-cleaning-eda-queries.sql)

```sql
-- Check if primary keys exist
SELECT 
    tc.table_name, 
    kcu.column_name, 
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.key_column_usage AS kcu
ON 
    tc.constraint_name = kcu.constraint_name
WHERE 
    tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
ORDER BY 
    tc.table_name, kcu.column_name;

-- Check for NULLs in primary key columns
SELECT 'actor' AS table_name, 'actor_id' AS primary_key, COUNT(*) AS null_count FROM actor WHERE actor_id IS NULL
UNION ALL
SELECT 'address', 'address_id', COUNT(*) FROM address WHERE address_id IS NULL
-- (...continued for all 13 tables...)

-- Check for duplicates in primary key columns
SELECT 1 AS sort_order, 'actor' AS table_name, 'actor_id' AS primary_key, COUNT(*) AS duplicate_count FROM  actor GROUP BY actor_id HAVING COUNT(*) > 1
UNION ALL
SELECT 2, 'address', 'address_id', COUNT(*) FROM address GROUP BY address_id HAVING COUNT(*) > 1
ORDER BY sort_order;
-- (...continued for all 13 tables...)

-- Check for NULLs across composite keys
SELECT 'film_actor' AS table_name, COUNT(*) AS null_count
FROM film_actor
WHERE actor_id IS NULL OR film_id IS NULL
UNION ALL
SELECT 'film_category', COUNT(*) 
FROM film_category
WHERE film_id IS NULL OR category_id IS NULL;

-- Check for duplicates across composite keys
SELECT 'film_actor' AS table_name, COUNT(*) - COUNT(DISTINCT actor_id || '-' || film_id) AS duplicate_count
FROM film_actor
UNION ALL
SELECT 'film_category', COUNT(*) - COUNT(DISTINCT film_id || '-' || category_id)
FROM film_category;
```

## Results
- No formal PRIMARY KEY constraints declared in the database.
- No NULLs found in any primary key candidate columns.
- No duplicates found in any primary key candidate columns.
- No NULLs found across composite key fields.
- No duplicates found across composite key pairings.

## Observations
- Despite the absence of formal primary key constraints, manual validation confirms that all key fields behave correctly.
- Link tables (`film_actor`, `film_category`) maintain proper composite key integrity.
- No immediate corrective action required.

## Notes
- Key columns will be briefly included in numeric summary statistics for range analysis later (to visually confirm ID behaviour).
- Sequence gaps are not evaluated here, as minor gaps are expected due to deletions or operational flows and are not critical for this project.

[⬆️ Back to Top](#)

---

# 6. Foreign Key Checks

## Objective
Verify that all foreign key relationships maintain referential integrity:
- Confirm whether formal foreign key constraints exist.
- Manually validate that child records correctly link to parent records.

## Approach
- Queried the information schema to check for formal foreign key constraints.
- Where no constraints were found, performed manual validation:
  - Used `LEFT JOIN` queries to detect any orphaned child records missing parent links.
  - Aggregated results for each foreign key relationship.

### Query
Refer to Section 6 of [SQL query here](./profiling-cleaning-eda-queries.sql)

```sql
-- Check foreign key constraints in the database
SELECT
    tc.table_name AS child_table,
    kcu.column_name AS child_column,
    ccu.table_name AS parent_table,
    ccu.column_name AS parent_column,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN 
    information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE 
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY 
    child_table, child_column;

-- Check if foreign keys link to valid parent records

-- TABLE: address
SELECT 1 AS sort_order, 'address' AS table_name, 'city_id' AS secondary_key, COUNT(*) AS missing_key_count
FROM address a
LEFT JOIN city c ON a.city_id = c.city_id
WHERE c.city_id IS NULL

UNION ALL

-- TABLE: city
SELECT 2, 'city', 'country_id', COUNT(*)
FROM city ci
LEFT JOIN country co ON ci.country_id = co.country_id
WHERE co.country_id IS NULL

-- (...continued for 21 checks...)

ORDER BY sort_order;
```

### Results
- No formal foreign key constraints found in the database.
- Manual checks confirmed no missing references in any relationship.
- 21 foreign key checks were performed across key tables.
- All missing_key_count values were zero.

### Observations
- Referential integrity appears to have been maintained through application logic or controlled imports.
- No immediate corrective action required.
- Foreign key validations will not need to be repeated unless the underlying data changes.

[⬆️ Back to Top](#)

---

# 7. Missing Data Checks (Key Variables)

## Objective
Identify and assess missing data across key business variables:
- Focus on columns where missingness would significantly impact analysis.
- Prioritise columns that are marked as allowing NULLs in the schema.

## Approach
- Queried `information_schema.columns` to identify all nullable fields in major tables.
- Selected key business-critical fields for targeted NULL count checks:
  - `customer.active`
  - `film.length`
  - `film.rating`
  - `film.release_year`
  - `rental.return_date`
- Reviewed NULL counts to assess data quality.

## Query
Refer to Section 7 of [SQL query here](./profiling-cleaning-eda-queries.sql)

```sql
-- Identify columns that allow NULL values
SELECT 
    table_name,
    column_name, 
    is_nullable 
FROM information_schema.columns
WHERE table_name IN(
    'actor', 'address', 'category', 'city', 'country', 
    'customer', 'film', 'film_actor', 'film_category', 
    'inventory', 'language', 'payment', 'rental', 'staff', 'store'
)
AND is_nullable = 'YES'
ORDER BY table_name, column_name;

-- Check key columns that allow NULLs

-- TABLE: customer
SELECT 'customer' AS table_name, 'active' AS column_name, COUNT(*) AS missing_count
FROM customer
WHERE active IS NULL

UNION ALL

-- TABLE: film
SELECT 'film', 'length', COUNT(*) FROM film WHERE length IS NULL
UNION ALL
SELECT 'film', 'rating', COUNT(*) FROM film WHERE rating IS NULL
UNION ALL
SELECT 'film', 'release_year', COUNT(*) FROM film WHERE release_year IS NULL

UNION ALL

-- TABLE: rental
SELECT 'rental', 'return_date', COUNT(*) FROM rental WHERE return_date IS NULL

ORDER BY table_name, column_name;
```

### Results
- 14 columns across tables allow NULLs.
- No missing values found in:
  customer.active
  film.length
  film.rating
  film.release_year
- 183 missing values found in rental.return_date.

### Observations
- `rental.return_date` missing values likely correspond to rentals that have not yet been returned.
- No major data quality concerns detected for customer or film attributes.
- Rental return dates will need to be considered carefully in any time-based or financial analysis.

[⬆️ Back to Top](#)

---

# 8. Duplicates Checks

## Objective
To identify potential duplicate records across key tables.

## Approach
- Queried the tables to count duplicates based on business-relevant fields.
- Summarised duplicate counts across all major tables.
- Investigated duplicate records in detail where they were identified.
- Created a clean VIEW for the actor table to remove confirmed duplicate entries while preserving data integrity.
- Validated the clean dataset by re-checking duplicate counts and row numbers.

Notes:
- inventory table duplicates are expected as multiple copies of the same film can exist per store.
- film_actor and film_category tables were excluded from duplicate checking here because composite primary keys were already validated separately and duplication is not expected beyond that.

## Query
Refer to Section 8 of [SQL query here](./profiling-cleaning-eda-queries.sql)

``` sql
-- Summary of duplicate counts by table
SELECT 1 AS sort_order, 'actor' AS table_name, COUNT(*) AS duplicate_count
FROM (
    SELECT first_name, last_name
    FROM actor
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
) AS dup
UNION ALL
SELECT 2, 'address', COUNT(*)
FROM (
    SELECT address, address2, district, city_id, postal_code, phone
    FROM address
    GROUP BY address, address2, district, city_id, postal_code, phone
    HAVING COUNT(*) > 1
) AS dup
UNION ALL
...
ORDER BY sort_order;

-- View duplicate rows in actor table
SELECT *
FROM actor
WHERE (first_name, last_name) IN (
    SELECT first_name, last_name
    FROM actor
    GROUP BY first_name, last_name
    HAVING COUNT(*) > 1
);

-- Create clean view for actor table
CREATE OR REPLACE VIEW clean_actor AS
SELECT *
FROM actor
WHERE actor_id NOT IN (
    SELECT actor_id
    FROM (
        SELECT actor_id,
               ROW_NUMBER() OVER (PARTITION BY first_name, last_name ORDER BY actor_id) AS rn
        FROM actor
    ) AS numbered
    WHERE rn > 1
);

-- Check counts
SELECT 'actor' AS table_name, COUNT(*) AS row_count FROM actor;
SELECT 'clean_actor' AS table_name, COUNT(*) AS row_count FROM clean_actor;
```

## Results
- 1 duplicate found in the actor table.
- 1521 duplicates found in the inventory table (expected).

All other tables returned zero duplciate counts

## Observations
- No action required for inventory.
- Duplicate actor record successfully handled by creating a cleaned view clean_actor.
- Validation queries confirmed successful removal of duplicates.

## Notes
- Future analysis will be based on the cleaned view where applicable.
- No destructive deletion was performed to preserve original data integrity.

[⬆️ Back to Top](#)

---

## 9. Distinct Value Counts (All Variables)

### Objective
Measure cardinality — the number of unique values in each column.

### Query
Refer to Section 9 of [SQL query here](./profiling-cleaning-eda-queries.sql)

### Results
- ...

### Observations
- ...

[⬆️ Back to Top](#)

---

## 10. Frequency Distributions (Categorical Variables)

### Objective
Analyse the frequency and balance of distinct categorical values.

### Query
Refer to Section 10 of [SQL query here](./profiling-cleaning-eda-queries.sql)

### Results
- ...

### Observations
- ...

[⬆️ Back to Top](#)

---

## 11. Descriptive Statistics (Numeric Variables)

### Objective
Provide descriptive statistics for numeric fields, including distribution analysis and outlier detection.

### Query
Refer to Section 11 of [SQL query here](./profiling-cleaning-eda-queries.sql)

### Subsections:
- ### 11.1 Summary Statistics
  - Mean, median, min, max, standard deviation.
- ### 11.2 Distributions
  - Shape analysis: normality, skewness, heavy tails.
- ### 11.3 Outlier Detection
  - Identification of extreme or anomalous values.

### Results
- ...

### Observations
- ...

[⬆️ Back to Top](#)

---

## 12. Temporal Checks

### Objective
Validate time fields (e.g., rental dates, return dates); detect logical issues like future dates or mis-sequenced timestamps.

### Query
Refer to Section 12 of [SQL query here](./profiling-cleaning-eda-queries.sql)

### Results
- ...

### Observations
- ...

[⬆️ Back to Top](#)

---

## 13. Logic and Dependency Checks

### Objective
Confirm that dependent fields logically align based on business rules.

### Query
Refer to Section 13 of [SQL query here](./profiling-cleaning-eda-queries.sql)

### Results
- ...

### Observations
- ...

[⬆️ Back to Top](#)

---



