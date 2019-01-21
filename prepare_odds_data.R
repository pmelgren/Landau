## prepare odds data

# Prepare the odds data found on https://www.sportsbookreviewsonline.com/scoresoddsarchives/ncaabasketball/ncaabasketballoddsarchives.htm
# to be usable for this analysis. 
library(data.table)

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