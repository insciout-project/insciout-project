--/// PR > NA : Causal language Analysis row 146 on Analysis.xls

-- need columns: Sample, Institution, PR Number, Study Design (JA), JA: Statement of Relationship Code, News Source, 
--                News: Statement of Relationship Code, News: Exaggeration/understated, PR: Exaggeration/understated, 


-- *******************************************************************************************************************


-- need a tmp table for the news causal statement, highest (title of MS) when IV & DV same, otherwise from MS only

WITH
tmpT1 AS
(
SELECT Reference,
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
JAPR_language_73.JA_CaCode,
JAPR_language_73.PR_Exag_Adams,
JAPR_language_73.PR_Exag_BMJ,
JAPR_language_73.PR_ActExag_Adams,
News_table.Source as News_Source,
-- statement of cause from news
tmpT1.News_CaCode,

-- is the news exaggerated relative to the JA (Adams et al coding)

CASE
    WHEN JABody_table.Design_Actual IN (0,8)                                         THEN -99
    WHEN JAPR_language_73.JA_CaCode IN (0,1,-9)   OR tmpT1.News_CaCode IN (0,1,-9)   THEN -99
    
    WHEN  JAPR_language_73.JA_CaCode IN (2,3,4)   AND tmpT1.News_CaCode IN (2,3,4)   THEN 0
    WHEN  JAPR_language_73.JA_CaCode IN (5,6)     AND tmpT1.News_CaCode IN (2,3,4)   THEN -1
    WHEN  JAPR_language_73.JA_CaCode IN (2,3,4)   AND tmpT1.News_CaCode IN (5,6)     THEN 1
    WHEN  JAPR_language_73.JA_CaCode IN (5,6)     AND tmpT1.News_CaCode IN (5,6)     THEN 0

    END
    News_Exag_Adams,


-- is the news exaggerated relative to the JA (BMJ coding)

CASE
    WHEN JABody_table.Design_Actual IN (0,8)                                         THEN -99
    WHEN JAPR_language_73.JA_CaCode IN (0,1,-9)   OR tmpT1.News_CaCode IN (0,1,-9)   THEN -99

    WHEN  JAPR_language_73.JA_CaCode = tmpT1.News_CaCode                             THEN 0
    WHEN  JAPR_language_73.JA_CaCode < tmpT1.News_CaCode                             THEN 1
    WHEN  JAPR_language_73.JA_CaCode > tmpT1.News_CaCode                             THEN -1
    END      
    News_Exag_BMJ, -- CHECK THAT THIS IS CORRECT WITH SOL
    


--- is the news exaggerated relative to the study design (Adams et al coding)

CASE
   WHEN JABody_table.Design_Actual IN (0,8)                                        THEN -99
   WHEN tmpT1.News_CaCode IN (0,1,-9)                                              THEN -99
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND tmpT1.News_CaCode IN (2,3,4) THEN 0
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND tmpT1.News_CaCode IN (2,3,4) THEN -1
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND tmpT1.News_CaCode IN (5,6)   THEN 1
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND tmpT1.News_CaCode IN (5,6)   THEN 0
   END
   News_ActExag_Adams
   
FROM
News_table
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN JAPR_language_73 USING(Reference)
LEFT JOIN tmpT1 USING(Reference)



