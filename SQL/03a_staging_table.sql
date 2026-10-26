-- Staging copy of aqi_daily with num_stations as text, so the import wizard
-- accepts the 77 rows where it is blank. Import aqi_daily_clean.csv into it,
-- then run 03b_load_missing_rows.sql.

USE aqi_india;

DROP TABLE IF EXISTS stg_aqi_daily;

CREATE TABLE stg_aqi_daily (
    obs_date              DATE,
    city                  VARCHAR(50),
    num_stations          VARCHAR(10),
    aqi_value             INT,
    aqi_category_original VARCHAR(20),
    aqi_category          VARCHAR(20),
    category_mismatch     TINYINT,
    main_pollutants       VARCHAR(40),
    n_main_pollutants     TINYINT,
    flag_sole_co_or_no2   TINYINT
);
