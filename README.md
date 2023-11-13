# Advanced-SQL-Week-3-

## Query Profile 

### Unfortunately I wasn't really able to really understand my query profile because of all the testing which went into making this query! Since I'm generally still pretty new to Snowflake as a whole, I spent a lot of time testing my code at every step to see if it would work the way I thought it would or not and hypothesizing the best way to go about this activity. So a very large portion of my data always remained in the cache. 

###  From what I can tell currently on the last few query profiles for the complete query, the most expensive node was from the VK_DATA.EVENTS.WEBSITE_ACTIVITY table scan. However, I believe this to be incorrect since I do a decent amount of ETL to get the data the way I want it. Having so many cached queries, I'm not really able to find just how much of my query is based on actual non-cached data, making me not able to really evaluate this properly. In the future, I'd like to come back to this when I know my data hasn't been ran again so I can really take a look at  the final query profile uncached. 

### Using the "ALTER SESSION SET USE_CACHED_RESULT = FALSE" did not seem to help in my case since my query profile statistics always displayed the Percentage scanned from cache as 100%. 
