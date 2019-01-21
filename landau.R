library(fuzzyjoin)
library(data.table)

#read in the scores dataset from data world 
scores = read.csv("https://query.data.world/s/ifvsddtb76qbf2i7f4ezmv6uutqtnj"
                    ,header=TRUE ,stringsAsFactors=FALSE)
scores = data.table(scores)

#filter by strategy criteria
scores = scores[!is.na(Rk..1) & is.na(Rk.)
                ,c("Year","Date","Schl","Rk.","Opp","Rk..1","PTS","OPP","MOV")]

#read in dataset of all team conferences from data world
confs = read.csv("https://query.data.world/s/nox5pnye7bjwbfcqa3ebudmie2f2dl"
                 , header=TRUE, stringsAsFactors=FALSE)
confs = data.table(confs)

#filter out only relevant years and columns
confs = confs[season >= "2015-16",c("school","conf","season")]

#prepare odds data
source("./prepare_odds_data.R")
              
#fuzzy join on just the unique names for efficiency
score_teams = data.table(scores = unique(c(scores$Schl,scores$Opp)))
conf_teams = data.table(confs = unique(confs$school))
odds_teams = data.table(odds = unique(c(odds$Home,odds$Away)))
join_tbl = stringdist_left_join(score_teams,conf_teams
                           ,by = c(scores = "confs"),ignore_case = TRUE)
join_tbl = stringdist_left_join(join_tbl,odds_teams
                                ,by = c(scores = "odds"),ignore_case = TRUE)

#write output of join_tbl to a csv so I can manually investigate and make any
#necessary changes by hand
write.csv(join_tbl,"./join_table.csv")
