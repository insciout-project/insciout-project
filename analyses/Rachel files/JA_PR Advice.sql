--// Analysis = JA >PR : Advice (see row 43 on Analysis.xls

-- Includes the following columns:
-- Sample, Institution, PR Number, Study Design (JA), PR: Advice, JA: Advice, Exaggeration/understated, News Uptake, Total Number of News Articles, 

-- create a tmp table to calcuate the strongest JA advice code (highest number in this case - MAX) - also has the PR advice code in
WITH
tmpT1 AS
(
SELECT Reference,
    MAX(JABody_table.Advice_Code, JATitle_table.Advice_Code) as JA_advice
    FROM JABody_table
    LEFT JOIN JATitle_table USING(Reference)
    ),
    

-- create a tmp table using WITH to calculate news uptake and number of news articles
NewsCount AS
(
SELECT Reference, COUNT() as Count
FROM News_table
GROUP BY Reference
)


SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual,
tmpT1.JA_advice as JA_Advice, -- max. advice from JA see WITH function above
--tmpT1.PR_advice as PR_Advice,
PR_table.Advice_Code as PR_Advice,
--  NEED TO CALCULATE EXAGGERATION
CASE
    WHEN PR_table.Advice_Code > JABody_table.Advice_Code THEN 1
    WHEN PR_table.Advice_Code < JABody_table.Advice_Code THEN -1
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
LEFT JOIN tmpT1 USING(Reference)
