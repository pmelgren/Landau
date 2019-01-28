library(fuzzyjoin)
library(data.table)

# read in the 3 tables stored the data folder (after they have been prepared
# by prepare_data.R)
scores = data.table(read.csv("./data/scores.csv"))
confs = data.table(read.csv("./data/confs.csv"))
odds = data.table(read.csv("./data/odds.csv"))
master = data.table(read.csv("./data/join_table.csv"))

#merge the join table into scores
setkey(master,scores)
setkey(scores,Schl)
scores = master[scores]
setkey(scores,Opp)
scores = master[scores]
colnames(scores) = gsub("i.","home.",colnames(scores))

#merge in conferences
setkey(scores,confs,Year)
setkey(confs,school,season)
scores = confs[scores,nomatch = 0]
 colnames(scores) = gsub("school","AwayTeam",colnames(scores))
setkey(scores,home.confs,season)
scores = confs[scores,nomatch = 0]

#filter only in-conference games
scores = scores[conference == i.conference,]

#merge in odds
setkey(scores,home.odds,Date)
setkey(odds,Home,Date)
scores = odds[scores]

scores = scores[,list(Conference = conference,Date,Home,Away
                      ,Away_Rank = Rk..1,Home_Spread,Home_Score = PTS
                      ,Away_Score = OPP)]
scores[,Cover := ifelse(Home_Score+Home_Spread > Away_Score,"Cover","No")]
scores[Home_Score+Home_Spread == Away_Score,Cover := "Push"]

write.csv(scores,"./Strategy_Results.csv",row.names = FALSE)