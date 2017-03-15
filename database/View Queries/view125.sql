SELECT
-- Select the columns you want to have:
-- Note that you can take any columns from any table that is written under the keyword 'FROM'
Reference,
Meta_table.Institution,
Meta_table.Sample,
JABody_table.Design_Actual,
News_table.Source as News_Source, -- you can created aliases for the column names (i.e. you can rename the column)
PR_table.Advice_Code as PR_Advice,
News_table.Advice_Code as News_Advice,
CASE
    WHEN News_table.Advice_Code > PR_table.Advice_Code THEN 1 -- WATCH OUT: you cannot use the aliases you created
    WHEN News_table.Advice_Code < PR_table.Advice_Code THEN -1
    ELSE 0
END News_Exageration,
A100.PR_Exageration

-- From the following merged table:
FROM
News_table
LEFT JOIN JABody_table USING(Reference) -- we are using the view JABody_table to get only one row per JA
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN PR_table USING(Reference)
LEFT JOIN A100 USING(Reference)
