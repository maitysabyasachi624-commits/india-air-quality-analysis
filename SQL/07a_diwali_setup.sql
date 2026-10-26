USE aqi_india;

/* Diwali dates (calendarific.com) and the before/after view. Safe to re-run. */
DROP VIEW IF EXISTS v_diwali_city_year;
DROP TABLE IF EXISTS diwali_dates;

CREATE TABLE diwali_dates (
    diwali_year SMALLINT NOT NULL,
    diwali_date DATE     NOT NULL,
    PRIMARY KEY (diwali_year)
);

INSERT INTO diwali_dates (diwali_year, diwali_date) VALUES
    (2015, '2015-11-11'),
    (2016, '2016-10-30'),
    (2017, '2017-10-19'),
    (2018, '2018-11-07'),
    (2019, '2019-10-27'),
    (2020, '2020-11-14'),
    (2021, '2021-11-04'),
    (2022, '2022-10-24'),
    (2023, '2023-11-12');

/* Q5 setup. One row per city, Diwali year and shift (0 = Diwali, -21 and 21 = placebo dates). */
CREATE VIEW v_diwali_city_year AS
WITH shifts AS (
    SELECT 0 AS shift_days
    UNION ALL SELECT -21
    UNION ALL SELECT 21
),
windowed AS (
    SELECT a.city,
           dd.diwali_year,
           s.shift_days,
           DATEDIFF(a.obs_date, dd.diwali_date) - s.shift_days AS rel_day,
           a.aqi_value
    FROM aqi_daily a
    JOIN city_dim d      ON d.city = a.city
    JOIN diwali_dates dd ON dd.diwali_year BETWEEN 2019 AND 2023
    JOIN shifts s        ON DATEDIFF(a.obs_date, dd.diwali_date) - s.shift_days BETWEEN -7 AND 3
    WHERE d.analysis_group = 'A_trend_2019_2023'
)
SELECT city,
       diwali_year,
       shift_days,
       COUNT(CASE WHEN rel_day BETWEEN -7 AND -1 THEN 1 END)           AS before_days,
       COUNT(CASE WHEN rel_day BETWEEN  1 AND  3 THEN 1 END)           AS after_days,
       AVG(CASE WHEN rel_day BETWEEN -7 AND -1 THEN aqi_value END)     AS before_avg,
       AVG(CASE WHEN rel_day BETWEEN  1 AND  3 THEN aqi_value END)     AS after_avg
FROM windowed
GROUP BY city, diwali_year, shift_days;

/* Check: 180 rows expected */
SELECT COUNT(*) AS view_rows, 180 AS expected FROM v_diwali_city_year;
