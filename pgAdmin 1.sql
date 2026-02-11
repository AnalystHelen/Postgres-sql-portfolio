SELECT * FROM orders LIMIT 10;

SELECT * FROM order_items LIMIT 10;

SELECT DISTINCT order_status FROM orders 
ORDER BY 1;

SELECT * FROM orders
WHERE order_status = 'COMPLETE' OR  order_status = 'CLOSED';

SELECT * FROM orders
WHERE order_status IN ('COMPLETE' , 'CLOSED');

----AGREGATION (Global; aggregate function without specific classification)
SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM order_items;

SELECT COUNT(DISTINCT order_status) FROM orders;

SELECT * FROM order_items;

SELECT SUM(order_item_subtotal)
FR


----
AGREGATION (Globa; aggregate function without specific classification)


--------------------------------------------------------------------------CTAs--------------------------------
CREATE TABLE order_count_by_status
AS
SELECT order_status, COUNT (*) order_count
FROM orders
GROUP BY 1;

SELECT * FROM order_count_by_status;


------------------------------------------------------------------------------------daily_revenue----------------------

CREATE TABLE daily_revenue 
AS
SELECT o.order_date,
    round(sum(oi.order_item_subtotal)::numeric, 2) AS order_revenue
FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETE', 'CLOSED')
GROUP BY 1;


SELECT * FROM daily_revenue
ORDER BY order_date;

------------------------------------------------------------------------------------daily_product_revenue-------------

CREATE TABLE daily_product_revenue
AS
SELECT o.order_date,
    oi.order_item_product_id,
    round(sum(oi.order_item_subtotal)::numeric, 2) AS order_revenue
FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETE', 'CLOSED')
GROUP BY 1,2;


SELECT * FROM daily_product_revenue
ORDER BY 1, 3 DESC;

----------------------------------------------------------------------------------Monthly order revenue--------------------------------

SELECT to_char(dr.order_date::timestamp, 'yyyy-MM') AS order_month,
    dr.order_date,
    dr.order_revenue,
    sum(order_revenue) OVER (
        PARTITION BY to_char(dr.order_date::timestamp, 'yyyy-MM')
    ) AS monthly_order_revenue
FROM daily_revenue AS dr
ORDER BY 2;


----------------------------------------------------------------------------------Monthly & daily revenue--------------------------------
SELECT *,
	SUM(dr.order_revenue) OVER(
	PARTITION BY to_char(dr.order_date :: timestamp, 'yyyy-mm')
	) AS total_order_revenue
FROM daily_revenue AS dr
ORDER BY 1;


----------------------------------------------------------------------------------RANKING IN SQL--------------------------------
SELECT COUNT(*)
FROM daily_product_revenue;


SELECT *
FROM daily_product_revenue
WHERE order_date = '2014-01-01 00:00:00.0'
ORDER BY order_date, order_revenue DESC;

----------------------------------------------------------Applying RANK
-------------------------------------For 2014-01-01
SELECT order_date,
		order_item_product_id,
		order_revenue,
		rank() OVER (ORDER BY order_revenue DESC) AS rank,
		dense_rank() OVER (ORDER BY order_revenue DESC) AS drank
FROM daily_product_revenue
WHERE order_date = '2014-01-01 00:00:00.0' ;

-------------------------------------For global rank
SELECT order_date,
		order_item_product_id,
		order_revenue,
	rank() OVER (
	PARTITION BY order_date ORDER BY order_revenue DESC)	AS rank,
	dense_rank() OVER(
	PARTITION BY order_date ORDER BY order_revenue DESC) AS drank
FROM daily_product_revenue
WHERE to_char(order_date :: date, 'yyyy-mm') = '2014-01'
ORDER BY order_date, order_revenue DESC;


----------------------------------------------------------Filtering Data based on RANK-------(USING NESTED query)

SELECT *
FROM 
(SELECT order_date,
		order_item_product_id,
		order_revenue,
		rank() OVER (ORDER BY order_revenue DESC) AS rank,
		dense_rank() OVER (ORDER BY order_revenue DESC) AS drank
FROM daily_product_revenue
WHERE order_date = '2014-01-01 00:00:00.0') AS q
WHERE drank <= 5
ORDER BY 3 DESC;

