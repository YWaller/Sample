

#read in the data
validateset<-read.csv("newtest.csv")

#clean the data
validateset[validateset == "NULL"] = NA
colnames(validateset)<-tolower(colnames(validateset))
validateset$load_dt<-as.Date(validateset$load_dt)
validateset$portfolioid<-as.factor(validateset$portfolioid)
validateset$producttypeid<-as.factor(validateset$producttypeid)
validateset$originalcompanyid<-as.factor(validateset$originalcompanyid)
validateset$originallastpaymentdate<-as.Date(validateset$originallastpaymentdate)
validateset$origlpdbin[is.na(validateset$originallastpaymentdate)]<-1
validateset$origlpdbin[is.na(validateset$origlpdbin)]<-0
validateset$exp_score<-as.integer(validateset$exp_score)
validateset$sol<-as.integer(validateset$sol)
validateset$portfolioid<-NULL
validateset$payer<-as.factor(validateset$payer)
validateset$originalcompanyid<-NULL
validateset$originallastpaymentdate[is.na(validateset$originallastpaymentdate)]<-"1999-01-01"
goodstatelist<-c('AL','AK','AS','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MH','MA','MI','FM','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')
validateset<-validateset[validateset$state %in% goodstatelist,] #just use ! on the validateset$state to invert something like this
validateset<-droplevels(validateset)
validateset$originalcompanyid<-NULL #too many categories for randomforest

validatesetcut<-subset(validateset, validateset$load_dt > as.Date("2013-06-30"))
validatesetcut<-subset(validatesetcut, validatesetcut$load_dt < as.Date("2018-08-01"))
val2<-validatesetcut
valpayer<-val2$payer

require(mlr)

val2<-rbind(full[1, ], val2)
val2<-val2[-1,]

temppayer<-val2$payer
val2$payer<-NULL

#feature creation
valspca<-createDummyFeatures(val2$state)
vspca<-predict(pcastate,valspca)

vbkpca2<-createDummyFeatures(val2[,c("bk7","bk11","bk13")])
vbkpca<-predict(bkpcait,vbkpca2)

vphtypca<-createDummyFeatures(val2$phone_type)
vphtypca2<-predict(pcaphone,vphtypca)

vprodtypepca<-createDummyFeatures(val2$producttypeid)
vprodtypepca2<-predict(prodtypepca, vprodtypepca)

val2$payer<-temppayer

keepvars<-c("ï..accountid","payer","instat","exp_score","co_amt","sum_cred_revolving_12mons","total_drogs","origlpdbin","debt_settlement","sum_bal_revolving_12mons","tot_accts_collection","phin_bk","paid_amt_prior_co","tot_accts_120_180_past_due_24mo")

val3<-val2[,keepvars]
val4<-cbind(val3,vspca[,c(1:4)],vbkpca[,c(1:2)],vphtypca2[,c(1:3)],vprodtypepca2[,c(1:3)])

#hardcoded since the datascrub is always the same
colnames(val4)[15]<-"statepca1"
colnames(val4)[16]<-"statepca2"
colnames(val4)[17]<-"statepca3"
colnames(val4)[18]<-"statepca4"
colnames(val4)[19]<-"bkpca1"
colnames(val4)[20]<-"bkpca2"
colnames(val4)[21]<-"phonepca1"
colnames(val4)[22]<-"phonepca2"
colnames(val4)[23]<-"phonepca3"
colnames(val4)[24]<-"produpca1"
colnames(val4)[25]<-"produpca2"
colnames(val4)[26]<-"produpca3"

val4$exp_score[is.na(val4$exp_score)]<-mean(val4$exp_score,na.rm=TRUE)

payer44<-as.data.frame(val4$payer)
colnames(payer44)<-"payer"
val4$payer<-NULL

names(payer44)<-"payer"

val5<-val4

#predict with the initial models
logpredict<-predict(logisticmodel, val5)

require(gbm)
gbmpred<-predict(gbmmodel2,newdata=val5,n.trees=100,type='link')

require(randomForest)
resultsrf<-predict(rfos,val5,cutoff=c(.55,.45))

require(FNN)
knntest<-scale(val5)
knnfinal<-knn(knntrain,knntest,synthpayer,k=5)

