rm(list=ls())

#This is a simple file that demonstrates linear, and subsequently multi, regression
#I am also familiar with regression splines and various other functional regressions like cubic, quadratic, etc.


require(MASS)    #Contains the Boston data frame
require(ISLR)    
### Investigate the Boston data frame
?Boston
str(Boston)
## Use the lm() function to produce a linear model called lm.fit that regresses median
## house value (medv) on percentage of households with low socioeconomic status (lstat)
lm.fit<-lm(medv~lstat,data=Boston)
##Investigate the structure of lm.fit
str(lm.fit)
## Extract  the coefficients
coef(lm.fit)
## Display a summary of the regression model
summary(lm.fit)
names(lm.fit)
head(lm.fit$model)         ### Retrieves input data via col names
lm.fit$coefficients
head(lm.fit$residuals)
###Extractor functions
coef(lm.fit)
confint(lm.fit)   ## For CIs for parameters - default is 95%
confint(lm.fit,level=.99)
predict(lm.fit,data.frame(lstat=(c(5,10,15))), interval="confidence")    ### For CIs of points, create a dataframe with a column of three points; confidence interval of doing it a million times, the epsilon will be reduced as much as you can this way
predict(lm.fit,data.frame(lstat=(c(5,10,15))), interval="prediction")    ### For PIs of points, You get the real point but also epsilon so these are two different intervals
#notice the fit for the line is the same for both
plot(Boston$lstat,Boston$medv)
abline(lm.fit,lwd=3,col="red")
plot(Boston$lstat,Boston$medv,col="red",pch=20)
plot(Boston$lstat,Boston$medv,col="red",pch="+")
plot(1:20,1:20,pch=1:20) #this is just showing off some of the possible little marks for graph points
par(mfrow=c(2,2))                        ### Divide graphics window into 2x2
plot(lm.fit)                             ### Plot 4 standard diagnostic plots – see Section 3.3.3; it shows you outliers; the q-q deal shows you that there's non linearity, if the points are on the line, a linear model is doing well; leverage points, identifies unusual x's whereas residuals identifies unusual y's, on row 375 is having an unusually large influence on the line, for example, those are high leverage points, above 5 or 10 is bad leverage; these plots apply to multiple regression the same as simple linear like we're doing
plot(predict(lm.fit), residuals(lm.fit)) ### Suggests non-linearity
plot(predict(lm.fit), rstudent(lm.fit))  ### Ditto – scale is in num t-StdDevs
plot(hatvalues(lm.fit))                  ### Plots leverage of points
which.max(hatvalues(lm.fit))             ### Find highest-leverage point
par(mfrow=c(1,1))                        ### Reset graphics window, good hygiene

##Assessing the accuracy of the coefficient estimates
### Compute the least squares of the estimators for a linear regression model that regresses median house value (medv) on percentage of households with low socioeconomic status (lstat).
lm.fit<-lm(medv~lstat,data=Boston)    #For comparison
summary(lm.fit)
beta1hat<-sum((Boston$lstat-mean(Boston$lstat))*(Boston$medv-mean(Boston$medv)))/sum((Boston$lstat-mean(Boston$lstat))^2)  #Slide 6
beta1hat
beta0hat<-mean(Boston$medv)-beta1hat*mean(Boston$lstat)
beta0hat
n<-nrow(Boston)
##Calculate the RSS
RSS<-sum((lm.fit$residuals)^2)
RSSalt<-sum((Boston$medv-(beta0hat+beta1hat*Boston$lstat))^2)   ###Same thing another way
RSS
RSSalt
##Calculate the RSE (Residual Standard Error)
RSE<-sqrt(RSS/(n-2))
RSE
##Calculating the standard error of the intercept
se0<-sqrt(RSE^2*(1/n+mean(Boston$lstat)^2/sum((Boston$lstat-mean(Boston$lstat))^2)))
se0
##Calculating the standard error of the slope
se1<-sqrt(RSE^2/sum((Boston$lstat-mean(Boston$lstat))^2))
se1
##Construct a 95% confidence interval for the slope parameter
confint(lm.fit,level=.95) #remember t value is just point divided by its standard error
myconfint<-c(beta1hat-qt(.975,n-2)*se1,beta1hat+qt(.975,n-2)*se1) #remember that .95 means each side of the distribution gets 2.5 of that 5%. Qt(.975 asks for the point such that 97.5% of the data is on the other side of it
myconfint #the p value is telling you the likelihood that your null is true with the sample's apparent distribution, how close those likely distributions are
##Conduct a hypothesis test of H0:beta1=0 H1:beta1<>0
tstat<-beta1hat/se1
tstat
pvalue<-2*pt(tstat,n-2)
pvalue
##Reject H0 since pvalue is VERY small
##Calculate TSS and r-squared
TSS<-sum((Boston$medv-mean(Boston$medv))^2)
TSS
rsquared<-1-RSS/TSS
rsquared
cor(Boston$lstat,Boston$medv)^2   #For simple regression, R-squared is the square of the correlation coefficient between x and y

lm.fit=lm(medv~lstat+age,data=Boston)  # Basic syntax is lm(y~a+b+c)
summary(lm.fit)
lm.fit=lm(medv~.,data=Boston)          # the "." is shorthand for "everything"
summary(lm.fit)
#install.packages("car")
require(car)                           # get access to vif() function
vif(lm.fit)                            # displays variance inflation factors. VIF > 5 to 10 implies multicollinearity
lm.fit1=lm(medv~.-age,data=Boston)     # Excludes age
summary(lm.fit1)                                             
lm.fit1=update(lm.fit, ~.-age)         # achieves same result
#Extension of regression
# Interaction Terms
summary(lm(medv~lstat*age,data=Boston))
# Non-linear Transformations of the Predictors
lm.fit2=lm(medv~lstat+I(lstat^2),data=Boston)
summary(lm.fit2)
lm.fit=lm(medv~lstat,data=Boston)
anova(lm.fit,lm.fit2)
par(mfrow=c(2,2))
plot(lm.fit2)
lm.fit5=lm(medv~poly(lstat,5),data=Boston)
summary(lm.fit5)
summary(lm(medv~log(rm),data=Boston))
# Qualitative Predictors
names(Carseats)
head(Carseats)
lm.fit=lm(Sales~.+Income:Advertising+Price:Age,data=Carseats)
summary(lm.fit)
contrasts(Carseats$ShelveLoc)
