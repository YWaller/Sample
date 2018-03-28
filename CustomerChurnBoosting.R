#This file shows a few tree-based methods for customer churn detection and type 1/type 2 error preference.

# Install packages
installIfAbsentAndLoad <- function(neededVector) {
  for(thispackage in neededVector) {
    if( ! require(thispackage, character.only = T) )
    { install.packages(thispackage)}
    require(thispackage, character.only = T)
  }
}

needed <- c("rpart",'tree',"randomForest","ada","e1071","gbm","xgboost","rattle")
installIfAbsentAndLoad(needed)

#load the data
churndata<-read.table("churndata.csv",sep=",",header=T)
data <- na.omit(churndata)
data$area<-factor(data$area)
nobs <- nrow(data)
set.seed(595)

#Define cost function
at_risk<-0.26448
no_risk<-1-at_risk
leave<-0.55
stay<-0.45
#f_cost<-function(x){x[1]*no_risk*1600+x[2]*at_risk*11500+x[3]*at_risk*(leave*13100+stay*1600)}
#(TP*at_risk*.55*13100)+(TP*at_risk*.45*1600)+(FN*at_risk*11500)+(FP*not_at_risk*1600)
f_cost<-function(x){(x[3]*at_risk*leave*13100)+(x[3]*at_risk*stay*1600)+(x[2]*at_risk*11500)+(x[1]*no_risk*1600)}
#error_rate<-c(FP,FN,TP,TN,OE)
#Divide into training and test data
set.seed(13185)
train<-sample(1:nrow(churndata), .7*nrow(churndata))
test<-churndata[-train,]

#Decision Tree
dt <- rpart(Churn ~ .,data=churndata[train,], method="class",
                 parms=list(split="information"),control=rpart.control(usesurrogate=0,maxsurrogate=0,cp=0,minbucket=1,minsplit=3))

xerr<-dt$cptable[,"xerror"] 
minxerr<-which.min(xerr)
mincp<-dt$cptable[minxerr,"CP"]
dt.prune<-prune(dt,cp=mincp)
plot(dt.prune)
text(dt.prune,pretty=0)
#fancyRpartPlot(dt.prune, main="Decision Tree With Minimum C.V. Error")
#asRules(dt.prune)

dt.prune.prob <- predict(dt.prune, newdata=test, type="prob")

cutoffs<-seq(0,0.99,0.01)
error_matrix<-matrix(0,nrow=length(cutoffs),ncol = 6,dimnames = list(NULL,c("FP","FN","TP","TN","OE","Exp.cost")))
for (i in 1:length(cutoffs)){
  dt.prune.pred <- rep("No", length(train))
  dt.prune.pred[dt.prune.prob[,2] > cutoffs[i]] <- "Yes"
  gbmmodel.pred[is.na(gbmmodel.pred)] <- "No"
  #mytable<-table(test$Churn, dt.prune.pred,dnn=c("Actual", "Predicted"))/length(dt.prune.pred)
  OE<-sum(dt.prune.pred!=test$Churn)/NROW(test$Churn)
  TN<-sum(dt.prune.pred=="No"&test$Churn=="No")/sum(test$Churn=="No")
  TP<-sum(dt.prune.pred=="Yes"&test$Churn=="Yes")/sum(test$Churn=="Yes")
  FN<-sum(dt.prune.pred=="No"&test$Churn=="Yes")/sum(test$Churn=="Yes")
  FP<-sum(dt.prune.pred=="Yes"&test$Churn=="No")/sum(test$Churn=="No")
  error_rate<-c(FP,FN,TP,TN,OE)
  exp_cost<-f_cost(error_rate)
  error_matrix[i,]<-c(FP,FN,TP,TN,OE,exp_cost)
}
mymatrix<-cbind(cutoffs,error_matrix)

mymatrix[which.min(mymatrix[,7]),]

#Random Forest
set.seed(5082)
rf <- randomForest(formula=Churn ~ .,data=churndata[train,],ntree=500, mtry=4,
                   importance=TRUE,localImp=TRUE,na.action=na.roughfix,replace=FALSE)
min.err <- min(rf$err.rate[,"OOB"])
min.err.idx <- which(rf$err.rate[,"OOB"]== min.err)
set.seed(13185)
rf <- randomForest(formula=Churn~.,data=churndata[train,],ntree= min.err.idx[1], mtry=4,
                   importance=TRUE,localImp=TRUE,na.action=na.roughfix,replace=FALSE)

