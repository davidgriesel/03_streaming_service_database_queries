-- ================================================================================
-- 2 - INTEGRITY CHECKS
-- ================================================================================

-- TABLE OF CONTENTS

-- 2.1 - DATA TYPES

-- 2.2 - CONSTRAINTS
-- 2.2.1 - PRIMARY KEY CONSTRAINTS
-- 2.2.2 - FOREIGN KEY CONSTRAINTS
-- 2.2.3 - NOT NULL CONSTRAINTS
-- 2.2.4 - UNIQUE CONSTRAINTS
-- 2.2.5 - CHECK CONSTRAINTS
-- 2.2.6 - DEFAULT VALUES

-- 2.3 - USER_DEFINED TYPES
-- 2.3.1 - CLASSIFY USER-DEFINED TYPES
-- 2.3.2 - RETRIEVE ENUMERATED VALUE SETS

-- --------------------------------------------------------------------------------
-- 2.1 - DATA TYPES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Validate data types across all columns of all base tables to ensure consistency
-- with content and compatibility in downstream analysis.

SELECT 
    c.table_name,
    c.column_name,
    c.data_type
FROM 
    information_schema.columns AS c
JOIN 
    information_schema.tables AS t
    ON c.table_schema = t.table_schema
    AND c.table_name = t.table_name
WHERE 
    c.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    c.data_type;

-- INSIGHTS
-- Most columns are of type smallint, integer, character varying, or timestamp.
-- Timestamp columns are typical system-generated columns tracking database updates.
-- A single column uses date (customer.create_date) while the rest all use full
-- timestamps.
-- One column (language.name) uses character rather than character varying like the
-- rest.
-- One column normally associated with boolean (customer.active) uses integer while
-- there is already a boolean column in the table.
-- Columns with less common or unusual data types include ARRAY 
-- (film.special_features), bytea (staff.picture), and tsvector (film.full_text).
-- One column (film.rating) with USER-DEFINED data type.

-- RECOMMENDATIONS
-- Cast retained timestamp columns to date where time-level precision is not
-- required (Refer 6.1).
-- Cast columns of type character to varchar to prevent padding and standardise
-- formats for analysis(Refer 6.1).
-- Review column normally associated with boolean for binary logic, compare to
-- boolean column, and remove if having similar functions (Refer 3.4 | 3.5).
-- Remove columns with unusual or complex data types not needed in the analysis
-- (Refer 6.1).
-- Confirm the actual data type of the user-defined column (Refer 2.3).

-- --------------------------------------------------------------------------------
-- 2.2 - CONSTRAINTS
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 2.2.1 - PRIMARY KEY CONSTRAINTS
-- --------------------------------------------------------------------------------
    
-- PURPOSE
-- Identify all primary key constraints (including composite keys) across base
-- tables to validate that each table has a unique identifier.

SELECT 
    tc.table_name,
    string_agg(kcu.column_name, ', ') AS primary_key_columns,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN 
    information_schema.tables AS t
    ON tc.table_schema = t.table_schema
    AND tc.table_name = t.table_name
WHERE 
    tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
GROUP BY 
    tc.table_name, tc.constraint_name
ORDER BY 
    tc.table_name;

-- INSIGHTS
-- All tables have a defined primary key with two being composite keys.

-- --------------------------------------------------------------------------------
-- 2.2.2 - FOREIGN KEY CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify foreign key relationships in all base tables to confirm whether
-- referential integrity is enforced to prevent invalid entries.

SELECT
    tc.table_name AS table_name,
    kcu.column_name AS foreign_key_column,
    ccu.table_name AS parent_table,
    ccu.column_name AS parent_column,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN 
    information_schema.constraint_column_usage AS ccu
    ON tc.constraint_name = ccu.constraint_name
    AND tc.table_schema = ccu.table_schema
JOIN 
    information_schema.tables AS t
    ON tc.table_schema = t.table_schema
    AND tc.table_name = t.table_name
WHERE 
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    tc.table_name, kcu.column_name;

-- INSIGHTS
-- Foreign key relationships are defined in 18 instances linking child tables to the
-- respective reference tables.
-- No relationships were defined to link the customer, inventory, and staff tables
-- to the store table via store_id.

-- RECOMMENDATIONS
-- Manually validate integrity for store_id columns where constraints are absent
-- (Refer 5.1.1).

-- --------------------------------------------------------------------------------
-- 2.2.3 - NOT NULL CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify columns that allow NULLs across al base tables to isolate columns for
-- targeted checks.

SELECT 
    c.table_name,
    c.column_name,
    c.is_nullable
FROM 
    information_schema.columns AS c
INNER JOIN 
    information_schema.tables AS t
    ON c.table_schema = t.table_schema
    AND c.table_name = t.table_name
WHERE 
    c.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    c.is_nullable;

-- INSIGHTS
-- 72 columns are not nullable.
-- 14 columns are declared nullable.