----------------------------------------------------------Filtering Data based on RANK-------(USING CTE)
WITH daily_product_revenue_rank AS
(SELECT order_date,
		order_item_product_id,
		order_revenue,
		rank() OVER (ORDER BY order_revenue DESC) AS rank,
		dense_rank() OVER (ORDER BY order_revenue DESC) AS drank
FROM daily_product_revenue
WHERE order_date = '2014-01-01 00:00:00.0')
SELECT * FROM daily_product_revenue_rank
WHERE drank <= 5;

----------------------------------------------------------Filtering Data based on RANK per Partition-------(USING nested query)
 SELECT *
FROM 
(SELECT order_date,
		order_item_product_id,
		order_revenue,
	rank() OVER (
	PARTITION BY order_date ORDER BY order_revenue DESC)	AS rank,
	dense_rank() OVER(
	PARTITION BY order_date ORDER BY order_revenue DESC) AS drank
FROM daily_product_revenue
WHERE to_char(order_date :: date, 'yyyy-mm') = '2014-01'
ORDER BY order_date, order_revenue DESC) AS q
WHERE drank <= 5
ORDER BY 1, 3 DESC;
 

----------------------------------------------------------Filtering Data based on RANK per Partition-------(USING CTE)
WITH daily_prouct_rank AS
(SELECT order_date,
		order_item_product_id,
		order_revenue,
	rank() OVER (
	PARTITION BY order_date ORDER BY order_revenue DESC)	AS rank,
	dense_rank() OVER(
	PARTITION BY order_date ORDER BY order_revenue DESC) AS drank
FROM daily_product_revenue
WHERE to_char(order_date :: date, 'yyyy-mm') = '2014-01'
ORDER BY order_date, order_revenue DESC) 
SELECT * 
FROM daily_prouct_rank 
WHERE drank <= 5
ORDER BY 1, 3 DESC;

select * from daily_product_revenue
----------------------------------------------------------------------------CREATING TABLE to show diff btw dense and normal rank

CREATE TABLE student_scores (
		student_id INT PRIMARY KEY,
		studen_score INT
);

INSERT INTO student_scores VALUES
(1, 980),
(2, 960),
(3, 960),
(4, 990),
(5, 920),
(6, 960),
(7, 980),
(8, 960),
(9, 940),
(10, 940);

SELECT * FROM student_scores
ORDER BY studen_score DESC;


SELECT student_id,
		studen_score,
	rank() OVER ( ORDER BY studen_score DESC) AS rank,
	dense_rank() OVER (ORDER BY studen_score DESC) AS drank
FROM student_scores


-----------------------------------------------------------SQL erros and debbug
SELECT order_status,
		count(*) AS order_count
FROM orders
GROUP BY 1
ORDER BY 2 DESC

-----------------------------------------------------------debuging

-----------------------------WRONG
CREATE TABLE orders_completed
AS
SELECT * FROM orders
WHERE order_status IN ('complete', 'closed');

SELECT * FROM orders_completed;

--If count is not 0, then review the data by selecting the first rows (with all column)

--DROP table before creating a new one

-----------------------------RIGHT

CREATE TABLE orders_completed
AS
SELECT * FROM orders
WHERE order_status IN ('COMPLETE', 'CLOSED');

SELECT * FROM orders_completed;

-----------------------------
--Check table structure to make sure its correct
--Get the count in orders_completed 
SELECT COUNT(*) FROM orders_completed
SELECT COUNT(*) FROM orders;



---------------------------------------------------------------------------------------GENERATE Explain plan for Sql

-- In explain plan, you can run the query using explain or analyse botton up beside the 'run query' 
--You can also run the query through PSQL tool (right-click on itversity_retail_db_)
EXPLAIN
SELECT * 
FROM orders
WHERE order_id = 2;



EXPLAIN
SELECT o.*, round(SUM(order_item_subtotal):: numeric, 2) AS rcevenue 
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
WHERE order_id = 2
GROUP BY o.order_id,
		 order_date,
		 order_customer_id,
		 order_status;
---------------------------------------
SELECT COUNT(*)
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
WHERE o.order_customer_id = 5		

---------------------------------------Test how long it'd take to run the query (choosing/testing performance)
DO $$
BEGIN 
	CALL perfdemo();
END;
$$;

