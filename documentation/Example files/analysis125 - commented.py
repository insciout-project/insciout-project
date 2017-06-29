import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv("../database/test_bigtable.csv", encoding='utf-8')

# We use the analysis explained in row 125 in Data Analysis.xls
# -----------------
# we want to obtain a table
# 1. Sample,
# 2. Institution,
# 3. Reference (PR number),
# 4. JA_Design:
#       Design_Actual when (Source == "Journal Article - Body") # note you may want to simplify the name
# 5. PR_Advise:
#       Advice_Code when (Source == "Final Press Release")
# -----------------
# !WARNING! note that in the document you speak about the JA - Body but you cite cell E40, which correspond to PR
# -----------------
# 6. News_Source
#       Source when (Source_Category == "News")
# 7. News_Advise
#       Advice_Code when (Source_Category == "News")
# 8. News_Exageration
#       1 if col7 > col5
#       0 if col7 == col5
#       -1 if col7 < col5
# 9. PR_Exageration
#       Advice when (Source == "Final Press Release")
# -----------------
# !WARNING! note that I am not sure of what you want here, that does not seem to make sense, you cited "column I39"
# -----------------


# Before to start, it is important to note that the resulting table as one line per news paper!
# Let us extract some information and divide it in three tables:
news_table = df.ix[df.Source_Category == 'News', ['Sample', 'Reference', 'Source', 'Advice_Code']]
JA_table = df.ix[df.Source == 'Journal Article - Body', ['Reference', 'Design_Actual']]
PR_table = df.ix[df.Source == 'Final Press Release', ['Reference', 'Advice_Code', 'Advice']]

# As the table we want as one line per news paper, we use news_table as the main table
# that is why we extract a lot of variables for news_table ('Source_Category', 'Source', 'Sample').
# and we will continue to fill it.

# let us include the PR Advice code in news_table
# First, we change the name of Advice_Code in news_table for avoiding to override it with the PR's Advice_Code
news_table.rename(columns={'Advice_Code': 'News_Advice_Code', "Source": "News_Source"}, inplace=True)
PR_table.rename(columns= {'Advice_Code': 'PR_Advice_Code', 'Advice': 'PR_Exageration'}, inplace=True)
# now we **merge** PR_table and news_table based **on** Reference, using References in news_table
# when writing:
#   pd.merge(news_table, PR_table)
# news_table is the 'left' table while PR_table in the 'right' table
#   pd.merge(news_table, PR_table, how='left')
#  is to say we want to keep only the reference present in news_table
news_table = pd.merge(news_table, PR_table, how='left', on='Reference')

# now we merge the JA's Design_Actual variable
JA_table.rename(columns={'Design_Actual': "JA_Design"})
news_table = pd.merge(news_table, JA_table, how='left', on='Reference')

# Finally we compute the important variable "News Exageration"
news_table['News_Exageration'] = np.where(news_table['News_Advice_Code'] - news_table['PR_Advice_Code'] > 0, 1, -1)
when_equality = (news_table['News_Advice_Code'] - news_table['PR_Advice_Code'] == 0)
news_table.ix[when_equality, 'News_Exageration'] = 0

news_table.to_csv('analysis_row125.csv', encoding='utf-8') # never forget the encoding='utf-8'
print "done!"