read.s45 = read.table("s45")

plot(read.s45[,1], type="l", main = "Packet sending time", xlab="Packet #", ylab="Cycle packets sent")

dev.print(device=postscript, "packettime.eps", onefile=FALSE, horizontal=FALSE)

s45 = diff(read.s45[,1])

s45 = s45[65:648]

#plot(s45, type="l", main = "Packet timing interval trace", xlab="Packet #", ylab="Interval between two successive packets (# cycles)")
plot(s45, type="l", main = "Packet timing interval trace", xlab="Packet #", ylab="Interval between packets (# cycles)")

dev.print(device=postscript, "s45.eps", onefile=FALSE, horizontal=FALSE)

par(mfrow=c(3,1))

acf(s45, main="Autocorrelation of packet interval")

#dev.print(device=postscript, "acfs45.eps", onefile=FALSE, horizontal=FALSE)

spectrum(s45, main="Raw spectrum of original series")

#dev.print(device=postscript, "spectrums45.eps", onefile=FALSE, horizontal=FALSE)


ms45 <- matrix(s45,ncol=8, byrow=TRUE)

means45 = apply(ms45,2,mean)

plot(means45, type="l", ylab="Invertal (# cycles)", main="Seasonal components");

dev.print(device=postscript, "s45All.eps", onefile=FALSE, horizontal=FALSE)

s45.res = s45 - means45 #residuals after remove seasonal component

par(mfrow=c(3,1))

plot(s45.res, type="l", ylab="Residuals after removing seasonal", main="Residuals after removing seasonal")

abline(h=0);

spectrum(s45.res, main="Raw spectrum of seasonal removed series")

acf(s45.res, lag.max=100, main="Autocorrelation of the residuals")

dev.print(device=postscript, "s45res.eps", onefile=FALSE, horizontal=FALSE)

#take only the peaks
ps45 = ms45[,8]

#SARIMA
fss45 <- arima(ps45[1:56], order=c(1,0,1), seasonal=list(order=c(1,1,1), period = 8))
ps45.pred = predict(fss45, n.ahead = 16)
ps45.res = ps45[57:72]-ps45.pred$pred

par(mfrow=c(3,1))
plot(ps45.pred$pred, type="l", ylab="Predicted interval (#cycles)", xlab="Packet index", main="Predicted values")
plot(ps45.res, type="l", ylab="Predicted interval residuals", xlab="Packet index", main="Predicted residuals")
acf(ps45.res, main="Autocorrelation of residuals")

dev.print(device=postscript, "predictions45.eps", onefile=FALSE, horizontal=FALSE)

k = kernel("daniell", 7) ##meaning m=4, i.e. L=2m+1=9
ps45.spec = spec.pgram(ps45.res, k, taper=0, detrend=FALSE, demean=TRUE, log="no", plot=FALSE)

df = ps45.spec$df
U = qchisq(0.025, df)
L = qchisq(0.975, df)

ps45.l = df*ps45.spec$spec/L
ps45.u = df*ps45.spec$spec/U 

ps45.spec.mean = mean(ps45.spec$spec)
l = ps45.spec.mean * df /L
u = ps45.spec.mean * df /U

ps45.spec.raw = spectrum(ps45.res, plot=FALSE)

#ylim = range(ps45.spec$spec, ps45.l, ps45.u, l, u, ps45.spec.raw$spec)
ylim = range(ps45.spec$spec, ps45.l, ps45.u, l, u)

#plot(ps45.spec.raw, type="l", ylim=ylim)
#lines(ps45.spec$freq, ps45.spec$spec,ylim=ylim, type="l")

plot(ps45.spec,ylim=ylim, type="l")
lines(ps45.spec$freq, ps45.l, lty='dashed')
lines(ps45.spec$freq, ps45.u, lty='dotdash' )

abline(h=u, col="red")
abline(h=l, col="green")