---------------------------------------------------------------------------------------INDEXES (It helps sql search through pages faster)
-----------------------------Creating Indexes ( Naming Rule: idx_<table>_<column>)
CREATE INDEX idx_order_item_order_id
ON order_items (order_item_order_id);


CREATE INDEX idx_order_customer_id
ON orders (order_customer_id);

---------------------------Testing it;
SELECT COUNT(*)
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
WHERE o.order_customer_id = 5

-------------------------------------------------------------------------




-----------------------------------------------------------NOTES-------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
-- to_char  ;Formats dates or numbers into text. Converts a timestamp into a readable string format(eg; to_char(order_date, 'YYYY-MM-DD'))															
 
--PARTITION BY  ;Group all rows that belong to the same (e.g; PARTITION BY to_char(dr.order_date::timestamp, 'yyyy-MM') this means .....“Group all rows that belong to the same month,then calculate the total revenue inside each group."  
-- Difference btw PARTITION BY &  GROUP BY:   GROUP BY → one row per month..   PARTITION BY → keeps all rows, but adds monthly totals

-- RANKING IN SQL:  Rank() - and dense_rank
--GLOBAL RANKING; contains only ORDER BY(eg. ORDER BY col1 DESC)
--RANKING BASED ON key or  PARTITON KEY; contains both ORDER BY & PARTITION BY. (eg. rank() OVER() PARTITION BY col2 ORDER BY col1 DESC)

--RANK: 
100 → rank 1
95  → rank 2
95  → rank 2
90  → rank 4   ❗ (rank 3 is skipped)
👉 Gaps appear
--

--DENSE_RANK:
100 → rank 1
95  → rank 2
95  → rank 2
90  → rank 3   ✅
👉 No gaps
-- 
--NESTED QUERY: query that has a whole query in bracket

-- CTE = Common Table Expression. (more like a sub-query).. “Let me create a temporary result, give it a name, and reuse it in my main query.”


-------------------------------Sql DEBUGGING ERROR
--Database conectivity:  when not work, got to telnet on powershell to confirm then run the test "telnet localhosy 5432" once it connects on powershell restart pgAdmin an run again. 

--Syntax: (its shows syntax error) errors when there's mispelling the typing 

--semantec errors: (it shows ordinary error) MAybe wrong table name

--Bugs in queries: (output is different from what it's meant to be) does not bring error message.


--** To get detail about a tale, all you need do is right-click on the table and go to script, that way you'll see the primary-key

--** An index is like the index of a book — instead of flipping through every page, you jump straight to what you need. Indexes don’t store the full data, they store an organized map that tells the system where to find the data.

--  Seq Scan: This meansFULL TABLE SCAN  (Seq Scan on order_items as oi (rows=172198 loops=1))

--Why INDEXES are added to tables;
--Imagine: A table = a book, Rows = pages, Column values = words in the book
--Without an index: PostgreSQL reads every page to find what it needs
--with an index: PostgreSQL uses the book index at the back. It jumps directly to the right page


--1. Sequential Scan (Seq Scan)

Meaning:
PostgreSQL reads every row in the table, one by one.

In simple terms:
Like flipping every page of a book to find one sentence.

When it happens: Table is small, No index exists, PostgreSQL thinks scanning all rows is faster

--2. Index Scan

Meaning:
PostgreSQL uses an index to find rows, then goes to the table to fetch them.

In simple terms:
Use the table of contents, then open the exact page.

When it happens: Index exists, Only a few rows are needed

--3. Index Only Scan

Meaning:
PostgreSQL gets everything it needs from the index alone.

In simple terms:
You read the answer directly from the table of contents — no book needed.

Why it’s fast: No table access, Index contains all required columns, Table rows are already “clean” (visible)

--4. Nested Loop

Meaning:
PostgreSQL joins tables by looping:

Pick one row from table A

Match it with rows in table B

In simple terms:
For each person, check every matching record in another list.

When it’s good: Small datasets, Indexed join columns

----------------------------------------------------------------------------------------------Interview
--How do you tune performance of sql queries
--(1). Review query (2). Generate explain plan for the query
--(3).Identitify performance bottle neck by reviewing explain plan again, eg if there are no indexes, i'd consider adding indexes to improve performace and also by testing it. 

------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
 
SELECT CURRENT_DATE





