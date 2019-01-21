library(data.table)
library(fuzzyjoin)

## prepare odds data

# Prepare the odds data found on https://www.sportsbookreviewsonline.com/scoresoddsarchives/ncaabasketball/ncaabasketballoddsarchives.htm
# to be usable for this analysis. 

odds = data.table()
for(year in c("2017-18","2016-17","2015-16")){
  next_year = data.table(read.csv(paste0("./data/odds",year,".csv")
                                   ,stringsAsFactors = FALSE,header = TRUE
                                   ,fileEncoding = "UTF-8-BOM"))
  next_year = next_year[,c("Date","Rot","Team","Close")]
  next_year[,Season := year]
  odds = rbind(odds,next_year)
}

# Change "pk" to 0 then set Close as numeric
odds = odds[Close != "NL",]
odds[Close == "pk",Close := "0"]
odds[,Close := as.numeric(Close)]

#fix a few naming inconsistencies
odds[Team == "Denver",Team:="DenverU"]
odds[Team == "Memphis",Team:="MemphisU"]

# Separate home and away as 2 separate DF's
V = odds[Rot%%2 == 1,]
H = odds[Rot%%2 == 0,]

# Rename team columns as home and away
colnames(V)[3] = "Away"
colnames(H)[3] = "Home"

# Join the 2 tables together so each game is 1 row
V[,Rot := Rot+1] #add 1 to visitor Rot so its the same as home
setkey(V,Date,Rot,Season) #set keys to join on
setkey(H,Date,Rot,Season)
odds = H[V] #inner join

#restructure date column
odds[,Date := paste0(substr(Date,1,nchar(Date)-2),"/"
                     ,substr(Date,nchar(Date)-1,nchar(Date)),"/20"
                     ,ifelse(nchar(Date) == 4,substr(Season,3,4)
                             ,substr(Season,6,7)))
     ]

odds[,Home_Spread := ifelse(Close < i.Close,-1*Close,i.Close)]
odds = odds[complete.cases(odds),]

write.csv(odds,"./data/odds.csv")


## prepare scores data

#read in the scores dataset from data world 
scores = read.csv("https://query.data.world/s/ifvsddtb76qbf2i7f4ezmv6uutqtnj"
                  ,header=TRUE ,stringsAsFactors=FALSE)
scores = data.table(scores)

#filter by strategy criteria
scores = scores[!is.na(Rk..1) & is.na(Rk.) & Year >= "2015-16"
                ,c("Year","Date","Schl","Rk.","Opp","Rk..1","PTS","OPP","MOV")]

write.csv(scores,"./data/scores.csv")

## prepare conference data

#read in dataset of all team conferences from data world
confs = read.csv("https://query.data.world/s/nox5pnye7bjwbfcqa3ebudmie2f2dl"
                 , header=TRUE, stringsAsFactors=FALSE)
confs = data.table(confs)

#filter out only relevant years and columns
confs = confs[season >= "2015-16",c("school","conf","season")]
confs18 = confs[season == "2016-17",]
confs18[,season := "2017-18"]
confs = rbind(confs,confs18)

write.csv(confs,"./data/confs.csv")


## prepare the join table by fuzzy joining each unique list of names.
## will manually adjust after writing to disk

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
write.csv(join_tbl,"./data/join_table.csv")