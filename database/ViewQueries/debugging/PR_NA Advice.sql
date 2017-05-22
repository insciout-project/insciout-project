--// Analysis = PR > NA : Advice (see row 125 on Analysis.xls

--need the following columns:
-- Sample, Institution, PR Number, Study Design (JA), JA: Advice, News Source, News: Advice, News: Exaggeration/understated, PR: Exaggeration/understated, 

--- *******************************************************************************************************************


-- create a tmp table to calcuate the strongest JA advice code (highest number in this case - MAX) 
WITH
tmpT1 AS
(
SELECT Reference,
    MAX(JABody_table.Advice_Code, JATitle_table.Advice_Code) as JA_advice
    FROM JABody_table
    LEFT JOIN JATitle_table USING(Reference)
    )

SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual,
tmpT1.JA_advice AS JA_Advice,
News_table.Source as News_Source,  
News_table.Advice_Code as News_Advice, 
CASE  
    WHEN News_table.Advice_Code > tmpT1.JA_advice THEN 1 
    WHEN News_table.Advice_Code < tmpT1.JA_advice THEN -1 
    ELSE 0
END 
News_Exageration,
--- was the PR exaggerated?
JAPR_Advice_43.PR_Advice_Exaggeration

FROM
News_table
LEFT JOIN Meta_table USING(reference)
LEFT JOIN JABody_table USING(reference)
LEFT JOIN JAPR_Advice_43 USING(reference)
LEFT JOIN tmpT1 USING(reference)