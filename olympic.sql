-- Practicing sql with olympic database
-- we are going to build base queries that can be used in creating report for olympic usecase
-- through this exercise we will be working with olympic database with 4 tables which are athlets,country,country_stats,summer_games, and winter_games

-- Report sections 1

-- Create report that shows Top 3 Sports with most athlets represented
SELECT 
	sport, 
    count(DISTINCT athlete_id) AS athletes
FROM summer_games
GROUP BY sport
-- Only include the 3 sports with the most athletes
ORDER BY count(DISTINCT athlete_id) DESC
LIMIT 3;

--- Create repots that shows Events, Athlets by Sports
SELECT
	sport, 
    COUNT(DISTINCT event) AS events,
    COUNT(DISTINCT athlete_id) AS athletes
FROM summer_games
GROUP BY sport

-- Create a report that shows region and age_of_oldest_athlete

SELECT 
	region, 
    max(age)AS age_of_oldest_athlete
FROM summer_games AS sg
JOIN athletes at 
ON at.id = sg.athlete_id
JOIN countries ct
ON ct.id = sg.country_id
GROUP BY ct.region;

-- Pull country_gdp by region and country
-- Calculate the global gdp
-- Calculate percent of global gdp
-- Calculate percent of gdp relative to its region
-- Filter out null gdp values
-- Show the highest country_gdp at the top

-- Pull country_gdp by region and country
SELECT 
	region,
    country,
	SUM(gdp) AS country_gdp,
    -- Calculate the global gdp
    SUM(SUM(gdp)) OVER () AS global_gdp,
    -- Calculate percent of global gdp
    SUM(gdp) / SUM(SUM(gdp)) OVER () AS perc_global_gdp,
    -- Calculate percent of gdp relative to its region
    SUM(gdp)/SUM(SUM(gdp))OVER(PARTITION BY region) AS perc_region_gdp
FROM country_stats AS cs
JOIN countries AS c
ON cs.country_id = c.id
-- Filter out null gdp values
WHERE gdp IS NOT NULL
GROUP BY region, country
-- Show the highest country_gdp at the top
ORDER BY country_gdp DESC;


-- -- Show max gdp per Across all years by  country
SELECT 
	country_id,
    year,
    gdp,
    -- Show max gdp per country and alias accordingly
	MAX(gdp) OVER (PARTITION BY country_id) AS country_max_gdp
FROM country_stats;

--- Your task is to create a query that shows the unique number of events held for each sport
--- use both summer_games and winter_games to create centralized report


-- Select sport and events for summer sports
SELECT 
	sport, 
    COUNT(DISTINCT event) AS events
FROM summer_games
GROUP BY sport
UNION
-- Select sport and events for winter sports
SELECT 
	sport, 
    COUNT(DISTINCT event) AS events
FROM winter_games
GROUP BY sport
-- Show the most events at the top of the report
ORDER BY events DESC;


--- create query to show Most decorated summer athletes with gold medal
--- the query should only include athletes with at least 3 medals, and should be ordered by gold medals won, with the most medals at the top.

SELECT 
	a.name AS athlete_name, 
    SUM(s.gold) AS gold_medals
FROM summer_games AS s
JOIN athletes AS a
ON s.athlete_id = a.id
GROUP BY a.name
-- Filter for only athletes with 3 gold medals or more
HAVING SUM(s.gold)>=3
-- Sort to show the most gold medals at the top
ORDER BY SUM(s.gold) DESC;

--  write query the featch the distinct events by country and season, season could be either summer or winter 
-- combine data from summer_games and winter_games

-- Query season, country, and events for all summer events
-- Query season, country, and events for all summer events
-- Add outer layer to pull season, country and unique events
SELECT 
	subquery.season, 
    c.country, 
    COUNT(DISTINCT subquery.event) AS events
FROM
    -- Pull season, country_id, and event for both seasons
    (SELECT 
     	'summer' AS season, 
     	event, 
     	country_id
    FROM summer_games
    UNION ALL 
    SELECT 
     	'winter' AS season, 
     	event, 
     	country_id
    FROM winter_games) AS subquery
JOIN countries AS c
ON c.id = subquery.country_id
-- Group by any unaggregated fields
GROUP BY subquery.season,c.country
-- Order to show most events at the top
ORDER BY events DESC;

--  Write query to help understand how BMI differs by each summer sport
-- add custom column named bmi_bucket, which splits up BMI into three groups: <.25, .25-.30, >.30

-- Pull in sport, bmi_bucket, and athletes
-- Uncomment the original query
SELECT 
	sport,
    CASE WHEN weight/height^2*100 <.25 THEN '<.25'
    WHEN weight/height^2*100 <=.30 THEN '.25-.30'
    WHEN weight/height^2*100 >.30 THEN '>.30'
    ELSE 'no weight recorded'
    END AS bmi_bucket,
    COUNT(DISTINCT athlete_id) AS athletes
