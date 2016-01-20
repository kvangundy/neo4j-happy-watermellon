//Basic Collaborative Filtering

MATCH (m:Movie {movieId:1})-[:HAS_TAG]->(tag)<-[:HAS_TAG]-(newMovie)
WITH count(tag) as commonTags, newMovie
RETURN newMovie.name as Movie, commonTags as `Tags in Common`
ORDER BY commonTags DESC
LIMIT 25;

// Sorted by Sentiment

MATCH 
(m:Movie {movieId:1})-[:HAS_TAG]->(tag)<-[:HAS_TAG]-(newMovie)
WITH count(tag) as commonTags, newMovie  
ORDER BY commonTags DESC LIMIT 25

//ranking the results with our sentiment analysis
RETURN newMovie, commonTags, newMovie.viewerSentiment as viewerScore
ORDER BY viewerScore DESC;
