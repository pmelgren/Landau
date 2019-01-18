library(fuzzyjoin)
#read in the scores dataset from data world 
scores = read.csv("https://query.data.world/s/ifvsddtb76qbf2i7f4ezmv6uutqtnj"
                    ,header=TRUE ,stringsAsFactors=FALSE)
#filter by strategy criteria
scores = scores[!is.na(scores$Rk..1) & is.na(scores$Rk.)
              ,c("Year","Date","Schl","Rk.","Opp","Rk..1","PTS","OPP","MOV")]

#read in dataset of all team conferences from data world
confs = read.csv("https://query.data.world/s/nox5pnye7bjwbfcqa3ebudmie2f2dl"
                 , header=TRUE, stringsAsFactors=FALSE)
#filter out only relevant years and columns
confs = confs[confs$season >= "2002-03",c("school","conf","season")]
              
#fuzzy join the 2 tables on home team
dat = stringdist_left_join(scores,confs
                           ,by = c(Schl = "school",Year = "season"))

#fuzzy join the 2 tables on away team
dat = stringdist_left_join(dat,confs
                           ,by = c(OPP = "school",Year = "season"))