--// Analysis = JA > NA : Advice - Creates View004

--need the following columns:
-- Reference, Institution, Sample, Design_Actual, JA_Advice, News_Source, News_Advice, News_Advice_Exaggeration, PR_Advice_Exaggeration, 

SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual,
View001.JA_Advice AS JA_Advice,
News_table.Source as News_Source,  
News_table.Advice_Code as News_Advice, 
CASE  
    WHEN News_table.Advice_Code = 0 AND View001.JA_Advice = 0        THEN -99
    WHEN News_table.Advice_Code = View001.JA_Advice                  THEN 0
    WHEN News_table.Advice_Code > View001.JA_Advice                  THEN 1 
    WHEN News_table.Advice_Code < View001.JA_Advice                  THEN -1 
    ELSE 0
END 
News_Advice_Exaggeration,
--- was the PR exaggerated?
View001.PR_Advice_Exaggeration

FROM
News_table
LEFT JOIN Meta_table USING(reference)
LEFT JOIN JABody_table USING(reference)
LEFT JOIN View001 USING(reference)