WITH

JAcategory AS (
SELECT
Reference,
JABody_table.Design_Actual,
-- add the correlational vs exp variable
-- 1 = correlational
-- 2 = experimental
-- 3 = other
CASE
WHEN JABody_table.Design_Actual IN (1,2,6) THEN 1
WHEN JABody_table.Design_Actual IN (4,7,9) THEN 2
WHEN JABody_table.Design_Actual IN (0,3,5,8) THEN 3
WHEN JABody_table.Design_Actual IN (-9) THEN -99
END
Study_Design_Category
FROM
JABody_table
),

--want the press release title causal code
-- need to make sure that the IV and DV are the same between PR and JA

PRtitle AS (
SELECT
Reference,
PRFinal_table.IVDV_Same,
CASE
WHEN PRFinal_table.IVDV_Same = 0 THEN -99
WHEN PRFinal_table.IVDV_Same = 1 THEN PRFinal_table.Title_Code
END
PR_TCAcode
FROM
PRFinal_table
),

PRMS AS (
SELECT
Reference,
PRFinal_table.IVDV_Same,
CASE
WHEN PRFinal_table.IVDV_Same = 0 THEN -99
WHEN PRFinal_table.IVDV_Same = 1 THEN PRFinal_table.MS_Code
END
PR_MSCAcode
FROM
PRFinal_table
)

SELECT
Reference,
Meta_table.Sample as Sample,
Meta_table.Institution as Institution,

-- NEED TO ADD INSTITUTION NAMES HERE
CASE
WHEN Institution = 4 THEN "Cardiff"
WHEN Institution = 11 THEN "Leeds"
WHEN Institution = 22 THEN "UCL"
WHEN Institution = 25 THEN "BMJ"
WHEN Institution = 26 THEN "Biomed"
WHEN Institution = 27 THEN "MRC"
WHEN Institution = 29 THEN "Leicester"
WHEN Institution = 32 THEN "Kent"
WHEN Institution = 33 THEN "FFS"
END
Institution_Name,


PRDraft_table.RCT_Condition as Condition,
JABody_table.Design_Actual as Study_Design,
JAcategory.Study_Design_Category as Study_Design_Category,
PRtitle.PR_TCAcode as PR_TCAcode,
PRMS.PR_MSCAcode as PR_MSCAcode,

-- is the PR title exaggerated relative to the study design?
-- using Adams et al coding
-- need to exclude causal codes 0,1,-9 and study design cat '3=other'

CASE
WHEN PR_TCAcode IN (0,1,-9,-99) THEN -99
WHEN Study_Design_Category = 3 THEN -99
WHEN Study_Design_Category = 1 AND PR_TCAcode IN (2,3,4) THEN 0
WHEN Study_Design_Category = 1 AND PR_TCAcode IN (5,6) THEN 1
WHEN Study_Design_Category = 2 AND PR_TCAcode IN (2,3,4) THEN -1
WHEN Study_Design_Category = 2 AND PR_TCAcode IN (5,6) THEN 0
END
PR_TCAExagg,

CASE
WHEN PR_MSCAcode IN (0,1,-9,-99) THEN -99
WHEN Study_Design_Category = 3 THEN -99
WHEN Study_Design_Category = 1 AND PR_MSCAcode IN (2,3,4) THEN 0
WHEN Study_Design_Category = 1 AND PR_MSCAcode IN (5,6) THEN 1
WHEN Study_Design_Category = 2 AND PR_MSCAcode IN (2,3,4) THEN -1
WHEN Study_Design_Category = 2 AND PR_MSCAcode IN (5,6) THEN 0
END
PR_MSCAExagg,


--Was there any info on study design
PRFinal_table.SDI_filled as PRSDI_Any,
PRFinal_table.SDI_Design as PR_SD,
PRFinal_table.SDI_Cause as PR_Cause,

--were the changes accepted or not?
PRFinal_table.RCT_Synonym as Synonym_acceptance,
PRFinal_table.RCT_Title as Title_acceptance,
PRFinal_table.RCT_MS1 as MS1_acceptance,
PRFinal_table.RCT_SDS as SDS_acceptance


FROM
Meta_table
LEFT JOIN PRDraft_table USING(Reference)
LEFT JOIN PRFinal_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN JAcategory USING(Reference)
LEFT JOIN PRtitle USING(Reference)
LEFT JOIN PRMS USING(Reference)

WHERE Reference like '%trial%'
