WITH
T1 AS (
SELECT Reference, JABody_table.Source
FROM JABody_table
    LEFT JOIN JATitle_table USING(Reference)
    LEFT JOIN PR_table USING(Reference)
)

SELECT Reference, COUNT(*)
FROM T1
GROUP BY Reference
HAVING COUNT(*)>1

-- SELECT Reference
-- FROM T1
-- WHERE Reference NOT IN
--     (SELECT Reference
--      FROM JABody_table)
