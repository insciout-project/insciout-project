--// Analysis = JA >PR : Advice -  - Creates View001

-- Includes the following columns: Reference, Institution, Sample, Design_Actual,JA_Advice, PR_Advice, PR_Advice_Exaggeration, News_Uptake, Total_News, 

-- first create a temporary table (t1) to calcuate the strongest JA advice code (highest number in this case - MAX)
WITH
t1 AS (
SELECT Reference,
    MAX(JABody_table.Advice_Code, JATitle_table.Advice_Code) as JA_advice
FROM JABody_table
LEFT JOIN JATitle_table USING(Reference)
    ),
    
-- create a temporary table using WITH to calculate news uptake and number of news articles
NewsCount AS (
SELECT 
Reference, 
COUNT() as Count
FROM News_table
GROUP BY Reference -- counts the number according to the reference
)

SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual,
t1.JA_Advice as JA_Advice, -- max. advice from JA see WITH function above
PR_table.Advice_Code as PR_Advice,

--  now calculate whether or not the PR is exaggerated compared to the JA
CASE
    WHEN PR_table.Advice_Code = 0 AND t1.JA_Advice = 0    THEN -99
    WHEN PR_table.Advice_Code = t1.JA_Advice              THEN 0
    WHEN PR_table.Advice_Code > t1.JA_Advice              THEN 1
    WHEN PR_table.Advice_Code < t1.JA_Advice              THEN -1
    ELSE 0
END 
PR_Advice_Exaggeration, 
-- add in news count and total news
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
PR_table
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN NewsCount USING(Reference)
LEFT JOIN t1 USING(Reference)