// Query 3: Confirm asymmetric ratings for the example pair in Section 2.1
// Participant 1 rated Participant 116 → expect IRLikedPartner = 9
MATCH (p:Participant {Part_num: 1})-[:HAD_DATE]->(d:DateRating)-[:WITH]
      ->(partner:Participant {Part_num: 116})
RETURN p.Part_num AS rater, partner.Part_num AS partner,
       d.IRLikedPartner AS score;