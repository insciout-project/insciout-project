SELECT 
Reference,
Meta_table.Sample as Meta_Sample, 
JA_table.Sample_Code as JA_Sample_Code,
PR_table.Sample_Code as PR_Sample_Code 
FROM
JA_table 
LEFT JOIN PR_table USING(Reference)
LEFT JOIN Meta_table USING(Reference);
