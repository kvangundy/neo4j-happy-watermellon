
MATCH (n:Review)
WHERE n.analyzed = FALSE
WITH n, split(n.review, " ") as words
UNWIND words as word
MATCH (rw:Keyword {word:word})
WITH n, rw
CREATE (rw)-[:IN_REVIEW]->(n);

// assigning word counts

MATCH (n:Review {analyzed: FALSE})
WITH n, size((n)<-[:IN_REVIEW]-()) as wordCount
SET n.wordCount = wordCount;


//scoring the reviews

MATCH (n:Review {analyzed:FALSE})-[:IN_REVIEW]-(wordReview)
WITH distinct wordReview
MATCH  (wordReview)-[:SENTIMENT]-(:Polarity)
OPTIONAL MATCH pos = (n:Review)-[:IN_REVIEW]-(wordReview)-[:SENTIMENT]-(:Polarity {polarity:'positive'})
WITH n, toFloat(count(pos)) as plus
OPTIONAL MATCH neg = (n:Review)-[:IN_REVIEW]-(wordReview)-[:SENTIMENT]-(:Polarity {polarity:'negative'})
WITH ((plus - COUNT(neg))/n.wordCount) as score, n
SET n.sentimentScore = score;

//scoring the movies

MATCH (m:Movie)<-[rel:ABOUT]-(r:Review)
WITH m, toFloat(sum(r.sentimentScore)/count(rel)) as viewerSentiment
SET m.viewerSentiment = viewerSentiment;
