library(dplyr)
library(data.table)
library(DBI)

# --- Analysis at row 125 in DataAnalasis.xls ----
### Split the Big Table in Three Tables (PR, JA and News) ----

db <- dbConnect(RSQLite::SQLite(), dbname = "../database/InSciOut.db")
news_table <- dbGetQuery(db, "SELECT Reference, Source, Advice_Code FROM News_table")
JA_table <- dbGetQuery(db, "SELECT Reference, Design_Actual FROM JABody_table")
PR_table <- dbGetQuery(db, "SELECT Reference, Advice_Code, Sample_Code FROM PR_table")
Meta_table <- dbGetQuery(db, "SELECT Reference, Sample FROM Meta_table")


### Create a Table that Crosses Information between JA, PR and News tables ----
# merge the PR Table to the News table
setnames(news_table, 
         old = c('Advice_Code','Source'), 
         new = c('News_Advice_Code','News_Source'))
setnames(PR_table, 
         old = c('Advice_Code'), 
         new = c('PR_Advice_Code'))

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
d125$News_Exageration[isNewsEqual] <- 0

### Add New Columns based on Older Analysis
d100 <- read.csv("./d100.csv", stringsAsFactors = F)
sub.d100 <- d100 %>%
  select(Reference, PR_Exageration)

d125 <- left_join(x = d125, y = sub.d100, by='Reference')

# save and display the first 10 rows:
write.csv(d125, "./d125.csv")
head(d125, 10)

