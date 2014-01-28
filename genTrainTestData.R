library(tm)
library(ggplot2)
library(data.table)
library(plyr)

data.path <- "./data/aiua.csv"

# split data up into wfu (with follow-up) and wofu (without-followup)
# use random 75% of entries of each 

# build text corpus
ua.dt <- read.csv(data.path,sep=",",stringsAsFactors=FALSE)
ua.dt <- data.table(ua.dt)

ua.dt<-ua.dt[,list(id=data_id,body=body,status=action,idate=issue_date)]
# drop if no data in body

ua.dt<-ua.dt[which(body!=""),]

# get number of times each id has a ua
id.counts <- data.table(count(ua.dt,"id"))
id.counts[,wfu:=(freq!=1)]
# ad to dt
ua.dt<-merge(ua.dt,id.counts[2:nrow(id.counts),],by="id")
# with and without followup
ua.wfu.dt<-ua.dt[which(wfu)]
ua.wofu.dt<-ua.dt[which(!wfu)]

# For those with followups, only interested in first entry, remove duplicates by id
ua.wfu.dt<-ua.wfu.dt[!duplicated(ua.wfu.dt$id),]

n_wfu=nrow(ua.wfu.dt)
n_wofu=nrow(ua.wofu.dt)
print(paste(n_wfu,"entries with follow-up"))
print(paste(n_wofu,"entries with out follow-up"))

# assume prior p=0.5 of followup, so equalize entries 
if(n_wfu>n_wofu){
	# print("hi")
	ua.wfu.dt <- ua.wfu.dt[1:n_wofu,]
	print(paste("Dropping",n_wfu-nrow(ua.wfu.dt),"entries from those with follow-up"))
	n_wfu<-nrow(ua.wfu.dt)
	}else{
 		# print("bi")
 	ua.wofu.dt <- ua.wofu.dt[1:n_wfu,]
 	print(paste("Dropping",n_wofu-nrow(ua.wofu.dt),"entries from those with-out follow-up"))
 	n_wofu<-nrow(ua.wofu.dt)
 }

 # Save training and test for both classes
 # Use random 75% of both for training, remaining 25% for testing
 train.bool <- sapply(runif(n_wfu,0,1),function(b){ ifelse(b<0.75,TRUE,FALSE)})

 ua.wfu.train.dt <- ua.wfu.dt[train.bool,]
 ua.wfu.test.dt <- ua.wfu.dt[!train.bool,]

 ua.wofu.train.dt <- ua.wofu.dt[train.bool,]
 ua.wofu.test.dt <- ua.wofu.dt[!train.bool,]
 
 write.csv(ua.wofu.train.dt, file.path("./data/train/", "ua_wofu_train.csv"), row.names = FALSE)
 write.csv(ua.wfu.train.dt, file.path("./data/train/", "ua_wfu_train.csv"), row.names = FALSE) 

 write.csv(ua.wofu.test.dt, file.path("./data/test/", "ua_wofu_test.csv"), row.names = FALSE)
 write.csv(ua.wfu.test.dt, file.path("./data/test/", "ua_wfu_test.csv"), row.names = FALSE) 
