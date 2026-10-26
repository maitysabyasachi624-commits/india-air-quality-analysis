-- Database and tables for the India AQI project. Run once, before importing the CSVs.
-- The DROP TABLE lines delete existing data, so do not re-run after importing.

CREATE DATABASE IF NOT EXISTS aqi_india;
USE aqi_india;

DROP TABLE IF EXISTS aqi_daily_pollutants;
DROP TABLE IF EXISTS city_year_coverage;
DROP TABLE IF EXISTS aqi_daily;
DROP TABLE IF EXISTS city_dim;

-- One row per city (city_dim.csv). `rows` is reserved in MySQL 8, hence the backticks.
CREATE TABLE city_dim (
    city                 VARCHAR(50)  NOT NULL,
    state_ut             VARCHAR(50),
    analysis_group       VARCHAR(40),
    first_date           DATE,
    last_date            DATE,
    `rows`               INT,
    coverage_pct_in_span DECIMAL(5,1),
    usable_years         VARCHAR(60),
    avg_stations         DECIMAL(5,1),
    longest_gap_days     INT,
    PRIMARY KEY (city)
);

-- One row per city per day (aqi_daily_clean.csv).
CREATE TABLE aqi_daily (
    obs_date              DATE        NOT NULL,
    city                  VARCHAR(50) NOT NULL,
    num_stations          INT         NULL,        -- blank in 77 early-2015 rows
    aqi_value             INT         NOT NULL,
    aqi_category_original VARCHAR(20),
    aqi_category          VARCHAR(20),
    category_mismatch     TINYINT,
    main_pollutants       VARCHAR(40),             -- e.g. PM10|PM2.5
    n_main_pollutants     TINYINT,
    flag_sole_co_or_no2   TINYINT,
    PRIMARY KEY (city, obs_date),
    FOREIGN KEY (city) REFERENCES city_dim (city)
);

-- One row per pollutant per city-day (aqi_daily_pollutants.csv).
CREATE TABLE aqi_daily_pollutants (
    obs_date  DATE        NOT NULL,
    city      VARCHAR(50) NOT NULL,
    pollutant VARCHAR(10) NOT NULL,
    PRIMARY KEY (city, obs_date, pollutant),
    FOREIGN KEY (city, obs_date) REFERENCES aqi_daily (city, obs_date)
);

-- One row per city per year (city_year_coverage.csv).
CREATE TABLE city_year_coverage (
    city           VARCHAR(50) NOT NULL,
    `year`         SMALLINT    NOT NULL,
    days_with_data SMALLINT,
    days_in_year   SMALLINT,
    coverage_pct   DECIMAL(5,1),
    usable_year    TINYINT,
    PRIMARY KEY (city, `year`),
    FOREIGN KEY (city) REFERENCES city_dim (city)
);
