## prepare odds data

# Prepare the odds data found on https://www.sportsbookreviewsonline.com/scoresoddsarchives/ncaabasketball/ncaabasketballoddsarchives.htm
# to be usable for this analysis. 
library(data.table)

odds = data.table()
for(year in c("2017-18","2016-17")){
  next_year = data.table(read.csv(paste0("./data/odds",year,".csv")
                                   ,stringsAsFactors = FALSE,header = TRUE
                                   ,fileEncoding = "UTF-8-BOM"))
  next_year = next_year[,c("Date","Rot","Team","Close")]
  next_year[,Season := year]
  odds = rbind(odds,next_year)
}

# Change "pk" to 0 then set Close as numeric
odds = odds[Close != "NL",]
odds[Close == "pk",Close := 0]
odds[,Close := as.numeric(Close)]

# Separate home and away as 2 separate DF's
V = odds[Rot%%2 == 1,][,VH := NULL]
H = odds[Rot%%2 == 0,][,VH := NULL]

# Rename team columns as home and away
colnames(V)[3] = "Away"
colnames(H)[3] = "Home"

# Join the 2 tables together so each game is 1 row
V[,Rot := Rot+1] #add 1 to visitor Rot so its the same as home
setkey(V,Date,Rot,Season) #set keys to join on
setkey(H,Date,Rot,Season)
odds = H[V] #inner join

odds[,Home_Spread := ifelse(Close > i.Close,-1*Close,i.Close)]