WITH

JAcategory AS (
SELECT
Reference,
JABody_table.Design_Actual,
-- add the correlational vs exp category
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

--want the news headline causal code
-- need to make sure that the IV and DV are the same between NA and JA

NewsHeadline AS (
SELECT
Reference,
News_table.Source,
News_table.IVDV_Same,
CASE
WHEN News_table.IVDV_Same = 0 THEN -99
WHEN News_table.IVDV_Same = 1 THEN News_table.Title_Code
END
News_HCAcode
FROM
News_table
),

NewsMS AS (
SELECT
Reference,
News_table.Source,
News_table.IVDV_Same,
CASE
WHEN News_table.IVDV_Same = 0 THEN -99
WHEN News_table.IVDV_Same = 1 THEN News_table.MS_Code
END
News_MSCAcode
FROM
News_table
)

SELECT
Reference,
Meta_table.Sample as Sample,
Meta_table.Year as Year,
Meta_table.Institution as Institution,


-- NEED TO ADD INSTITUTION NAMES HERE
CASE
WHEN Institution = 1 THEN "Birmingham"
WHEN Institution = 2 THEN "Bristol"
WHEN Institution = 3 THEN "Cambridge"
WHEN Institution = 4 THEN "Cardiff"
WHEN Institution = 5 THEN "Durham"
WHEN Institution = 6 THEN "Edinburgh"
WHEN Institution = 7 THEN "Exeter"
WHEN Institution = 8 THEN "Glasgow"
WHEN Institution = 9 THEN "Imperial"
WHEN Institution = 10 THEN "Kings"
WHEN Institution = 11 THEN "Leeds"
WHEN Institution = 12 THEN "Liverpool"
WHEN Institution = 13 THEN "LSE"
WHEN Institution = 14 THEN "Manchester"
WHEN Institution = 15 THEN "Newcastle"
WHEN Institution = 16 THEN "Nottingham"
WHEN Institution = 17 THEN "Oxford"
WHEN Institution = 18 THEN "QMUL"
WHEN Institution = 19 THEN "Belfast"
WHEN Institution = 20 THEN "Sheffield"
WHEN Institution = 21 THEN "Southampton"
WHEN Institution = 22 THEN "UCL"
WHEN Institution = 23 THEN "Warwick"
WHEN Institution = 24 THEN "York"
WHEN Institution = 25 THEN "BMJ"
WHEN Institution = 26 THEN "Biomed"
WHEN Institution = 27 THEN "MRC"
WHEN Institution = 29 THEN "Leicester"
WHEN Institution = 33 THEN "FFS"
END
Institution_Name,



PRDraft_table.RCT_Condition as Condition,
News_table.Source as News_Source,
JABody_table.Design_Actual as Study_Design,
JAcategory.Study_Design_Category as Study_Design_Category,
NewsHeadline.News_HCAcode as News_HCAcode,
NewsMS.News_MSCAcode as News_MSCAcode,

-- is the news headline exaggerated relative to the study design?
-- using Adams et al coding
-- need to exclude causal codes 0,1,-9 and study design cat '3=other'

CASE
WHEN News_HCAcode IN (0,1,-9,-99) THEN -99
WHEN Study_Design_Category = 3 THEN -99
WHEN Study_Design_Category = 1 AND News_HCAcode IN (2,3,4) THEN 0
WHEN Study_Design_Category = 1 AND News_HCAcode IN (5,6) THEN 1
WHEN Study_Design_Category = 2 AND News_HCAcode IN (2,3,4) THEN -1
WHEN Study_Design_Category = 2 AND News_HCAcode IN (5,6) THEN 0
END
News_HCAExagg,


CASE
WHEN News_MSCAcode IN (0,1,-9,-99) THEN -99
WHEN Study_Design_Category = 3 THEN -99
WHEN Study_Design_Category = 1 AND News_MSCAcode IN (2,3,4) THEN 0
WHEN Study_Design_Category = 1 AND News_MSCAcode IN (5,6) THEN 1
WHEN Study_Design_Category = 2 AND News_MSCAcode IN (2,3,4) THEN -1
WHEN Study_Design_Category = 2 AND News_MSCAcode IN (5,6) THEN 0
END
News_MSCAExagg,



--Was there any info on study design
News_table.SDI_filled as NewsSDI_Any,
News_table.SDI_Design as News_SD,
News_table.SDI_Cause as News_Cause


FROM
News_table
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN PRDraft_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN JAcategory USING(Reference)
LEFT JOIN NewsHeadline USING(Reference,Source)
LEFT JOIN NewsMS USING(Reference,Source)
