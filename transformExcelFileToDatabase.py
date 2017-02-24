import pandas as pd
import glob, sys
pd.set_option('display.max_rows', 20)
pd.set_option('precision', 5)

# note that we could directly import the column from an excel file
# but it seems that LibreOffice makes xls files incompatible with pandas.
# column_file = pd.ExcelFile("./Column Names.xls")
# df_col = column_file.parse(0, header=None)
df_col = pd.read_csv("./Column Names.csv", header=None)

metadata_columns = df_col.iloc[0:9, 2].tolist()
# > should give something like:
# > ['PR Title', 'Original Title', 'Discipline', 'SubDiscipline 1', 'SubDiscipline 2', 'Notes', 'Coder', 'Reference', 'Sample']
rearranged_columns = metadata_columns[2:] + metadata_columns[:2]
metadata_table = pd.DataFrame(columns = metadata_columns)

data_columns = df_col.iloc[9:, 2].tolist()
# > looks like that:
# ['Source', 'isFilled', 'Date',  'Author',  'Author_Title',  'ELNU',  'PODO',  'JointPR',  'Embargo_SD',
#  'Embargo_Time',  'Embargo_Duration',  'IV',  'DV',  'IVDV_Same',  'Title_Rship',  'Title_Code',  'MS_Rship',
#  'MS_Code',  'TMS_IVDV_Same',  'Sample_Actual',  'Sample_Conc',  'Sample_Code',  'Design_Actual',  'SDI_filled',
#  'SDI_Design',  'SDI_Cause',  'SDI_Cause_Why',  'SDI_Context',  'SDI_Eval',  'SDI_Statement', 'SDI_Statement_WordsTM',
#  'SDI_Statement_Quote',  'Advice',  'Advice_Code', 'Institution_Mention',  'Institution_WordsTM',  'Body_WordCount',
#  'RCT_Condition', 'RCT_Synonym', 'RCT_Synonym_WordsTM',  'RCT_Title',  'RCT_Title_WordsTM',  'RCT_MS1',
#  'RCT_MS1_WordsTM',  'RCT_MS2',  'RCT_MS2_WordsTM',  'RCT_SDS',  'RCT_SDS_Quote',  'RCT_SDS_WordsTM']
big_data_columns = metadata_columns[2:] + data_columns
big_data_table = pd.DataFrame(columns = big_data_columns)

folder_name = 'datatest'
excel_files = glob.glob("./" + folder_name + "/*.xls")
for i, filepath in enumerate(excel_files):
    sheet = pd.ExcelFile(filepath)
    df = sheet.parse(0, header=None)
    metadata = df.iloc[0:8, 0:2]
    metadata_table.loc[i, :-1] = metadata.iloc[:,1].values
    metadata_table.loc[i, 'Sample'] = folder_name

    data_table = df.iloc[6:55, 2: 48]
    data_table = data_table.transpose()
    data_table.columns = data_columns # mandatory to make append
    data_table = data_table[1:]
    data_table = data_table[data_table.isFilled == 1]

    # we include the metadata in the data table except the titles.
    # to do so we simple repeat the metadata (last row of metadata_table) to fill the data table
    rep_metadata = pd.DataFrame(data=[metadata_table.iloc[-1, 2:].values] * len(data_table),
                                columns=metadata_table.columns[2:])
    data_table.reset_index(inplace=True, drop=True)
    data_table = pd.concat([rep_metadata, data_table], axis=1)

    # here we put the data table in the big data table
    big_data_table = big_data_table.append(data_table, ignore_index=True)

print "metadata table"
metadata_table = metadata_table[rearranged_columns]
print metadata_table
metadata_table.to_csv("test_metatable.csv", encoding='utf-8')
print "big data table"
print big_data_table
big_data_table.to_csv("test_bigtable.csv", encoding='utf-8')

