install.packages("xts")
install.packages("dynlm")
require(diptest) #this package provides a test that tests for unimodality, and if it's rejected you've got either bi- or multi- modality.
require(grid) 
require(gridBase) 
require(forecast)
require(tseries)
require("e1071")
require(MASS) 
require(caret)
require(lmtest)
require(tidyr)
require(moments)
require(Rmisc)
require(ggplot2)
require(reshape)
require(stargazer)
require(car)
require(zoo)
require(glmnet)
require(xts)
require(dynlm)

#Bring in the data

data<-read.csv("ConstructionTimeSeriesDataV2(1).csv")
head(data)
names(data)<-tolower(names(data))
colnames(data)[3]<-"Total"
colnames(data)[4]<-"Private"
colnames(data)[5]<-"Public"
str(data)
data$month.year<-as.character(data$month.year)
str(data)
data$month.year[nchar(data$month.year) == 5] #don't need , after 5 since dealing with only one column
data$month.year[nchar(data$month.year) == 5] <- paste0("0", data$month.year[nchar(data$month.year) == 5])
paste0("0", data$month.year[nchar(data$month.year) == 5])
str(data)
head(data)

#convert the data to the yearmon class from zoo
data$month.year<-as.yearmon(data$month.year,"%y-%b")

#Construct a graph of the data
jumanji<-summary(data)
jumanji
par(mfrow=c(1,3))
hist(data[,3], main= "Total Construction", xlab= NULL)
hist(data[,4], main= "Private Construction", xlab= NULL)
hist(data[,5], main= "Public Construction", xlab= NULL)
formelt<-data[,-1]
str(formelt)
Melted_Data<-melt(formelt, id.vars = "month.year")
str(Melted_Data)
p <- ggplot(Melted_Data, aes(factor(variable), value)) 
p + geom_boxplot(fill="grey80",color="blue") + ggtitle("Boxplots of Construction Types") + labs(x="Type",y="Dollars (millions)")  ## + facet_wrap(~variable, scale="free") 

merged<-merge(data,two, all=TRUE)

#Find the difference between the two sets
two<-ratePub-ratePriv
two
two<-rbind(c(0), two[1])
data["Difference"]=ratePub-ratePriv

op<-par()
par(op)
#get yearly summaries
dataxts<-xts(data, order.by = data$month.year)
dataxts<-dataxts[,-c(1,2)]
datayr<-apply.yearly(dataxts, mean)
datamn<-apply.monthly(dataxts, mean)
dataqtr<-apply.quarterly(dataxts, mean)

#Set the number of plots, and then plot the data
par(mfrow=c(3,1), cex=2)
plot(datayr)
plot(dataqtr)
plot(datamn)
datats<-ts(data[,-1], start=c(2002,1), end=c(2014,2), frequency=12)
plot(datats, main="Construction", axis(3, las=1))
publicstl<-stl(datats[,'Public'], s.window=12)
privatestl<-stl(datats[,'Private'], s.window=12)
totalstl<-stl(datats[,'Total'], s.window=12)
png("public.png", width=900, height=1000)
plot(publicstl, main = "Public Construction", lwd=2, col="tan4")
axis(2, cex.axis=1.2)
dev.off()
png("private.png", width=900, height=1000)
plot(privatestl, main = "Private Construction", lwd=2, col="steelblue")
dev.off()
png("total.png", width=900, height=1000)
plot(totalstl, main = "Total Construction", lwd=2, col="plum4")
dev.off()
acf(datats)
accuracy(publicstl)

#Get the year correlation
str(datayr)
corryr<-ccf(drop(datayr$Private), drop(datayr$Public), type = c("correlation", "covariance"))

corr<-ccf(drop(as.numeric(dataqtr$Private)), drop(as.numeric(dataqtr$Public)))
corr2<-ccf(drop(as.numeric(dataqtr$Public)), drop(as.numeric(dataqtr$Private)))

corr3<-ccf(drop(as.numeric(datamn$Public)), drop(as.numeric(datamn$Private)))

#Plot the correlations
plot(corryr)
png("correlation.png", width=900, height=700)
plot(corr, main = "Correlation of Private and Public Construction per Quarter")
dev.off()

#Run a regression on the public data with private as a lag variable
datafs<-dynlm(drop(as.numeric(dataqtr$Public)) ~ lag(drop(as.numeric(dataqtr$Private)),-10), dataqtr)
summary(datafs)
plot(datafs)

#create an html table of the output
stargazer(datafs, type="html")

#Run a t-test to check results
t.test(data$Public, data$Private, paired=TRUE,conf.level=.95)

t.test(Data$Typical, 
       Data$Odd, 
       paired=TRUE, 
       conf.level=0.95)

data["difference"]<-data$Private-data$Public
str(data)
plot(data$difference)
data

#final plot
ggplot(data=data, aes(x=month.year, y=difference, group=1)) +
  geom_line()+
  geom_point()


