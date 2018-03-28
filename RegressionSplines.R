rm(list=ls())
installIfAbsentAndLoad <- function(neededVector) {
  if(neededVector != "") {
    for(thispackage in neededVector) {
      if( ! require(thispackage, character.only = T) )
      { install.packages(thispackage)}
      require(thispackage, character.only = T)
    }    
  }
}
needed <- c("splines", "ISLR", "boot")
installIfAbsentAndLoad(needed)

# From 'splines' library, we use bs() to fit regression splines. 
# bs() will generate a entire matrix of basis functions for splines, default - cubic splines. 
# You need to specify the knots in the bs() function. 

# Boot is used to compute cross validation errors using the cv.glm() function.

################################################
###                Section 1                 ###
### Splines and Age Demographics in Colombia ###
################################################

demographics <- read.table("http://data.princeton.edu/eco572/datasets/cohhpop.dat",
                           col.names=c("age","pop"), header=FALSE)
#We will be using a dataset on demographics in Colombia. Examine the structure.
head(demographics)
sum(demographics$pop)
#This is a dataset of 55,750 Colombian individuals.
plot(demographics$age,demographics$pop,main="Age Demographics in Colombia",
     ylab="Number of Individuals", xlab="Age")

#How would a linear regression fit?

linear <- lm(pop ~ age, data=demographics)
lines(demographics$age,linear$fit,lwd=2)

#Not so well! What about a second degree polynomial?

plot(demographics$age,demographics$pop,main="Age Demographics in Colombia",
     ylab="Number of Individuals", xlab="Age")
seconddegree <- lm(pop ~ age + I(age^2), data=demographics)
lines(demographics$age,seconddegree$fit,lwd=2)

#Better, but probably not ideal. It doesn't really capture how the graph
#rises then falls at the beginning. We might start to worry about overfitting 
#as we increase the degree of the polynomial further. The data might be best 
#represented by a piecewise function. A common practice is putting knots at the 
#25th, 50th, and 75th percentiles. We will try that, and then compare to putting 
#just one knot at the 20th percentile, and then finally putting knots on the 
#20th, 40th, 60th, and 80th percentiles.

par(mfrow=c(1,3))

#25th, 50th, 75th percentile knots

model1 <- lm(pop ~ bs(age, knots=c(25, 50, 75)), data=demographics)

pred=predict(model1,newdata=list(demographics$age))
plot(demographics$age,demographics$pop, main="25th, 50th, 75th percentiles",
     xlab="",ylab="")
lines(demographics$age,model1$fit,lwd=2)

#20th percentile knot

model2 <- lm(pop ~ bs(age, knots=20), data=demographics)

pred=predict(model2,newdata=list(demographics$age))
plot(demographics$age,demographics$pop, main="20th percentile only",
     xlab="",ylab="")
lines(demographics$age,model2$fit,lwd=2)

#20th, 40th, 60th, 80th percentile knots

model3 <- lm(pop ~ bs(age, knots=c(20,40,60,80)), data=demographics)

pred=predict(model3,newdata=list(demographics$age))
plot(demographics$age,demographics$pop, main="20th, 40th, 60th, 80th percentiles",
     xlab="",ylab="")
lines(demographics$age,model3$fit,lwd=2)

par(mfrow=c(1,1))

#Which is the best fit? Let's compare the MSE of each model.

RSS1 <- 0
RSS2 <- 0
RSS3 <- 0
for(i in 1:length(demographics$pop)){
  RSS1 <- RSS1 + (model1$fitted.values[i]-demographics$pop[i])^2
}
for(i in 1:length(demographics$pop)){
  RSS2 <- RSS2 + (model2$fitted.values[i]-demographics$pop[i])^2
}
for(i in 1:length(demographics$pop)){
  RSS3 <- RSS3 + (model3$fitted.values[i]-demographics$pop[i])^2
}
(MSE1 <- RSS1 / length(demographics$pop))
(MSE2 <- RSS2 / length(demographics$pop))
(MSE3 <- RSS3 / length(demographics$pop))

#The first model, where we used knots on the 25th, 50th, and 75th percentiles, has 
#the lowest MSE. While it is common to place knots at certain intervals, try 
#experimenting and see what you can come up with. The second model, where there is
#just one knot at the 20th percentile, is not so shabby. Examine your  data and try
#to determine where trends change and a piecewise function might suit.

### CHALLENGE: Placing no more than 3 knots, try to get a lower MSE than model 1 (11010.14).
### Do this on line 112, inside knots=c( )

