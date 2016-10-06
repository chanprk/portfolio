load('precompute.RData')

estimationCalc <- function(start.est, end.est) {

  TSAlign.est = TSAlign[dateRange(start.est, end.est),]

  m = ca.jo(log(TSAlign.est))
  isOpposite <- apply(m@V,function(x){sign(x[2])==-1},MARGIN = 2)

  if(all(!isOpposite)) {
    rv <- c(1, -1)
  } else {
    if(all(isOpposite)) {
      isOpposite <- which.max(m@V[2,])
    } 
    rv <- m@V[,isOpposite]
  }
  
  res <- as.xts(t(rv%*%t(log(TSAlign.est))))
  
  list(
    model = m,
    relvec = rv,
    residual = res,
    glob_mean = mean(res),
    glob_sd = sd(res)
  )
}

require(lubridate)
require(xts)
require(urca)
require(ecp)

plot_dynamic_mean <- function(x, estimates, ylim=NULL){
  plot.xts(x, main="", auto.grid = FALSE, ylim=ylim)
  
  changePoints <- estimates[c(-1,-length(estimates))]
  
  breaks <- diff(c(0,changePoints,length(x)))
  trendGroup <- unlist(sapply(c(1:length(breaks)), function(i){
    rep(i,breaks[i])
  }))
  
  loc_means <- rep(tapply(x, trendGroup, mean), breaks)
  lines(xts(loc_means, order.by=index(x)),col='blue')
  #loc_sds <- rep(tapply(x - loc_means, trendGroup, sd), breaks)
  #lines(xts(loc_means+2*loc_sds, order.by=index(x)),col='red')
  demean_sd <- sd(x-loc_means)
  lines(xts(loc_means+2*demean_sd, order.by=index(x)),col='red')
  legend('bottomright',c('spread','mean','mean + 2*sd'),lty=1, col=c('black', 'blue', 'red'), bty='n')
  abline(v=index(x)[estimates],lty=4,col='gray')
  list(
    dynamic_mean=tail(loc_means,1),
    demean_sd=demean_sd
    )
}