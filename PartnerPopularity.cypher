// Query B: Partner popularity — in-degree and mean received rating
MATCH (d:DateRating)-[:WITH]->(partner:Participant)
WITH  partner,
      count(d)              AS n_raters,
      avg(d.IRLikedPartner) AS mean_received_rating,
      stdev(d.IRLikedPartner) AS sd_received_rating
RETURN partner.Part_num    AS partner_id,
       n_raters,
       round(mean_received_rating, 2) AS mean_received_rating,
       round(sd_received_rating,  2)  AS sd_received_rating
ORDER BY mean_received_rating DESC
LIMIT 20;
