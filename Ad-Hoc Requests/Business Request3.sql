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
