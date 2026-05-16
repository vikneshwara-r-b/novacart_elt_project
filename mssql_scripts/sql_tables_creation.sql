-- 1. DROP TABLES (Reverse order of dependency)
IF OBJECT_ID('dbo.payments', 'U') IS NOT NULL DROP TABLE dbo.payments;
IF OBJECT_ID('dbo.orders', 'U') IS NOT NULL DROP TABLE dbo.orders;
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL DROP TABLE dbo.products;

-- 2. CREATE PRODUCTS (The Master List)
CREATE TABLE dbo.products (
    product_id    INT           NOT NULL PRIMARY KEY,
    product_name  VARCHAR(100)  NULL,
    category      VARCHAR(100)  NULL,
    price         VARCHAR(30)   NULL, 
    updated_at    DATETIME2     NOT NULL
);

-- 3. CREATE ORDERS (The Central Hub)
-- This table is "connected" to Products via the product_id FK
CREATE TABLE dbo.orders (
    order_id      INT           NOT NULL PRIMARY KEY,
    customer_id   INT           NULL,      
    product_id    INT           NULL,      -- The connection to Products
    order_status  VARCHAR(50)   NULL,      
    order_amount  VARCHAR(30)   NULL,      
    created_at    DATETIME2     NOT NULL,
    updated_at    DATETIME2     NOT NULL,
    CONSTRAINT FK_Orders_Products FOREIGN KEY (product_id) 
        REFERENCES dbo.products(product_id)
);

-- 4. CREATE PAYMENTS (Connected to Orders)
-- This table is "connected" to Orders via the order_id FK
CREATE TABLE dbo.payments (
    payment_id     INT NOT NULL PRIMARY KEY,
    order_id       INT NOT NULL,           -- The connection to Orders
    payment_status VARCHAR(50) NULL,  
    paid_amount    VARCHAR(30) NULL,  
    processed_at   DATETIME NOT NULL,
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (order_id) 
        REFERENCES dbo.orders(order_id)
);