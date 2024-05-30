create database pizza_project
select * from pizza_project.dbo.order_details
select * from pizza_project.dbo.orders
select * from pizza_project.dbo.pizza_types
select * from pizza_project.dbo.pizzas

****Total no of orders placed
select count(*) from pizza_project.dbo.orders

****identify most common pizza size ordered
select count(p.size ) as no_of_pizzas,p.size from
pizza_project.dbo.order_details od inner join pizza_project.dbo.pizzas p
on od.pizza_id=p.pizza_id 
group by p.size
order by count(p.size) desc


****total revenue generated from pizza sales

select round(sum(p.price*od.quantity),2)as revenue_generated from
pizza_project.dbo.order_details od inner join pizza_project.dbo.pizzas p
on od.pizza_id=p.pizza_id

select od.pizza_id,round(sum(p.price*od.quantity),2)as revenue_generated from
pizza_project.dbo.order_details od inner join pizza_project.dbo.pizzas p
on od.pizza_id=p.pizza_id
group by od.pizza_id
order by revenue_generated desc

***Identify the highest priced pizza
select top(1) pizza_id ,round(price,1)as price from pizza_project.dbo.pizzas
group by pizza_id,price
having price=max(price)
order by price desc

***list the top 5 ordered pizza types along with their quantity
select top (5) p.pizza_type_id,od.quantity from 
pizza_project.dbo.pizzas p inner join 
pizza_project.dbo.order_details od 
on p.pizza_id=od.pizza_id,
pizza_project.dbo.pizzas as pz inner join pizza_project.dbo.pizza_types pt
on pz.pizza_type_id=pt.pizza_type_id
group by p.pizza_type_id,od.quantity
order by od.quantity desc


#### Total quantity of each pizza category ordered

select  p.pizza_type_id,sum(od.quantity ) as total_quantity from 
pizza_project.dbo.pizzas p inner join 
pizza_project.dbo.order_details od 
on p.pizza_id=od.pizza_id,
pizza_project.dbo.pizzas as pz inner join pizza_project.dbo.pizza_types pt
on pz.pizza_type_id=pt.pizza_type_id
group by p.pizza_type_id
order by total_quantity desc

####  Determine the distribution of orders by hour of day
select  count(order_id )as no_of_orders,DATEPART(hour,time )as hour from pizza_project.dbo.orders
group by DATEPART(hour,time )
order by no_of_orders desc

#### group orders by date and find average pizza orders per day
with cte as(
select  count(o.order_id )as no_of_orders,DATEPART(DAY,date )as date 
from pizza_project.dbo.orders o inner join pizza_project.dbo.order_details od
on od.order_id=o.order_id
group by DATEPART(DAY,date))
select AVG(no_of_orders),DATEPART(DAY,date )as date  from cte 
group by DATEPART(DAY,date)
order by DATEPART(DAY,date)

#### Find category wise distribution of pizza
select  pt.category ,count(od.quantity)as quantity  from pizza_project.dbo.pizzas p 
inner join pizza_project.dbo.order_details od 
on od.pizza_id=p.pizza_id
inner join pizza_project.dbo.pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category

select category,count(category)as category_count from pizza_project.dbo.pizza_types
group by category

Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)

select p.pizza_type_id,round(sum(p.price*od.quantity),2)as categorywise_revenue_generated from
pizza_project.dbo.order_details od inner join pizza_project.dbo.pizzas p
on od.pizza_id=p.pizza_id
group by p.pizza_type_id
order by round(sum(p.price*od.quantity),2)

select p.pizza_type_id,concat(cast((sum(p.price*od.quantity)/( select round(sum(p.price*od.quantity),2)
 from pizza_project.dbo.order_details od inner join pizza_project.dbo.pizzas p
on od.pizza_id=p.pizza_id))*100 as decimal(10,2)),'%')as category_wise_revenue_generated from pizza_project.dbo.pizzas p 
inner join pizza_project.dbo.order_details od 
on od.pizza_id=p.pizza_id
inner join pizza_project.dbo.pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by p.pizza_type_id
order by  category_wise_revenue_generated desc




select * from pizza_project.dbo.order_details
select * from pizza_project.dbo.pizzas




Analyze the cumulative revenue generated over time.
with cte1 as
(select datepart(hour,o.time)as hour ,round(sum(od.quantity*p.price),2)as revenue_generated from
pizza_project.dbo.order_details od inner join pizza_project.dbo.orders o
on od.order_id=o.order_id
inner join pizza_project.dbo.pizzas p
on od.pizza_id=p.pizza_id
group by datepart(hour,o.time))
select *,sum(revenue_generated) over(order by hour)as cumulative_revenue from cte1
group by hour ,revenue_generated


Determine the top 3 most ordered pizza types based on revenue for each pizza category (In each category which pizza is the most selling)
with cte1 as(select  pt.category,pt.name,round(sum(od.quantity*p.price),2)as revenue_generated from pizza_project.dbo.pizzas p 
inner join pizza_project.dbo.order_details od 
on od.pizza_id=p.pizza_id
inner join pizza_project.dbo.pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category,pt.name)
,cte2 as
(select *, rank() over (partition by category order by revenue_generated desc) as rank from cte1)
select * from cte2 where rank in(1,2,3)
order by category,name,revenue_generated desc



