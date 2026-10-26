-- Copy the rows the import wizard skipped (blank num_stations) from staging into aqi_daily.
-- Run after stg_aqi_daily has been filled from aqi_daily_clean.csv.

USE aqi_india;

-- Staging should hold all rows (39431)
SELECT COUNT(*) AS staging_rows, 39431 AS expected FROM stg_aqi_daily;

-- Rows missing from aqi_daily (expect 77)
SELECT COUNT(*) AS missing_rows, 77 AS expected
FROM stg_aqi_daily s
LEFT JOIN aqi_daily a ON a.city = s.city AND a.obs_date = s.obs_date
WHERE a.city IS NULL;

-- Insert only the missing rows, blank station counts become NULL
INSERT INTO aqi_daily
    (obs_date, city, num_stations, aqi_value, aqi_category_original, aqi_category,
     category_mismatch, main_pollutants, n_main_pollutants, flag_sole_co_or_no2)
SELECT s.obs_date, s.city, NULLIF(TRIM(s.num_stations), ''), s.aqi_value,
       s.aqi_category_original, s.aqi_category, s.category_mismatch,
       s.main_pollutants, s.n_main_pollutants, s.flag_sole_co_or_no2
FROM stg_aqi_daily s
LEFT JOIN aqi_daily a ON a.city = s.city AND a.obs_date = s.obs_date
WHERE a.city IS NULL;

-- Verify: 39431 rows and 77 NULL station counts
SELECT COUNT(*) AS aqi_daily_rows, 39431 AS expected FROM aqi_daily;
SELECT COUNT(*) AS null_station_rows, 77 AS expected FROM aqi_daily WHERE num_stations IS NULL;

-- Then drop the staging table: DROP TABLE stg_aqi_daily
