SELECT 
    city.city_name,
    COUNT(trips.trip_id) AS total_trips,
    ROUND(SUM(trips.fare_amount) / SUM(trips.distance_travelled_km),2) AS avg_fare_per_km,
    ROUND(SUM(trips.fare_amount) / COUNT(trips.trip_id),2) AS avg_fare_per_trip,
    CONCAT(ROUND((COUNT(trips.trip_id) / (SELECT COUNT(*) FROM fact_trips)) * 100.0, 2), ' %') AS percentage_contribution_to_total_trips
FROM
    dim_city city
        LEFT JOIN
    fact_trips trips ON city.city_id = trips.city_id
GROUP BY city.city_name;
