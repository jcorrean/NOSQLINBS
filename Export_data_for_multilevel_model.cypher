// Export data for multilevel model
MATCH (p:Participant)-[:HAD_DATE]->(d:DateRating)-[:FOLLOWED_UP]->(f:FollowUp)
WHERE d.IRLikedPartner IS NOT NULL
  AND f.FURomInterest  IS NOT NULL
RETURN p.Part_num        AS participant,
       d.MatchID_clean   AS partner,
       p.sex_M1_F2       AS sex,
       d.IRLikedPartner  AS initial_attraction,
       d.Mutmatch        AS mutual_match,
       f.Follow_clean    AS week,
       f.FURomInterest   AS romantic_interest
ORDER BY participant, partner, week;
