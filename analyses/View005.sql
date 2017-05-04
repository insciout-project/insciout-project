--/// Analysis = JA > NA : Causal language - View005

-- need columns: Reference, Institution, Sample, Design_Actual, News_Source, News_CaCode, News_CL_Exaggeration, PR_CL_Exaggeration

-- need a tmp table for the news causal statement, highest (title of MS) when IV & DV same, otherwise from MS only

WITH
t1 AS
(
SELECT Reference,
    News_table.Source, -- have to include source in both tables so that (Reference, Source) acts as a unique identifier between the two tables.
    News_table.Title_Code,
    News_table.MS_Code,
    News_table.TMS_IVDV_Same,
CASE 
    WHEN News_table.TMS_IVDV_Same = 1  THEN MAX(News_table.Title_Code, News_table.MS_Code)
    WHEN News_table.TMS_IVDV_Same = 0  THEN News_table.MS_Code
    END
    News_CaCode
    
    FROM News_table
    )
    
SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual, 
News_table.Source as News_Source,
-- statement of cause from news (taken from temporary table above)
t1.News_CaCode as News_CaCode,

--- is the news exaggerated relative to the study design (Adams et al coding)
CASE
   WHEN JABody_table.Design_Actual IN (0,8)                                        THEN -99
   WHEN t1.News_CaCode IN (0,1,-9)                                              THEN -99
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND t1.News_CaCode IN (2,3,4) THEN 0
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND t1.News_CaCode IN (2,3,4) THEN -1
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND t1.News_CaCode IN (5,6)   THEN 1
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND t1.News_CaCode IN (5,6)   THEN 0
   END
   News_CL_Exaggeration,
   
View002.PR_CL_Exaggeration   
   
FROM
News_table
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN View002 USING(Reference)
LEFT JOIN t1 USING(Reference, Source) -- note this has to be joined using Source as well because Reference alone cannot tell SQL what is the relation between t1' s rows and News_table' s rows because both tables have several occurences of the same Reference. The Source with the Reference makes the News unique.