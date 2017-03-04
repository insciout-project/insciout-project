library(dplyr)
library(data.table)

# --- Analysis at row 125 in DataAnalasis.xls ----
### Split the Big Table in Three Tables (PR, JA and News) ----
df <- read.csv("../database/test_bigtable.csv")
news_table = df[df$Source_Category == 'News', c('Sample', 'Reference', 'Source', 'Advice_Code')]
JA_table = df[df$Source == 'Journal Article - Body', c('Reference', 'Design_Actual')]
PR_table = df[df$Source == 'Final Press Release', c('Reference', 'Advice_Code', 'Advice')]

### Create a Table that Crosses Information between JA, PR and News tables ----
# merge the PR Table to the News table
setnames(news_table, 
         old = c('Advice_Code','Source'), 
         new = c('News_Advice_Code','News_Source'))
setnames(PR_table, 
         old = c('Advice_Code','Advice'), 
         new = c('PR_Advice_Code','PR_Exageration'))

d125 <- merge(x = news_table, y = PR_table, by='Reference', all.x = TRUE)
# alternative way, using dplyr:
# d125 <- left_join(news_table, PR_table, by='Reference')

# merge the JA Table to the Result Table:
setnames(JA_table, old = c('Design_Actual'), new = c('JA_Design'))
d125 <- merge(x = d125, y = JA_table, by='Reference', all.x = TRUE)

### Add New Columns To Our Table based on its Current Columns ----
isNewsGreater <- d125$News_Advice_Code > d125$PR_Advice_Code
d125$News_Exageration = ifelse(isNewsGreater, 1, -1)

isNewsEqual = d125$News_Advice_Code == d125$PR_Advice_Code
results_table$News_Exageration[isNewsEqual] <- 0

### Add New Columns based on Older Analysis
sub.d100 <- d100 %>%
  select(Reference, PR_Exageration)

d125 <- left_join(x = d125, y = sub.d100, by='Reference')

# save and display the first 10 rows:
write.csv(d125, "./d125.csv")
head(d125, 10)

