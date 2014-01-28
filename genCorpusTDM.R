library(tm)
library(ggplot2)
library(data.table)

train.wfu.file<-"./data/train/ua_wfu_train.csv"
train.wofu.file<-"./data/train/ua_wofu_train.csv"

test.wfu.file<-"./data/test/ua_wfu_test.csv"
test.wofu.file<-"./data/test/ua_wofu_test.csv"

# get vector of body messages to apply to get.tdm
train.wfu.dt <- data.table(read.csv(train.wfu.file,sep=",",stringsAsFactors=FALSE))
train.wofu.dt <- data.table(read.csv(train.wofu.file,sep=",",stringsAsFactors=FALSE))
test.wofu.dt <- data.table(read.csv(test.wofu.file,sep=",",stringsAsFactors=FALSE))
test.wfu.dt <- data.table(read.csv(test.wfu.file,sep=",",stringsAsFactors=FALSE))

train.wfu.body <- train.wfu.dt$body
train.wofu.body <- train.wofu.dt$body

test.wfu.body <- test.wfu.dt$body
test.wofu.body <- test.wofu.dt$body

# get term document matrix
# NxM, where (i,j) is number of times term i (rows) was found in document j (columns)
get.tdm <- function(doc.vec) {
	doc.corpus <- Corpus(VectorSource(doc.vec))
	control <- list(stopwords=TRUE, removePunctuation=TRUE, removeNumbers=TRUE, minDocFreq=3)
	doc.dtm <- TermDocumentMatrix(doc.corpus,control)
	return(doc.dtm)
}

# get train tdms
train.wfu.tdm <- get.tdm(train.wfu.body)
train.wofu.tdm <- get.tdm(train.wofu.body)

# convert to matrix
train.wfu.matrix <- as.matrix(train.wfu.tdm)
# vector of total frequency counts for each term
train.wfu.counts <- rowSums(train.wfu.matrix)
train.wfu.df <- data.frame(cbind(names(train.wfu.counts),as.numeric(train.wfu.counts)),stringsAsFactors=FALSE)

names(train.wfu.df) <- c("term","frequency")
train.wfu.df<-data.table(train.wfu.df)
train.wfu.df[,frequency:=as.numeric(frequency)]

# for each row (term), calculate the fraction of files that have that term
train.wfu.occurrence <- sapply(1:nrow(train.wfu.matrix),
	function(i) {
	length(which(train.wfu.matrix[i,]>0))/ncol(train.wfu.matrix)
	})

# for each row (term), calculate the fraction of that term wrt all the other terms
train.wfu.density <- train.wfu.df$frequency/sum(train.wfu.df$frequency)

# add to df

train.wfu.df[,`:=`(density=train.wfu.density,occurrence=train.wfu.occurrence)]
# 
# 
#  do same with train.wofu
# 
# 
# 
# convert to matrix
train.wofu.matrix <- as.matrix(train.wofu.tdm)
# vector of total frequency counts for each term
train.wofu.counts <- rowSums(train.wofu.matrix)
train.wofu.df <- data.frame(cbind(names(train.wofu.counts),as.numeric(train.wofu.counts)),stringsAsFactors=FALSE)

names(train.wofu.df) <- c("term","frequency")
train.wofu.df<-data.table(train.wofu.df)
# train.wofu.df$frequency <- as.numeric(train.wofu.df$frequency)
train.wofu.df[,frequency:=as.numeric(frequency)]

# for each row (term), calculate the fraction of files that have that term
train.wofu.occurrence <- sapply(1:nrow(train.wofu.matrix),
	function(i) {
	length(which(train.wofu.matrix[i,]>0))/ncol(train.wofu.matrix)
	})

# for each row (term), calculate the fraction of that term wrt all the other terms
train.wofu.density <- train.wofu.df$frequency/sum(train.wofu.df$frequency)

# add to df
train.wofu.df[,`:=`(density=train.wofu.density,occurrence=train.wofu.occurrence)]


# write classifier for single messege

