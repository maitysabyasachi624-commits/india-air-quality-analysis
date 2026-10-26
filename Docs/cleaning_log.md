# Cleaning log: India city AQI, 2015-2023

Source: CPCB daily AQI bulletins compiled by Urban Emissions (India NCAP), one CSV per city.

## What was done
| Step | Detail | Rows affected |
|---|---|---|
| Combine | 20 files received, 1 duplicate upload removed, 19 cities combined | 39,431 rows |
| Dates | Parsed as dates, ISO format. No invalid dates, no duplicate city-days | 0 |
| City names | Already consistent, one city per file | 0 |
| Pollutant names | "OZONE" standardised to "O3" | 1,493 values |
| Category labels | Casing standardised ("Very poor" to "Very Poor") | 6 |
| Category re-derived | `aqi_category` is recomputed from `aqi_value` with CPCB bands; the source label is kept in `aqi_category_original` | 54 rows differ (50 are on a band boundary, 4 are not) |
| Multi-valued pollutant cells | Split into `aqi_daily_pollutants.csv` (one row per pollutant per day). In the main table they are joined with "|" | 18,089 rows have more than one pollutant |
| Missing No. Stations | Left as NULL, not imputed. All are in 2015 and in six cities | 77 |
| Suspect pollutant flag | `flag_sole_co_or_no2` = 1 when CO or NO2 is the only main pollutant. Flagged, not removed | see below |

## AQI bands used (CPCB)
Good 0-50, Satisfactory 51-100, Moderate 101-200, Poor 201-300, Very Poor 301-400, Severe 401-500.

## Coverage rules
- A **usable year** has at least 80% of the year's days with data.
- **A_trend_2019_2023**: every year 2019-2023 usable. Used for trend and seasonality questions.
- **B_from_2020**: every year 2020-2023 usable but not 2019.
- **C_2023_only**: 2023 usable but not all earlier years.
- **D_limited_not_comparable**: 2023 not usable. Keep out of rankings.

| City | State/UT | Group | First date | Rows | Usable years | Longest gap (days) |
|---|---|---|---|---|---|---|
| Ahmedabad | Gujarat | A_trend_2019_2023 | 2015-05-01 | 2538 | 2018,2019,2020,2021,2022,2023 | 241 |
| Bengaluru | Karnataka | A_trend_2019_2023 | 2015-05-02 | 3120 | 2016,2017,2018,2019,2020,2021,2022,2023 | 7 |
| Chennai | Tamil Nadu | A_trend_2019_2023 | 2015-05-01 | 3074 | 2016,2017,2018,2019,2020,2021,2022,2023 | 15 |
| Delhi | Delhi (UT) | A_trend_2019_2023 | 2015-05-01 | 3143 | 2016,2017,2018,2019,2020,2021,2022,2023 | 6 |
| Guwahati | Assam | A_trend_2019_2023 | 2019-02-19 | 1744 | 2019,2020,2021,2022,2023 | 10 |
| Hyderabad | Telangana | A_trend_2019_2023 | 2015-05-01 | 3132 | 2016,2017,2018,2019,2020,2021,2022,2023 | 5 |
| Jaipur | Rajasthan | A_trend_2019_2023 | 2015-11-27 | 2720 | 2018,2019,2020,2021,2022,2023 | 41 |
| Kolkata | West Bengal | A_trend_2019_2023 | 2016-07-05 | 2510 | 2019,2020,2021,2022,2023 | 167 |
| Lucknow | Uttar Pradesh | A_trend_2019_2023 | 2015-05-02 | 3056 | 2016,2017,2018,2019,2020,2021,2022,2023 | 16 |
| Mumbai | Maharashtra | A_trend_2019_2023 | 2015-08-20 | 2884 | 2016,2017,2019,2020,2021,2022,2023 | 20 |
| Patna | Bihar | A_trend_2019_2023 | 2015-09-18 | 2590 | 2018,2019,2020,2021,2022,2023 | 22 |
| Thiruvananthapuram | Kerala | A_trend_2019_2023 | 2017-07-13 | 2301 | 2018,2019,2020,2021,2022,2023 | 9 |
| Chandigarh | Chandigarh (UT) | B_from_2020 | 2019-09-17 | 1558 | 2020,2021,2022,2023 | 3 |
| Indore | Madhya Pradesh | B_from_2020 | 2019-09-23 | 1530 | 2020,2021,2022,2023 | 8 |
| Visakhapatnam | Andhra Pradesh | B_from_2020 | 2016-07-12 | 2445 | 2017,2018,2020,2021,2022,2023 | 13 |
| Dehradun | Uttarakhand | C_2023_only | 2022-04-23 | 450 | 2023 | 15 |
| Raipur | Chhattisgarh | C_2023_only | 2022-10-26 | 363 | 2023 | 68 |
| Bhubaneswar | Odisha | D_limited_not_comparable | 2023-11-02 | 59 |  | 2 |
| Dhanbad | Jharkhand | D_limited_not_comparable | 2023-02-28 | 214 |  | 15 |

## Known data-quality issues kept in the data
- **Station counts differ widely** (1 to 39 per city-day). Keep `num_stations` in any comparison.
- **Large early gaps**: Ahmedabad (Nov 2015-Jun 2016, Mar-Nov 2017) and Kolkata (Oct 2017-Apr 2018).
- **2015 is a partial year for every city** (earliest start is 1 May 2015).
- **Sole CO or NO2 as the main pollutant** is unusually common in some cities and may be a sensor or reporting issue:

| City | Flagged rows | % of city rows |
|---|---|---|
| Dhanbad | 110 | 51.4 |
| Thiruvananthapuram | 601 | 26.1 |
| Dehradun | 78 | 17.3 |
| Ahmedabad | 234 | 9.2 |
| Mumbai | 217 | 7.5 |
| Raipur | 26 | 7.2 |
| Indore | 109 | 7.1 |
| Kolkata | 175 | 7.0 |
| Bhubaneswar | 3 | 5.1 |
| Chennai | 148 | 4.8 |
| Patna | 90 | 3.5 |
| Bengaluru | 95 | 3.0 |
| Visakhapatnam | 73 | 3.0 |
| Lucknow | 56 | 1.8 |
| Chandigarh | 17 | 1.1 |
| Guwahati | 11 | 0.6 |
| Jaipur | 17 | 0.6 |
| Hyderabad | 9 | 0.3 |
| Delhi | 5 | 0.2 |

## Column dictionary: aqi_daily_clean.csv
| Column | Meaning |
|---|---|
| obs_date | Bulletin date |
| city | City name |
| num_stations | Stations reporting that day (NULL in 77 early rows) |
| aqi_value | City-average AQI (10-500) |
| aqi_category | Category derived from aqi_value |
| aqi_category_original | Category as given in the source |
| category_mismatch | 1 if the two categories differ |
| main_pollutants | Main pollutant(s), "|" separated |
| n_main_pollutants | Number of main pollutants that day |
| flag_sole_co_or_no2 | 1 if CO or NO2 is the only main pollutant |
