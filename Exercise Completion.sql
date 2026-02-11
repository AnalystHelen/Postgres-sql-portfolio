
---CONTINUATION

---------------------------------------------------
-- EXERCISE 4 — Revenue Per Category
---------------------------------------------------

SELECT 
    c.category_id,
    c.category_department_id,
    c.category_name,
    ROUND(SUM(oi.order_item_subtotal)::numeric, 2) AS category_revenue
FROM categories AS c
JOIN products AS p
    ON c.category_id = p.product_category_id
JOIN order_items AS oi
    ON p.product_id = oi.order_item_product_id
JOIN orders AS o
    ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('CLOSED', 'COMPLETE')
    AND TO_CHAR(order_date, 'yyyy-mm') = '2014-01'
GROUP BY 1,2,3
ORDER BY 1;


---------------------------------------------------
-- EXERCISE 5 — Product Count Per Department
---------------------------------------------------

SELECT 
    d.department_id,
    d.department_name,
    COUNT(*) AS product_count
FROM departments AS d
JOIN categories AS c 
    ON d.department_id = c.category_department_id
JOIN products AS p
    ON c.category_id = p.product_category_id
GROUP BY 1,2
ORDER BY 1;


---------------------------------------------------
-- EXTRA — Products Not Visible in Category
---------------------------------------------------

SELECT *
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM categories AS c
    WHERE c.category_id = p.product_category_id
);


---------------------------------------------------
-- EXTRA — Categories Not Visible in Department
---------------------------------------------------

SELECT *
FROM categories AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM departments AS d
    WHERE d.department_id = c.category_department_id
);
