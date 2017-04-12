---// PR > News: Sample Analysis Row 161 (Analysis.xls

---columns needed:
--- Sample, Institution, PR Number, Study Design (JA), JA: Actual sample, JA: Sample, News Source, News: Sample, News: Exaggeration/understated, PR: Exaggeration/understated, 

--- *******************************************************************************************************************

-- create a tmp table with lowest JA sample code (MIN from abstract and body) 

WITH
tmpT1 AS
(
SELECT Reference,
    MIN(JABody_table.Sample_Code, JATitle_table.Sample_Code) as JA_sample
    FROM JABody_table
    LEFT JOIN JATitle_table USING(reference)
    )

SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual, 
JABody_table.Sample_Actual as Actual_Sample,
--- min reported sample in JA
tmpT1.JA_sample as JA_Sample,
News_table.Source,
News_table.Sample_Code as News_Sample,
--- was the news exaggerated relative to the actual Sample?
CASE
    WHEN News_table.Sample_Code IN (1,2) AND JABody_table.Sample_Actual IN (1,2) THEN 0
    WHEN News_table.Sample_Code IN (1,2) AND JABody_table.Sample_Actual = 3      THEN 1
    WHEN News_table.Sample_Code =3       AND JABody_table.Sample_Actual = 3      THEN 0
    WHEN News_table.Sample_Code =3       AND JABody_table.Sample_Actual IN (1,2) THEN -1
    WHEN News_table.Sample_Code =4       OR JABody_table.Sample_Actual =4        THEN -99
END
NA_Actual_Exaggeration,
--- was the news exaggerated relative to the JA sample?
CASE
    WHEN News_table.Sample_Code IN (1,2) AND tmpT1.JA_sample IN (1,2) THEN 0
    WHEN News_table.Sample_Code IN (1,2) AND tmpT1.JA_sample = 3      THEN 1
    WHEN News_table.Sample_Code =3       AND tmpT1.JA_sample = 3      THEN 0
    WHEN News_table.Sample_Code =3       AND tmpT1.JA_sample IN (1,2) THEN -1
    WHEN News_table.Sample_Code =4       OR JABody_table.Sample_Actual =4        THEN -99
END
NA_JA_Exaggeration,
--- was the PR sample exaggerated compared to Actual sample??
JAPR_Sample_100.PR_Actual_Exaggeration as PR_Actual_Exaggeration,
---was the PR sample exaggerated compared to the JA sample???
JAPR_Sample_100.PR_JA_Exaggeration as PR_JA_Exaggeration


FROM
News_table
LEFT JOIN Meta_table USING(reference)
LEFT JOIN JABody_table USING(reference)
LEFT JOIN tmpT1 USING(reference)
LEFT JOIN JAPR_Sample_100 USING(reference)
