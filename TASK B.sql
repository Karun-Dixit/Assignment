-- TASK B

--Question 1

CREATE VIEW view_recent_orders_30d as  -- CTE 
SELECT
  o.order_id,                                        
  o.customer_id,                                     
  o.order_date,                                      
  o.status,                                          
  SUM(oi.quantity * oi.unit_price) AS order_total  -- total revenue calculated
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id  -- items joined
WHERE o.status != 'cancelled'  -- cancelled orders are excluded
  AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'  -- 30 days subtracted for calculating order date
GROUP BY o.order_id, o.customer_id, o.order_date, o.status;

-- DROP VIEW view_recent_orders_30d;

-- ============================================================================================================

--Question 2

SELECT 
  p.product_id,
  p.product_name,
  p.category
FROM products p
WHERE NOT EXISTS (  -- checked for matching orders if they exist
  SELECT 1
  FROM order_items oi
  WHERE oi.product_id = p.product_id
);

-- ============================================================================================================

--Question 3

WITH city_cat AS (                                -- CTE
  SELECT
    c.city,
    p.category,
    SUM(oi.quantity * oi.unit_price) AS revenue
  FROM customers c
  JOIN orders o       ON o.customer_id = c.customer_id
  JOIN order_items oi ON oi.order_id   = o.order_id
  JOIN products p     ON p.product_id  = oi.product_id
  GROUP BY c.city, p.category
),
ranked AS (  -- pick best inside each city
  SELECT
    city,
    category,
    revenue,
    ROW_NUMBER() OVER (PARTITION BY city ORDER BY revenue DESC, category ASC) AS rn
  FROM city_cat
)
SELECT city, category, revenue
FROM ranked
WHERE rn = 1  -- only rank 1 selected
ORDER BY city;

-- ============================================================================================================

--Question 4

SELECT
  c.customer_id,            
  c.full_name,              
  c.city                    
FROM customers c
WHERE NOT EXISTS ( 
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
    AND o.status = 'delivered' -- dfilter for 'delivered' only
)
ORDER BY c.customer_id;      
