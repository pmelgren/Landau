library(fuzzyjoin)
library(data.table)

# read in the 3 tables stored the data folder (after they have been prepared
# by prepare_data.R)
scores = data.table(read.csv("./scores.csv"))
confs = data.table(read.csv("./confs.csv"))
odds = data.table(read.csv("./odds.csv"))
master = data.table(read.csv("./join_table.csv"))


