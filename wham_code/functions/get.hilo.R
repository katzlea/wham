get.hilo<-function(x) {
  med<-median(x[x!=0])
  hilo<-rep(0,length(x))
  hilo[x>med] <- "high"
  hilo[x<=med] <- "low"
  hilo[x==0] <- 0
  return(hilo)
}