-- RECOMMENDATIONS
-- Perform targeted null profiling for columns that are nullable (Refer 3.1).

-- --------------------------------------------------------------------------------
-- 2.2.4 - UNIQUE CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Check for columns explicitly constrained to hold only unique values, beyond
-- those already enforced as keys.

SELECT 
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN 
    information_schema.tables AS t
    ON tc.table_schema = t.table_schema
    AND tc.table_name = t.table_name
WHERE 
    tc.constraint_type = 'UNIQUE'
    AND tc.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    tc.table_name, kcu.column_name;

-- INSIGHTS
-- No explicit UNIQUE constraints were defined beyond those enforced by primary
-- keys.
-- Columns expected to hold unique values (e.g. emails or usernames) are not
-- constrained as unique.

-- RECOMMENDATIONS
-- Review frequency tables for duplicates where columns are expected to hold
-- unique values (Refer 3.5 | 3.7.4).

-- --------------------------------------------------------------------------------
-- 2.2.5 - CHECK CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify all CHECK constraints to understand business rules enforced beyond
-- primary and foreign keys.

SELECT 
    tc.table_name,
    cc.check_clause
FROM 
    information_schema.table_constraints AS tc
JOIN 
    information_schema.check_constraints AS cc
    ON tc.constraint_name = cc.constraint_name
    AND tc.constraint_schema = cc.constraint_schema
JOIN 
    information_schema.tables AS t
    ON tc.table_schema = t.table_schema
    AND tc.table_name = t.table_name
WHERE 
    tc.constraint_type = 'CHECK'
    AND tc.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY 
    tc.table_name;

-- INSIGHTS
-- All CHECK constraints enforce IS NOT NULL conditions and align with the list of
-- 72 non-nullable columns identified in 2.2.3.
-- No additional business rules are enforced at the table level, indicating that
-- such rules must be enforced manually.

-- RECOMMENDATIONS
-- Perform manual checks to confirm whether expected business rules are applied
-- (Refer 5.3 | 5.4).

-- --------------------------------------------------------------------------------
 -- 2.2.6 - DEFAULT VALUES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify columns with default values to understand where the database
-- automatically assigns values when no input is provided.

SELECT 
    c.table_name,
    c.column_name,
    c.column_default
FROM 
    information_schema.columns AS c
JOIN 
    information_schema.tables AS t
    ON c.table_schema = t.table_schema
    AND c.table_name = t.table_name
WHERE 
    c.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND c.column_default IS NOT NULL
ORDER BY 
    c.column_default, c.table_name;

-- INSIGHTS
-- In columns with primary keys, defaults enforce unique ID generation.
-- All last_update columns default to the current time to track database changes.
-- Column of type date captures changes but truncates the current timestamp to
-- retain only the date.
-- Business-related columns include some predefined defaults.
-- Boolean values default to true.
-- Column with USER-DEFINED data type 'mpaa_rating' defaults to 'G', suggesting
-- that the type is likely ENUMERATED with constrained categorical values.

-- RECOMMENDATIONS
-- Confirm whether user-defined columns use ENUMERATED types by classifying the
-- mpaa_rating type in the database (Refer 2.3).

-- --------------------------------------------------------------------------------
-- 2.3 - USER_DEFINED TYPES
-- --------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
-- 2.3.1 - CLASSIFY USER-DEFINED TYPES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Classify USER-DEFINED data types for columns using the mpaa_rating type to
-- uncover implicit constraints and guide downstream analysis.

SELECT 
    t.typname AS type_name,
    t.typtype,
    CASE t.typtype
        WHEN 'e' THEN 'enum'
        WHEN 'd' THEN 'domain'
        WHEN 'c' THEN 'composite'
        WHEN 'r' THEN 'range'
        WHEN 'b' THEN 'base'
        ELSE 'other'
    END AS type_kind
FROM 
    pg_type t
JOIN 
    pg_namespace n ON t.typnamespace = n.oid
WHERE 
    t.typname = 'mpaa_rating';

-- INSIGHTS
-- The USER-DEFINED type 'mpaa_rating' is classified as ENUM, confirming that 
-- 'rating' in the film table is restricted to a predefined set of values.

-- RECOMMENDATION
-- Retrieve the ENUM values for further analysis (Refer 2.3.2).

-- --------------------------------------------------------------------------------
-- 2.3.2 - RETRIEVE ENUMERATED VALUE SETS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Retrieve the set of values defined for the ENUM type 'mpaa_rating'. 

SELECT 
    t.typname AS enum_type,
    e.enumlabel AS enum_value
FROM 
    pg_type t 
JOIN 
    pg_enum e 
    ON t.oid = e.enumtypid
JOIN 
    pg_catalog.pg_namespace n
    ON n.oid = t.typnamespace
ORDER BY 
    enum_type, enum_value;

-- INSIGHTS
-- The ENUM type 'mpaa_rating' defines a fixed set of five permissible values.