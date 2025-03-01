rm(list=ls()) # clears workspace
#
#
# Nicholas Golina
#
#

install.packages("strucchange")
library(strucchange)
install.packages("tseries")
library(tseries)
#
#
# Assignment 7 July 9th, July 10th 
#
#

shift<-function(x,shift_by){
  stopifnot(is.numeric(shift_by))
  stopifnot(is.numeric(x))
  if (length(shift_by)>1)
  return(sapply(shift_by,shift, x=x))
  out<-NULL
  
  abs_shift_by=abs(shift_by)
  if (shift_by > 0 )
    out<-c(tail(x,-abs_shift_by),rep(NA,abs_shift_by))
  else if (shift_by < 0 )
    out<-c(rep(NA,abs_shift_by), head(x,-abs_shift_by))
    else 
      out<- x 
  out
  }

#
#
#The data appears to be stationary at different cutoff points, but not as a whole. 

ps7 <- read.csv("~/Google Drive/UA/Senior Year/Economic Forecasting/Data/ps7.csv")
View(ps7)

x <- ts(ps7$x)

x_Structural_Break <- x[799:805]

ts.plot(x, main="Plot of x", col = "red", ylab="x", xlab="Time")

#
#
#The acf shows a gradual decline with high autocorrelation, which means it is not stationary. 

acf(x)

#
#
#The structural break appears to occur at either 802, 801, and 800 based off of the plot. 
#The dummy tests show that the the p value for the dummy variables are all statistically significant 
#at the 1% level. The x.int term is lowest at 800 and highest at 802, but they were not statistically 
#significant.This means that we may not reject the null hypothesis that the lagged x variable and x variable
#change there relationship with each other after a structural break. The lowest p value for the dummy variable
#was at 801, which means that the structural break for this test was most likely at 801 and we may reject the null
#hypothesis that there is not a structural break. 

ts.plot(x_Structural_Break, main= "Plot of x Towards the Structural Break",col="blue", ylab="x", xlab="Time")

dummy_pre <- 1:1000
x.lag1 <- shift(x,-1)
x.lag2 <- shift(x,-2)
dummy <- ifelse(dummy_pre < 802, 0, 1)
x.int802 <- x.lag1*dummy
reg1 <- lm(x ~ -1 + x.lag1 + dummy, data=ps7)
reg1.int <- lm(x ~ -1 + x.lag1 + dummy + x.int802, data=ps7)
summary(reg1)
summary(reg1.int)

dummy2 <- ifelse(dummy_pre < 801, 0, 1)
x.int801 <- x.lag1*dummy2
reg2 <- lm(x ~ -1 + x.lag1 + dummy, data=ps7)
reg2.int <- lm(x ~ -1 + x.lag1 + dummy2 + x.int801, data=ps7)
summary(reg2)
summary(reg2.int)

dummy3 <- ifelse(dummy_pre < 800, 0, 1)
x.int800 <- x.lag1*dummy3
reg3 <- lm(x ~ -1 + x.lag1 + dummy3, data=ps7)
reg3.int <- lm(x ~ -1 + x.lag1 + dummy3 + x.int800, data=ps7)
summary(reg3)
summary(reg3.int)

#
#
#For the Chow Tests, the critical value for the f procedure is 3.85079320 at alpha=.05. There was a higher calculated f value from the
#Chow Test for a structural break at 802,  which means that there is stronger evidence that there is a structural break at 802. 
#This means that we may reject the null hypothesis that there is not
#a structural break at observation 802.


allsum <- lm(x ~ -1 + x.lag1, data=ps7)
allsumsquare_residuals <- sum((allsum$residuals)^2)

presum <- lm(x[1:799] ~ -1 + x.lag1[1:799], data=ps7)
presumsquare_residuals <- sum((presum$residuals)^2)
  
postsum <- lm(x[800:1000] ~ -1 + x.lag1[800:1000], data=ps7)
postsumsquare_residuals <- sum((postsum$residuals)^2)

Chow800 <- ((allsumsquare_residuals - presumsquare_residuals - postsumsquare_residuals)/1)/((presumsquare_residuals + postsumsquare_residuals)/(1000-2))
print(Chow800)

presum1 <- lm(x[1:800] ~ -1 + x.lag1[1:800], data=ps7)
presumsquare_residuals1 <- sum((presum1$residuals)^2)

postsum1 <- lm(x[801:1000] ~ -1 + x.lag1[801:1000], data=ps7)
postsumsquare_residuals1 <- sum((postsum1$residuals)^2)

Chow801 <- ((allsumsquare_residuals - presumsquare_residuals1 - postsumsquare_residuals1)/1)/((presumsquare_residuals1 + postsumsquare_residuals1)/(1000-2))
print(Chow801)

presum2 <- lm(x[1:801] ~ -1 + x.lag1[1:801], data=ps7)
presumsquare_residuals2 <- sum((presum2$residuals)^2)

postsum2 <- lm(x[802:1000] ~ -1 + x.lag1[802:1000], data=ps7)
postsumsquare_residuals2 <- sum((postsum2$residuals)^2)

Chow802 <- ((allsumsquare_residuals - presumsquare_residuals2 - postsumsquare_residuals2)/1)/((presumsquare_residuals2 + postsumsquare_residuals2)/(1000-2))
print(Chow802)

#
#
#For the full model the t value for the ar1 parameter is 26.97778, which means that it is statistically
#significant at the 1% level. The ar2 parameter is not statistically significant at the 1% level because the t value is 2.234177
#which is lower than 2.576 using a two tailed test. It is statistically significant at the 5% level though.


ARIMA_Full <- arima(x, order = c(2,0,0), include.mean=FALSE, 
      seasonal = list(order = c(0,0,0)))
summary(ARIMA_Full)

ar1 <- (0.8498/0.0315)
print(ar1)

ar2 <- (0.0706/0.0316)
print(ar2)

#
#
#For the pre structural break, the ar1 parameter estimate is statistically siginificant as well at the 1%
#level with a t value of 19.35127. The ar 2 parameter is not statitically significant at all with a t value 
#at -1.484419. This is different from the full model parameter estimate for ar2. 

ARIMA_Pre <- arima(x[1:801], order = c(2,0,0), include.mean=FALSE, 
                    seasonal = list(order = c(0,0,0)))
summary(ARIMA_Pre)

ar1_pre <- (0.6831/0.0353)
print(ar1_pre)

ar2_pre <- (-0.0524/0.0353)
print(ar2_pre)

#
#
#The ar1 parameter was also statistically significant at the 1% level with a t value of 13.25601.
#The ar2 parameter estimate was statistically insignificant at the 10% with a t value at 0.6140845.
#This is a departure from the full model estimate. 

ARIMA_Post <- arima(x[802:1000], order = c(2,0,0), include.mean=FALSE, 
                   seasonal = list(order = c(0,0,0)))
summary(ARIMA_Post)

ar1_Post <- (0.9372/0.0707)
print(ar1_Post)

ar2_Post <- (0.0436/0.0710)
print(ar2_Post)

#
#
#The plot does not identify a structural break anywhere in the data series. This shows that the CUSUM 
#test is not always successful at identifying structural breaks. 
  
plot(efp(x ~ lag(x, k=-1) + lag(x, k=-2), type="Rec-CUSUM"))

#
#
#The autocorrelation at lags quickly decays and then osscilallates at different levels for both pre and post
#This means that they are both stationary. This means that structural breaks are important to identify 
#so that you can accurately forcast your data with the right model. 

x1 <- x[1:801]

x2 <- x[802:1000]

acf(x1)

acf(x2)
  
  
  
