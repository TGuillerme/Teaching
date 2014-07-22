#Load the matrices from the "mat/" folder
setwd("matrices/")

tab<-list(rep('NA',length(list.files(pattern='.mat'))))
for (i in 1:length(list.files())) {
	try(tmp<-read.table(list.files()[i], sep=' ',header=F), silent=TRUE)
	try(tab.tmp<-rep(NA, ncol(tmp)), silent=TRUE)	
for (j in 1:ncol(tmp)) {
	#Isolating the number of levels excluding "?" and odd ones
	try(tab.tmp[j]<-length(grep('^[0-9]', levels(as.factor(tmp[,j])))), silent=TRUE)}
	try(tab[[i]]<-tab.tmp, silent=TRUE)
	}
	
#Creating the states vector excluding chacters 0 | 1 |>10
mat<-unlist(tab)
matr<-mat[-c(which(mat == 0 | mat == 1 | mat > 10))]

#Ploting the results
d1<-hist(matr, breaks=c(1,2,3,4,5,6,7,8,9,10), plot=FALSE)$counts/length(matr)
d2<-hist(matr, breaks=c(1,2,3,4,5,6,7,8,9,10), plot=FALSE)$counts/length(matr)
dat<-rbind(d1,d2)
colnames(dat)<-c("2","3","4","5","6","7","8","9","10")

#Saving the results
setwd("..")
pdf("Histogram.pdf")
barplot(dat[1,], xlab="Number of character states", ylab="Probabilities", main="Frequencies of character states number from 100 matrices",cex.main=1)
text (5,0.8, paste("n=",length(matr)))
dev.off()


tab<-NULL
for (i in 1:length(list.files())) {
    tab[[i]]<-read.table(list.files()[i], skip=1)}

head<-NULL
for (i in 1:length(list.files())) {
    head[[i]]<-read.table(list.files()[i], nrows=1)}

proportion<-NULL
for (i in 1:length(list.files())) {
    proportion[i]<-length(grep('?', tab[[i]]))/(head[[i]][,1]*head[[i]][,2])}

hist(proportion, breaks=20, xlab="Missing Data", main="Frequencies of missing data among 100 morphological matrices")