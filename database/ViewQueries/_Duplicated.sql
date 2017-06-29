SELECT Reference, COUNT(*)
FROM JABody_table
GROUP BY Reference
HAVING COUNT(*)>1