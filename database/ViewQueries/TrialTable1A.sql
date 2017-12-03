WITH

JAcategory AS (
SELECT
Reference,
JABody_table.Design_Actual,
-- add the correlational vs exp variable
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
Meta_table.Year as Year,
Meta_table.Institution as Institution,


-- NEED TO ADD INSTITUTION NAMES HERE
CASE
--WHEN Institution = 1 THEN "Birmingham"
--WHEN Institution = 2 THEN "Bristol"
--WHEN Institution = 3 THEN "Cambridge"
WHEN Institution = 4 THEN "Cardiff"
--WHEN Institution = 5 THEN "Durham"
--WHEN Institution = 6 THEN "Edinburgh"
--WHEN Institution = 7 THEN "Exeter"
--WHEN Institution = 8 THEN "Glasgow"
--WHEN Institution = 9 THEN "Imperial"
--WHEN Institution = 10 THEN "Kings"
WHEN Institution = 11 THEN "Leeds"
--WHEN Institution = 13 THEN "LSE"
--WHEN Institution = 14 THEN "Manchester"
--WHEN Institution = 15 THEN "Newcastle"
--WHEN Institution = 16 THEN "Nottingham"
--WHEN Institution = 17 THEN "Oxford"
--WHEN Institution = 18 THEN "QMUL"
--WHEN Institution = 19 THEN "Belfast"
--WHEN Institution = 20 THEN "Sheffield"
--WHEN Institution = 21 THEN "Southampton"
WHEN Institution = 22 THEN "UCL"
--WHEN Institution = 23 THEN "Warwick"
--WHEN Institution = 24 THEN "York"
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
PRFinal_table.SDI_Cause as PR_Cause


FROM
Meta_table
LEFT JOIN PRDraft_table USING(Reference)
LEFT JOIN PRFinal_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN JAcategory USING(Reference)
LEFT JOIN PRtitle USING(Reference)
LEFT JOIN PRMS USING(Reference)

WHERE Institution IN(4,11,22,25,26,27,29,32,33)