classify.ua <- function(msg.body, training.df, prior=0.5, cst=1e-4){
	msg.tdm <- get.tdm(msg.body)
	msg.freq <- rowSums(as.matrix(msg.tdm))
	# find intersections of words
	msg.match <- intersect(names(msg.freq),training.df$term)

	if(length(msg.match)<1){
		# no match, the probability is the prior * (a small probaility)^(# of terms)
		if(nrow(msg.tdm)==0){
			return(0)
		}else{
		return(prior*cst^(length(msg.freq)))
	}
	}
	else{
		# occurences in training of words that were also in messege
		# match function returns matching elements *positions*
		match.probs <- training.df$occurrence[match(msg.match,training.df$term)]
		# ret_val<-prior*prod(match.probs[match.probs>0.1])*cst^(length(msg.freq)-length(msg.match))
		ret_val<-prior*prod(match.probs[match.probs>0.1])*cst^(length(msg.freq)-length(msg.match))
		return(ret_val)
	}
}

# # get test tdms
# test.wfu.tdm <- get.tdm(test.wfu.body)
# test.wofu.tdm <- get.tdm(test.wofu.body)

# wofu.wofu.test <- sapply(test.wofu.body,
# 	function(p){classify.ua(p,training.df=train.wofu.df)});

# Finally, attempt to classify the test.wofu data using the classifer developed above.
# The rule is to classify a message as wofu if Pr(ua) = wofu > Pr(ua) = wfu
ua.classifier <- function(test.body)
{

  pr.wofu <- classify.ua(test.body, training.df=train.wofu.df)
  pr.wfu <- classify.ua(test.body, training.df=train.wfu.df)
  return(c(pr.wofu, pr.wfu, ifelse(pr.wofu > pr.wfu, 1, 0)))
}

# test.wofu.class <- ua.classifier(test.wofu.tdm)
test.wofu.class <- suppressWarnings(lapply(test.wofu.body,function(p)	{ ua.classifier(p) }))
test.wfu.class <- suppressWarnings(lapply(test.wfu.body,function(p)	{ ua.classifier(p) }))
	

test.wofu.matrix <- do.call(rbind, test.wofu.class)
test.wofu.final <- cbind(test.wofu.matrix, "WithOutFU")

test.wfu.matrix <- do.call(rbind, test.wfu.class)
test.wfu.final <- cbind(test.wfu.matrix, "WithFU")

class.matrix <- rbind(test.wofu.final,test.wfu.final)
class.df <- data.frame(class.matrix, stringsAsFactors = FALSE)

names(class.df) <- c("Pr.WithOutFU" ,"Pr.WithFU", "Class", "Type")
class.df$Pr.WithOutFU <- as.numeric(class.df$Pr.WithOutFU)
class.df$Pr.WithFU <- as.numeric(class.df$Pr.WithFU)
class.df$Class <- as.logical(as.numeric(class.df$Class))
class.df$Type <- as.factor(class.df$Type)


# Create final plot of results
class.plot <- ggplot(class.df, aes(x = log(Pr.WithOutFU), log(Pr.WithFU))) +
    geom_point(aes(shape = Type, alpha = 0.5)) +
    stat_abline(yintercept = 0, slope = 1) +
    scale_shape_manual(values = c("WithOutFU" = 1,
                                  "WithFU" = 2),
                       name = "UA type") +
    scale_alpha(guide = "none") +
    xlab("log[Pr(WithOutFU)]") +
    ylab("log[Pr(WithFU)]") +
    theme_bw() +
    theme(axis.text.x = element_blank(), axis.text.y = element_blank())
ggsave(plot = class.plot,
       filename = file.path("figures/latest/", "ua_fu_class.pdf"),
       height = 10,
       width = 10)

get.results <- function(bool.vector)
{
  results <- c(length(bool.vector[which(bool.vector == FALSE)]) / length(bool.vector),
               length(bool.vector[which(bool.vector == TRUE)]) / length(bool.vector))
  return(results)
}

# Save results as a 2x3 table
wofu.col <- get.results(subset(class.df, Type == "WithOutFU")$Class)
wfu.col <- get.results(subset(class.df, Type == "WithFU")$Class)

class.res <- rbind(wofu.col, wfu.col)
colnames(class.res) <- c("WithOutFU", "WithFU")
print(class.res)

