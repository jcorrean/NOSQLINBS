LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE (
  trim(row.FURomInterest) <> '' OR trim(row.FUSexDesire)  <> '' OR
  trim(row.FUCommitted)   <> '' OR trim(row.FUStatus)     <> '' OR
  trim(row.FUEager)       <> ''
)
CALL (row) {
  MERGE (f:FollowUp {
    follow_id: toString(toInteger(trim(row.Part_num)))
             + '_'
             + toString(toInteger(trim(row.MatchID_clean)))
             + '_'
             + toString(toInteger(trim(row.Follow_clean)))
  })
  ON CREATE SET
    f.Part_num      = toInteger(trim(row.Part_num)),
    f.MatchID_clean = toInteger(trim(row.MatchID_clean)),
    f.Follow_clean  = toInteger(trim(row.Follow_clean)),
    f.FUStatus       = CASE WHEN trim(row.FUStatus)      <> ''
                            THEN toFloat(trim(row.FUStatus))      ELSE null END,
    f.FURomInterest  = CASE WHEN trim(row.FURomInterest) <> ''
                            THEN toFloat(trim(row.FURomInterest)) ELSE null END,
    f.FUSexDesire    = CASE WHEN trim(row.FUSexDesire)   <> ''
                            THEN toFloat(trim(row.FUSexDesire))   ELSE null END,
    f.FUCommitted    = CASE WHEN trim(row.FUCommitted)   <> ''
                            THEN toFloat(trim(row.FUCommitted))   ELSE null END,
    f.FUEager        = CASE WHEN trim(row.FUEager)       <> ''
                            THEN toFloat(trim(row.FUEager))       ELSE null END
} IN TRANSACTIONS OF 10000 ROWS;