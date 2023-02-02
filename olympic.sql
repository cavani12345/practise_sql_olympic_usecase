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
