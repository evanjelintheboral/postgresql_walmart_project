select * from walmart;
select count(*) from walmart;
select distinct payment_method from walmart; 
select 
    payment_method,count(*)
	from walmart
	group by payment_method;
select count(distinct branch) from walmart;
select max(quantity) from walmart;

--business problems
-- Q 1.find different payment method and number of transaction,number of qty sold

select
    payment_method,
	count(*) as num_of_transactions,
	sum(quantity) as no_of_qty_sold
	from walmart
	group by payment_method;

--Q 2.identify the highest - rated category in each branch,displaying the branch,category,avg rating
select * from
(select
     branch,
	 category,
	 avg(rating) as avg_rating,
	 rank() over(partition by branch order by avg(rating) desc) as rank
	 from walmart
	 group by branch,category
	)where rank=1;

--Q3.identify the busiest day for each branch based on the number of transactions
select * from
(select
    branch,
	to_char(to_date(date,'dd/mm/yy'),'Day') as day_name,
	count(*) as no_transactions,
	rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by 1,2)
	where rank=1


-- Q4.calculate the total quantity of items sold per payment method.list payment_ method and total quantity.

select 
   payment_method,
   sum(quantity) as quantity
   from walmart
   group by payment_method


--Q 5.determine the average,min,max rating of product for each city
--list the city,average_rating,min_rating,max_rating

select
    city,
	category,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
	from walmart
	group by 1,2;

--Q6.calculate the total profit for each category by considering total profit as (unit_price*quantity*profit margin).
--list category and total profit,ordered from highest to lowest profit

select
    category,
	sum(total) as total_revenue,
	sum(total * profit_margin) as profit
	from walmart
	group by 1;


--Q7.determine the most common payment method for each branch
--display branch and the preferred_payment_method

select * from(
select
    branch,
	payment_method,
	count(*) as total_trans,
	rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by 1,2
)where rank=1;


--Q8.categorize sales into 3 group morn,aftn,even
--find out each of the shift and num of invoices

SELECT
  branch,
  CASE

       WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
       WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
       ELSE 'Evening'
  END day_time,
  count(*)
  FROM walmart

GROUP BY 1,2
order by 1,3 desc


--Q9.identify 5 branch with highest decrese ratio in revenue copare to last year(current yr 2023 and last year 2022)
--rdr = last_rev-cr_rev/last_rev * 100
select*,
   extract(year from to_date(date,'dd/mm/yy')) as formated_date
   from walmart
--2022 sales
with revenue_2022 as(
select
   branch,
   sum(total) as revenue
   from walmart
   where extract(year from to_date(date,'dd/mm/yy'))  = 2022
   group by 1
),
 revenue_2023 as(
select
   branch,
   sum(total) as revenue
   from walmart
   where extract(year from to_date(date,'dd/mm/yy'))  = 2023
   group by 1
)
select 
  ls.branch,
  ls.revenue as last_year_revenue,
  cs.revenue as cr_year_revenue,
  round(
       (ls.revenue - cs.revenue)::numeric/
	   ls.revenue::numeric * 100,
	   2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch=cs.branch
where 
    ls.revenue>cs.revenue
order by 4 desc limit 5;