combineMod<-cbind(logpredict,resultsrf,gbmpred,knnfinal)
combineMod<-as.data.frame(combineMod)

range01<-function(x){(x-min(x))/(max(x)-min(x))}

isEmpty <- function(x) {
  return(identical(x, numeric(0)))
}


#create the optimization function that meets the criteria established
optcutoffs<-function(qq){
  combineMod$chance<-(as.numeric(combineMod$logpredict)*qq[1]+as.numeric(combineMod$resultsrf)*qq[2]+as.numeric(combineMod$gbmpred)*qq[3]+as.numeric(combineMod$knnfinal)*qq[4])
  combineMod$chance[combineMod$chance > mean(combineMod$chance)+sd(combineMod$chance)*5] = mean(combineMod$chance)
  combineMod$chance<-range01(combineMod$chance)
  bracketing<-as.data.frame(cbind(combineMod$chance,valpayer))
  names(bracketing)[2]<-'V2'
  b1s<-order(bracketing[,1], decreasing=TRUE)[1:(NROW(bracketing[,1])/4)]
  b2s<-order(bracketing[,1], decreasing=TRUE)[(((NROW(bracketing[,1])/4)+1):((NROW(bracketing[,1])/4)*2))]
  b3s<-order(bracketing[,1], decreasing=TRUE)[(((NROW(bracketing[,1])/4)*2+1):((NROW(bracketing[,1])/4)*3))]
  b4s<-order(bracketing[,1], decreasing=TRUE)[(((NROW(bracketing[,1])/4)*3+1):((NROW(bracketing[,1])/4)*4))]
  br1<-bracketing[b1s,]
  br2<-bracketing[b2s,]
  br3<-bracketing[b3s,]
  br4<-bracketing[b4s,]
  sinkingleaf<-NROW(br1[br1$V2 == 2,])/(NROW(br1[br1$V2 == 2,])+(NROW(br1[br1$V2 == 1,])))
  darkcoldcinder<-NROW(br2[br2$V2 == 2,])/(NROW(br2[br2$V2 == 2,])+(NROW(br2[br2$V2 == 1,])))
  defiantmountain<-NROW(br3[br3$V2 == 2,])/(NROW(br3[br3$V2 == 2,])+(NROW(br3[br3$V2 == 1,])))
  gladeplaza<-NROW(br4[br4$V2 == 2,])/(NROW(br4[br4$V2 == 2,])+(NROW(br4[br4$V2 == 1,])))

  rr<--NROW(br1[br1$V2 == 2,])/nrow(bracketing[bracketing$V2 == 2,])
  return(rr)
}

#run the genetic algorithm that determines the best weights to give each model's predictions
require(GenSA)
hellolocal2<-GenSA(fn=optcutoffs,lower=c(-2,-2,-2,-2),upper=c(2,2,2,2),control=list(maxit=100,temperature=4000))

#now with those, use them
qq<-hellolocal2$par
combineMod$chance<-(as.numeric(combineMod$logpredict)*qq[1]+as.numeric(combineMod$resultsrf)*qq[2]+as.numeric(combineMod$gbmpred)*qq[3]+as.numeric(combineMod$knnfinal)*qq[4])
combineMod$chance[combineMod$chance > mean(combineMod$chance)+sd(combineMod$chance)*5] = mean(combineMod$chance)
combineMod$chance<-range01(combineMod$chance)
bracketing<-as.data.frame(cbind(combineMod$chance,valpayer,val5$ï..accountid))

bobo<-((-sinkingleaf*3)+((-darkcoldcinder))+((defiantmountain))+((gladeplaza*1.2)))# #print(qq)

sinkingleaf
darkcoldcinder
defiantmountain
gladeplaza
plot(combineMod$chance, col=c("darkolivegreen3","brown2")[valpayer], pch=c(2,9)[valpayer])
plot(combineMod$chance, col=c("darkolivegreen3","brown2")[valpayer], pch=c(2,9)[valpayer])

#in case validation data
#NROW(br1[br1$V2 == 2,])/nrow(bracketing[bracketing$V2 == 2,])

bbb<-val5$ï..accountid
ccc<-combineMod$chance
ooo<-valpayer

#output results
output<-cbind(bbb,ccc,ooo)
write.csv(output,"output3.csv")




















