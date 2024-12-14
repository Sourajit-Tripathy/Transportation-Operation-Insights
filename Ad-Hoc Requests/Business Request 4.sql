(select city_id,total_new, case
when rnk in(1,2,3) then 'Top 3'
 end  as category from (select city_id, sum(new_passengers) as total_new ,
rank()over(order by sum(new_passengers) desc) as rnk
from fact_passenger_summary  group by city_id) a 
limit 3)
UNION ALL
(select city_id,total_new, case
when rnk in(1,2,3) then 'bottom 3'
 end  as category from (select city_id, sum(new_passengers) as total_new ,
rank()over(order by sum(new_passengers) ) as rnk
from fact_passenger_summary  group by city_id) a 
limit 3 );
