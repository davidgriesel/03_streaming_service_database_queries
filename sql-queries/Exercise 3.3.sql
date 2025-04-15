-- Which film genres exist in the category table
SELECT category_id, name
FROM category;

-- Add 'Thriller', 'Crime', 'Mystery', 'Romance', and 'War' categories
INSERT INTO category (name)
VALUES ('Thriller'),
	('Crime'),
	('Mystery'),
	('Romance'),
	('War');

-- View adjustments
SELECT category_id, name
FROM category;

-- Find film_id for 'African Egg'
SELECT film_id, title
FROM film
WHERE title = 'African Egg';

-- Find category_id for 'Thriller'
SELECT category_id, name
FROM category
WHERE name = 'Thriller';

-- View record to change
SELECT film_id, category_id
FROM film_category
WHERE film_id = 5;

-- Update category of movie titled 'African Egg' to 'Thriller'
UPDATE film_category
SET category_id = 17
WHERE film_id = 5;

-- View result
SELECT film_id, category_id
FROM film_category
WHERE film_id = 5;

-- View record to delete
SELECT category_id, name
FROM category
WHERE name = 'Mystery';

-- Delete 'Mystery' category
DELETE
FROM category
WHERE name = 'Mystery';

-- View result
SELECT category_id, name
FROM category;

-- Create table with constraints
CREATE TABLE employees
(
employee_id SERIAL PRIMARY KEY,
name TEXT NOT NULL,
contact_number VARCHAR(15),
designation_id INTEGER,
last_update TIMESTAMP NOT NULL DEFAULT now()
);

-- View result
SELECT *
FROM employees;
)