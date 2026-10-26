-- Post-import checks. Each result should match the expected value.

USE aqi_india;

-- Row counts
SELECT 'city_dim' AS tbl, COUNT(*) AS n, 19 AS expected FROM city_dim
UNION ALL SELECT 'aqi_daily', COUNT(*), 39431 FROM aqi_daily
UNION ALL SELECT 'aqi_daily_pollutants', COUNT(*), 62000 FROM aqi_daily_pollutants;

-- Blank station counts must be NULL, not 0
SELECT COUNT(*) AS null_station_rows, 77 AS expected
FROM aqi_daily
WHERE num_stations IS NULL;

-- Date range
SELECT MIN(obs_date) AS first_day, MAX(obs_date) AS last_day FROM aqi_daily;

-- Per-city row counts vs city_dim (should return no rows)
SELECT d.city, d.`rows` AS in_city_dim, a.n AS in_aqi_daily
FROM city_dim d
JOIN (SELECT city, COUNT(*) AS n FROM aqi_daily GROUP BY city) a ON a.city = d.city
WHERE a.n <> d.`rows`;

-- Spot check (expect 35 stations, AQI 398, Very Poor, original label Severe, PM2.5)
SELECT * FROM aqi_daily WHERE city = 'Delhi' AND obs_date = '2023-11-15';

-- Rows per year
SELECT YEAR(obs_date) AS yr, COUNT(*) AS rows_in_year
FROM aqi_daily
GROUP BY YEAR(obs_date)
ORDER BY yr;
