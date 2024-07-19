CREATE DATABASE pizza_database;
USE pizza_database;


-- 1)Retrieve total number of oredered placed

SELECT count(order_id) AS Total_orders FROM orders;



-- 2)Calculate total revenvue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    
    
-- 3)Calculate the highest priced pizza

SELECT 
    pizzas.price, pizza_types.name
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Identify most common pizza size ordered

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;
    
    


-- 4)List the top 5 most ordered pizza types along with there quantity

SELECT 
    SUM(order_details.quantity) AS total_quantity,
    pizza_types.name AS pizza_name
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_name
ORDER BY total_quantity DESC
LIMIT 5;





-- 5)Join the necessary tables to find the total quantity of each pizza Category ordered

SELECT 
	SUM(order_details.quantity) AS total_quantity,
    pizza_types.category AS pizza_category
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_category
ORDER BY total_quantity DESC;




-- 6)Determine the distribution of order by hour of the day

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY order_count DESC;



-- 7) Join relevant tables to find the category wise distribution of pizzas

SELECT category , count(name) FROM pizza_types
GROUP BY category;



-- 8)Calculate the orders by date and Calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_ordered_pizza_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS order_quantity;



-- 8) Determine the top 3 ordered pizza based on revenue

SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- 9)Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price)
             / (SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id )*100 ,2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



-- 10) Calculate the cumulative revenue generated over time.

SELECT order_date ,  SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue FROM
(SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS sales;



-- 11) Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT category,name,revenue FROM
(SELECT category,name,revenue , RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn FROM
(SELECT pizza_types.category,pizza_types.name, SUM((order_details.quantity) * pizzas.price) AS revenue 
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY  pizza_types.category,pizza_types.name) AS a) AS b
WHERE rn <=3;