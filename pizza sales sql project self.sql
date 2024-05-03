create database pizza_sales
use  pizza_sales

select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where table_name='pizza_types'

select * from pizzas

alter table pizzas
alter column price decimal(10,2)

/*Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.*/

--Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders

--Calculate the total revenue generated from pizza sales.
select sum(p.price*od.quantity) total_revenue from pizzas p
join order_details od
on p.pizza_id=od.pizza_id

--Identify the highest-priced pizza.
select  top 1 pt.name,max(price) high_price_pizza from pizzas p
join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by high_price_pizza desc

select max(price) from pizzas 

--Identify the most common pizza size ordered.
select top 1 size, count(size) total_ordered from pizzas
group by size
order by count(size) desc

--List the top 5 most ordered pizza types along with their quantities
select top 5 p.pizza_type_id,sum(od.quantity) pizza_ordered from pizzas p
join order_details od
on p.pizza_id=od.pizza_id
group by p.pizza_type_id,od.quantity
order by count(p.pizza_type_id) desc


/*Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.*/

--Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category,sum(od.quantity) total_quantity from pizza_types pt
join pizzas p
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on od.pizza_id=p.pizza_id
group by pt.category

select * from order_details
select * from pizza_types

select category,sum(category) total_quantity from pizza_types 
group by category

--Determine the distribution of orders by hour of the day.
select datepart(hour,time) hour_of_day , count(order_id) total_orders from orders
group by datepart(hour,time)

--Join relevant tables to find the category-wise distribution of pizzas.
select pt.category ,count(p.pizza_id) pizza_quantity from pizza_types pt
join pizzas p
on p.pizza_type_id=pt.pizza_type_id
group by pt.category

select category ,count(name) pizza_quantity from pizza_types 
group by category
select * from pizzas
select * from pizza_types

--Group the orders by date and calculate the average number of pizzas ordered per day


with cte as(select o.date date,sum(od.quantity) total from orders o
join order_details od
on o.order_id=od.order_id
group by  o.date)

select avg(total) from cte


select * from orders

--Determine the top 3 most ordered pizza types based on revenue.*
select top 3 p.pizza_type_id,sum(p.price*od.quantity) revenue from pizzas p
join order_details od
on p.pizza_id=od.pizza_id
group by p.pizza_type_id
order by revenue desc


/*Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/


--Calculate the percentage contribution of each pizza type to total revenue.

 with cte as(select  pt.category ,sum(p.price*od.quantity) revenue from pizzas p
 join pizza_types pt
 on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.category)

select *,revenue*100/(select sum(p.price*od.quantity)  from pizzas p
join order_details od
on p.pizza_id=od.pizza_id) as percentage from cte

--Analyze the cumulative revenue generated over date.
with str1 as(select o.date date,sum(p.price*od.quantity) revenue from order_details od
join orders o
on o.order_id=od.order_id
join pizzas p
on p.pizza_id=od.pizza_id
group by o.date)
 select date,sum(revenue) over (order by date) cr from str1

 --
--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as(select  pt.category,pt.name,sum(p.price*od.quantity)  revenue,row_number() over (partition by category order by sum(p.price*od.quantity) desc ) r1 from pizzas p
join pizza_types pt
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.category,pt.name)

select category,name,revenue from cte
where r1<=3


select distinct category from pizza_types