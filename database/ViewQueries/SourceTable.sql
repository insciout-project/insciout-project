WITH
t1 AS (
SELECT
Reference,
Meta_table.Sample as Sample,
Meta_table.Institution as Institution,

CASE
WHEN Sample LIKE '%before%' AND Institution IN (4,11,22,25,26,27,29,32,33) THEN 1
WHEN Sample LIKE '%trial%' THEN 1
ELSE 0
END
Filter
FROM
Meta_table
)


SELECT
Reference,
Meta_table.Sample,
Meta_table.Institution,
PRDraft_table.RCT_Condition,
t1.Filter as Filter,

CASE
WHEN filter = 0 THEN -99
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 4 THEN 'Baseline_Cardiff'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 11 THEN 'Baseline_Leeds'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 22 THEN 'Baseline_UCL'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 25 THEN 'Baseline_BMJ'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 26 THEN 'Baseline_BMC'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 27 THEN 'Baseline_MRC'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 29 THEN 'Baseline_Leicester'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 32 THEN 'Baseline_Kent'
WHEN Meta_table.Sample LIKE '%before%' AND Meta_table.Institution = 33 THEN 'Baseline_FFS'


WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 4 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_Cardiff1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 4 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_Cardiff2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 4 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_Cardiff3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 4 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_Cardiff4'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 11 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_Leeds1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 11 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_Leeds2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 11 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_Leeds3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 11 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_Leeds4'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 22 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_UCL1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 22 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_UCL2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 22 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_UCL3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 22 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_UCL4'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 25 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_BMJ1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 25 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_BMJ2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 25 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_BMJ3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 25 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_BMJ4'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 26 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_BMC1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 26 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_BMC2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 26 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_BMC3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 26 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_BMC4'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 27 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_MRC1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 27 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_MRC2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 27 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_MRC3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 27 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_MRC3'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 29 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_Leicester1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 29 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_Leicester2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 29 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_Leicester3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 29 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_Leicester4'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 32 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_Kent1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 32 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_Kent2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 32 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_Kent3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 32 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_Kent4'

WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 33 AND PRDraft_table.RCT_Condition = 1 THEN 'Trial_FFS1'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 33 AND PRDraft_table.RCT_Condition = 2 THEN 'Trial_FFS2'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 33 AND PRDraft_table.RCT_Condition = 3 THEN 'Trial_FFS3'
WHEN Meta_table.Sample LIKE '%trial%' AND Meta_table.Institution = 33 AND PRDraft_table.RCT_Condition = 4 THEN 'Trial_FFS4'
END
Assignment


FROM
Meta_table
LEFT JOIN PRDraft_table USING(Reference)
LEFT JOIN t1 USING(Reference)
