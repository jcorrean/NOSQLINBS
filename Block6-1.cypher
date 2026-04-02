// Query 1: Node counts by label
MATCH (n)
RETURN labels(n)[0] AS label, count(n) AS total
ORDER BY label;