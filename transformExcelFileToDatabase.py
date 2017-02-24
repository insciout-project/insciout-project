import pandas as pd
import glob, sys
pd.set_option('display.max_rows', 20)
pd.set_option('precision', 5)

# sheet0 = pd.ExcelFile("./datatest/03-15-013.xls")

metadata_columns = \
    ['PR Title', 'Original Title', 'Discipline', 'SubDiscipline 1', 'SubDiscipline 2', 'Notes', 'Coder', 'Reference', 'Sample']
rearranged_columns = metadata_columns[2:] + metadata_columns[:2]
metadata_table = pd.DataFrame(columns = metadata_columns)

# could put that in a file.
data_columns = \
    ['Source', 'isFilled', 'Date', 'Author', 'Author Title', 'ELNU', 'PDO', 'Jointed Release', 'Embargo SD',
     'Embargo Time', 'Embargo Duration', 'MC IVs', 'MC DVs', 'JAPRVs Coherence', 'Causation TPS', 'Causation TPC',
     'Causation MPS', 'Causation MPC', 'TMVs Coherence', 'Sample', 'MC Target', 'Sample Code', 'Design', 'isInfoDesign',
     'isDesignStated', 'Causation Mention', 'Causation Warning', 'isContextualized', 'isCritical', 'RTC Design',
     'RTC DesignWords', 'RTC DesignQuote', 'Advice', 'Advice Code', 'isIntitution', 'Institution WordPos', 'Word Count',
     'PR ExpCond', 'PR Synonym', 'PR SynWords', 'PR CPCT', 'PR CPCTWords', 'PR CPCM1', 'PR CPCM1Words',
     'PR CPCM2', 'PR CPCM2Words', 'PR Design', 'PR DesignQuote', 'PR DesignWords']
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

