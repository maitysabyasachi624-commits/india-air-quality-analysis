USE aqi_india;

/* Q5a. Average AQI from 7 days before to 7 days after Diwali (group A, 2019-2023 pooled). */
WITH rel AS (
    SELECT DATEDIFF(a.obs_date, dd.diwali_date) AS day_offset,
           a.aqi_value
    FROM aqi_daily a
    JOIN city_dim d      ON d.city = a.city
    JOIN diwali_dates dd ON dd.diwali_year BETWEEN 2019 AND 2023
    WHERE d.analysis_group = 'A_trend_2019_2023'
      AND DATEDIFF(a.obs_date, dd.diwali_date) BETWEEN -7 AND 7
)
SELECT day_offset,
       COUNT(*)                   AS city_days,
       ROUND(AVG(aqi_value), 1)   AS avg_aqi
FROM rel
GROUP BY day_offset
ORDER BY day_offset;

/* Q5b. By city: rise from the 7 days before to the 3 days after Diwali, against the same rise 21 days earlier and later (placebo). extra_change = difference. */
SELECT v.city,
       ROUND(AVG(CASE WHEN v.shift_days = 0 THEN v.before_avg END), 1)                  AS avg_before,
       ROUND(AVG(CASE WHEN v.shift_days = 0 THEN v.after_avg END), 1)                   AS avg_after,
       ROUND(AVG(CASE WHEN v.shift_days = 0 THEN v.after_avg - v.before_avg END), 1)    AS diwali_change,
       ROUND(AVG(CASE WHEN v.shift_days <> 0 THEN v.after_avg - v.before_avg END), 1)   AS placebo_change,
       ROUND(AVG(CASE WHEN v.shift_days = 0 THEN v.after_avg - v.before_avg END)
           - AVG(CASE WHEN v.shift_days <> 0 THEN v.after_avg - v.before_avg END), 1)   AS extra_change
FROM v_diwali_city_year v
WHERE v.before_days >= 5
  AND v.after_days  >= 2
GROUP BY v.city
ORDER BY extra_change DESC;

/* Q5c. By year (average of the 12 group A cities). */
SELECT v.diwali_year,
       dd.diwali_date,
       ROUND(AVG(CASE WHEN v.shift_days = 0 THEN v.after_avg - v.before_avg END), 1)    AS diwali_change,
       ROUND(AVG(CASE WHEN v.shift_days <> 0 THEN v.after_avg - v.before_avg END), 1)   AS placebo_change,
       ROUND(AVG(CASE WHEN v.shift_days = 0 THEN v.after_avg - v.before_avg END)
           - AVG(CASE WHEN v.shift_days <> 0 THEN v.after_avg - v.before_avg END), 1)   AS extra_change
FROM v_diwali_city_year v
JOIN diwali_dates dd ON dd.diwali_year = v.diwali_year
WHERE v.before_days >= 5
  AND v.after_days  >= 2
GROUP BY v.diwali_year, dd.diwali_date
ORDER BY v.diwali_year;
