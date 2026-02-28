/* 
1. Amount Sold by Product 
This query groups items by product_id and then lists the amount sold of each item, presenting it as the amount sold in descending order. 
*/
SELECT 
   	order_items.product_id,
   	SUM(order_items.quantity) AS total_sold
FROM order_items 
JOIN (
SELECT order_id
FROM orders
ORDER BY order_id DESC
LIMIT 1000
) recent_orders
ON order_items.order_id = recent_orders.order_id
GROUP BY order_items.product_id
ORDER BY total_sold ASC
LIMIT 1000;
*/
2. Low Sales Products
This query groups the products like the one used above, only returning the products with two or less total sales. This will be used for Tableau. It’s LEFT JOINed to allow for zero sales too.
*/
SELECT 
    p.product_id,
    p.product_name AS 'Name of Product',
    c.category_name AS 'Bike Type',
    COALESCE(ws.total_sold, 0) AS total_sold
FROM products p
JOIN categories c 
    ON p.category_id = c.category_id
LEFT JOIN (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) AS total_sold
    FROM order_items oi
    JOIN (
        SELECT order_id
        FROM orders
        ORDER BY order_id DESC
        LIMIT 1000
    ) recent_orders
        ON oi.order_id = recent_orders.order_id
    GROUP BY oi.product_id
) ws
    ON p.product_id = ws.product_id
WHERE COALESCE(ws.total_sold, 0) <= 2
ORDER BY total_sold ASC;The following query is used to join categories and products to see the product id, name of the product, and the type of bike it is.
SELECT 
products.product_id, 
products.product_name AS 'Name of Product', 
categories.category_name AS 'Bike Type'
FROM products
INNER JOIN categories
ON products.category_id = categories.category_id;
*/
3. Total Paid Per Order
This query is used to determine the total amount paid before and after discount for each order and shows how many items were in the order. Grouped by the order id. It also makes sure no NULL values are generated in Discount.
*/
SELECT 
order_id AS 'Order ID', 
SUM(quantity) AS 'Total Items', 
SUM(list_price * quantity) AS 'Total Before Discount', 
ROUND(SUM(list_price * quantity * (1 - COALESCE(discount, 0))),  2 ) AS 'Total After Discount'
FROM order_items
GROUP BY order_id;
*/
4. Order Lookup
This query is used to check previous orders. Can change the WHERE statement to search for customer names or any other order id as required. 
*/
SELECT 
CONCAT(first_name, ' ', last_name) AS 'Full Name',
customers.customer_id, 
CONCAT(city, ' ', state, ' ', zip_code) AS 'Delivery Information',
street,
orders.order_id,
orders.order_date,
orders.shipped_date,
orders.store_id
FROM customers
INNER JOIN orders
ON customers.customer_id = orders.customer_id
WHERE orders.order_id = 6;
*/
5. Lowest Sales by Item
This query does the top ten lowest items in terms of sales by revenue, starting with the lowest. You can switch it from ASC to DESC to check the highest 10 or change it from 10 very easily if you want more. 
*/
SELECT 
    order_items.product_id,
    SUM(order_items.quantity * order_items.list_price) AS total_revenue
FROM order_items 
GROUP BY order_items.product_id
ORDER BY total_revenue ASC
LIMIT 10;
*/
6. Tableau Data
This query is only used for data visualization in Tableau.
*/
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_revenue
FROM order_items oi
JOIN orders o 
    ON oi.order_id = o.order_id
JOIN products p 
    ON oi.product_id = p.product_id
JOIN categories c 
    ON p.category_id = c.category_id
GROUP BY 
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY 
	total_revenue DESC;
