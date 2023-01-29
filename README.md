## Practicing sql with olympic database
#### we are going to build base queries that can be used in creating report for olympic usecase
#### through this exercise we will be working with olympic database with 4 tables which are athlets,country,country_stats,summer_games, and winter_games

### Report sections 1
#### Top 3 Sports with most athlets represented
SELECT 
	sport, 
    count(DISTINCT athlete_id) AS athletes
FROM summer_games
GROUP BY sport
-- Only include the 3 sports with the most athletes
ORDER BY count(DISTINCT athlete_id) DESC
LIMIT 3;



