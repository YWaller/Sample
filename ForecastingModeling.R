#########################
###IGNORE THIS SECTION###
#########################

install.packages(c("forecast","tseries"))
install.packages("gridBase") #for the graphs
install.packages("grid") #also for graphs
install.packages("diptest")
install.packages("het.test")
require(diptest) #this package provides a test that tests for unimodality, and if it's rejected you've got either bi- or multi- modality.
require(grid) #I love R packages it's like christmas whenever I get a new one
require(gridBase) 
require(forecast)#Remember that all models are wrong; the practical question is how wrong do they have to be to not be useful.
require(tseries) #A useful quote from someone for future me
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
require(het.test) #this is for vector autoregression of white's test, don't need it here but maybe some day
#require(installr) ##I had to update my R
#installed.packages()
#load("installed_old.rda")
#tmp <- installed.packages()
#installedpkgs.new <- as.vector(tmp[is.na(tmp[,"Priority"]), 1])
#missing <- setdiff(installedpkgs, installedpkgs.new)
#updateR()
#install.packages(missing) #restart R
#update.packages()
#.libloc <<- "C:/Users/Yale/Documents/R/win-library/3.4" #gotta tell R about the directory
#C:\Users\Yale\Documents\R\win-library\3.4 #restart R before running above
##this code above will update R and bring all packages in

#######################
###BEGIN ACTUAL WORK###
#######################

#This file represents the culmination of a large project I undertook at one of my jobs
#It begins by verifying data integrity and regression assumptions, completes the regression,
#and then goes onto forecasting with time series.


#Initial data processing
purchasesurvey<-read.table("purchasesurvey.txt", header=TRUE, sep="\t")
colnames(purchasesurvey)<-tolower(colnames(purchasesurvey))
tractorsales<-read.table("tractorsales.txt", header=TRUE, sep="\t")
colnames(tractorsales)<-tolower(colnames(tractorsales))
str(purchasesurvey)
str(tractorsales)
tractorsales$month<-as.yearmon(as.character(tractorsales$month),"%b-%y")
head(purchasesurvey)
head(tractorsales)
tail(tractorsales, 1) #how to get last value of dataset!

#get column means of the purchase survey
p_survey_means<-colMeans(purchasesurvey, na.rm=TRUE)
p_survey_means

#a custom function for calculating column standard deviations
colSDs<-function(x, na.rm=TRUE) {
  if (na.rm) {
    n <- colSums(!is.na(x))
  } else {
    n <- nrow(x)
  }
  colVar <- colMeans(x*x, na.rm=na.rm) - (colMeans(x, na.rm=na.rm))^2
  return(sqrt(colVar * n/(n-1)))
}

p_survey_sds<-colSDs(purchasesurvey)
p_survey_sds
jumanji<-summary(purchasesurvey)
stargazer(purchasesurvey, title="Summary Statistics of Purchase Survey", summary=TRUE, type="html")
length(unique(purchasesurvey$respondent.id)) == nrow(purchasesurvey)
stargazer(tractorsales, title="Summary Statistics of Tractor Sales", summary=TRUE, type="html")

purchasesurvey$overall.service[purchasesurvey$overall.service<1]<- NA
purchasesurvey$buying.type[purchasesurvey$buying.type>3]<- NA #do these then re-create the stargazer tables

par(mar=c(9,6,4,1)) #bottom, left, top, right margin sizes
barplot(p_survey_means[-1],col=rainbow(13),beside=TRUE,ylab="Mean, various scales",main="Means of Survey Response Items",las=2,cex.names=1)
title(xlab="Survey Item", line=6.5) #moves the xlab down

#melt the data into the proper form
melted_ps<-melt(purchasesurvey[-1], na.rm=TRUE)
#use stargazer to get html table output
stargazer(moments::kurtosis(purchasesurvey[-c(11:14)], na.rm=TRUE),type="html",title="Kurtosis",flip=TRUE)
stargazer(skewness(purchasesurvey[-c(11:14)], na.rm=TRUE),type="html",title="Purchase Survey Skewness", flip= TRUE) #use flip to make it long instead of wide
ggplot(melted_ps, aes(x=value, fill=variable)) + geom_histogram(binwidth=.5)+ facet_grid(variable~.)
hist(purchasesurvey$usage.level,breaks=50)
dip(purchasesurvey$usage.level) #Hartigan's dip test

Melted_Data<-melt(purchasesurvey[-1])
str(Melted_Data)
p <- ggplot(Melted_Data, aes(factor(variable), value)) 
p + geom_boxplot(fill="grey80",color="blue") + ggtitle("Boxplots of Purchase Survey Items") + labs(x="Survey Item",y="")  ## + facet_wrap(~variable, scale="free") 


#ANOVA is an omnibus test statistic and cannot tell you which specific groups were statistically significantly different from each other, only that at least two groups were. To determine which specific groups differed from each other, you need to use a post hoc test.
str(purchasesurvey) #usage level is PLE use % and satisfaction level is customer satisfaction
reguse<-purchasesurvey[-c(1,10)]
regcust<-purchasesurvey[-c(1,9)]
str(reguse)
str(regcust)
#coerce the categorical variables to factors so R knows for the regression
cols<-c("size.of.firm", "purchasing.structure", "industry", "buying.type")
reguse[cols]<-lapply(reguse[cols], factor)
regcust[cols]<-lapply(regcust[cols], factor)

reguse.mod<-lm(reguse$usage.level~.,data=reguse)
summary(reguse.mod)
stargazer(reguse.mod, title="Regression Output for PLE Usage Level", type="html")
bptest(reguse.mod) #data suffer from heteroskedasticity

par(mfrow=c(2,2)) # init 4 charts in 1 panel
plot(reguse.mod)## the residual plot looks good, not much shift off the expected line

