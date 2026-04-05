-- =========================================================
-- INITIAL LOAD : CLEAN + MESSY DATA
-- =========================================================

-- 1. CLEAN UP: Delete in dependency order
DELETE FROM dbo.payments;
DELETE FROM dbo.orders;
DELETE FROM dbo.products;

-- =========================================================
-- 2. PRODUCTS (120 rows: 1001 to 1120)
-- Mix of:
-- - clean product_name/category/price
-- - null product_name
-- - typo category
-- - lowercase category
-- - comma price
-- - dollar sign price
-- - invalid price
-- =========================================================
;WITH n AS (
    SELECT TOP (120) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO dbo.products (product_id, product_name, category, price, updated_at)
SELECT
    1000 + rn AS product_id,
    CASE
        WHEN rn % 20 = 0 THEN NULL
        WHEN rn % 15 = 0 THEN '   Product ' + CAST(rn AS varchar) + '   '
        WHEN rn % 11 = 0 THEN 'PRODUCT-' + CAST(rn AS varchar)
        WHEN rn % 9  = 0 THEN 'Prod_' + CAST(rn AS varchar)
        ELSE 'Product ' + CAST(rn AS varchar)
    END AS product_name,
    CASE
        WHEN rn % 18 = 0 THEN 'ELECTRNICS'   -- typo
        WHEN rn % 14 = 0 THEN 'lifestyle'
        WHEN rn % 10 = 0 THEN 'FITNESS'
        WHEN rn % 7  = 0 THEN 'electronics'
        ELSE 'Electronics'
    END AS category,
    CASE
        WHEN rn % 25 = 0 THEN '??'
        WHEN rn % 16 = 0 THEN '$' + CAST(10 + (rn % 90) AS varchar) + '.00'
        WHEN rn % 13 = 0 THEN CAST(10 + (rn % 90) AS varchar) + ',00'
        WHEN rn % 8  = 0 THEN ' ' + CAST(10 + (rn % 90) AS varchar) + '.00 '
        ELSE CAST(10 + (rn % 90) AS varchar) + '.00'
    END AS price,
    DATEADD(minute, rn, CAST('2026-02-01T09:00:00' AS datetime2)) AS updated_at
FROM n;

-- =========================================================
-- 3. ORDERS (500 rows: 200001 to 200500)
-- Mix of:
-- - clean rows
-- - null customer_id
-- - null order_status
-- - blank order_status
-- - zero amount
-- - messy amount strings
-- =========================================================
;WITH n AS (
    SELECT TOP (500) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO dbo.orders (order_id, customer_id, product_id, order_status, order_amount, created_at, updated_at)
SELECT
    200000 + rn AS order_id,
    CASE
        WHEN rn % 40 = 0 THEN NULL
        ELSE 5000 + (rn % 200)
    END AS customer_id,
    1001 + ((rn - 1) % 120) AS product_id,
    CASE
        WHEN rn % 33 = 0 THEN NULL
        WHEN rn % 22 = 0 THEN ''
        WHEN rn % 15 = 0 THEN 'shipped'
        WHEN rn % 9  = 0 THEN 'cancelled'
        ELSE 'PLACED'
    END AS order_status,
    CASE
        WHEN rn % 45 = 0 THEN '0.00'
        WHEN rn % 28 = 0 THEN 'N/A'
        WHEN rn % 17 = 0 THEN '$' + CAST(50 + (rn % 100) AS varchar) + '.00'
        WHEN rn % 12 = 0 THEN CAST(50 + (rn % 100) AS varchar) + ',00'
        ELSE CAST(50 + (rn % 100) AS varchar) + '.00'
    END AS order_amount,
    DATEADD(minute, rn, CAST('2026-02-01T10:00:00' AS datetime2)) AS created_at,
    DATEADD(minute, rn, CAST('2026-02-01T10:00:00' AS datetime2)) AS updated_at
FROM n;

-- =========================================================
-- 4. PAYMENTS (430 rows: 900001 to 900430)
-- Mix of:
-- - clean rows
-- - null payment_status
-- - zero amount
-- - messy amount strings
-- =========================================================
;WITH n AS (
    SELECT TOP (430) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO dbo.payments (payment_id, order_id, payment_status, paid_amount, processed_at)
SELECT
    900000 + rn AS payment_id,
    200000 + rn AS order_id,
    CASE
        WHEN rn % 35 = 0 THEN NULL
        WHEN rn % 18 = 0 THEN 'failed'
        WHEN rn % 12 = 0 THEN 'pending'
        ELSE 'SUCCESS'
    END AS payment_status,
    CASE
        WHEN rn % 40 = 0 THEN '0.00'
        WHEN rn % 23 = 0 THEN '??'
        WHEN rn % 16 = 0 THEN '$100.00'
        WHEN rn % 11 = 0 THEN '100,00'
        ELSE '100.00'
    END AS paid_amount,
    DATEADD(minute, rn, CAST('2026-02-01T11:00:00' AS datetime2)) AS processed_at
FROM n;