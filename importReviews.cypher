//import reviews

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/kvangundy/neo4j-happy-watermellon/master/reviews.csv' AS line
WITH line, toINT(line.movieId) AS idM
MATCH (m:Movie {movieId:idm})
WITH line, m
CREATE (r:Review {review:line.review})
WITH r, m
CREATE (r)-[:ABOUT]->(m);
