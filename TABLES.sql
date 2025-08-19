-- ===============================================
-- E-commerce Training Dataset (PostgreSQL)
-- Creates a fresh schema and loads sample data
-- ===============================================

DROP SCHEMA IF EXISTS training_ecom CASCADE;
CREATE SCHEMA training_ecom;

-- ---------- Tables ----------
CREATE TABLE customers (
    customer_id      SERIAL PRIMARY KEY,
    full_name        VARCHAR(100) NOT NULL,
    city             VARCHAR(60)  NOT NULL,
    signup_date      DATE         NOT NULL DEFAULT CURRENT_DATE,
    email            VARCHAR(120) UNIQUE
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category     VARCHAR(60)  NOT NULL,
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date  TIMESTAMP NOT NULL,
    status      VARCHAR(20) NOT NULL CHECK (status IN ('placed','shipped','delivered','cancelled'))
);

CREATE TABLE order_items (
    order_id   INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id   INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    amount     NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    method     VARCHAR(20) NOT NULL CHECK (method IN ('card','cash','wallet')),
    paid_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------- Seed Data ----------
-- Customers
INSERT INTO customers (full_name, city, signup_date, email) VALUES
('Alice Carter','Kathmandu','2024-12-15','alice@example.com'),
('Bikash Rana','Lalitpur','2025-01-05','bikash@example.com'),
('Chhaya Shrestha','Bhaktapur','2025-02-10','chhaya@example.com'),
('Deepak Gurung','Kathmandu','2025-01-22','deepak@example.com'),
('Elina Magar','Pokhara','2024-11-30','elina@example.com'),
('Farhan Ansari','Butwal','2025-02-15','farhan@example.com'),
('Gita Adhikari','Lalitpur','2025-03-01','gita@example.com'),
('Hari Khadka','Biratnagar','2025-03-12','hari@example.com');

-- Products
INSERT INTO products (product_name, category, unit_price, active) VALUES
('USB-C Charger 30W','Electronics',1999.00, TRUE),
('Wireless Mouse','Electronics',1499.00, TRUE),
('Notebook A5','Stationery',199.00, TRUE),
('Ballpoint Pen (10-pack)','Stationery',249.00, TRUE),
('Ceramic Mug','Home',599.00, TRUE),
('Yoga Mat','Fitness',1899.00, TRUE),
('Stainless Water Bottle','Fitness',1299.00, TRUE),
('LED Desk Lamp','Home',2499.00, TRUE);

-- Orders
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2025-03-05 10:15', 'delivered'),
(1, '2025-03-20 18:30', 'delivered'),
(2, '2025-03-18 09:42', 'shipped'),
(3, '2025-04-01 14:05', 'delivered'),
(3, '2025-04-15 16:21', 'placed'),
(4, '2025-04-10 11:00', 'cancelled'),
(5, '2025-05-02 19:45', 'delivered'),
(6, '2025-05-10 08:10', 'placed'),
(6, '2025-05-25 12:30', 'shipped'),
(7, '2025-06-05 15:00', 'delivered'),
(8, '2025-06-20 17:20', 'delivered'),
(8, '2025-07-01 10:40', 'placed');

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1,1,1,1999.00),
(1,3,3,199.00),
(1,5,1,599.00),
(2,2,1,1499.00),
(2,7,2,1299.00),
(3,1,1,1999.00),
(3,4,2,249.00),
(4,8,1,2499.00),
(4,3,5,199.00),
(5,6,1,1899.00),
(6,2,2,1499.00),
(7,5,2,599.00),
(7,7,1,1299.00),
(8,6,1,1899.00),
(9,1,1,1999.00),
(9,3,2,199.00),
(10,2,1,1499.00),
(10,7,1,1299.00),
(10,5,1,599.00),
(11,8,1,2499.00),
(12,3,10,199.00);

-- Payments
INSERT INTO payments (order_id, amount, method, paid_at) VALUES
(1, 1999.00 + 3*199.00 + 599.00, 'card',   '2025-03-05 10:20'),
(2, 1499.00 + 2*1299.00,         'wallet', '2025-03-20 18:35'),
(3, 1999.00 + 2*249.00,          'card',   '2025-03-18 09:50'),
(4, 2499.00 + 5*199.00,          'cash',   '2025-04-01 14:10'),
(5, 1899.00,                      'wallet', '2025-04-15 16:25'),
(7, 2*599.00 + 1299.00,          'card',   '2025-05-02 19:47'),
(8, 1899.00,                      'wallet', '2025-05-10 08:12'),
(9, 1999.00 + 2*199.00,          'card',   '2025-05-25 12:35'),
(10, 1499.00 + 1299.00 + 599.00, 'card',   '2025-06-05 15:05'),
(11, 2499.00,                     'cash',   '2025-06-20 17:25');