cutoffs<-seq(0,0.99,0.01)
error_matrix<-matrix(0,nrow=length(cutoffs),ncol = 6,dimnames = list(NULL,c("FP","FN","TP","TN","OE","Exp.cost")))
for (i in 1:length(cutoffs)){
  rf.prob <- predict(rf, newdata=test, type="prob") 
  rf.prob[rf.prob[,1] >= cutoffs[i]] <- "No"
  rf.prob[rf.prob[,1] != "No"] <- "Yes"
  rf.pred = rf.prob[,1]
  OE<-sum(rf.pred!=test$Churn)/NROW(test$Churn)
  TN<-sum(rf.pred=="No"&test$Churn=="No")/sum(test$Churn=="No")
  TP<-sum(rf.pred=="Yes"&test$Churn=="Yes")/sum(test$Churn=="Yes")
  FN<-sum(rf.pred=="No"&test$Churn=="Yes")/sum(test$Churn=="Yes")
  FP<-sum(rf.pred=="Yes"&test$Churn=="No")/sum(test$Churn=="No")
  error_rate<-c(FP,FN,TP,TN,OE)
  exp_cost<-f_cost(error_rate)
  error_matrix[i,]<-c(FP,FN,TP,TN,OE,exp_cost)
  
}
mymatrix<-cbind(cutoffs,error_matrix)

mymatrix[which.min(mymatrix[,7]),]

#Boosting-ada
set.seed(13185)
bm<- ada(formula=Churn ~ .,data=churndata[train,],iter=50,bag.frac=0.5,
         control=rpart.control(maxdepth=30,cp=0.01,minsplit=20,xval=10))
bm.prob <- predict(rf, newdata=test, type="prob")

# Tune model
# set.seed(13185)
# bm.tune<-tune(ada,churn~.,data=churndata[train,],ranges = list(iter=c(50,100,200,500),nu=c(0.01,0.1,1,2)),bag.frac=0.5,control=rpart.control(maxdepth=30,cp=0.01,minsplit=20,xval=10))
# bestmodel=bm.tune$best.model

cutoffs<-seq(0,0.99,0.01)
error_matrix<-matrix(0,nrow=length(cutoffs),ncol = 6,dimnames = list(NULL,c("FP","FN","TP","TN","OE","Exp.cost")))
for (i in 1:length(cutoffs)){
  bm.pred <- rep("No", length(train))
  bm.pred[bm.prob[,2] > cutoffs[i]] <- "Yes"
  #mytable<-table(test$Churn, bm.pred,dnn=c("Actual", "Predicted"))/length(bm.pred)
  OE<-mean(bm.pred!=test$Churn)
  TN<-mean(bm.pred=="No"&test$Churn=="No")
  TP<-mean(bm.pred=="Yes"&test$Churn=="Yes")
  FN<-mean(bm.pred=="No"&test$Churn=="Yes")
  FP<-mean(bm.pred=="Yes"&test$Churn=="No")
  error_rate<-c(FP,FN,TP,TN,OE)
  exp_cost<-f_cost(error_rate)
  error_matrix[i,]<-c(FP,FN,TP,TN,OE,exp_cost)
}
mymatrix<-cbind(cutoffs,error_matrix)

mymatrix[which.min(mymatrix[,7]),]

#Boosting-gbm
set.seed(13185)
gbm.data<-churndata

gbm.data$Churn=as.character(gbm.data$Churn)
for (i in 1:nrow(gbm.data)){
  if (gbm.data$Churn[i]=="Yes"){
    gbm.data$Churn[i]=1
  } else {
    gbm.data$Churn[i]=0
  }
}
gbm.data$Churn=as.numeric(gbm.data$Churn)
gbmtest<-gbm.data[-train,]


# gbm bernoulli
gbmmodel<-gbm(Churn~.,distribution = 'bernoulli',data=gbm.data[train,],n.trees=50,shrinkage=0.3,bag.fraction = 0.5)

gbmmodel.prob <- predict(gbmmodel, newdata=test, type="response",n.trees=50)

cutoffs<-seq(0,0.99,0.01)
error_matrix<-matrix(0,nrow=length(cutoffs),ncol = 6,dimnames = list(NULL,c("FP","FN","TP","TN","OE","Exp.cost")))
for (i in 1:length(cutoffs)){
  gbmmodel.pred <- rep(0, length(test))
  gbmmodel.pred[gbmmodel.prob >= cutoffs[i]] <- 1
  gbmmodel.pred[is.na(gbmmodel.pred)] <- 0
  OE<-sum(gbmmodel.pred!=gbmtest$Churn)/NROW(gbmtest$Churn)
  TN<-sum(gbmmodel.pred==0&gbmtest$Churn==0)/sum(gbmtest$Churn==0)
  TP<-sum(gbmmodel.pred==1&gbmtest$Churn==1)/sum(gbmtest$Churn==1)
  FN<-sum(gbmmodel.pred==0&gbmtest$Churn==1)/sum(gbmtest$Churn==1)
  FP<-sum(gbmmodel.pred==1&gbmtest$Churn==0)/sum(gbmtest$Churn==0)
  error_rate<-c(FP,FN,TP,TN,OE)
  exp_cost<-f_cost(error_rate)
  error_matrix[i,]<-c(FP,FN,TP,TN,OE,exp_cost)
}
mymatrix<-cbind(cutoffs,error_matrix)

mymatrix[which.min(mymatrix[,7]),]

