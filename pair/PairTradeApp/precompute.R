fn <- "precompute.RData"
if (file.exists(fn)) file.remove(fn)

require(lubridate)
require(xts)
require(Quandl)
require(urca)

estReport <- function(model) {
  test <- cbind(round(model@teststat,2), model@cval)
  colnames(test)[1] <- 'test'
  test <- capture.output(print(test))
  eigen <- c('beta=',capture.output(print(model@V)))
  paste(paste(test,collapse = '\n'),paste(eigen,collapse = '\n'), sep="\n\n")
}

dateRange <- function(d1,d2) {
  paste(d1,d2,sep="/")
}

list <- structure(NA,class="result")
"[<-.result" <- function(x,...,value) {
  args <- as.list(match.call())
  args <- args[-c(1:2,length(args))]
  length(value) <- length(args)
  for(i in seq(along=args)) {
    a <- args[[i]]
    if(!missing(a)) eval.parent(substitute(a <- v,list(a=a,v=value[[i]])))
  }
  x
}



positionCalc <- function(entry, exit , relvec) {
  TSAlign.position = TSAlign[dateRange(entry %m-% months(6),exit),]
  list(
    position = TSAlign.position,
    residual = as.xts(t(relvec%*%t(log(TSAlign.position))))
  )
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

USDGBP = Quandl("BOE/XUDLGBD", api_key="")
USDGBP.ts = xts(USDGBP$Value,order.by = USDGBP$Date)
GSK.all = Quandl("LSE/GSK", api_key="")
GSK.price.ts = xts(GSK.all$Price,order.by = GSK.all$Date)

TSAlign = merge.xts(USDGBP.ts, GSK.price.ts)
names(TSAlign) <- c("USDGBP","GSK")

TSAlign[,1] <- rollapply(TSAlign[,1],5,fill)
TSAlign[,2] <- rollapply(TSAlign[,2],5,fill)


#### Feb Event  ----

entry.feb <- ymd('2016-02-24')
start.est.feb <- entry.feb %m-% years(1) + days(1)
end.est.feb <- entry.feb
exit.feb <- entry.feb %m+% months(2)

list[model.feb, relvec.feb, residual.est.feb, glob_mean.feb, glob_sd.feb] <- estimationCalc( start.est.feb, end.est.feb)
list[TSAlign.position.feb, residual.position.feb] <- positionCalc(entry.feb, exit.feb, relvec.feb)

#### June Event  ----

entry.june <- ymd('2016-06-27')
start.est.june <- entry.june %m-% years(1) + days(1)
end.est.june <- entry.june
exit.june <- entry.june %m+% months(1)

list[model.june, relvec.june, residual.est.june, glob_mean.june, glob_sd.june] <- estimationCalc( start.est.june, end.est.june)
list[TSAlign.position.june, residual.position.june] <- positionCalc(entry.june, exit.june, relvec.june)

#### In-Sample Analysis  ----

start.est.IS <- ymd('2012-01-01')
end.est.IS <- ymd('2016-09-30')

list[model.IS, relvec.IS, residual.est.IS, glob_mean.IS, glob_sd.IS] <- estimationCalc( start.est.IS, end.est.IS)
list[TSAlign.position.IS.feb, residual.position.IS.feb] <- positionCalc(entry.feb, exit.feb, relvec.IS)
list[TSAlign.position.IS.june, residual.position.IS.june] <- positionCalc(entry.june, exit.june, relvec.IS)

save.image('precompute.RData')