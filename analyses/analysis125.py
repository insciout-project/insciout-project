import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv("../database/test_bigtable.csv", encoding='utf-8')

news_table = df.ix[df.Source_Category == 'News', ['Sample', 'Reference', 'Source', 'Advice_Code']]
JA_table = df.ix[df.Source == 'Journal Article - Body', ['Reference', 'Design_Actual']]
PR_table = df.ix[df.Source == 'Final Press Release', ['Reference', 'Advice_Code', 'Advice']]

news_table.rename(columns={'Advice_Code': 'News_Advice_Code', "Source": "News_Source"}, inplace=True)
PR_table.rename(columns= {'Advice_Code': 'PR_Advice_Code', 'Advice': 'PR_Exageration'}, inplace=True)

news_table = pd.merge(news_table, PR_table, how='left', on='Reference')

JA_table.rename(columns={'Design_Actual': "JA_Design"})
news_table = pd.merge(news_table, JA_table, how='left', on='Reference')

news_table['News_Exageration'] = np.where(news_table['News_Advice_Code'] - news_table['PR_Advice_Code'] > 0, 1, -1)
when_equality = (news_table['News_Advice_Code'] - news_table['PR_Advice_Code'] == 0)
news_table.ix[when_equality, 'News_Exageration'] = 0

news_table.to_csv('analysis_row125.csv', encoding='utf-8') # never forget the encoding='utf-8'
print "done!"