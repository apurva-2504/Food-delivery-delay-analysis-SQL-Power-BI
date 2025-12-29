
DROP TABLE IF EXISTS deliveries_raw;

CREATE TABLE deliveries_raw (
    order_id TEXT,
    order_datetime TEXT,
    day_of_week TEXT,
    hour_of_day TEXT,
    is_weekend TEXT,
    is_peak_hour TEXT,
    month TEXT,
    restaurant_id TEXT,
    restaurant_locality TEXT,
    cuisine_type TEXT,
    delivery_locality TEXT,
    distance_km TEXT,
    partner_id TEXT,
    vehicle_type TEXT,
    partner_experience_months TEXT,
    weather_condition TEXT,
    order_value_inr TEXT,
    estimated_prep_time_min TEXT,
    estimated_delivery_time_min TEXT,
    actual_delivery_time_min TEXT,
    estimated_delivery_datetime TEXT,
    actual_delivery_datetime TEXT,
    delay_minutes TEXT,
    is_delayed TEXT,
    delay_category TEXT,
    distance_bin TEXT,
    experience_bin TEXT,
    value_bin TEXT
);


CREATE INDEX idx_order_datetime ON deliveries(order_datetime);
CREATE INDEX idx_restaurant_locality ON deliveries(restaurant_locality);
CREATE INDEX idx_weather ON deliveries(weather_condition);
CREATE INDEX idx_hour ON deliveries(hour_of_day);
CREATE INDEX idx_delay ON deliveries(is_delayed);

SELECT COUNT(*) FROM deliveries_raw;

SELECT * FROM deliveries_raw LIMIT 5;


DROP TABLE IF EXISTS deliveries;

CREATE TABLE deliveries (
    order_id TEXT PRIMARY KEY,
    order_datetime TIMESTAMP,
    day_of_week TEXT,
    hour_of_day INT,
    is_weekend BOOLEAN,
    is_peak_hour BOOLEAN,
    month INT,
    restaurant_id TEXT,
    restaurant_locality TEXT,
    cuisine_type TEXT,
    delivery_locality TEXT,
    distance_km NUMERIC(6,2),
    partner_id TEXT,
    vehicle_type TEXT,
    partner_experience_months INT,
    weather_condition TEXT,
    order_value_inr NUMERIC(10,2),
    estimated_prep_time_min INT,
    estimated_delivery_time_min INT,
    actual_delivery_time_min INT,
    estimated_delivery_datetime TIMESTAMP,
    actual_delivery_datetime TIMESTAMP,
    delay_minutes INT,
    is_delayed BOOLEAN,
    delay_category TEXT,
    distance_bin TEXT,
    experience_bin TEXT,
    value_bin TEXT
);

SET datestyle = 'DMY';

INSERT INTO deliveries
SELECT
    order_id,
    order_datetime::TIMESTAMP,
    day_of_week,
    hour_of_day::INT,
    is_weekend::BOOLEAN,
    is_peak_hour::BOOLEAN,
    month::INT,
    restaurant_id,
    restaurant_locality,
    cuisine_type,
    delivery_locality,
    distance_km::NUMERIC,
    partner_id,
    vehicle_type,
    partner_experience_months::INT,
    weather_condition,
    order_value_inr::NUMERIC,
    estimated_prep_time_min::INT,
    estimated_delivery_time_min::INT,
    actual_delivery_time_min::INT,
    estimated_delivery_datetime::TIMESTAMP,
    actual_delivery_datetime::TIMESTAMP,
    delay_minutes::INT,
    is_delayed::BOOLEAN,
    delay_category,
    distance_bin,
    experience_bin,
    value_bin
FROM deliveries_raw;

SELECT COUNT(*) FROM deliveries;
SELECT * FROM deliveries LIMIT 10;

-- Null values
SELECT
COUNT(*)- COUNT(order_id) as null_order_id,
COUNT(*)- COUNT(delay_minutes) as null_delay,
COUNT(*)- COUNT(weather_condition) as null_weather,
COUNT(*)- COUNT(restaurant_locality) as null_locality
FROM deliveries;