FROM summer_games AS s
JOIN athletes AS a
ON s.athlete_id = a.id
GROUP BY sport, bmi_bucket
ORDER BY sport, athletes DESC;

-- Comment out the troubleshooting query
/*
SELECT 
	height, 
    weight, 
    weight/height^2*100 AS bmi
FROM athletes
WHERE weight/height^2*100 IS NULL;
*/
-- Bring in region, country, and gdp_per_million
-- Output the worlds gdp_per_million
-- Build the performance_index in the 3 lines below
-- Filter for 2016 and remove null gdp values
-- Bring in region, country, and gdp_per_million
SELECT 
    region,
    country,
    SUM(gdp) / SUM(pop_in_millions) AS gdp_per_million,
    -- Output the worlds gdp_per_million
    SUM(SUM(gdp)) OVER () / SUM(SUM(pop_in_millions)) OVER () AS gdp_per_million_total,
    -- Build the performance_index in the 3 lines below
    (SUM(gdp) / SUM(pop_in_millions))
    /
    (SUM(SUM(gdp)) OVER () / SUM(SUM(pop_in_millions)) OVER ()) AS performance_index
-- Pull from country_stats_clean
FROM country_stats_clean AS cs
JOIN countries AS c 
ON cs.country_id = c.id
-- Filter for 2016 and remove null gdp values
WHERE year = '2016-01-01' AND gdp IS NOT NULL
GROUP BY region, country
-- Show highest gdp_per_million at the top
ORDER BY gdp_per_million DESC;

-- build a report that shows each country's month-over-month views
-- include revenue per month
-- Create previous_month_views that pulls the total views from last month for the given country
--- percentage of current month relative to previous month revenue ( positive show grow, negative show a loss)
SELECT
	-- Pull month and country_id
	date_part('month',date) AS month,
	country_id,
    -- Pull in current month views
    SUM(views) AS month_views,
    -- Pull in last month views
    LAG(SUM(views)) OVER(PARTITION BY country_id ORDER BY date_part('month',date)) AS previous_month_views,
    -- Calculate the percent change
    SUM(views)/LAG(SUM(views)) OVER(PARTITION BY country_id ORDER BY date_part('month',date))-1 AS perc_change
FROM web_data
WHERE date <= '2018-05-31'
GROUP BY month,country_id;
 
 ---- Caclculate average view for the last 7 days for every date
 SELECT
	-- Pull in date and daily_views
	date,
	SUM(views) AS daily_views,
    -- Calculate the rolling 7 day average
	AVG(SUM(views)) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS weekly_avg
FROM web_data
GROUP BY date;

----- Output the value of weekly_avg from 7 days prior
-- -- Calculate percent change vs previous period
SELECT 
	-- Pull in date and weekly_avg
	date,
    weekly_avg,
    -- Output the value of weekly_avg from 7 days prior
    LAG(weekly_avg,7) OVER (ORDER BY date) AS weekly_avg_previous,
    -- Calculate percent change vs previous period
    (weekly_avg/(LAG(weekly_avg,7) OVER (ORDER BY date)))-1 AS perc_change
FROM
  (SELECT
      -- Pull in date and daily_views
      date,
      SUM(views) AS daily_views,
      -- Calculate the rolling 7 day average
      AVG(SUM(views)) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS weekly_avg
  FROM web_data
  -- Alias as subquery
  GROUP BY date) AS subquery
-- Order by date in descending order
ORDER BY date DESC;

--- arrange athlete in same country with respect to their height tallest should named as 1
SELECT 
     	-- Pull in country_id and height
        country_id, 
        height, 
        -- Number the height of each country's athletes
        ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY height DESC) AS row_num
    FROM winter_games AS w 
    JOIN athletes AS a ON w.athlete_id = a.id
    GROUP BY country_id, height
    -- Alias as subquery
    ORDER BY country_id, height DESC
    
    --- calculate avg tallest height by region
    -- Calculate region's percent of world gdp
    
    SELECT
	-- Pull in region and calculate avg tallest height
    region,
    AVG(height) AS avg_tallest,
    -- Calculate region's percent of world gdp
    SUM(gdp)/SUM(SUM(gdp))OVER() AS perc_world_gdp   
FROM countries AS c
JOIN
    (SELECT 
     	-- Pull in country_id and height
        country_id, 
        height, 
        -- Number the height of each country's athletes
        ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY height DESC) AS row_num
    FROM winter_games AS w 
    JOIN athletes AS a ON w.athlete_id = a.id
    GROUP BY country_id, height
    -- Alias as subquery
    ORDER BY country_id, height DESC) AS subquery
ON c.id = subquery.country_id
-- Join to country_stats
JOIN country_stats AS cs
ON c.id = cs.country_id
-- Only include the tallest height for each country
WHERE row_num = 1
GROUP BY region;
    
