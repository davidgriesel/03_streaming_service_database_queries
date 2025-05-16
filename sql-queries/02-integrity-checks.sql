-- ================================================================================
-- 2. INTEGRITY CHECKS
-- ================================================================================

-- PURPOSE 
-- Validate data types and constraints to ensure data integrity.

-- --------------------------------------------------------------------------------
-- 2.1 DATA TYPES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Validate the data types of columns across all base tables to ensure consistency and
-- compatibility for downstream cleaning and analysis.

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
-- Most fields are type smallint, integer, or character varying.
-- 17 columns use timestamp without time zone, typical of system-generated or
-- transactional date fields.
-- A single column uses date while the rest use full timestamps.
-- One column uses character rather than character varying which may cause padding
-- or formatting inconsistencies.
-- One column normally associated with boolean uses integer.
-- Less common data types include ARRAY, USER-DEFINED ENUM, bytea, and tsvector
-- suggesting less common or rich metadata fields.

-- RECOMMENDATIONS
-- Change fields with type timestamp where time-level precision is not required to
-- date for standardisation (Refer 4.5).

-- Change fields with type character to varchar for standardisation (Refer 4.5).

-- Confirm ENUM values for fields with type USER-DEFINED needed in analysis 
-- (Refer 2.2.7).

-- Review variable normally associated with boolean for binary logic (Refer 3.5).

-- Remove columns with unusual or complex data types if not needed in the analysis
-- Refer 4.3).


-- --------------------------------------------------------------------------------
-- 2.2.1 - PRIMARY KEY CONSTRAINTS
-- --------------------------------------------------------------------------------
    
-- PURPOSE
-- Identify all primary key constraints (including composite keys) across base
-- tables to validate that each table has a unique identifier & enforce row-level
-- integrity.

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
-- All tables have a defined primary key with two tables having composite keys.

-- --------------------------------------------------------------------------------
-- 2.2.2 - FOREIGN KEY CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify foreign key relationships for all base tables to confirm that child
-- tables are properly linked to referenced tables, supporting referential
-- integrity across the schema.

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
-- Foreign key relationships are defined and generally align with the expected
-- relational structure of the schema.
-- Constraints are missing for some expected links to the store table.

-- RECOMMENDATIONS
-- Manually validate integrity for store-linked fields where constraints are absent
-- (Refer 3.8.1).

-- --------------------------------------------------------------------------------
-- 2.2.3 - NOT NULL CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify fields that allow NULLs across al base tables, helping to isolate
-- columns that require additional quality checks.

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
-- 72 varaibles are not nullable.
-- 14 columns across 5 tables are declared nullable.

-- RECOMMENDATIONS
-- Perform targeted null profiling for fields that are nullable (Refer 3.1).

-- --------------------------------------------------------------------------------
-- 2.2.4 - UNIQUE CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Check for columns explicitly constrained to hold only unique values, beyond
-- those already enforced as keys helping to reveal additional integrity rules.

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
-- Any expected uniqueness in other fields (e.g. emails or usernames) is not
-- structurally guaranteed.

-- RECOMMENDATIONS
-- Review frequency tables for duplicates where variables are expected to hold
-- unique values (Refer 3.5 | 3.7.4).

-- --------------------------------------------------------------------------------
-- 2.2.5 - CHECK CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify all CHECK constraints applied at table level to understand enforced
-- business rules or structural protections beyond primary and foreign keys.

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
-- All CHECK constraints enforce IS NOT NULL conditions and align exactly with
-- the list of 72 non-nullable fields identified in 2.2.3.
-- No additional busienss rules are enforced at the table level, indicating that
-- such rules must be enforced manually.

-- RECOMMENDATIONS
-- Perform manual checks to confirm whether expected business rules are applied
-- (Refer 3.8).

-- --------------------------------------------------------------------------------
-- 2.2.6 - DEFAULT VALUES
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify columns with default values to understand where the database is
-- automatically assigning values when no input is provided.

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
-- No unexpected default values identified. 
-- Default values are defined for some columns, related to classifications, dates,
-- primary keys, and boolean flags.
-- In primary key fields, defaults enforce unique ID generation.
-- Timestamp fields default to the current time to track record changes.
-- A small set of business-related fields include predefined default values to
-- classify records or populate known attributes.
-- Boolean values default to true.

-- --------------------------------------------------------------------------------
-- 2.2.7 - ENUMERATED | DOMAIN CONSTRAINTS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify enumerated types defined in the database and list their allowed values.

SELECT 
    n.nspname AS schema_name,
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
-- A single ENUM type (mpaa_rating) is defined, providing a controlled list of
-- classification values.

-- RECOMMENDATIONS
-- Confirm columns using ENUMs (Refer 2.2.8).

-- --------------------------------------------------------------------------------
-- 2.2.8 - ENUMERATED | DOMAIN CONSTRAINT MAPPING TO COLUMNS
-- --------------------------------------------------------------------------------

-- PURPOSE
-- Identify which base table columns are assigned user-defined ENUM types to ensure
-- consistency in categorisation and assess compatibility with tools or exports.

SELECT 
    c.table_name,
    c.column_name,
    c.udt_name AS enum_type
FROM 
    information_schema.columns AS c
JOIN 
    information_schema.tables AS t
    ON c.table_schema = t.table_schema
    AND c.table_name = t.table_name
WHERE 
    c.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND c.data_type = 'USER-DEFINED'
ORDER BY 
    c.table_name, c.column_name;

-- INSIGHTS
-- One user-defined ENUM (mpaa_rating) is applied to the rating column in the
-- film table.

-- RECOMMENDATIONS
-- Transform data type of film.rating to varchar for use in analysis (Refer 4.5).