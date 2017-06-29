WITH -- Create temporary tables that makes SELECT easier
  t1 AS -- makes things easier for the CASE / WHEN below
    (SELECT
      Reference, -- we will need it
      MIN(JABody_table.Sample_Code, JATitle_table.Sample_Code) as JA_Sample_Code,
      PR_table.Sample_Code as PR_Sample_Code
    FROM JABody_table -- list all the tables you used in SELECT
    LEFT JOIN JATitle_table USING(Reference)
    LEFT JOIN PR_table USING(Reference)
    ), -- don't forget the comma

  NewsCount AS -- make the LEFT JOIN clearer
    (SELECT Reference, COUNT() as Count
     FROM News_table GROUP BY Reference) -- GROUP BY Reference allows to COUNT the number of row for each Reference

SELECT -- Select the columns you want to have:
  Reference,
  Meta_table.Institution,
  Meta_table.Sample,
  JABody_table.Design_Actual as JA_Design,
  JABody_table.Sample_Actual as JA_Actual_Sample,
  t1.JA_Sample_Code as JA_Sample_Code,
  t1.PR_Sample_Code as PR_Sample_Code,
  CASE -- note that the column name is after the keyword END
      WHEN t1.PR_Sample_Code IN (1,2) AND t1.JA_Sample_Code = 1 THEN 0
      WHEN t1.PR_Sample_Code IN (1,2) AND t1.JA_Sample_Code = 3 THEN 1
      WHEN t1.PR_Sample_Code = 3      AND t1.JA_Sample_Code = 3 THEN 0
      WHEN t1.PR_Sample_Code = 3      AND t1.JA_Sample_Code = 1 THEN -1
      WHEN t1.PR_Sample_Code = 4                                THEN -99
  END PR_Exageration,
  CASE
    WHEN NewsCount.Count IS NOT NULL
    THEN 'yes' ELSE 'no'
  END News_Uptake,
  CASE
    WHEN NewsCount.Count IS NOT NULL
    THEN NewsCount.Count ELSE 0
  END Total_News

FROM -- list ALL the tables used in SELECT (even the temporary)
PR_table
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN NewsCount USING(Reference)
-- we could have substituted NewsCount_table with its query here ((SELECT Reference, COUNT(Reference) as Total_News FROM News_table))
LEFT JOIN t1 USING(Reference)
