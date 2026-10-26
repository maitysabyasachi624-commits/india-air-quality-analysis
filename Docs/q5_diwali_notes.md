# Question 5: does AQI rise around Diwali?

Stretch question. Queries are in `sql/07a_diwali_setup.sql` (run once) and `sql/07b_diwali_queries.sql`.

## Design (fixed before looking at results)
- Cities: the 12 group A cities. Years: the five Diwalis from 2019 to 2023, where every city has full-year data.
- Before window: the 7 days before Diwali (days -7 to -1).
- After window: the 3 days after Diwali (days +1 to +3). Diwali day itself (day 0) is in neither window.
- Placebo check: the same windows repeated 21 days before and 21 days after Diwali. AQI normally climbs through October and November, so a before-to-after rise alone proves nothing. The question is whether the rise around Diwali is bigger than the rise at the placebo dates. That gap is `extra_change`.

## Limits to state in the write-up
- Five festivals only, so five data points per city.
- No weather data (wind, rain, temperature), which can swamp a 3-day effect.
- This shows a pattern around a date. It does not show that firecrackers caused it.
- The placebo dates can contain other events (for example Dussehra falls about three weeks before Diwali).
- No significance test was run.
- Two placebo city-years are dropped by the window filter: Patna 2019 (21 days before) and Chennai 2023 (21 days after).

## Diwali dates used
Source: calendarific.com. 2016 and 2019 were cross-checked against when-is.com.

| Year | Date |
|---|---|
| 2015 | 11 Nov |
| 2016 | 30 Oct |
| 2017 | 19 Oct |
| 2018 | 7 Nov |
| 2019 | 27 Oct |
| 2020 | 14 Nov |
| 2021 | 4 Nov |
| 2022 | 24 Oct |
| 2023 | 12 Nov |

Only 2019 to 2023 are used in the analysis.
