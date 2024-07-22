use shop_data;
select * from buisness_data;

-- 1]find top 10 highest reveune generating products 

SELECT 
    product_id, SUM(sale_price) AS sales
FROM
    buisness_data
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- 2]find top 5 highest selling products in each region

with cte as (
select region, product_id,sum(sale_price) as sales,
row_number() over(partition by region order by sum(sale_price) desc) as ranks
from buisness_data
group by region,product_id
)
select region,product_id,sales
from cte
where ranks <=5
order by region,ranks ;


-- 3]find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as(
select year(order_date) as years,month(order_date) as months,sum(sale_price) as sales
from buisness_data
group by years,months
order by years,months
)
select months
, sum(case when years=2022 then sales else 0 end) as sales_2022
, sum(case when years=2023 then sales else 0 end) as sales_2023
from cte 
group by months
order by months;


-- 4]for each category which month had highest sales 
with cte as(
select category,month(order_date) as months,sum(sale_price) as sales
from buisness_data
group by category,months
-- order by category,months)
)
select * from(
select * , row_number() over(partition by category order by sales desc) as rn
 from cte) as a
 where rn=1;
 
 
 -- 5]which sub category had highest growth by profit in 2023 compare to 2022
 
 with cte as(
 select sub_category,year(order_date)as years,month(order_date) as months, sum(sale_price) as sales
 from buisness_data
 group by sub_category,years,months
--  order by sub_category,years,months
 )
 , cte2 as(select sub_category,
 sum(case when years=2022 then sales else 0 end) as sales_2022,
 sum(case when years=2023 then sales else 0 end) as sales_2023
 from cte
 group by sub_category
)
select sub_category,sales_2022,sales_2023,
(sales_2023-sales_2022) as sales_diff
FROM 
    cte2
ORDER BY 
    sales_diff DESC
LIMIT 1;




