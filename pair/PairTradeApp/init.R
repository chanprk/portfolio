# This is an old version of initialization step before splitted into lib + precompute
  
require(xts)
require(Quandl)
USDGBP = Quandl("BOE/XUDLGBD", api_key="")
USDGBP.ts = xts(USDGBP$Value,order.by = USDGBP$Date)
GSK.all = Quandl("LSE/GSK", api_key="")
GSK.price.ts = xts(GSK.all$Price,order.by = GSK.all$Date)

TSAlign = merge.xts(USDGBP.ts, GSK.price.ts)
names(TSAlign) <- c("USDGBP","GSK")

estReport <- function(model) {
  test <- cbind(round(model@teststat,2), model@cval)
  colnames(test)[1] <- 'test'
  test <- capture.output(print(test))
  eigen <- c('beta=',capture.output(print(model@V)))
  paste(paste(test,collapse = '\n'),paste(eigen,collapse = '\n'), sep="\n\n")
}


fill <- function(x){
  if (is.na(x[5])) {
    nonmissing <- tail(which(!is.na(x)),1)
    ifelse(length(nonmissing),x[nonmissing],NA)
  }
  else {
    x[5]
  }
}

TSAlign[,1] <- rollapply(TSAlign[,1],5,fill)
TSAlign[,2] <- rollapply(TSAlign[,2],5,fill)

require(urca)


#### 2016 analysis  ----

par(mfrow=c(1,1))

TSAlign.2016 = (TSAlign['2016/',])
m.2016  = ca.jo(log(TSAlign.2016))
summary(m.2016) # promising
residual.2016 <- as.xts(t(m.2016@V[,1]%*%t(log(TSAlign['2016/']))))
glob_mean.2016 <- mean(residual.2016)
glob_sd.2016 <- sd(residual.2016)

#### Feb Event  ----

TSAlign.pre.feb = (TSAlign['2015-02-25/2016-02-24',])
m.feb = ca.jo(log(TSAlign.pre.feb))
residual.pre.feb <- as.xts(t(m.feb@V[,1]%*%t(log(TSAlign.pre.feb))))
glob_mean.feb <- mean(residual.pre.feb)
glob_sd.feb <- sd(residual.pre.feb)
residual.post.feb <- as.xts(t(m.feb@V[,1]%*%t(log(TSAlign['2016-01-24/2016-04-24',]))))


#### June Event  ----

TSAlign.pre.june = (TSAlign['2015-06-28/2016-06-27',])
m.june = ca.jo(log(TSAlign.pre.june))
residual.pre.june <- as.xts(t(m.june@V[,1]%*%t(log(TSAlign.pre.june))))
glob_mean.june <- mean(residual.pre.june)
glob_sd.june <- sd(residual.pre.june)
residual.post.june <- as.xts(t(m.june@V[,1]%*%t(log(TSAlign['2016-05-27/2016-08-27',]))))
