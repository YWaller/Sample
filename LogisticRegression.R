rm(list=ls())

#This simply demonstrates the use of logistic regression, or classification, and a confusion matrix.

#Get the data into a data frame
data<-read.table("LogisticsRegressionExample1DataInR.txt",sep="\t",header=T,stringsAsFactors=F)
#Display breakdown of the purchase variable
table(data$purchase)
#Compute error rate if always predict No
nrow(data[data$purchase=="Yes",])/nrow(data)
#Convert the dependent variable to a nominal factor
data$purchase<-as.factor(data$purchase)
contrasts(data$purchase)  #Model will predict the class whose value is 1 - in this case, Yes
#Build the model
glm.fit<-glm(purchase~income+age+zip,data=data,family=binomial)
#Display the model results
summary(glm.fit)
#Chi-square Hypothesis test on H0:Model Has No Predictive Power 
pval<-1-pchisq(glm.fit$null.deviance-glm.fit$deviance,glm.fit$df.null-glm.fit$df.residual)
pval    #Reject null hypothesis - model has predictive power
#Compute the AIC (Akaike Information Criterion) - good way to compare two models built using same data
probs<-c()
yes.indices<-which(data$purchase=='Yes')
#Model's fittedvalues element is the vector of probabilities of a Yes for the training data
#Create a vector of probs of obtaining the training y-values - just the fitted values if y was Yes, otherwise 1-fittedvalues
probs[yes.indices]<-glm.fit$fitted.values[yes.indices]
probs[-yes.indices]<-1-glm.fit$fitted.values[-yes.indices]
#Sum of the ln's of the probs is the ln of the product of the probs, so the exp of this sum is the product of the probs, or the maximum likelihood
maxli<-exp(sum(log(probs)))
AIC<-2*length(glm.fit$coefficients)-2*log(maxli)
AIC
#Evaluate various measures of predictive accuracy

glm.pred<-rep('No', nrow(data))
glm.pred[predict(glm.fit,type='response')>.5]<-'Yes'
#Compute the proportion of correct and incorrect predictions
mean(glm.pred==data$purchase)
mean(glm.pred!=data$purchase)
#So we have cut the naive prediction error rate computed earlier (0.3888888) in half
#Create a Confusion Matrix (aka Contingency Table)
train.table<-table(data$purchase,glm.pred)
#Overall error rate again, this time from the table
(train.table["No","Yes"]+train.table["Yes","No"])/sum(train.table)
#Type I Error Rate
(train.table["No","Yes"]/sum(train.table["No",]))
#Type II Error Rate
(train.table["Yes","No"]/sum(train.table["Yes",]))
#Power
1-(train.table["Yes","No"]/sum(train.table["Yes",]))

