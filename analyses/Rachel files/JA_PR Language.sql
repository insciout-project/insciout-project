---/// JA > PR: Causal language Analysis row 73 on Analysis.xls

--- need columns:
---    Sample, Institution, PR Number, Study Design (JA), JA: Statement of Relationship Code, PR: Statement of Relationship Code, 
---    Exaggeration/understated, News Uptake, Total Number of News Articles, 


--- *******************************************************************************************************************

--- need a tmp table to calculate the causal lang of the JA
--- when IV and DV are the same in the title and the MS take the highest (from title, abstract and discussion)
--- when they're not the same take the highest from the abstract and discussion
--- same for the PR


WITH
tmpT1 AS
(
SELECT Reference,
    CASE 
    WHEN JABody_table.TMS_IVDV_Same = 1  THEN MAX(JATitle_table.Title_Code, JATitle_table.MS_Code, JABody_table.MS_Code)
    WHEN JABody_table.TMS_IVDV_Same = 0  THEN MAX(JATitle_table.MS_Code, JABody_table.MS_Code)
    END
    JA_CaCode,
    
   CASE 
    WHEN PR_table.TMS_IVDV_Same = 1  THEN MAX(PR_table.Title_Code, PR_table.MS_Code)
    WHEN PR_table.TMS_IVDV_Same = 0  THEN PR_table.MS_Code
    END
    PR_CaCode
    
    FROM JABody_table
    LEFT JOIN JATitle_table USING(Reference)
    LEFT JOIN PR_table USING(Reference)
    ),

-- create a tmp table to calculate news uptake and number of news articles
NewsCount AS
(
SELECT Reference, COUNT() as Count
FROM News_table
GROUP BY Reference
)


SELECT
Reference,
Meta_table.Institution, 
Meta_table.Sample,
JABody_table.Design_Actual, 
tmpT1.JA_CaCode,
tmpT1.PR_CaCode,

--- is the PR lower than the JA causal code (BMJ analysis with Adams et al coding)

CASE
    WHEN JABody_table.Design_Actual IN (0,8)                            THEN -99
    WHEN tmpT1.JA_CaCode IN (0,1,-9)   OR tmpT1.PR_CaCode IN (0,1,-9)   THEN -99
    WHEN  tmpT1.JA_CaCode IN (2,3,4)   AND tmpT1.PR_CaCode IN (2,3,4)   THEN 0
    WHEN  tmpT1.JA_CaCode IN (5,6)     AND tmpT1.PR_CaCode IN (2,3,4)   THEN -1
    WHEN  tmpT1.JA_CaCode IN (2,3,4)   AND tmpT1.PR_CaCode IN (5,6)     THEN 1
    WHEN  tmpT1.JA_CaCode IN (5,6)     AND tmpT1.PR_CaCode IN (5,6)     THEN 0

    END
    PR_Exag_Adams,


--- is the PR lower than the JA causal code (BMJ analysis with old coding)

CASE
    WHEN JABody_table.Design_Actual IN (0,8)                          THEN -99
    WHEN tmpT1.JA_CaCode IN (0,1,-9) OR tmpT1.PR_CaCode IN (0,1,-9)   THEN -99
    WHEN  tmpT1.JA_CaCode = tmpT1.PR_CaCode                           THEN 0
    WHEN  tmpT1.JA_CaCode < tmpT1.PR_CaCode                           THEN 1
    WHEN  tmpT1.JA_CaCode > tmpT1.PR_CaCode                           THEN -1
    END
    PR_Exag_BMJ,    -- CHECK THAT THIS IS CORRECT WITH SOL
    
--- is the PR code exaggerated compared to the study design?

CASE
   WHEN JABody_table.Design_Actual IN (0,8)                                      THEN -99
   WHEN tmpT1.PR_CaCode IN (0,1,-9)                                              THEN -99
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND tmpT1.PR_CaCode IN (2,3,4) THEN 0
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND tmpT1.PR_CaCode IN (2,3,4) THEN -1
   WHEN JABody_table.Design_Actual IN (1,2,3,5,6) AND tmpT1.PR_CaCode IN (5,6)   THEN 1
   WHEN JABody_table.Design_Actual IN (4,7,9)     AND tmpT1.PR_CaCode IN (5,6)   THEN 0
   END
   PR_ActExag_Adams,


-- add in news count and total news
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
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN tmpT1 USING(Reference)
LEFT JOIN NewsCount USING(Reference)

