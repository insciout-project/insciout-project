---/// JA > PR: Sample Analysis - Creates View003

--- need columns: Reference, Institution, Sample, Design_Actual, Actual_Sample, PR_Sample, PR_Sample_Exaggeration, News_Uptake, Total_News,

-- create a temporary table to calculate news uptake and number of news articles
WITH
NewsCount AS -- make the LEFT JOIN clearer
    (SELECT 
    Reference, 
    COUNT() as Count 
    FROM News_table GROUP BY Reference -- counts the number according to the reference
    )

SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual, 
JABody_table.Sample_Actual as Actual_Sample,
PR_table.Sample_Code as PR_Sample,
--- calculate whether or not the PR is exaggerated
CASE
    WHEN PR_table.Sample_Code IN (1,2) AND JABody_table.Sample_Actual IN (1,2) THEN 0
    WHEN PR_table.Sample_Code IN (1,2) AND JABody_table.Sample_Actual = 3      THEN 1
    WHEN PR_table.Sample_Code =3       AND JABody_table.Sample_Actual = 3      THEN 0
    WHEN PR_table.Sample_Code =3       AND JABody_table.Sample_Actual IN (1,2) THEN -1
    WHEN PR_table.Sample_Code =4       OR JABody_table.Sample_Actual =4        THEN -99
END
PR_Sample_Exaggeration,

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
PR_table
LEFT JOIN Meta_table USING(reference)
LEFT JOIN JABody_table USING(reference)
LEFT JOIN NewsCount USING(reference)