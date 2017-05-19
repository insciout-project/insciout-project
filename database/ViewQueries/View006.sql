--/// Analysis = JA > NA : Sample - View006

-- need columns: Reference, Institution, Sample, Design_Actual, Actual_Sample, News_Source, News_Sample, News_Sample_Exaggeration, PR_Sample_Exaggeration

SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual, 
JABody_table.Sample_Actual as Actual_Sample,
News_table.Source as News_Source,
News_table.Sample_Code as News_Sample,
--- was the news exaggerated relative to the actual Sample?
CASE
    WHEN News_table.Sample_Code IN (1,2) AND JABody_table.Sample_Actual IN (1,2) THEN 0
    WHEN News_table.Sample_Code IN (1,2) AND JABody_table.Sample_Actual = 3      THEN 1
    WHEN News_table.Sample_Code =3       AND JABody_table.Sample_Actual = 3      THEN 0
    WHEN News_table.Sample_Code =3       AND JABody_table.Sample_Actual IN (1,2) THEN -1
    WHEN News_table.Sample_Code =4       OR JABody_table.Sample_Actual =4        THEN -99
END
News_Sample_Exaggeration,

--- was the PR sample exaggerated compared to Actual sample??
View003.PR_Sample_Exaggeration

FROM
News_table
LEFT JOIN Meta_table USING(reference)
LEFT JOIN JABody_table USING(reference)
LEFT JOIN View003 USING(reference)