model4 <- lm(pop ~ bs(age, knots=c( )), data=demographics)
pred=predict(model4,newdata=list(demographics$age))
RSS4 <- 0
for(i in 1:length(demographics$pop)){
  RSS4 <- RSS4 + (model4$fitted.values[i]-demographics$pop[i])^2
}
(MSE4 <- RSS4 / length(demographics$pop))

##########################################
###              Section 2             ###
### Regression Splines / Lab from ISLR ###
##########################################

###########
### Prediction
###########
# Recall dof=K+d+1. Here we choose 3 knots, use the default cubic splines
# Our selection will result in dof=3+3+1=7. 
# These 7 dof will be used up by 1 intercept and 6 basis functions.
attach(Wage)
fit=lm(wage~bs(age,knots=c(25,40,60)),data=Wage) # fit wage to age, specifying 3 knots
# Here we are making the x-axis, age.grid, for the plot
agelims=range(age) 
age.grid=seq(from=agelims[1],to=agelims[2]) 
pred=predict(fit,newdata=list(age=age.grid),se=T) # predict wage base on age

length(age) # there are 3000 data points, which gives us 3000 dof
pred$df # Noting that there are 2993 dof left to measure variance. 

##########
### Plotting
##########
plot(age,wage,col="gray") # plot the age/wage data
lines(age.grid,pred$fit,lwd=2) # plot the line of predicted 

# Plot dashed line with +/- 2 standard error,
# which gives us 95% confidence interval 
# You will notice that the dashed lines are further away from our prediction line at both ends.
# It is because polynomial function tends to go wild at the boundaries (properity of polinomial).
lines(age.grid,pred$fit+2*pred$se,lty="dashed") 
lines(age.grid,pred$fit-2*pred$se,lty="dashed") 

#The bs function will show as incercept is False, the function will use 6 dof
dim(bs(age,knots=c(25,40,60)))
#dim(bs(age,knots=c(25,40,60),intercept=TRUE))
dim(bs(age,df=6))
attr(bs(age,df=6),"knots")

##########
### Natural Spline
##########
# As an upgrade of regression splines, natural splines add additional constrains.
# New constraints require the function to be linear at the boundaries (at both ends). 
fit2=lm(wage~ns(age,df=4),data=Wage)
pred2=predict(fit2,newdata=list(age=age.grid),se=T)
lines(age.grid, pred2$fit,col="red",lwd=2)
lines(age.grid,pred2$fit+2*pred2$se,lty="dashed", col="red") 
lines(age.grid,pred2$fit-2*pred2$se,lty="dashed", col="red")


########################################################
###                   Section 3                      ###
###  Regression Splines, CV df, and audio forensics  ###
########################################################

#Real life application: (forensics) time stamping audio files
#based on "mains hum": the background frequency between 50 and 60 Hz
#coming from all electrical appliances. Mains hum varies with the local power line
#frequency. "mains hum" can be recorded by utility generators. Then, when 
#detection agencies are given an audio file & told it is from a certain time, 
#they can verify that by comparing the background hz in the file to the utility's
#record of the mains hum during that time frame.

#Mains hum would look like a small sine wave variation on a larger sine wave.
#see the formula 15 lines down.

#We will use CV to see what the appropriate degrees of freedom
#are for modeling a given section of our signal with a regression spline.
#we will first do CV manually; and then use cv.glm from the boot library.

#first choose the size of our data set:
n = 1000

#our x values will range from 0 to 20
#randomly draw from that range with runif.
x = runif(n, 0, 20)

#create a small error term by pulling from 
#an rnorm distribution with a small standard deviation.
e = rnorm(n, 0, 0.02)

#create the y values from your x values.
y = 0.1*sin(10*x) + sin(x) + e

#make a data frame of your data.
dat = as.data.frame(cbind(x,y))

#plot y vs. x to get a sense of the data's shape.
plot(x,y)

#plot to see what the idealized fxn with no
#error term looks like.  (Would not be able
#to do this in practice.)
graphXs = seq(0,20,0.05)
graphYs = 0.1*sin(10*graphXs) + sin(graphXs)
plot(dat, col = "gray")
lines(graphXs, graphYs, lwd = 2, col = "blue")

#choose some potential degrees of freedom to iterate
#over for trying to fit the data.
possibleDFs = seq(5,155,10)

#make an MSE matrix to hold the test MSEs for all 10 folds
#for each df value.
MSEmatrix = matrix(nrow = length(possibleDFs), ncol = 10)

