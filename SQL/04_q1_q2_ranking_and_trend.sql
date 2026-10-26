-- Q1 and Q2: which cities have the worst air, and is it getting better
-- Group A = cities with at least 80% of days in every year 2019-2023 (see docs/cleaning_log.md).

USE aqi_india;

-- Q1a: 2023 ranking by average AQI (1 = worst). Group D cities excluded (too little data).
SELECT RANK() OVER (ORDER BY AVG(a.aqi_value) DESC)                       AS rank_worst,
       a.city,
       d.state_ut,
       d.analysis_group,
       COUNT(*)                                                           AS days_with_data,
       ROUND(AVG(a.aqi_value), 1)                                         AS avg_aqi,
       ROUND(100.0 * SUM(CASE WHEN a.aqi_value > 200 THEN 1 ELSE 0 END) / COUNT(*), 1)
                                                                          AS pct_days_poor_or_worse,
       ROUND(AVG(a.num_stations), 1)                                      AS avg_stations
FROM aqi_daily a
JOIN city_dim d ON d.city = a.city
WHERE a.obs_date >= '2023-01-01'
  AND a.obs_date <  '2024-01-01'
  AND d.analysis_group <> 'D_limited_not_comparable'
GROUP BY a.city, d.state_ut, d.analysis_group
ORDER BY rank_worst;

-- Q1b: 2019-2023 ranking, group A cities.
SELECT RANK() OVER (ORDER BY AVG(a.aqi_value) DESC)                       AS rank_worst,
       a.city,
       COUNT(*)                                                           AS days_with_data,
       ROUND(AVG(a.aqi_value), 1)                                         AS avg_aqi_2019_2023,
       ROUND(100.0 * SUM(CASE WHEN a.aqi_value > 200 THEN 1 ELSE 0 END) / COUNT(*), 1)
                                                                          AS pct_days_poor_or_worse,
       ROUND(AVG(a.num_stations), 1)                                      AS avg_stations
FROM aqi_daily a
JOIN city_dim d ON d.city = a.city
WHERE a.obs_date >= '2019-01-01'
  AND a.obs_date <  '2024-01-01'
  AND d.analysis_group = 'A_trend_2019_2023'
GROUP BY a.city
ORDER BY rank_worst;

-- Q1c: rank of each city per year, to check whether the ranking is stable.
WITH yearly AS (
    SELECT a.city,
           YEAR(a.obs_date)    AS yr,
           AVG(a.aqi_value)    AS avg_aqi
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
    GROUP BY a.city, YEAR(a.obs_date)
)
SELECT yr,
       city,
       ROUND(avg_aqi, 1)                                      AS avg_aqi,
       RANK() OVER (PARTITION BY yr ORDER BY avg_aqi DESC)    AS rank_worst
FROM yearly
ORDER BY yr, rank_worst;

-- Q2a: average AQI per year and the change from 2019 to 2023 (negative = cleaner).
WITH yearly AS (
    SELECT a.city,
           YEAR(a.obs_date)    AS yr,
           AVG(a.aqi_value)    AS avg_aqi
    FROM aqi_daily a
    JOIN city_dim d ON d.city = a.city
    WHERE a.obs_date >= '2019-01-01'
      AND a.obs_date <  '2024-01-01'
      AND d.analysis_group = 'A_trend_2019_2023'
    GROUP BY a.city, YEAR(a.obs_date)
)
SELECT city,
       ROUND(MAX(CASE WHEN yr = 2019 THEN avg_aqi END), 1)    AS aqi_2019,
       ROUND(MAX(CASE WHEN yr = 2020 THEN avg_aqi END), 1)    AS aqi_2020,
       ROUND(MAX(CASE WHEN yr = 2021 THEN avg_aqi END), 1)    AS aqi_2021,
       ROUND(MAX(CASE WHEN yr = 2022 THEN avg_aqi END), 1)    AS aqi_2022,
       ROUND(MAX(CASE WHEN yr = 2023 THEN avg_aqi END), 1)    AS aqi_2023,
       ROUND(MAX(CASE WHEN yr = 2023 THEN avg_aqi END)
           - MAX(CASE WHEN yr = 2019 THEN avg_aqi END), 1)    AS change_points,
       ROUND(100 * (MAX(CASE WHEN yr = 2023 THEN avg_aqi END)
                  / MAX(CASE WHEN yr = 2019 THEN avg_aqi END) - 1), 1)
                                                              AS change_pct
FROM yearly
GROUP BY city
ORDER BY change_pct;

-- Q2b: 2016-2023 trend with year-on-year change, for cities with 8 usable years.
WITH long_cities AS (
    SELECT city
    FROM city_year_coverage
    WHERE `year` BETWEEN 2016 AND 2023
      AND usable_year = 1
    GROUP BY city
    HAVING COUNT(*) = 8
),
yearly AS (
    SELECT a.city,
           YEAR(a.obs_date)    AS yr,
           COUNT(*)            AS days_with_data,
           AVG(a.aqi_value)    AS avg_aqi
    FROM aqi_daily a
    JOIN long_cities l ON l.city = a.city
    WHERE a.obs_date >= '2016-01-01'
      AND a.obs_date <  '2024-01-01'
    GROUP BY a.city, YEAR(a.obs_date)
)
SELECT city,
       yr,
       days_with_data,
       ROUND(avg_aqi, 1)                                                      AS avg_aqi,
       ROUND(avg_aqi - LAG(avg_aqi) OVER (PARTITION BY city ORDER BY yr), 1)  AS change_vs_prev_year
FROM yearly
ORDER BY city, yr;
