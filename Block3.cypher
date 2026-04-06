LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row WHERE toInteger(trim(row.Follow_clean)) = 1
CALL (row) {
  MERGE (d:DateRating {
    date_rating_id: toString(toInteger(trim(row.Part_num)))
                  + '_'
                  + toString(toInteger(trim(row.MatchID_clean)))
  })
  ON CREATE SET
    d.Part_num        = toInteger(trim(row.Part_num)),
    d.MatchID_clean   = toInteger(trim(row.MatchID_clean)),
    d.IRLikedPartner  = CASE WHEN trim(row.IRLikedPartner) <> ''
                             THEN toFloat(trim(row.IRLikedPartner)) ELSE null END,
    d.IRSexAttract    = CASE WHEN trim(row.IRSexAttract)   <> ''
                             THEN toFloat(trim(row.IRSexAttract))   ELSE null END,
    d.IRCommon        = CASE WHEN trim(row.IRCommon)       <> ''
                             THEN toFloat(trim(row.IRCommon))       ELSE null END,
    d.IRSayYes        = CASE WHEN trim(row.IRSayYes)       <> ''
                             THEN toFloat(trim(row.IRSayYes))       ELSE null END,
    d.Yessing         = CASE WHEN trim(row.yessing)        <> ''
                             THEN toInteger(trim(row.yessing))      ELSE null END,
    d.Mutmatch        = CASE WHEN trim(row.mutmatch)       <> ''
                             THEN toInteger(trim(row.mutmatch))     ELSE null END
} IN TRANSACTIONS OF 10000 ROWS;