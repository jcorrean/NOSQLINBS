// Query 4: Visualize mutual-match dyads with its follow-up trajectory
MATCH (p:Participant)-[r1:HAD_DATE]->(d:DateRating {Mutmatch: 1})
      -[r2:FOLLOWED_UP]->(f:FollowUp)
MATCH (d)-[r3:WITH]->(partner:Participant)
RETURN p, r1, d, r2, f, r3, partner
LIMIT 40;