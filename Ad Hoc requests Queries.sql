use trips_db;
use targets_db;
select * from dim_city;
select * from dim_repeat_trip_distribution;
select * from fact_passenger_summary;
select * from fact_trips;

-- total trips 
select count(trip_id) as total_trip from fact_trips;
-- avg_travelled_per_km
select avg(fare_amount/distance_travelled_km) as avg_per_km from fact_trips;

-- avgerage cost for each fare
select avg(fare_amount) as _average_fare from fact_trips;

-- % contribution for all trips by city 

with cte (city, totalcount) as
 (select c.city_name , count(f.trip_id)
from dim_city c join fact_trips f 
on c.city_id = f.city_id
group by c.city_name
),
 sumofcount as (select sum(totalcount) as sumx from cte)
 select city,totalcount,(totalcount*100/sumx)as percentage_contribution from sumofcount,cte
 order by percentage_contribution desc ;
 
 -------------- BUSINESS REQUEST THREE ----
SELECT * FROM dim_repeat_trip_distribution;

with cte as (
select c.city_name,  trip_count,
100 * sum(case when t.trip_count = '2-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "2trips", 
100 * sum(case when t.trip_count = '3-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "3trips",
100 * sum(case when t.trip_count = '4-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "4trips",
100 * sum(case when t.trip_count = '5-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "5trips",
100 * sum(case when t.trip_count = '6-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "6trips",
100 * sum(case when t.trip_count = '7-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "7trips",
100 * sum(case when t.trip_count = '8-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "8trips",
100 * sum(case when t.trip_count = '9-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "9trips",
100 * sum(case when t.trip_count = '10-trips' then t.repeat_passenger_count end) / sum(p.repeat_passengers) as "10trips"
from 
dim_city c join dim_repeat_trip_distribution t join fact_passenger_summary p 
on c.city_id = t.city_id = p.city_id 
group by 1,2
)
select city_name, sum(2trips) as '2-trips', sum(3trips) as '3-trips', sum(4trips) as '4-trips', sum(5trips) as '5-trips'
, sum(6trips) as '6-trips', sum(7trips) as '7-trips',
 sum(8trips) as '8-trips', sum(9trips) as '9-trips', sum(10trips) as '10-trips'
from cte group by city_name ;


 -------------- BUSINESS REQUEST FOUR ----
 
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

 -------------- BUSINESS REQUEST FIVE ------
 SELECT * FROM fact_trips;
 

 WITH cte AS (
    select c.city_name ,
        month(t.date) AS Month_no ,
        monthname(t.date) AS Month ,
        SUM(t.distance_travelled_km * t.fare_amount) AS revenue ,
        RANK() OVER(PARTITION BY c.city_name ORDER BY SUM(t.distance_travelled_km * t.fare_amount) DESC ) AS rn
    from fact_trips t
    join dim_city c
    on t.city_id = c.city_id
    group by   c.city_name,month(t.date),monthname(t.date)
    ),
pct_contribution AS (
    select city_name ,
        Month AS highest_revenue_month ,
        revenue , 
        ROUND( 100*(revenue / SUM(revenue) OVER(PARTITION BY city_name )) , 2 ) AS percentage_contribution
        ,rn
    from cte 
    )
SELECT city_name ,
    highest_revenue_month ,
    revenue ,
    percentage_contribution
FROM pct_contribution
where rn = 1 ;

select * from monthly_target_trips;
select * from fact_trips;

----- BUSINESS REQUEST TWO -----
with cte as (select c.city_name as city ,

        monthname(t.date) AS Month ,
        t.city_id as city_id,
        count(t.trip_id) AS actual_trip
    from fact_trips t
    inner join dim_city c
    on t.city_id = c.city_id
    group by  c.city_name,t.city_id,monthname(t.date))
    
    SELECT tc.city,
    monthname(tar.month), 
    tc.actual_trip, tar.total_target_trips,
ROUND(100 * (tc.actual_trip - tar.total_target_trips) / tar.total_target_trips , 2) as Difference_pct,
CASE 
    WHEN tc.actual_trip > tar.total_target_trips THEN "Above Target"
    ELSE "Below Target" END AS "Performance"
FROM 
cte tc INNER JOIN monthly_target_trips tar 
ON tc.city_id = tar.city_id AND tc.month = monthname(tar.month) 
;
-- BUSINESS REQUEST SIX -- 
-- City Wise --
select c.city_name as city,
sum(s.total_passengers) as total_passengers, sum(s.repeat_passengers) as repeat_passengers,
concat(ROUND(100*(sum(s.repeat_passengers)/sum(s.total_passengers)),2), '%') as city_repeat_passenger_rate from
dim_city c join fact_passenger_summary s
on c.city_id= s.city_id
group by 1
;
select c.city_name as city,
monthname(s.month) as month,
sum(s.total_passengers) as total_passengers, sum(s.repeat_passengers) as repeat_passengers,
concat(ROUND(100*(sum(s.repeat_passengers)/sum(s.total_passengers)),2), '%') as city_repeat_passenger_rate from
dim_city c join fact_passenger_summary s
on c.city_id= s.city_id
group by 1,2
order by 2  desc