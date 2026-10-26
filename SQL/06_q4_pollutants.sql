-- Q4: which pollutants drive poor-air days (AQI > 200), group A cities, 2019-2023.
-- A day is counted under every pollutant it lists, so the percentages in a row add up to more than 100.

USE aqi_india;

-- Q4a: pollutant share of all poor-air days, with and without days where CO or NO2 is the only pollutant.
WITH poor_days AS (
    SELECT a.city, a.obs_date, a.flag_sole_co_or_no2
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.aqi_value > 200
      AND a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
)
SELECT p.pollutant,
       COUNT(*)                                                                     AS poor_days_listing_it,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM poor_days), 1)                AS pct_all_poor_days,
       ROUND(100.0 * SUM(CASE WHEN pd.flag_sole_co_or_no2 = 0 THEN 1 ELSE 0 END)
             / (SELECT COUNT(*) FROM poor_days WHERE flag_sole_co_or_no2 = 0), 1)   AS pct_excl_flagged_days
FROM poor_days pd
JOIN aqi_daily_pollutants p ON p.city = pd.city AND p.obs_date = pd.obs_date
GROUP BY p.pollutant
ORDER BY poor_days_listing_it DESC;

-- Q4b: the same, by city.
WITH poor_days AS (
    SELECT a.city, a.obs_date
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.aqi_value > 200
      AND a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
)
SELECT pd.city,
       COUNT(DISTINCT pd.obs_date)                                                         AS poor_days,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'PM2.5' THEN 1 ELSE 0 END)
             / COUNT(DISTINCT pd.obs_date), 1)                                             AS pm25_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'PM10'  THEN 1 ELSE 0 END)
             / COUNT(DISTINCT pd.obs_date), 1)                                             AS pm10_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'O3'    THEN 1 ELSE 0 END)
             / COUNT(DISTINCT pd.obs_date), 1)                                             AS o3_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'CO'    THEN 1 ELSE 0 END)
             / COUNT(DISTINCT pd.obs_date), 1)                                             AS co_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'NO2'   THEN 1 ELSE 0 END)
             / COUNT(DISTINCT pd.obs_date), 1)                                             AS no2_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'SO2'   THEN 1 ELSE 0 END)
             / COUNT(DISTINCT pd.obs_date), 1)                                             AS so2_pct
FROM poor_days pd
JOIN aqi_daily_pollutants p ON p.city = pd.city AND p.obs_date = pd.obs_date
GROUP BY pd.city
ORDER BY poor_days DESC;

-- Q4c: pollutant share by season, all days.
WITH base AS (
    SELECT a.city,
           a.obs_date,
           CASE WHEN MONTH(a.obs_date) IN (12, 1, 2)  THEN 'Winter'
                WHEN MONTH(a.obs_date) IN (3, 4, 5)   THEN 'Pre-monsoon'
                WHEN MONTH(a.obs_date) IN (6, 7, 8, 9) THEN 'Monsoon'
                ELSE 'Post-monsoon' END AS season
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
),
season_days AS (
    SELECT season, COUNT(*) AS n
    FROM base
    GROUP BY season
)
SELECT b.season,
       sd.n                                                                         AS city_days,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'PM2.5' THEN 1 ELSE 0 END) / sd.n, 1) AS pm25_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'PM10'  THEN 1 ELSE 0 END) / sd.n, 1) AS pm10_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'O3'    THEN 1 ELSE 0 END) / sd.n, 1) AS o3_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'CO'    THEN 1 ELSE 0 END) / sd.n, 1) AS co_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'NO2'   THEN 1 ELSE 0 END) / sd.n, 1) AS no2_pct,
       ROUND(100.0 * SUM(CASE WHEN p.pollutant = 'SO2'   THEN 1 ELSE 0 END) / sd.n, 1) AS so2_pct
FROM base b
JOIN season_days sd ON sd.season = b.season
JOIN aqi_daily_pollutants p ON p.city = b.city AND p.obs_date = b.obs_date
GROUP BY b.season, sd.n
ORDER BY CASE b.season WHEN 'Winter' THEN 1 WHEN 'Pre-monsoon' THEN 2
                       WHEN 'Monsoon' THEN 3 ELSE 4 END;

-- Q4d: share of days where CO or NO2 is the only main pollutant, per city (data quality check).
SELECT a.city,
       d.analysis_group,
       COUNT(*)                                                       AS days,
       SUM(a.flag_sole_co_or_no2)                                     AS flagged_days,
       ROUND(100.0 * SUM(a.flag_sole_co_or_no2) / COUNT(*), 1)        AS pct_flagged
FROM aqi_daily a
JOIN city_dim d ON d.city = a.city
GROUP BY a.city, d.analysis_group
ORDER BY pct_flagged DESC;
