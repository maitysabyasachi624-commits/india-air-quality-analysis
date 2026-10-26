-- Q3: how AQI changes through the year (group A cities, 2019-2023).
-- Seasons: Winter Dec-Feb, Pre-monsoon Mar-May, Monsoon Jun-Sep, Post-monsoon Oct-Nov.

USE aqi_india;

-- Q3a: average AQI by month, all group A cities pooled.
-- month_no is built in a CTE so GROUP BY passes MySQL strict mode.
WITH base AS (
    SELECT MONTH(a.obs_date) AS month_no,
           a.aqi_value
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
)
SELECT month_no,
       SUBSTRING('JanFebMarAprMayJunJulAugSepOctNovDec', (month_no - 1) * 3 + 1, 3)   AS month_name,
       COUNT(*)                                                                       AS city_days,
       ROUND(AVG(aqi_value), 1)                                                       AS avg_aqi,
       ROUND(100.0 * SUM(CASE WHEN aqi_value > 200 THEN 1 ELSE 0 END) / COUNT(*), 1)  AS pct_days_poor_or_worse
FROM base
GROUP BY month_no
ORDER BY month_no;

-- Q3b: average AQI by city and month (heatmap data).
WITH base AS (
    SELECT a.city,
           MONTH(a.obs_date) AS month_no,
           a.aqi_value
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
)
SELECT city,
       month_no,
       SUBSTRING('JanFebMarAprMayJunJulAugSepOctNovDec', (month_no - 1) * 3 + 1, 3)   AS month_name,
       COUNT(*)                                                                       AS days_with_data,
       ROUND(AVG(aqi_value), 1)                                                       AS avg_aqi
FROM base
GROUP BY city, month_no
ORDER BY city, month_no;

-- Q3c: average AQI by city and season.
WITH seasonal AS (
    SELECT a.city,
           CASE WHEN MONTH(a.obs_date) IN (12, 1, 2)  THEN 'Winter'
                WHEN MONTH(a.obs_date) IN (3, 4, 5)   THEN 'Pre-monsoon'
                WHEN MONTH(a.obs_date) IN (6, 7, 8, 9) THEN 'Monsoon'
                ELSE 'Post-monsoon' END                                    AS season,
           a.aqi_value
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
)
SELECT city,
       ROUND(AVG(CASE WHEN season = 'Winter'       THEN aqi_value END), 1) AS winter,
       ROUND(AVG(CASE WHEN season = 'Pre-monsoon'  THEN aqi_value END), 1) AS pre_monsoon,
       ROUND(AVG(CASE WHEN season = 'Monsoon'      THEN aqi_value END), 1) AS monsoon,
       ROUND(AVG(CASE WHEN season = 'Post-monsoon' THEN aqi_value END), 1) AS post_monsoon,
       ROUND(AVG(CASE WHEN season = 'Winter' THEN aqi_value END)
           - AVG(CASE WHEN season = 'Monsoon' THEN aqi_value END), 1)      AS winter_minus_monsoon
FROM seasonal
GROUP BY city
ORDER BY winter_minus_monsoon DESC;

-- Q3d: worst month, best month and the ratio between them, per city.
WITH monthly AS (
    SELECT a.city,
           MONTH(a.obs_date)   AS month_no,
           AVG(a.aqi_value)    AS avg_aqi
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
    GROUP BY a.city, MONTH(a.obs_date)
),
ranked AS (
    SELECT city, month_no, avg_aqi,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY avg_aqi DESC) AS worst_rk,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY avg_aqi ASC)  AS best_rk
    FROM monthly
)
SELECT city,
       SUBSTRING('JanFebMarAprMayJunJulAugSepOctNovDec',
                 (MAX(CASE WHEN worst_rk = 1 THEN month_no END) - 1) * 3 + 1, 3)  AS worst_month,
       ROUND(MAX(CASE WHEN worst_rk = 1 THEN avg_aqi END), 1)                     AS worst_month_aqi,
       SUBSTRING('JanFebMarAprMayJunJulAugSepOctNovDec',
                 (MAX(CASE WHEN best_rk = 1 THEN month_no END) - 1) * 3 + 1, 3)   AS best_month,
       ROUND(MAX(CASE WHEN best_rk = 1 THEN avg_aqi END), 1)                      AS best_month_aqi,
       ROUND(MAX(CASE WHEN worst_rk = 1 THEN avg_aqi END)
           / MAX(CASE WHEN best_rk = 1 THEN avg_aqi END), 2)                      AS swing_ratio
FROM ranked
GROUP BY city
ORDER BY swing_ratio DESC;