--performance summary
SELECT
'Overall Performance ' as metric,
COUNT(*) AS total_orders,
SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) AS delayed_orders,
ROUND(100.0 *SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2 ) AS delay_percentage,
ROUND (AVG(delay_minutes),2) as avg_delay_minutes,
ROUND(AVG(distance_km),2) AS avg_distance_km
FROM deliveries;

--weather impact
SELECT
weather_condition,
COUNT(*) AS total_orders,
SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) AS delayed_orders,
ROUND(100.0 *SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2 ) AS delay_percentage,
ROUND (AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY weather_condition
ORDER BY delay_percentage DESC;

--percentage increase from clear to rainy weather 
WITH weather_Stats AS(
SELECT
weather_condition,
ROUND(100.0 *SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2 ) AS delay_percentage
FROM deliveries
GROUP BY weather_condition
)
SELECT 
w1.weather_condition as rainy_weather,
w1.delay_percentage as rainy_delay_percentage,
w2.weather_condition as clear_weather,
w2.delay_percentage as clear_delay_percentage,
ROUND((w1.delay_percentage - w2.delay_percentage / w2.delay_percentage)*100,2) as percentage_increase
FROM weather_stats w1
CROSS JOIN weather_stats w2
WHERE w1.weather_condition LIKE '%Rain%'
AND w2.weather_condition = 'Clear';

--peak hour impact
SELECT 
CASE WHEN is_peak_hour THEN 'Peak Hours (12-2pm, 7-9pm)'
ELSE 'Non-Peak Hours'
END AS hour_type,
COUNT(*) AS total_orders,
COUNT(*) AS total_orders,
SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) AS delayed_orders,
ROUND(100.0 *SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2 ) AS delay_percentage,
ROUND (AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY is_peak_hour
ORDER BY is_peak_hour DESC;

-- hourly breakdown
SELECT 
hour_of_day,
COUNT(*) AS total_orders,
ROUND(100.0 * SUM (CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes,
CASE 
WHEN hour_of_day IN (12,13,14) THEN 'Lunch hour peak time'
WHEN hour_of_day IN (19,20,21) THEN ' Diner hour peak time'
ELSE 'Regular'
END as period_type
FROM deliveries
GROUP BY hour_of_day
ORDER BY hour_of_day;

--best performing localities
SELECT 
restaurant_locality,
COUNT(*) AS total_orders,
ROUND(AVG(distance_km), 2) as avg_distance,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) / COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY restaurant_locality
HAVING COUNT(*) >= 20 
ORDER BY delay_percentage ASC
LIMIT 10;

-- Worst performing localities
SELECT 
restaurant_locality,
COUNT(*) AS total_orders,
ROUND(AVG(distance_km), 2) as avg_distance,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) / COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY restaurant_locality
HAVING COUNT(*) >= 20 
ORDER BY delay_percentage DESC
LIMIT 10;

--delay by distance range
SELECT 
CASE 
WHEN distance_km <= 3 THEN '0-3 Km'
WHEN distance_km <= 5 THEN '3-5 Km'
WHEN distance_km <= 8 THEN '5-8 Km'
WHEN distance_km <= 12 THEN '8-12 Km'
ELSE '12+ Km'
END as distance_range,
COUNT(*) AS total_orders,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2)AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes,
ROUND(AVG(distance_km),2) as avg_distance
FROM deliveries
GROUP BY 
CASE 
WHEN distance_km <= 3 THEN '0-3 Km'
WHEN distance_km <= 5 THEN '3-5 Km'
WHEN distance_km <= 8 THEN '5-8 Km'
WHEN distance_km <= 12 THEN '8-12 Km'
ELSE '12+ Km'
END
ORDER BY avg_distance;

--weekend vs weekday analysis
SELECT 
CASE WHEN is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
COUNT(*) as total_orders,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*) ,2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY is_weekend;