regcust.mod<-lm(regcust$satisfaction.level~.,data=regcust)
summary(regcust.mod)
stargazer(regcust.mod, title="Regression Output for PLE Customer Satisfaction", type="html")
bptest(regcust.mod) #larger result than former
par(mfrow=c(2,2))
plot(regcust.mod)
#scale-location shows that the residuals remain roughly standard for increasing x values
#QQ norm is still okay, the residuals vs fitted is less okay, but within acceptable bounds
#assumptions not violated, good to go

vif(reguse.mod) #overall service, price level, delivery speed, and purchasing structure all exhibit notable levels of multicollinearity.
vif(regcust.mod) #the same ones exhibit multicollinearity
stargazer(vif(reguse.mod), type="html", title="VIFs for Usage Level Regression")
stargazer(vif(regcust.mod), type="html", title="VIFs for Customer Satisfaction Regression")

#this makes a graph with all the scatterplots on the bottom and the significances above

panel.cor<- function(x, y, digits = 2, cex.cor, ...)
{
  usr<- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  # correlation coefficient
  r<- cor(x, y, use="complete.obs")
  txt<- format(c(r, 0.123456789), digits = digits)[1]
  txt<- paste("r= ", txt, sep = "")
  text(0.5, 0.6, txt)

  # p-value calculation
  p<- cor.test(x, y)$p.value
  txt2<- format(c(p, 0.123456789), digits = digits)[1]
  txt2<- paste("p= ", txt2, sep = "")
  if(p<0.01) txt2 <- paste("p= ", "<0.01", sep = "")
  text(0.5, 0.4, txt2)
} 
pairs(regcust, upper.panel = panel.cor)
pairs(reguse, upper.panel = panel.cor)

anova(reguse.mod)
anova(regcust.mod)

cor(regcust[1:7],use="complete.obs")
pairs(regcust[1:7])


#Below are the forecasting methods and results

###time series###
tractorts<-ts(tractorsales[-1], start=c(2010,1), end=c(2014,12), frequency=12)
#frequency = 4 for quarterly data, initial data object
plot(tractorts, main="Tractor Sales")
#use start(data) and end(data) to get start/end date
#use tractorts.subset<-window(tractorts, start=date, end=date) to subset the data
colnames(tractorts)
nastl<-stl(tractorts[, 'na.'], s.window=12)
sastl<-stl(tractorts[, 'sa'], s.window=12)
eurstl<-stl(tractorts[, 'eur'], s.window=12)
pacstl<-stl(tractorts[, 'pac'], s.window=12)
chistl<-stl(tractorts[, 'china'], s.window=12)
worldstl<-stl(tractorts[, 'world'], s.window=12)

plot(nastl, main="NA")
plot(sastl,main="SA")
plot(eurstl,main="EUR")
plot(pacstl,main="PAC")
plot(chistl,main="China")
plot(worldstl,main="World")

naets<-ets(tractorts[, 'na.'], model="ZZZ")
saets<-ets(tractorts[, 'sa'], model="MAM")
eurets<-ets(tractorts[, 'eur'], model="MAM")
pacets<-ets(tractorts[, 'pac'], model="ZZZ")
chiets<-ets(tractorts[, 'china'], model="ZZZ")
worldets<-ets(tractorts[, 'world'], model="ZZZ")

accuracy(naets)
accuracy(saets)
accuracy(eurets)
accuracy(pacets)
accuracy(chiets)
accuracy(worldets) #mean absolute error gives the error in number of units, the Mean Average Percentage Error gives how much percent you're off on average

#when checking residuals, if the mean is non zero and is m, add m to all forecasts.
naets$mae
naets
forecast(naets, 5)
plot(forecast(tractorts[,'na.'],model=naets, 60),ylab="Tractor Sales",xlab="Year")
mtext("North America")
checkresiduals(naets)
plot(forecast(saets, 60),ylab="Tractor Sales",xlab="Year")
mtext("South America")
checkresiduals(saets)
plot(forecast(eurets, 60),ylab="Tractor Sales",xlab="Year")
mtext("Europe")
checkresiduals(eurets)
plot(forecast(pacets, 60),ylab="Tractor Sales",xlab="Year")
mtext("Pacific")
checkresiduals(pacets)
plot(forecast(chiets, 60),ylab="Tractor Sales",xlab="Year")
mtext("China")
checkresiduals(chiets)
plot(forecast(worldets, 60),ylab="Tractor Sales",xlab="Year")
mtext("World")
checkresiduals(worldets)


#logistic to determine if data are missing at random or missing not at random
missinglogtest<- as.data.frame(abs(is.na(purchasesurvey$product.quality)))
missinglogtest<-cbind(missinglogtest, purchasesurvey)
str(missinglogtest)
missinglogtest<-na.aggregate(missinglogtest) #zoo package
missinglogtest$buying.type<-round(missinglogtest$buying.type)
missinglogtest[cols]<-lapply(missinglogtest[cols], factor)
sum(is.na(missinglogtest))
colnames(missinglogtest)[1]<-"checkmiss"
sum(missinglogtest$checkmiss==1)
#loop version of the same 
#for(i in 1:ncol(data)){
#  data[is.na(data[,i]), i] <- mean(data[,i], na.rm = TRUE)
#}
missingmodel<- glm(checkmiss ~.,family=binomial(link='logit'),data=missinglogtest[-9])
stargazer(missingmodel, type="text")
par(mfrow=c(2,2))
plot(missingmodel)
summary(missingmodel)
1-pchisq(471.21-450.15, 599-585)#this is equivalent to the global f test for the overall significance; it is the p-value that you get
#it tests the null hypothesis that the model is no better than a model only fit with the intercept term






