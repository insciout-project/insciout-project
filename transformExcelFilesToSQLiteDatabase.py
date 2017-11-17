import pandas as pd
import sqlite3
import utils
import glob, sys, os
pd.set_option('display.max_rows', 20)
pd.set_option('precision', 5)

# do we update or replace the current tables?
# True will replace the existing table if you try to add a table with the same name
# False will append the new entries to the existing table if you try to add a table with the same name
# If you want to reset the database (replace the database), delete the current database or change its name (to back it up).
REPLACE = True

folder_names = glob.glob("./rawdata/*/")
print folder_names
# note that we could directly import the column from an excel file
# but it seems that LibreOffice makes xls files incompatible with pandas.
# column_file = pd.ExcelFile("./Column Names.xls")
# df_col = column_file.parse(0, header=None)
df_col = pd.read_csv("./Column Names.csv", header=None)

metadata_columns = df_col.iloc[0:11, 2].tolist()
# > should give something like:
# > ['PR Title', 'Original Title', 'Discipline', 'SubDiscipline 1',
# 'SubDiscipline 2', 'Notes', 'Coder', 'Reference', 'Sample', 'Year', 'Institution']
rearranged_columns = metadata_columns[2:] + metadata_columns[:2]

data_columns = df_col.iloc[11:, 2].tolist()
# > looks like that:
# ['Source_Category', 'Source', 'isFilled', 'Date',  'Author',  'Author_Title',  'ELNU',  'PODO',  'JointPR',  'Embargo_SD',
#  'Embargo_Time',  'Embargo_Duration',  'IV',  'DV',  'IVDV_Same',  'Title_Rship',  'Title_Code',  'MS_Rship',
#  'MS_Code',  'TMS_IVDV_Same',  'Sample_Actual',  'Sample_Conc',  'Sample_Code',  'Design_Actual',  'SDI_filled',
#  'SDI_Design',  'SDI_Cause',  'SDI_Cause_Why',  'SDI_Context',  'SDI_Eval',  'SDI_Statement', 'SDI_Statement_WordsTM',
#  'SDI_Statement_Quote',  'Advice',  'Advice_Code', 'Institution_Mention',  'Institution_WordsTM',  'Body_WordCount',
#  'RCT_Condition', 'RCT_Synonym', 'RCT_Synonym_WordsTM',  'RCT_Title',  'RCT_Title_WordsTM',  'RCT_MS1',
#  'RCT_MS1_WordsTM',  'RCT_MS2',  'RCT_MS2_WordsTM',  'RCT_SDS',  'RCT_SDS_Quote',  'RCT_SDS_WordsTM']
big_data_columns = ['Reference'] + data_columns

