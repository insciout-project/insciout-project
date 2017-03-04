library(dplyr)
library(data.table)

### --- Analysis at row 100 in DataAnalasis.xls ----
df <- read.csv("../database/test_bigtable.csv")
# Select relevant data and split them in three tables:
news_table = df[df$Source_Category == 'News', c('Reference'), drop=FALSE]
JA_table = df[df$Source_Category == 'JA', c('Reference', 'Source', 'Design_Actual', 'Sample_Actual', 'Sample_Code')]
PR_table = df[df$Source_Category == 'PR', c('Sample', 'Reference', 'Sample_Code')]

# Select the minim between Sample_Code from Article's Title and Article's Body
JA_table <- JA_table %>% # note that both Title and Body rows are in JA_table 
  group_by(Reference) %>%
  mutate(Sample_Code = min(Sample_Code)) # we override the column Sample_Code with its minimum
# Note that %>% is the syntax that dplyr uses to pipe/chain operations:

# remove the rows from Article's Body from JA_table with dplyr's syntax:
JA_table <- JA_table %>%
  filter(Source == 'Journal Article - Body')

# merge the JA table to the PR table
setnames(JA_table, 
         old = c('Sample_Code'), 
         new = c('JA_Sample_Code'))
setnames(PR_table, 
         old = c('Sample_Code'), 
         new = c('PR_Sample_Code'))
d100 <- merge(x = PR_table, y = JA_table, by='Reference')
d100 <- select(d100, -Source) # remove the column 'Source'

# Make columns `PR_Exageration`according to rules.
setDT(d100) # we make it a Data.Table, allows to go faster and write less
d100 <- d100[(PR_Sample_Code %in% c(1,2)) & (JA_Sample_Code == 1), PR_Exageration:= 0 ]
d100 <- d100[(PR_Sample_Code %in% c(1,2)) & (JA_Sample_Code == 3), PR_Exageration:= 1 ]
d100 <- d100[(PR_Sample_Code == 3) & (JA_Sample_Code == 3), PR_Exageration:= 0 ]
d100 <- d100[(PR_Sample_Code == 3) & (JA_Sample_Code == 1), PR_Exageration:= -1 ]
d100 <- d100[(PR_Sample_Code == 4), PR_Exageration:= -99 ]

# Finally we are adding the columns with the count in new_table:
news_table <- news_table %>% 
  group_by(Reference) %>%
  mutate(News_Uptake = 'yes', Total_News= n()) %>%
  filter(row_number()==1)

# and we merge everything:
d100 <- left_join(d100, news_table, by='Reference')
d100$News_Uptake[is.na(d100$News_Uptake)] <- 'no' # note that NA can only be detected with is.na()
d100$Total_News[is.na(d100$Total_News)] <- 0

write.csv(d100, "./d100.csv")