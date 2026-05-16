/* =====================================================
   PRODUCTS — product_id > 1130
   ===================================================== */

INSERT INTO dbo.products (product_id, product_name, category, price, updated_at)
VALUES
(1131, 'Product 1131', 'LIFESTYLE', '60.00', SYSDATETIME()),
(1132, 'Product 1132', 'FITNESS', '61.00', SYSDATETIME()),
(1133, 'Product 1133', 'ELECTRONICS', '62.00', SYSDATETIME()),
(1134, 'Product 1134', 'LIFESTYLE', '63.00', SYSDATETIME()),
(1135, 'Product 1135', 'FITNESS', '64.00', SYSDATETIME()),
(1136, 'Product 1136', 'ELECTRONICS', '65.00', SYSDATETIME()),
(1137, 'Product 1137', 'LIFESTYLE', '66.00', SYSDATETIME()),
(1138, 'Product 1138', 'FITNESS', '67.00', SYSDATETIME()),
(1139, 'Product 1139', 'ELECTRONICS', '68.00', SYSDATETIME()),
(1140, 'Product 1140', 'LIFESTYLE', '69.00', SYSDATETIME());


/* =====================================================
   ORDERS — order_id > 200510
   ===================================================== */

INSERT INTO dbo.orders
(order_id, customer_id, product_id, order_status, order_amount, created_at, updated_at)
VALUES
(200511, 6011, 1131, 'PLACED', '110.00', SYSDATETIME(), SYSDATETIME()),
(200512, 6012, 1132, 'SHIPPED', '111.00', SYSDATETIME(), SYSDATETIME()),
(200513, 6013, 1133, 'PLACED', '112.00', SYSDATETIME(), SYSDATETIME()),
(200514, 6014, 1134, 'PLACED', '113.00', SYSDATETIME(), SYSDATETIME()),
(200515, 6015, 1135, 'SHIPPED', '114.00', SYSDATETIME(), SYSDATETIME()),
(200516, 6016, 1136, 'PLACED', '115.00', SYSDATETIME(), SYSDATETIME()),
(200517, 6017, 1137, 'SHIPPED', '116.00', SYSDATETIME(), SYSDATETIME()),
(200518, 6018, 1138, 'PLACED', '117.00', SYSDATETIME(), SYSDATETIME()),
(200519, 6019, 1139, 'PLACED', '118.00', SYSDATETIME(), SYSDATETIME()),
(200520, 6020, 1140, 'SHIPPED', '119.00', SYSDATETIME(), SYSDATETIME());


/* =====================================================
   PAYMENTS — payment_id > 900440
   ===================================================== */

INSERT INTO dbo.payments
(payment_id, order_id, payment_status, paid_amount, processed_at)
VALUES
(900441, 200511, 'SUCCESS', '110.00', SYSDATETIME()),
(900442, 200512, 'SUCCESS', '111.00', SYSDATETIME()),
(900443, 200513, 'SUCCESS', '112.00', SYSDATETIME()),
(900444, 200514, 'SUCCESS', '113.00', SYSDATETIME()),
(900445, 200515, 'SUCCESS', '114.00', SYSDATETIME()),
(900446, 200516, 'SUCCESS', '115.00', SYSDATETIME()),
(900447, 200517, 'SUCCESS', '116.00', SYSDATETIME()),
(900448, 200518, 'SUCCESS', '117.00', SYSDATETIME()),
(900449, 200519, 'SUCCESS', '118.00', SYSDATETIME()),
(900450, 200520, 'SUCCESS', '119.00', SYSDATETIME());