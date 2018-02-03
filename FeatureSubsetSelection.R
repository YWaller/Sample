install.packages("leaps")
install.packages("ISLR")
library(ISLR)
require(leaps)
data<-mtcars
data2<-na.omit(Hitters)

#This file demonstrates the use of various subset selection methods for choosing which features to use in regression.
#It can be very useful to implement when there are many, many features available.


####################best
##########mtcars
reg1<-regsubsets(mpg~.,
  data = data, nvmax = 10, method = "exhaustive")
plot(reg1, labels=reg1$xnames, main="BEST", scale=c("bic", "Cp", "adjr2", "r2"),
col=gray(seq(0, 0.9, length = 10)))

##########hitters
reg1<-regsubsets(Salary~.,
  data = data, nvmax = 19, method = "exhaustive")
plot(reg1, labels=reg1$xnames, main="BEST", scale=c("bic", "Cp", "adjr2", "r2"),
col=gray(seq(0, 0.9, length = 10)))

###################forward
##########mtcars
reg3<-regsubsets(mpg~.,
  data = data, nvmax= 10, method = "forward")
plot(reg3, labels=reg3$xnames, main="FORWARD", scale=c("bic", "Cp", "adjr2", "r2"),
col=gray(seq(0, 0.9, length = 10)))

##########hitters
reg3<-regsubsets(Salary~.,
  data = data, nvmax= 19, method = "forward")
plot(reg3, labels=reg3$xnames, main="FORWARD", scale=c("bic", "Cp", "adjr2", "r2"),
col=gray(seq(0, 0.9, length = 10)))

##################backward
#########mtcars
reg2<-regsubsets(mpg~.,
  data = data, nvmax = 10, method = "backward")
plot(reg2, labels=reg2$xnames, main="BACKWARD", scale=c("bic", "Cp", "adjr2", "r2"),
col=gray(seq(0, 0.9, length = 10)))

########hitters
reg2<-regsubsets(Salary~.,
  data = data, nvmax = 19, method = "backward")
plot(reg2, labels=reg2$xnames, main="BACKWARD", scale=c("bic", "Cp", "adjr2", "r2"),
col=gray(seq(0, 0.9, length = 10)))

#To compare multiple graphs, call dev.new() after each plot.

#################hybrid
#######hitters
reg4<-regsubsets(Salary~.,
  data = data, nvmax = 19, method= "seqrep")

plot(reg4, labels=reg4$xnames, main="HYBRID", scale=c("bic", "Cp", "adjr2", "r2"),
col=gray(seq(0, 0.9, length = 10)))







