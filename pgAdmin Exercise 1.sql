-- Let us take care of exercises related to filtering and aggregations using SQL.
-- * Get all the details of the courses which are in `inactive` or `draft` state.
-- * Get all the details of the courses which are related to `Python` or `Scala`.
-- * Get count of courses by `course_status`. The output should contain `course_status` and `course_count`.
-- * Get count of `published` courses by `course_author`. The output should contain `course_author` and `course_count`.
-- * Get all the details of `Python` or `Scala` related courses in `draft` status.
-- * Get the author and count where the author have more than **one published** course. The output should contain `course_author` and `course_count`.

DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(60),
    course_author VARCHAR(40),
    course_status VARCHAR(9),
    course_published_dt DATE);

SELEC	

INSERT INTO courses
    (course_name, course_author, course_status, course_published_dt)
VALUES
    ('Programming using Python', 'Bob Dillon', 'published', '2020-09-30'),
    ('Data Engineering using Python', 'Bob Dillon', 'published', '2020-07-15'),
    ('Data Engineering using Scala', 'Elvis Presley', 'draft', null),
    ('Programming using Scala' , 'Elvis Presley' , 'published' , '2020-05-12'),
    ('Programming using Java' , 'Mike Jack' , 'inactive' , '2020-08-10'),
    ('Web Applications - Python Flask' , 'Bob Dillon' , 'inactive' , '2020-07-20'),
    ('Web Applications - Java Spring' , 'Bob Dillon' , 'draft' , null),
    ('Pipeline Orchestration - Python' , 'Bob Dillon' , 'draft' , null),
    ('Streaming Pipelines - Python' , 'Bob Dillon' , 'published' , '2020-10-05'),
    ('Web Applications - Scala Play' , 'Elvis Presley' , 'inactive' , '2020-09-30'),
    ('Web Applications - Python Django' , 'Bob Dillon' , 'published' , '2020-06-23'),
    ('Server Automation - Ansible' , 'Uncle Sam' , 'published' , '2020-07-05');

SELECT * FROM courses ORDER BY course_id;





---------------------------------------------------SECOND-----------------------------------------------------------------------------------------
---------------------------------------------------EXERCISE---------------------------------------------------------------------------------------

-- Here are some of the exercises for which you can write SQL queries to self evaluate using all the concepts we have learnt to write SQL Queries.
-- * All the exercises are based on retail tables.
-- * We have already setup the tables and also populated the data.
-- * We will use all the 6 tables in retail database as part of these exercises.

-- Here are the commands to validate the tables
SELECT count(*) FROM departments;
SELECT count(*) FROM categories;
SELECT count(*) FROM products;
SELECT count(*) FROM orders;
SELECT count(*) FROM order_items;
SELECT count(*) FROM customers;

-- ### Exercise 1 - Customer order count

-- Get order count per customer for the month of 2014 January.

-- * Tables - `orders` and `customers`
-- * Data should be sorted in descending order by count and ascending order by customer id.
-- * Output should contain `customer_id`, `customer_fname`, `customer_lname` and `customer_order_count`.

-------------------------------Check All customers count
SELECT count(*) FROM customers;

-------------------------------Check distinct customers ID
SELECT COUNT(DISTINCT order_customer_id)
FROM orders AS o
	JOIN customers AS c
		ON o.order_customer_id = c. customer_id

-------------------------------Final Answer(distinct customers In anuary 2024)
SELECT * 
FROM (SELECT c.customer_id,
		c.customer_fname,
		c.customer_lname,
		COUNT(*) AS Custoer_order_cout
FROM orders AS o
	JOIN customers AS c
		ON o.order_customer_id = c. customer_id
WHERE to_char(order_date, 'yyyy-mm') = '2014-01'
GROUP BY 1, 2, 3) AS q
ORDER BY  4 DESC, 1


---------------------------------------------------EXERCISE--2-------------------------------------------------------------------------------------

-- ### Exercise 2 - Dormant Customers

-- Get the customer details who have not placed any order for the month of 2014 January.
-- * Tables - `orders` and `customers`
-- * Output Columns - **All columns from customers as is**
-- * Data should be sorted in ascending order by `customer_id`
-- * Output should contain all the fields from `customers`
-- * Make sure to run below provided validation queries and validate the output.

-------------------------------Total Customer Tat place orders in January (AS y 4696)
SELECT count(DISTINCT order_customer_id)
FROM orders
WHERE to_char(order_date, 'yyyy-MM') = '2014-01';

-------------------------------Total Customer Check (AS x 12435)
SELECT count(*)
FROM customers; 

-------------------------------CHeck for NULL 
SELECT c.* 
FROM customers AS c
	LEFT OUTER JOIN orders AS o
		ON o.order_customer_id = c. customer_id
			AND to_char(order_date, 'yyyy-mm') = '2014-01'
WHERE o.order_customer_id IS NULL
ORDER BY 1
LIMIT 10

-------------------------------FINAL Answer (x - y = 7739)
SELECT c.* 
FROM customers AS c
WHERE c.customer_id NOT IN 
	(SELECT o.order_customer_id 
	FROM orders AS o
	WHERE o.order_customer_id = c.customer_id
		AND to_char(order_date, 'yyyy-mm') = '2014-01' )
ORDER BY 1

-- Get the difference
-- Get the count using solution query, both the difference and this count should match

-- * Hint: You can use `NOT IN` or `NOT EXISTS` or `OUTER JOIN` to solve this problem.

			

---------------------------------------------------EXERCISE--3-------------------------------------------------------------------------------------

-- ### Exercise 3 - Revenue Per Customer

-- Get the revenue generated by each customer for the month of 2014 January
-- * Tables - `orders`, `order_items` and `customers`
-- * Data should be sorted in descending order by revenue and then ascending order by `customer_id`
-- * Output should contain `customer_id`, `customer_fname`, `customer_lname`, `customer_revenue`.
-- * If there are no orders placed by customer, then the corresponding revenue for a given customer should be 0.
-- * Consider only `COMPLETE` and `CLOSED` orders
SELECT c.customer_id, 
		c.customer_fname,
		c.customer_lname,
		coalesce(round(SUM(oi.order_item_subtotal):: numeric, 2), 0) AS customer_revenue
FROM customers AS c
	LEFT OUTER JOIN orders AS o
		ON o.order_customer_id = c.customer_id
			AND to_char(order_date, 'yyyy-mm') = '2014-01'
			AND order_status IN ('COMPLETE', 'CLOSED')
	LEFT OUTER JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC, 1
LIMIT 10

---------------------------------------------------EXERCISE---4------------------------------------------------------------------------------------

-- ### Exercise 4 - Revenue Per Category

-- Get the revenue generated for each category for the month of 2014 January
-- * Tables - `orders`, `order_items`, `products` and `categories`
-- * Data should be sorted in ascending order by `category_id`.
-- * Output should contain all the fields from `categories` along with the revenue as `category_revenue`.
-- * Consider only `COMPLETE` and `CLOSED` orders


---------------------------------------------------EXERCISE---5------------------------------------------------------------------------------------

-- ### Exercise 5 - Product Count Per Department

-- Get the count of products for each department.
-- * Tables - `departments`, `categories`, `products`
-- * Data should be sorted in ascending order by `department_id`
-- * Output should contain all the fields from `departments` and the product count as `product_count`