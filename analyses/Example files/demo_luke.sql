SELECT
Reference,  
Meta_table.Institution,
Meta_table.Sample,
JABody_table.Design_Actual,
News_table.Source as News_Source,
PR_table.Advice_Code as PR_Advice,
News_table.Advice_Code as News_Advice,
CASE
    WHEN News_table.Advice_Code > PR_table.Advice_Code THEN 1
    WHEN News_table.Advice_Code < PR_table.Advice_Code THEN -1
    ELSE 0
END News_Exageration,
A100.PR_Exageration

-- // 'From the following merged tables:'
FROM
News_table
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN PR_table USING(Reference)
LEFT JOIN A100 USING(Reference)
