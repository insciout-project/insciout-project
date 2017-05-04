---/// JA > PR: Causal language Analysis  - Creates View002

--- need columns: Reference, Institution, Sample, Design_Actual,PR_CaCode, PR_CL_Exaggeration, News_Uptake, Total_News,


-- need a temporary table to calculate the causal lang of the PR (PR_CaCode)
-- when IV and DV are the same in the title and the MS (TMS_IVDV_Same = 1) take the highest (from title and main statement)
-- when they're not the same take the main statement code
WITH
t1 AS (
SELECT 
Reference,
   CASE 
    WHEN PR_table.TMS_IVDV_Same = 1  THEN MAX(PR_table.Title_Code, PR_table.MS_Code)
    WHEN PR_table.TMS_IVDV_Same = 0  THEN PR_table.MS_Code
    END
    PR_CaCode
    
    FROM PR_table
    ),

-- create a temporary table to calculate news uptake and number of news articles
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
t1.PR_CaCode,

--- is the PR code exaggerated compared to the study design?

CASE
   WHEN JABody_table.Design_Actual IN (0,8)                                   THEN -99
   WHEN t1.PR_CaCode IN (0,1,-9)                                              THEN -99
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND t1.PR_CaCode IN (2,3,4) THEN 0
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND t1.PR_CaCode IN (2,3,4) THEN -1
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND t1.PR_CaCode IN (5,6)   THEN 1
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND t1.PR_CaCode IN (5,6)   THEN 0
   END
   PR_CL_Exaggeration,


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
LEFT JOIN t1 USING(Reference)
LEFT JOIN NewsCount USING(Reference)