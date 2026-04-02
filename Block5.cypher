// HAD_DATE: Participant (rater) --> DateRating
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row WHERE toInteger(trim(row.Follow_clean)) = 1
CALL (row) {
  MATCH (p:Participant {Part_num: toInteger(trim(row.Part_num))})
  MATCH (d:DateRating  {date_rating_id:
    toString(toInteger(trim(row.Part_num))) + '_' +
    toString(toInteger(trim(row.MatchID_clean)))})
  MERGE (p)-[:HAD_DATE]->(d)
} IN TRANSACTIONS OF 10000 ROWS;

// WITH: DateRating --> Participant (partner)
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row WHERE toInteger(trim(row.Follow_clean)) = 1
CALL (row) {
  MATCH (d:DateRating {date_rating_id:
    toString(toInteger(trim(row.Part_num))) + '_' +
    toString(toInteger(trim(row.MatchID_clean)))})
  MATCH (partner:Participant {Part_num: toInteger(trim(row.MatchID_clean))})
  MERGE (d)-[:WITH]->(partner)
} IN TRANSACTIONS OF 10000 ROWS;

// FOLLOWED_UP: DateRating --> FollowUp
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE (
  trim(row.FURomInterest) <> '' OR trim(row.FUSexDesire)  <> '' OR
  trim(row.FUCommitted)   <> '' OR trim(row.FUStatus)     <> '' OR
  trim(row.FUEager)       <> ''
)
CALL (row) {
  MATCH (d:DateRating {date_rating_id:
    toString(toInteger(trim(row.Part_num))) + '_' +
    toString(toInteger(trim(row.MatchID_clean)))})
  MATCH (f:FollowUp {follow_id:
    toString(toInteger(trim(row.Part_num))) + '_' +
    toString(toInteger(trim(row.MatchID_clean))) + '_' +
    toString(toInteger(trim(row.Follow_clean)))})
  MERGE (d)-[:FOLLOWED_UP {week: toInteger(trim(row.Follow_clean))}]->(f)
} IN TRANSACTIONS OF 10000 ROWS;

// REPORTED_BY: FollowUp --> Participant (partner)
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE (
  trim(row.FURomInterest) <> '' OR trim(row.FUSexDesire)  <> '' OR
  trim(row.FUCommitted)   <> '' OR trim(row.FUStatus)     <> '' OR
  trim(row.FUEager)       <> ''
)
CALL (row) {
  MATCH (f:FollowUp      {follow_id:
    toString(toInteger(trim(row.Part_num))) + '_' +
    toString(toInteger(trim(row.MatchID_clean))) + '_' +
    toString(toInteger(trim(row.Follow_clean)))})
  MATCH (partner:Participant {Part_num: toInteger(trim(row.MatchID_clean))})
  MERGE (f)-[:REPORTED_BY]->(partner)
} IN TRANSACTIONS OF 10000 ROWS;