#set up a matrix to hold the average test MSE values
#for each df. (each value in the second column of this
#matrix will be an average of the 10-folds in the 
#MSEmatrix.)
avgMSEmatrix = matrix(nrow= length(possibleDFs), ncol = 2, 
                      dimnames = list(list(), list("df", "MSE")))

#initialize a count to use as an index within the for loop
#since the element iterated over is df, which does not start at
#1 or act like an index.
count = 1

#calculate the number of data points in each fold.
#(will allow us to index our test set for each fold.)
foldLen = n/10

#Loop through all the df's that you want to check and see
#which one best models the data.
for (i in possibleDFs) {
  
  #make indices to pull out the first fold.
  testIndxStart = 1
  testIndexEnd = foldLen
  #fold index will mark which of the k folds we
  #are on as we loop through them.
  foldIndx = 1
  
  for (j in seq(1,10,1)) {
    
    #index the test Set
    testSetIndices = seq(testIndxStart, testIndexEnd, 1)
    testSet = dat[testSetIndices,]
    #put the rest of the data into the training set
    trainSetIndices = sample(setdiff(1:n, testSetIndices))
    trainSet = dat[trainSetIndices,]
    trainXs = trainSet[,1]    
    trainYs = trainSet[,2]
    
    #fit with regression spline using the bs() function.
    #********this is the regression spline part :) ********
    fit = lm(trainYs~bs(trainXs, df=i, intercept = TRUE), data = trainSet) 
    
    #order the test data points based on the x values.
    #because if the predict() function is given
    #unordered data, then it tries to connect the 
    #points in the order given (makes a messy web of lines)
    testSet = testSet[order(testSet[,1]),]
    testXs = testSet[,1]
    testYs = testSet[,2]
    
    #use that spline to predict the y values of the test data.
    #Note: the newdata argument must be given a named list, the 
    #name of this list must match the name of the data you 
    #used to train the lm function!! (trainXs in this case)
    pred = predict(fit, newdata=list(trainXs = testXs), se = T) 
    
    #calculate the test MSE and put it in the matrix.
    testMSE = sum((testYs - pred$fit)^2) / foldLen
    MSEmatrix[count, foldIndx] = testMSE
    
    #now move forward to the next fold by updating 
    #the indices.
    testIndxStart = testIndxStart + foldLen
    testIndexEnd = testIndexEnd + foldLen
    foldIndx = foldIndx + 1
  }
  
  #calculate the average test MSE from all k folds.
  avgTestMSE = mean(MSEmatrix[count,])
  #put that test MSE into a matrix.
  avgMSEmatrix[count, ] = c(i, avgTestMSE)
  
  #plot the original points.
  plot(dat, col="gray")
  #create a line showing the predicted values.
  #for convenience, I'm only plotting the last fold.
  lines(testXs, pred$fit, lwd=2, col = "blue")
  #put standard error dashed lines at 2 SE's from the 
  #prediction.
  lines(testXs, pred$fit+2*pred$se, lty = "dashed")
  lines(testXs, pred$fit-2*pred$se, lty= "dashed")
  
  #increment the count index.
  count = count + 1
}

#print and plot the avg. test MSE matrix.
avgMSEmatrix
#the first df setting (df = 5) is omitted b/c it is
#very high & makes it hard to see the rest of the graph.
plot(avgMSEmatrix[-1,], type = 'b')

####################################
#using the cv.glm function to perform the cross validation
#glm DOES appear to work with the bs() function.
#This is where the "boot" library is used.
#(Note: the tune() function appears to Not recognize the bs()
#fxn, so it cannot be used to perform cross validation.)

#reset the avgMSEmatrix to a clean slate.
avgMSEmatrix = matrix(nrow= length(possibleDFs), ncol = 2, 
                      dimnames = list(list(), list("df", "MSE")))

#reset the count
count = 1

#loop through the possible DFs
for (i in possibleDFs) {
  
  #fit the data using the glm function.
  fit = glm(y~bs(x, df=i, intercept = TRUE), data = dat)
  
  #set the test MSE to cv.glm's output, with K = 10
  #for 10 fold cross validation.
  avgMSEmatrix[count, ] = c(i, cv.glm(dat, fit, K=10)$delta[1])
  
  count = count + 1
}

#again, the first df setting (df = 5) is omitted b/c
#it is very high & makes it hard to see the rest of the graph.
plot(avgMSEmatrix[-1,], type = 'b')
