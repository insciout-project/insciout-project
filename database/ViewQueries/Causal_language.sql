--// some variables require re-coding, twice. Where this is the case they cannot be recoded in the 
--// main table but instead require their own temporary table at the beginning of the script
--// this can be done using WITH


-- first we need to categorise study design as either correlational or experimental
-- 1 = correlational, 2 = experimental, 3 = other

WITH
JAcategory AS ( -- create a new table 'JAcategory'
SELECT -- SELECT the variables we want (eg. Design_Actual) FROM the associated table (eg. JABody_table)
Reference,
JABody_table.Design_Actual,
-- recode the Design_Actual variable into the new Study_Design_Category variable using CASE and WHEN
CASE
WHEN JABody_table.Design_Actual IN (1,2,6) THEN 1 -- The correlational categories are 1,2 and 6
WHEN JABody_table.Design_Actual IN (4,7,9) THEN 2 -- The experimental categories are 4,7 and 9
WHEN JABody_table.Design_Actual IN (0,3,5,8) THEN 3 -- Non-defined categories are 0,3,5 and 8
WHEN JABody_table.Design_Actual IN (-9) THEN -99 -- -9 means the variable has not been coded
END
Study_Design_Category -- this is the name of the new variable that we will call later
FROM
JABody_table
),

-- now we need the news headline causal code
-- we need to make sure that the IV and DV are the same between NA and JA
-- where they're not the same code as -99
-- where they are the same provide the News headline code (News_table.Title_Code)
-- this creates the new variable News_HCAcode

NewsHeadline AS ( -- create the new table NewsHeadline
SELECT
Reference,
News_table.Source, -- we need the source and the reference because there are multiple news with the same reference
News_table.IVDV_Same,

CASE
WHEN News_table.IVDV_Same = 0 THEN -99
WHEN News_table.IVDV_Same = 1 THEN News_table.Title_Code
END
News_HCAcode
FROM
News_table
),

-- now do the same for the news main statement and create 'News_MSCAcode'

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


-- this is the main table
-- select the data we want in the order that we want it

SELECT
Reference,
Meta_table.Sample as Sample, --renamed using as, because PR/JA tables have the same variable name
PRDraft_table.RCT_Condition as Condition,
News_table.Source as News_Source,
JABody_table.Design_Actual as Study_Design,
JAcategory.Study_Design_Category as Study_Design_Category, -- here we start calling variables we have created above
NewsHeadline.News_HCAcode as News_HCAcode,
NewsMS.News_MSCAcode as News_MSCAcode,

-- now we want to know whether the News was weakly or strongly causal?
-- using Adams et al (2017) coding

-- News headline
CASE
WHEN News_HCAcode IN (0,1,-9,-99) THEN -99 -- first we exclude statements of no cause / NA
WHEN Study_Design_Category = 3 THEN -99 -- and exclude study designs in category 3 = other (as coded above)
WHEN News_HCAcode IN (2,3,4) THEN 0 -- statement codes 2, 3, and 4 are considered weakly causal
WHEN News_HCAcode IN (5,6) THEN 1 -- statement codes 5 and 6 are considered strongly causal
END
News_HStated,

---- News main statement
CASE
WHEN News_MSCAcode IN (0,1,-9,-99) THEN -99
WHEN Study_Design_Category = 3 THEN -99
WHEN News_MSCAcode IN (2,3,4) THEN 0
WHEN News_MSCAcode IN (5,6) THEN 1
END
News_MSStated -- note there is no comma for the last variable

-- reference where we want to source the data from
FROM
News_table -- use the news table as a reference table i.e. one row per news article
LEFT JOIN Meta_table USING(Reference)
LEFT JOIN PRDraft_table USING(Reference)
LEFT JOIN PRFinal_table USING(Reference)
LEFT JOIN JABody_table USING(Reference)
LEFT JOIN JAcategory USING(Reference)
LEFT JOIN NewsHeadline USING(Reference,Source) -- note we need the Reference and Source for the news tables
LEFT JOIN NewsMS USING(Reference,Source)

WHERE Reference like '%trial%' -- we are only including trial data
AND News_table.IVDV_Same = 1 -- only include cases where the IV and DV were the same between JA and News
AND Study_Design_Category<3 -- only include observational and experimental studies

-- to remove NA cases for headlines (coded -99) remove the '--' in the line below 
--AND News_HStated IN (0,1) -- only include headlines that are weakly / strongly causal

-- to remove NA cases for main statements (coded -99) remove the '--' in the line below
--AND News_MSStated IN (0,1) -- only include main statements that are weakly / strongly causal