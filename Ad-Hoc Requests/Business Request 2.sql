

with cte (city, totalcount) as
 (select c.city_name , count(f.trip_id)
from dim_city c join fact_trips f 
on c.city_id = f.city_id
group by c.city_name
),
 sumofcount as (select sum(totalcount) as sumx from cte)
 select city,totalcount,(totalcount*100/sumx)as percentage_contribution from sumofcount,cte
 order by percentage_contribution desc ;
 
