require(graphics)

simple_kde <- function(u) {
	if( u <= 1 && u > -1) {
		return(0.5)
	} else {
		return(0)
	}
}

f_hat <- function(x, data, h, kernel_func)	{
	x_sample = as.matrix(data[1])
	n = nrow(data) 
	sum = 0 
	for(i in 1:n)	{
		sum = sum + kernel_func((x-x_sample[i])/h)	
	}
	estimate = sum/(n * h)
	return(estimate)
}


filename <- "cdrate.tab"

data <- read.table(filename, header = TRUE)
h = 10 
hist(xi, prob=TRUE, h)

estimates = 0 
for(i in 1:n)	{
	estimates[i] = f_hat(as.matrix(data[1])[i], data, 0.14, simple_kde)
}

lines(estimates)
