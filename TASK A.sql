-- TASK A

--Question 1

WITH m AS (              -- CTE to create a temporary table
  SELECT
    TO_CHAR(DATE_TRUNC('month', o.order_date), 'YYYY-MM') AS month_txt,  -- Changes month to text
    o.customer_id,
    SUM(oi.quantity * oi.unit_price) AS total_monthly_spend
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY TO_CHAR(DATE_TRUNC('month', o.order_date), 'YYYY-MM'), o.customer_id
)
SELECT
  month_txt,
  customer_id,
  total_monthly_spend,
  RANK() OVER (PARTITION BY month_txt ORDER BY total_monthly_spend DESC) AS rank_in_month  -- Ranking 
FROM m
ORDER BY month_txt, rank_in_month, customer_id;

-- ============================================================================================================

--Question 2

SELECT
  oi.order_id,
  oi.product_id,
  oi.quantity * oi.unit_price AS item_revenue, -- revenue calculated
  SUM(oi.quantity * oi.unit_price) OVER (PARTITION BY oi.order_id) AS order_total,
  (oi.quantity * oi.unit_price)
    / NULLIF(SUM(oi.quantity * oi.unit_price) OVER (PARTITION BY oi.order_id), 0) AS share_in_order -- item share calculated
FROM order_items oi
ORDER BY oi.order_id, oi.product_id;

-- ============================================================================================================

--Question 3

SELECT
  o.customer_id,                                                           
  o.order_id,                                                              
  o.order_date,                                                            
  LAG(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS prev_order_date, -- last order calculated
  EXTRACT(DAY FROM (o.order_date - LAG(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date))) AS days_since_last_order -- gap in days
FROM orders o
ORDER BY o.customer_id, o.order_date;

-- ============================================================================================================

--Question 4

WITH product_revenue AS (   -- CTE to create a temporary table
  SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue   -- total revenue calculated
  FROM products p
  LEFT JOIN order_items oi ON p.product_id = oi.product_id -- tables joined
  GROUP BY p.product_id, p.product_name
)
SELECT 
  product_id,
  product_name,
  revenue,
  NTILE(4) OVER (ORDER BY revenue DESC) AS quartile   -- products divided into 4 parts/quartiles
FROM product_revenue;

-- ============================================================================================================

--Question 5


WITH tbl AS (   -- CTE to create a temporary table
  SELECT
    o.customer_id,
    o.order_date,
    p.category
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
)
SELECT DISTINCT
  customer_id,                                                                                 -- one row per customer
  FIRST_VALUE(category) OVER (PARTITION BY customer_id ORDER BY order_date ASC)  AS first_category,   -- earliest category
  LAST_VALUE(category)  OVER (
    PARTITION BY customer_id
    ORDER BY order_date ASC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS recent_category                                                                          -- most recent category
FROM tbl
ORDER BY customer_id;


