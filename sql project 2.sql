select * from customer_details
select * from product_details
select * from sales_details


--Use a CASE statement to categorize customers based on their total purchase amount 
--into 'High', 'Medium', and 'Low'.

with total_sales as (
select cd.cust_id, cd.cust_address, sum(pd.product_price * sd.product_quantity) as total_amount
from customer_details as cd
join  sales_details as sd
on cd.cust_id = sd.cust_id
join product_details as pd
on sd.product_id = pd.product_id
group by cd.cust_id, cd.cust_address)
select cust_id , cust_address, total_amount ,
   case 
      when total_amount > 10000 then 'High'
	  when total_amount between 5000 and 10000 then 'Medium'
	  else 'low'
	  end as category 
from total_sales 
order by total_amount desc;

--Use a window function to rank customers based on their total purchase amount.

with total_sales as (
select cd.cust_id, cd.cust_address, sum(pd.product_price * sd.product_quantity) as total_amount
from customer_details as cd
join  sales_details as sd
on cd.cust_id = sd.cust_id
join product_details as pd
on sd.product_id = pd.product_id
group by cd.cust_id, cd.cust_address)

select cust_id , cust_address, total_amount,
       rank() over (order by total_amount desc) as rank
from total_sales

--Find the customers who bought the most expensive product in each category.

select cd.cust_id , pd.product_id , pd.product_name
from customer_details as cd
join  sales_details as sd
on cd.cust_id = sd.cust_id
join product_details as pd
on sd.product_id = pd.product_id
where pd.product_price = (select max(pd.product_price)
                          from product_details as pd)

--find how many number of  customers who's product_quantity more than one purchase.

select count(*)
from customer_details as cd
join sales_details as sd 
on cd.cust_id = sd.cust_id
where sd.product_quantity > 1

--Rank products within each category based on their total sales.

select sd.product_id , pd.product_name, 
       sum(sd.product_quantity * pd.product_price) as total_amount,
	   rank() over (partition by pd.product_name order by sum(sd.product_quantity * pd.product_price) desc) as rank
from sales_details as sd
join product_details as pd
on sd.product_id = pd.product_id
group by sd.product_id , pd.product_name

-- Get the total sales by product name and including all combinations of subtotals.

select sd.product_id , pd.product_name, sum(sd.product_quantity * pd.product_price) as total_amount
from sales_details as sd
join product_details as pd
on sd.product_id = pd.product_id
group by sd.product_id , pd.product_name
order by total_amount desc

--Write a query using a FULL OUTER JOIN to show all customers and their purchase history, 
--including those with no purchases and products not purchased.

select cd.cust_id, cd.cust_address, cd.cust_age, sd.order_id, sd.product_id, sd.order_date,
        pd.product_id, pd.product_name,
         sum(sd.product_quantity * pd.product_price) as total_amount
from customer_details as cd
full outer join  sales_details as sd
on cd.cust_id = sd.cust_id
full outer join product_details as pd
on sd.product_id = pd.product_id 
group by  cd.cust_id, cd.cust_address, cd.cust_age, 
       sd.order_id, sd.product_id, sd.order_date, 
	    pd.product_id, pd.product_name
order by total_amount desc
	   
--write a query to index all the tables to fetch the data quick and easy.

create index cust_id on customer_details(cust_id)
create index product_id on product_details(product_id)
create index order_date on sales_details(order_date)

-- find the total number of customers and total orders and total products and total_revenue

select  count(distinct(cd.cust_id)) as total_customers, 
        count(distinct(sd.order_id)) as total_orders, 
	    count(distinct(sd.product_id)) as total_products,
        sum(sd.product_quantity * pd.product_price) as total_revenue
from customer_details as cd
join  sales_details as sd
on cd.cust_id = sd.cust_id
join product_details as pd
on sd.product_id = pd.product_id

--Write a CTE to find the total sales amount for each customer.

with total_sales as (
select sd.cust_id , sum(sd.product_quantity * pd.product_price) as total_amount
from sales_details as sd
join product_details as pd
on sd.product_id = pd.product_id
group by sd.cust_id
order by total_amount desc )
select * from total_sales