-- week pattern analysis
SELECT 
day_of_week,
COUNT(*) AS total_orders,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2)AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes,
CASE WHEN is_weekend THEN 'weekend' ELSE 'weekday' END AS day_category
FROM deliveries
GROUP BY day_of_week, is_weekend
ORDER BY
CASE day_of_week
WHEN 'Monday' THEN 1
WHEN 'Tuesday' THEN 2
WHEN 'Wednesday' THEN 3
WHEN 'Thursday' THEN 4
WHEN 'Friday' THEN 5
WHEN 'Saturday' THEN 6
WHEN 'Sunday' THEN 7

END;

-- cuisine wise performance analysis
SELECT 
cuisine_type,
COUNT
(*) AS total_orders,
ROUND(AVG(estimated_prep_time_min),2) as avg_prep_time,
ROUND(100.0*SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/ COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries 
GROUP BY  cuisine_type
ORDER BY delay_percentage DESC;

--Vehicle type performance analysis
SELECT
vehicle_type,
COUNT(*) AS total_deliveries,
ROUND(AVG(distance_km),2) as avg_distance,
ROUND(100.0 * SUM (CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes), 2) as avg_delay_minutes
FROM deliveries
GROUP BY vehicle_type
ORDER BY delay_percentage DESC;

-- weather and peak hour correlation 
SELECT weather_condition,
CASE WHEN is_peak_hour THEN 'Peak Hour' ELSE 'Non-Peak' END as hour_type,
COUNT(*) as total_orders,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY weather_condition , is_peak_hour
ORDER BY delay_percentage DESC;


-- creating views for POWER BI visualization
--View 1 : summary
CREATE OR REPLACE VIEW v_summary AS
SELECT 
    DATE(order_datetime) as order_date,
    day_of_week,
    COUNT(*) as total_orders,
    SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) as delayed_orders,
    ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) / COUNT(*), 2) as delay_percentage,
    ROUND(AVG(delay_minutes), 2) as avg_delay_minutes
FROM deliveries
GROUP BY DATE(order_datetime), day_of_week
ORDER BY order_date;

--View 2 : hourly patterns
CREATE OR REPLACE VIEW v_hourly_patterns AS
SELECT
hour_of_day,
day_of_week,
is_peak_hour,
COUNT(*) AS total_orders,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2) AS delivery_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY hour_of_day, day_of_week,is_peak_hour
ORDER BY hour_of_day;

--view 3: locality performance
CREATE OR REPLACE VIEW v_locality_performance AS
SELECT 
restaurant_locality,
COUNT(*) AS total_orders,
ROUND(AVG(distance_km), 2) as avg_distance,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) / COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY restaurant_locality
HAVING COUNT(*) >= 10;

--view 4 : weather impact
CREATE OR REPLACE VIEW v_weather_impact AS
SELECT weather_condition,
is_peak_hour,
COUNT(*) as total_orders,
ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END)/COUNT(*),2) AS delay_percentage,
ROUND(AVG(delay_minutes),2) as avg_delay_minutes
FROM deliveries
GROUP BY weather_condition , is_peak_hour;

SELECT 'v_daily_summary' as view_name, COUNT(*) as record_count FROM v_summary
UNION ALL
SELECT 'v_hourly_patterns', COUNT(*) FROM v_hourly_patterns
UNION ALL
SELECT 'v_locality_performance', COUNT(*) FROM v_locality_performance
UNION ALL
SELECT 'v_weather_impact', COUNT(*) FROM v_weather_impact;

CREATE OR REPLACE VIEW v_deep_dive_analysis AS
SELECT
    DATE(order_datetime) AS order_date,
    day_of_week,
    hour_of_day,
    weather_condition,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(AVG(delay_minutes), 2) AS avg_delay_minutes
FROM deliveries
GROUP BY
    DATE(order_datetime),
    day_of_week,
    hour_of_day,
    weather_condition;


SELECT * 
FROM v_deep_dive_analysis
LIMIT 10;

