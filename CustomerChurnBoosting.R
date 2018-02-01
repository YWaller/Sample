rm(list=ls())
require(rattle)
require(ada)
churndata<-read.table("churndata.csv",sep=",",header=T)
data <- na.omit(churndata)
data$area<-factor(data$area)
nobs <- nrow(data)
set.seed(595)
train <- sample(nobs, 0.7*nobs)
bm<- ada(formula=churn ~ .,data=data[train,],iter=50,bag.frac=0.5,control=rpart.control(maxdepth=30,
cp=0.01,minsplit=20,xval=10))
print(bm) 
# Evaluate by scoring the training set
prtrain <- predict(bm, newdata=data[train,])
table(data[train,"churn"], prtrain,dnn=c("Actual", "Predicted"))
round(100* table(data[train,"churn"], prtrain,dnn=c("% Actual", "% Predicted"))/length(prtrain))
# Evaluate by scoring the test set
test <- setdiff(1:nobs, train) 
prtest <- predict(bm, newdata=data[test,])
table(data[test,"churn"], prtest,dnn=c("Actual", "Predicted"))
round(100* table(data[test,"churn"], prtest,dnn=c("% Actual", "% Predicted"))/length(prtest))