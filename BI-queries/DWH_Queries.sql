-- Q.1: total_sales per customer
-- Total query runtime: 72 msec.
EXPLAIN ANALYZE select cd.contact_name, sum(sf.total_price) as total_sales,
		dense_rank() over(order by sum(sf.total_price) desc) as ranking
from customers_dim cd
join sales_fact sf using(cust_sk)
group by cd.contact_name
order by total_sales desc;
----------------------------------------------------------
-- Q.2: total_sales per product
-- Total query runtime: 91 msec.
EXPLAIN ANALYZE select pd.product_name, sum(sf.total_price) as total_sales,
		dense_rank() over(order by sum(sf.total_price) desc) as ranking
from products_dim pd
join sales_fact sf using(product_sk)
group by pd.product_name
order by total_sales desc;
----------------------------------------------------------
-- Q.3: count_how_many_gap_of_3_days_happened
-- Total query runtime: 71 msec.
EXPLAIN ANALYZE select count(difference) as count_3_days_diff
from
(
	select days, next_day, (next_day - days) as difference  
	from
	( 
		select sf.order_date_sk as days,  
				lead (sf.order_date_sk) over (order by sf.order_date_sk asc) as next_day  
		from sales_fact sf
	 )   
	where days <> next_day  
	order by difference desc
)
where difference = 3;
----------------------------------------------------------
-- max_consecutive_days
-- Total query runtime: 74 msec.
EXPLAIN ANALYZE with CTE as(
    select cd.contact_name, sf.order_date_sk, 
		dense_rank() over (partition by cd.contact_name order by sf.order_date_sk),
        (sf.order_date_sk - dense_rank() over (partition by contact_name order by sf.order_date_sk)) * INTERVAL '1 day' as date_check
    from sales_fact sf
	join customers_dim cd using(cust_sk)
    )

select contact_name, max(counts) as max_consecutive_days
from
(
    select contact_name, count(date_check) counts
    from cte
    group by contact_name, date_check
)
group by contact_name
order by max_consecutive_days desc;
----------------------------------------------------------
-- select top city with sales
EXPLAIN ANALYZE select ship_city, sum(total_price) as total_sales, 
	dense_rank() over (order by sum(total_price) desc) as ranking 
from sales_fact
group by ship_city;
----------------------------------------------------------
-- select top country with sales 
EXPLAIN ANALYZE select ship_country, sum(total_price) as total_sales,
		dense_rank() over (order by sum(total_price) ) as ranking 
from sales_fact 
group by ship_country  
order by total_sales desc;
----------------------------------------------------------
-- price deviation 
EXPLAIN ANALYZE with products_sales as
	(select 
	 	p.product_name, s.unit_price, d.date_actual as change_date, 
		lag( s.unit_price) over(partition by p.product_name order by d.date_actual ) as previous_price
	from products_dim as p 
	join sales_fact as s using(product_sk)
	join date_dim as d on s.order_date_sk = d.date_dim_sk)

select product_name, unit_price, change_date 
from products_sales
where unit_price <> previous_price 
OR previous_price IS NULL;
----------------------------------------------------------
--top categories 
EXPLAIN ANALYZE select 
 	category_name, sum(total_price) as total_sales , 
 	dense_rank() over (order by sum(total_price) desc) as ranking 
from sales_fact 
group by category_name;
-----------------------------------------------------------
-- RFM and customers sementation
EXPLAIN ANALYZE with RFM as (
	select distinct cd.contact_name,
		max(dd.date_actual) over(partition by cd.contact_name) as recency,
		count(sf.order_id) over(partition by cd.contact_name) as frequency,
		sum(sf.total_price) over(partition by cd.contact_name) as monerty
	from sales_fact sf
	join customers_dim cd using(cust_sk)
	join date_dim dd on dd.date_dim_sk=sf.order_date_sk
	order by cd.contact_name),
rfm_score as(
	select distinct contact_name,
	ntile(5) over(order by recency desc) as r_score,
	ntile(5) over(order by frequency desc) as f_score,
	ntile(5) over(order by monerty desc) as m_score
from RFM
)

select contact_name, r_score, f_score, m_score,
CASE  
    WHEN (r_score >= 5 AND f_score >= 5)  
        OR (r_score >= 5 AND f_score = 4)  
        OR (r_score = 4 AND f_score >= 5) THEN 'champions'  
        
    WHEN (r_score >= 5 AND f_score = 2)  
        OR (r_score = 4 AND f_score = 2)  
        OR (r_score = 3 AND f_score = 3)  
        OR (r_score = 4 AND f_score >= 3) THEN 'potential loyalists'  
        
    WHEN (r_score >= 5 AND f_score = 3)  
        OR (r_score = 4 AND f_score = 4)  
        OR (r_score = 3 AND f_score >= 5)  
        OR (r_score = 3 AND f_score >= 4) THEN 'loyal customers'  
        
    WHEN r_score >= 5 AND f_score = 1 THEN 'recent customers'  
        
    WHEN (r_score = 4 AND f_score = 1)  
        OR (r_score = 3 AND f_score = 1) THEN 'promising'  
        
    WHEN (r_score = 3 AND f_score = 2)  
        OR (r_score = 2 AND f_score = 3)  
        OR (r_score = 2 AND f_score = 2) THEN 'customers needing attention'  
        
    WHEN (r_score = 2 AND f_score >= 5)  
        OR (r_score = 2 AND f_score = 4)  
        OR (r_score = 1 AND f_score = 3) THEN 'at risk'  
        
    WHEN (r_score = 1 AND f_score >= 5)  
        OR (r_score = 1 AND f_score = 4) THEN 'cant lose them'  
        
    WHEN (r_score = 1 AND f_score = 2)  
        OR (r_score = 2 AND f_score = 1) THEN 'hibernating'  
        
    WHEN r_score = 1 AND f_score <= 1 THEN 'lost'  
        
    ELSE 'other'  
END AS cust_segment 
FROM RFM_score;
-----------------------------------------------------------