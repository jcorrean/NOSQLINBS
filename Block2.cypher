LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row WHERE NOT toInteger(trim(row.Part_num)) IS NULL
CALL (row) {
  MERGE (p:Participant {Part_num: toInteger(trim(row.Part_num))})
  ON CREATE SET
    p.sex_M1_F2 = toFloat(trim(row.sex_M1_F2)),
    p.DemAge    = CASE WHEN trim(row.DemAge) <> ''
                       THEN toFloat(trim(row.DemAge)) ELSE null END,
    p.DemEthn   = CASE WHEN trim(row.DemEthn) <> ''
                       THEN toInteger(trim(row.DemEthn)) ELSE null END
  ON MATCH SET
    p.DemAge    = CASE WHEN p.DemAge  IS NULL AND trim(row.DemAge)  <> ''
                       THEN toFloat(trim(row.DemAge)) ELSE p.DemAge END,
    p.DemEthn   = CASE WHEN p.DemEthn IS NULL AND trim(row.DemEthn) <> ''
                       THEN toInteger(trim(row.DemEthn)) ELSE p.DemEthn END
} IN TRANSACTIONS OF 10000 ROWS;