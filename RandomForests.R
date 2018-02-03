rm(list=ls())

#install.packages("randomForest")

#This file demonstrates the construction of a random forest, based on decision trees; this method is a type of bootstrap aggregation, or bagging.

require(randomForest)
weather<-read.table("myweatherdata.csv",sep=",",header=T)
dim(weather)
###Discard unwanted columns
names(weather)
discardcols <- names(weather) %in% c("Date", "Location","RISK_MM")
weather<- weather[!discardcols]
names(weather)
###Build 70% training vector of indices and 30% test data frame named weather.test
set.seed(42)
train<-sample(1:nrow(weather), 0.7*nrow(weather))
weather.test<-weather[-train,]
###Grow a Random Forest of 500 trees and observe its performance
set.seed(42)
rf <- randomForest(RainTomorrow ~ .,data=weather[train,],ntree=500,mtry=4,
	importance=TRUE, na.action=na.roughfix,replace=FALSE)
rf
###Specify values for class size representation in stratified random sample of 70 observations
set.seed(42) #the normal mtry is 4
rf <- randomForest(RainTomorrow ~ .,data=weather[train,], ntree=500,mtry=4, 
 	importance=TRUE, na.action=na.roughfix, replace=FALSE, sampsize=c(35,35))
rf
###List the importance of the variables. Good for showing people what you did since it demonstrates the msot important variables and such, perhaps use a graph
#third column, MDA, is most important since it shows actual importance
rn <- round(importance(rf), 2)
rn[order(rn[,3], decreasing=TRUE),]
###Display a chart of Variable Importance
varImpPlot(rf, main="Variable Importance in the Random Forest")
###Plot the error rate against the number of trees.
plot(rf, main="Error Rates Random Forest")
legend("topright", c("OOB", "No", "Yes"), text.col=1:6, lty=1:3, col=1:3)
###Calculate the area under the ROC curve and confidence interval for this value
which.min #try it yo to determine how many trees were actually useful
#install.packages("pROC")

require(pROC)
roc(rf$y, as.numeric(rf$predicted))
ci.auc(rf$y, as.numeric(rf$predicted))
###Plot the OOB ROC curve.

#install.packages("verification")

require(verification)
aucc <- roc.area(as.integer(as.factor(weather[train,"RainTomorrow"]))-1,rf$votes[,2])$A
roc.plot(as.integer(as.factor(weather[train,"RainTomorrow"]))-1,rf$votes[,2], 
	main="OOB ROC Curve for the Random Forest")
###Change vote cutoff to reduce Type II Error Rate (at the expense of the Type I Error Rate)
set.seed(42)
rf <- randomForest(RainTomorrow ~ .,data=weather[train,], ntree=500,mtry=4, 
 	importance=TRUE, na.action=na.roughfix, replace=FALSE, sampsize=c(35,35),cutoff=c(0.6,0.4))
rf #the cutoffs are for the votes from the trees, so only 40% now saying it'll be a yes are necessary to call it a yes
###Evaluate by scoring the test set
pred.test <- predict(rf, newdata=weather.test)
mytable<-table(weather.test$RainTomorrow, pred.test,dnn=c("Actual", "Predicted"))
round(100* mytable/sum(mytable))

