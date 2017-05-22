---/// JA > PR: Sample Analysis row 100 on Analysis.xls

--- need columns:
---Sample, Institution, PR Number, Study Design (JA), JA: Actual sample, JA: Sample, PR: Sample, Exaggeration/understated, News Uptake, Total Number of News Articles, 


--- *******************************************************************************************************************


-- create a tmp table with Actual Sample, the lowest JA sample code (MIN from abstract and body) and the PR sample

WITH
tmpT1 AS
(
SELECT Reference,
    JABody_table.Sample_Actual as Actual_sample,
    MIN(JABody_table.Sample_Code, JATitle_table.Sample_Code) as JA_sample,
    PR_table.Sample_Code as PR_sample   
    FROM JABody_table
    LEFT JOIN JATitle_table USING(Reference)
    LEFT JOIN PR_table USING(Reference)
    ),

--- tmp table to calculate news uptake and total num news

NewsCount AS -- make the LEFT JOIN clearer
    (SELECT Reference, COUNT() as Count 
     FROM News_table GROUP BY Reference
    )




SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual, 
tmpT1.Actual_sample as Actual_Sample,
tmpT1.JA_sample as JA_Sample,
tmpT1.PR_sample as PR_Sample,

--- is the PR lower than the JA Actual

CASE
    WHEN tmpT1.PR_sample IN (1,2) AND tmpT1.Actual_sample IN (1,2) THEN 0
    WHEN tmpT1.PR_sample IN (1,2) AND tmpT1.Actual_sample = 3      THEN 1
    WHEN tmpT1.PR_sample =3       AND tmpT1.Actual_sample = 3      THEN 0
    WHEN tmpT1.PR_sample =3       AND tmpT1.Actual_sample IN (1,2) THEN -1
    WHEN tmpT1.PR_sample =4       OR tmpT1.Actual_sample =4        THEN -99
END
PR_Actual_Exaggeration,

---is the PR lower than the JA code

CASE
    WHEN tmpT1.PR_sample IN (1,2) AND tmpT1.JA_sample IN (1,2) THEN 0
    WHEN tmpT1.PR_sample IN (1,2) AND tmpT1.JA_sample = 3      THEN 1
    WHEN tmpT1.PR_sample =3       AND tmpT1.JA_sample = 3      THEN 0
    WHEN tmpT1.PR_sample =3       AND tmpT1.JA_sample IN (1,2) THEN -1
    WHEN tmpT1.PR_sample =4       OR tmpT1.Actual_sample =4    THEN -99
END
PR_JA_Exaggeration,
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
LEFT JOIN tmpT1 USING(reference)
LEFT JOIN NewsCount USING(reference)
