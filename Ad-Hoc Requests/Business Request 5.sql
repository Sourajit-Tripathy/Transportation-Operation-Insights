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
