/* =====================================================
   PRODUCTS — product_id > 1120
   ===================================================== */

INSERT INTO dbo.products (product_id, product_name, category, price, updated_at)
VALUES
(1121, 'Product 1121', 'ELECTRONICS', '50.00', SYSDATETIME()),
(1122, 'Product 1122', 'LIFESTYLE', '51.00', SYSDATETIME()),
(1123, 'Product 1123', 'FITNESS', '52.00', SYSDATETIME()),
(1124, 'Product 1124', 'ELECTRONICS', '53.00', SYSDATETIME()),
(1125, 'Product 1125', 'LIFESTYLE', '54.00', SYSDATETIME()),
(1126, 'Product 1126', 'FITNESS', '55.00', SYSDATETIME()),
(1127, 'Product 1127', 'ELECTRONICS', '56.00', SYSDATETIME()),
(1128, 'Product 1128', 'LIFESTYLE', '57.00', SYSDATETIME()),
(1129, 'Product 1129', 'FITNESS', '58.00', SYSDATETIME()),
(1130, 'Product 1130', 'ELECTRONICS', '59.00', SYSDATETIME());


/* =====================================================
   ORDERS — order_id > 200500
   ===================================================== */

INSERT INTO dbo.orders
(order_id, customer_id, product_id, order_status, order_amount, created_at, updated_at)
VALUES
(200501, 6001, 1121, 'PLACED', '100.00', SYSDATETIME(), SYSDATETIME()),
(200502, 6002, 1122, 'SHIPPED', '101.00', SYSDATETIME(), SYSDATETIME()),
(200503, 6003, 1123, 'PLACED', '102.00', SYSDATETIME(), SYSDATETIME()),
(200504, 6004, 1124, 'PLACED', '103.00', SYSDATETIME(), SYSDATETIME()),
(200505, 6005, 1125, 'SHIPPED', '104.00', SYSDATETIME(), SYSDATETIME()),
(200506, 6006, 1126, 'PLACED', '105.00', SYSDATETIME(), SYSDATETIME()),
(200507, 6007, 1127, 'SHIPPED', '106.00', SYSDATETIME(), SYSDATETIME()),
(200508, 6008, 1128, 'PLACED', '107.00', SYSDATETIME(), SYSDATETIME()),
(200509, 6009, 1129, 'PLACED', '108.00', SYSDATETIME(), SYSDATETIME()),
(200510, 6010, 1130, 'SHIPPED', '109.00', SYSDATETIME(), SYSDATETIME());


/* =====================================================
   PAYMENTS — payment_id > 900430
   ===================================================== */

INSERT INTO dbo.payments
(payment_id, order_id, payment_status, paid_amount, processed_at)
VALUES
(900431, 200501, 'SUCCESS', '100.00', SYSDATETIME()),
(900432, 200502, 'SUCCESS', '101.00', SYSDATETIME()),
(900433, 200503, 'SUCCESS', '102.00', SYSDATETIME()),
(900434, 200504, 'SUCCESS', '103.00', SYSDATETIME()),
(900435, 200505, 'SUCCESS', '104.00', SYSDATETIME()),
(900436, 200506, 'SUCCESS', '105.00', SYSDATETIME()),
(900437, 200507, 'SUCCESS', '106.00', SYSDATETIME()),
(900438, 200508, 'SUCCESS', '107.00', SYSDATETIME()),
(900439, 200509, 'SUCCESS', '108.00', SYSDATETIME()),
(900440, 200510, 'SUCCESS', '109.00', SYSDATETIME());