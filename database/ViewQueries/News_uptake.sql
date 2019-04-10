-- create the temporary table NewsCount
WITH
NewsCount AS 
    (SELECT 
    Reference, 
    COUNT() as Count 
    FROM News_table GROUP BY Reference -- counts the number according to the reference
    )

-- create the main table
SELECT
Reference,
Meta_table.Sample,
PRDraft_table.RCT_Condition as Condition,


--- add news uptake / number of news
CASE
    WHEN NewsCount.Count IS NOT NULL
    THEN 1 ELSE 0
  END 
News_Uptake,
  CASE
    WHEN NewsCount.Count IS NOT NULL
    THEN NewsCount.Count ELSE 0
END 
Total_News 

FROM
PRDraft_table
LEFT JOIN Meta_table USING(reference)
LEFT JOIN NewsCount USING(reference)

WHERE Reference like '%trial%' -- we are only including trial data