for ifolder, folder_name in enumerate(folder_names):
    metadata_table = pd.DataFrame(columns=metadata_columns)
    big_data_table = pd.DataFrame(columns=big_data_columns)
    print "-------------------------------------\nAccessing folder: " + folder_name
    excel_files = glob.glob(folder_name + "/*.xls")
    # excel_files = glob.glob(folder_name + "\\04-012 - COMPLETE.xls")
    for i, filepath in enumerate(excel_files):
        try:
            sheet = pd.ExcelFile(filepath)
        except:
            print "--\nTABLE NOT INCLUDED: Can't open file: " + filepath + ". It will not be included. Check if it is an encrypted/protected file.\n--"
            continue
        df = sheet.parse(0, header=None)
        #print 'FILENAME: ', filepath

        # EXTRACT DATA FROM EXCEL SPREADSHEET:
        metadata_sheet = df.iloc[0:8, 0:2]
        # Sample, Institution, Source_Category and Source are not in the spreadsheet, hence the -4
        metadata_table.loc[i, :-3] = metadata_sheet.iloc[:, 1].values
        metadata_table.loc[i, 'Sample'] = os.path.basename(os.path.dirname(folder_name))
        metadata_table.loc[i, 'Institution'] = int(metadata_table.loc[i, 'Reference'].split('-')[0])  # take 15 in 03-15-001
        if len(metadata_table.loc[i, 'Reference'].split('-')) > 2:  # if equals 3, it must contains the year
            metadata_table.loc[i, 'Year'] = int("20" + metadata_table.loc[i, 'Reference'].split('-')[1])  # take 15 in 03-15-001
        metadata_table.loc[i, 'Reference'] = '-'.join([metadata_table.loc[i, 'Sample'], metadata_table.loc[i, 'Reference']])

        data_table = df.iloc[6:55, 3: 48]
        data_table = data_table.transpose()
        data_table.insert(0, data_columns[0], 'News') # insert the column Source_Category
        data_table[data_columns[0]].iloc[0:2] = 'PR'
        data_table[data_columns[0]].iloc[2:4] = 'JA' # those rows are still here (as we only filter after)
        if len(data_table.columns) < 50:
            print 'TABLE NOT INCLUDED, the following file is lacking %i column: %s'%(50-len(data_table.columns), filepath)
            continue
        data_table.columns = data_columns # mandatory to make append
        # data_table = data_table[1:] # FIXME: THIS LINE REMOVE THE DRAFT PRESS RELEASE, IT IS NORMAL?? if not what was its aim?

        # SUSPICION TESTS:
        # --> we try to keep only the rows that contain something!
        filling_filter = data_table.isFilled == 1
        secondary_filter = ~pd.isnull(data_table.IV)
        if any(filling_filter != secondary_filter):
            print "--\nROW NOT INCLUDED: In Excel File {}, the following Column(s) (i.e. Source) are marked as 'not filled' while it contains information. \n" \
                  "{} \nThat Source won't be added unless you marked it as 'filled'.\n--"\
                .format(filepath, data_table.Source[filling_filter != secondary_filter].values)

        # whatever the results we don't take the risk of taking suspicious Sources
        # we try to keep only the row that contains something!
        data_table = data_table[data_table.isFilled == 1]

        # --> we test whether SDI_Statement was filled correctly
        if metadata_table['Sample'].iloc[0] == 'sample_trial':
            d = data_table.ix[data_table["Source"] == "Final Press Release", :]
            if len(d) > 0:
                if (d["SDI_Design"].iloc[0] <= 0) or (d["SDI_Cause"].iloc[0] <= 0):
                    if not d["SDI_Statement"].iloc[0] == 0:
                        print "--\nWARNING: In Excel File {}, in Final Press Release, SDI_Statement should be 0 when either SDI_Design <= 0 or SDI_Cause <= 0'.\n--" \
                            .format(filepath)
            else:
                print "--\nWARNING: In Excel File {} does not contain a Final Press Release.\n--" \
                    .format(filepath)

        # EXTRACT METADATA AND ADD THE DATA TO BIG TABLE:
        # we include the metadata reference in the data.
        # to do so we simple repeat the metadata (last row of metadata_table) to fill the data table
        rep_metadata = pd.DataFrame(data=[metadata_table['Reference'].iloc[-1]] * len(data_table),
                                    columns=['Reference'])
        data_table.reset_index(inplace=True, drop=True)
        data_table = pd.concat([rep_metadata, data_table], axis=1)

        # here we put the data table in the big data table
        big_data_table = big_data_table.append(data_table, ignore_index=True)


    print "Extraction of data done! \nUpdate of the Database in Progress ..."
    conn = sqlite3.connect("./database/InSciOut.sqlite3")
    if ifolder > 0: REPLACE = False
    metadata_table = metadata_table[rearranged_columns]
    utils.upsert_to_db(metadata_table, "Meta_table", conn, replace=REPLACE,
                       dup_cols=['Reference'])

    categories = big_data_table.Source_Category.unique()
    for category in categories:
        utils.upsert_to_db(big_data_table.ix[big_data_table.Source_Category == category,:],
                     category+"_table", conn, replace=REPLACE,
                     dup_cols= ['Reference', 'Source'])
    print "Folder " + folder_name + " added successfully! \n\n"

    duplicated = metadata_table.duplicated(subset='Reference', keep='first')
    if any(duplicated):
        print "--\nWARNING: duplicated References found:\n{}".format(metadata_table.ix[duplicated, 'Reference'].values)
