-- TASK E

--Question 1

WITH order_totals AS (   -- order_id = order_total
  SELECT
    oi.order_id,
    SUM(oi.quantity * oi.unit_price) AS order_total
  FROM order_items oi
  GROUP BY oi.order_id
)
SELECT
  c.city,                                                
  AVG(ot.order_total) AS avg_order_value,                
  COUNT(*) AS delivered_orders_count           
FROM orders o
JOIN order_totals ot ON ot.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'delivered'                             
GROUP BY c.city
HAVING COUNT(*) >= 2   --cities with at least 2 delivered orders
ORDER BY avg_order_value DESC, c.city; 

-- ============================================================================================================

--Question 2

SELECT
  o.customer_id,                                        
  p.category,                                           
  COUNT(DISTINCT o.order_id) AS distinct_orders_count   -- count of distinct orders
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id  -- link items
JOIN products p   ON p.product_id  = oi.product_id  
GROUP BY o.customer_id, p.category
ORDER BY o.customer_id, distinct_orders_count DESC, p.category; 

-- ============================================================================================================

--Question 3

CREATE TEMP VIEW v_electronics_buyers AS
SELECT DISTINCT o.customer_id                         -- people who bought electronics
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
WHERE p.category = 'Electronics';

CREATE TEMP VIEW v_fitness_buyers AS
SELECT DISTINCT o.customer_id                         -- people who bought itness
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
WHERE p.category = 'Fitness';

SELECT 'UNION' AS set_name, customer_id  -- Union
FROM (
  SELECT customer_id FROM v_electronics_buyers
  UNION
  SELECT customer_id FROM v_fitness_buyers
) u
ORDER BY set_name, customer_id;


SELECT 'INTERSECT' AS set_name, customer_id  -- Intersection
FROM (
  SELECT customer_id FROM v_electronics_buyers
  INTERSECT
  SELECT customer_id FROM v_fitness_buyers
) i
ORDER BY set_name, customer_id;


SELECT 'EXCEPT' AS set_name, customer_id  -- Except
FROM (
  SELECT customer_id FROM v_electronics_buyers
  EXCEPT
  SELECT customer_id FROM v_fitness_buyers
) e
ORDER BY set_name, customer_id;

--DROP VIEW IF EXISTS v_electronics_buyers;  -- remove Electronics set
--DROP VIEW IF EXISTS v_fitness_buyers;      -- remove Fitness set