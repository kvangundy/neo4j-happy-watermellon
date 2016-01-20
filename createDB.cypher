//load in movies and tags

CREATE INDEX ON :Movie(name);
CREATE INDEX ON :Tag(tag);
CREATE INDEX ON :Review(word);
CREATE INDEX ON :Review(analyzed);

USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/kvangundy/neo4j-happy-watermellon/master/movies.csv" AS line
WITH line
CREATE (m:Movie {name:line.title, movieId:toINT(line.movieId), viewerSentiment:0});

USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/kvangundy/neo4j-happy-watermellon/master/movies.csv" AS line
WITH line, split(line.genres, "|") as genres UNWIND(genres) as genre
MERGE (:Tag {tag:genre});

USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/kvangundy/neo4j-happy-watermellon/master/movies.csv" AS line
WITH line, toINT(line.movieId) as ids, split(line.genres, "|") as genres UNWIND(genres) as genre
WITH genre, ids
MATCH (m:Movie {movieId:ids}), (t:Tag {tag:genre})
MERGE (m)-[:HAS_TAG]->(t);

//create reviews

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/kvangundy/neo4j-happy-watermellon/master/reviews.csv' AS line
WITH line, toINT(line.movieId) AS idM
MATCH (m:Movie {movieId:idm, analyzed:FALSE})
WITH line, m
CREATE (r:Review {review:line.review})
WITH r, m
CREATE (r)-[:ABOUT]->(m);

//create lexicon

//Sentiment Dictionary Import
CREATE CONSTRAINT ON (w:Word) ASSERT w.word IS UNIQUE;
CREATE CONSTRAINT ON (w:Keyword) ASSERT w.word IS UNIQUE;
CREATE CONSTRAINT ON (p:Polarity) ASSERT p.polarity IS UNIQUE;

//create poles

CREATE
(:Polarity {polarity:"positive"}),
(:Polarity {polarity:"negative"});

//import corpus

USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/kvangundy/ThreeEye-neo4j-sentiment-analyzer/master/sentimentDict.csv" AS line
WITH line
MERGE (a:Keyword {word:line.word});

USING PERIODIC COMMIT 5000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/kvangundy/ThreeEye-neo4j-sentiment-analyzer/master/sentimentDict.csv" AS line
WITH line
MATCH (w:Keyword {word:line.word}), (p:Polarity {polarity:line.polarity})
MERGE (w)-[:SENTIMENT]->(p);


