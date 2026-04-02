// Show all nodes and all relationships
MATCH (n)
OPTIONAL MATCH (n)-[r]-()
RETURN n, r