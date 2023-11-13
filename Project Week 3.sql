-- ALTER SESSION SET USE_CACHED_RESULT = FALSE

-- Daiy unique sessions 
WITH daily_unique_sessions AS (
    SELECT
        DATE(event_timestamp) AS day,
        COUNT(DISTINCT session_id)AS count_sessions
    FROM VK_DATA.EVENTS.WEBSITE_ACTIVITY
    GROUP BY DATE(event_timestamp)
    
),
--  Daily average session length in seconds 

session_by_row_numbers AS (
    SELECT 
        DATE(event_timestamp) AS day,
        session_id,
        DATEDIFF(SECONDS,MIN(event_timestamp),MAX(event_timestamp)) AS session_length_seconds
    FROM VK_DATA.EVENTS.WEBSITE_ACTIVITY
    GROUP BY DATE(event_timestamp),session_id       
),

-- Daily average number of searches before recipe 

searches_recipe_rows AS (
    SELECT
        DATE(event_timestamp) AS day,
        session_id,
        PARSE_JSON(event_details):event::STRING AS event,
        PARSE_JSON(event_details):recipe_id::STRING AS recipe_id
    FROM VK_DATA.EVENTS.WEBSITE_ACTIVITY
    WHERE (event = 'search' OR event = 'view_recipe')
    ORDER BY session_id
),

count_searches_per_recipe AS (
    SELECT
        day,
        session_id,
        CASE 
            WHEN COUNT_IF(event = 'view_recipe') > 0 THEN COUNT_IF(event = 'search') 
        END AS search_count
    FROM searches_recipe_rows
    GROUP BY day,session_id   
),

--  Most viewed recipe ID 

searches_recipe_rows AS (
    SELECT
        DATE(event_timestamp) AS day,
        session_id,
        PARSE_JSON(event_details):event::STRING AS event,
        PARSE_JSON(event_details):recipe_id::STRING AS recipe_id
    FROM VK_DATA.EVENTS.WEBSITE_ACTIVITY
    WHERE (event = 'search' OR event = 'view_recipe')
    ORDER BY session_id
),

recipe_engagement AS (
SELECT 
    day,
    recipe_id,
    COUNT(recipe_id) AS recipe_view_count
FROM searches_recipe_rows
WHERE recipe_id IS NOT NULL
GROUP BY day,recipe_id
),

most_viewed_recipe AS (
    SELECT 
        day,
        recipe_id
        FROM recipe_engagement
    QUALIFY 
        RANK() OVER (PARTITION BY day ORDER BY recipe_view_count DESC, recipe_id) = 1
    ORDER BY day
)
    
-- Final Data

SELECT 
    dus.day,
    dus.count_sessions,
    AVG(session_length_seconds)::INTEGER AS average_session_length,
    AVG(srp.search_count)::FLOAT AS average_search_count,
    recipe_id AS most_viewed_recipe
FROM daily_unique_sessions as dus
LEFT JOIN count_searches_per_recipe AS srp
ON dus.day = srp.day
LEFT JOIN session_by_row_numbers AS sbr
ON dus.day = sbr.day
LEFT JOIN most_viewed_recipe AS mvr
ON dus.day = mvr.day 
GROUP BY ALL
ORDER BY dus.day

