WITH

JAcategory AS (
SELECT
Reference,
JABody_table.Design_Actual,
-- add the correlational vs exp category
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
News_table.Source as News_Source
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
News_table.SDI_Cause as News_Cause,

--were the changes accepted or not?
PRFinal_table.RCT_Synonym as Synonym_acceptance,
PRFinal_table.RCT_Title as Title_acceptance,
PRFinal_table.RCT_MS1 as MS1_acceptance,
PRFinal_table.RCT_SDS as SDS_acceptance


FROM
News_table
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN PRDraft_table USING(Reference)
LEFT JOIN PRFinal_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN JAcategory USING(Reference)
LEFT JOIN NewsHeadline USING(Reference,Source)
LEFT JOIN NewsMS USING(Reference,Source)

WHERE Reference like '%trial%'
