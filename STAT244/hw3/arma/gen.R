#ARMA (2,2)
sq <- arima.sim(model=list(ar=c(.9,-.2),ma=c(-.7,.1)),n=1000)
write(sq, "armasq.dat", 1)
