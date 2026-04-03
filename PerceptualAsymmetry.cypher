// Query A: Perceptual asymmetry in mutual-match dyads
MATCH (a:Participant)-[:HAD_DATE]->(d1:DateRating {Mutmatch: 1})
-[:WITH]->(b:Participant),
      (b)-[:HAD_DATE]->(d2:DateRating {Mutmatch: 1})-[:WITH]->(a)
WHERE a.Part_num < b.Part_num
  AND d1.IRLikedPartner IS NOT NULL
  AND d2.IRLikedPartner IS NOT NULL
RETURN a.Part_num                                      AS rater_a,
       b.Part_num                                      AS rater_b,
       d1.IRLikedPartner                               AS a_liked_b,
       d2.IRLikedPartner                               AS b_liked_a,
       abs(d1.IRLikedPartner - d2.IRLikedPartner)      AS asymmetry
ORDER BY asymmetry DESC;