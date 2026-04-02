// Query 2: Relationship counts by type
MATCH ()-[r]->()
RETURN type(r) AS relationship, count(r) AS total
ORDER BY relationship;