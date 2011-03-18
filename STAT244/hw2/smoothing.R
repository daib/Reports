# smoothing.R
# Author: Dai Bui

require(tcltk) || stop("tcltk support is absent")
require(tkrplot) || stop("tkrplot support is absent")

#generate plot based on kernel type and the number of bin 
genPlot <- function(nBins, kernelType){
	xi <- as.matrix(data[dataCol])
	varName = colnames(data[dataCol])
	#check data type, only numeric data can be used
	if(!is.numeric(xi)) {
		tkmessageBox(message=paste("Invalid data type: selected column '", 
			varName, "' is not of a numeric type"))
	} else {
		range = max(xi) - min(xi)

		dxi = density(xi, kernel=kernelType, bw = range/nBins)
		hist(xi, prob = TRUE, breaks = nBins - 1, 
			main=paste("Histogram & Density of ", varName), 
        	xlab=varName )
		lines(dxi, type='l', col = "red")
	}
} 

doPlot <- function(...){
	n <- as.integer(tclvalue(nBins))
   	genPlot(n, tclvalue(rbVal))
}

mkRadioButtons <- function(var, parentFr){
	fr <- tkframe(parentFr)
	tkpack(tklabel(fr,width=15,text=var),side='left')
	tkpack(tkradiobutton(fr, variable=rbVal, value=var, 
		command=replot), side='left')
	tkpack(fr,side='top')
}

destroy <- function(...) {
	tkdestroy(base)
}

replot <- function(...) {
	tkrreplot(img)
}

openDataFile <- function(...) {
	chooseDataFile()
	replot() #redraw
}

#function displays a dialog to select a data file
chooseDataFile <- function() {
	fileName <- tclvalue(tkgetOpenFile())
	readData <- read.table(fileName, header = TRUE)

	#there are possibly several data columns, users need to select one
	selectDataColumn(readData)
	
	#save the read data 
	assign("data", readData, envir = .GlobalEnv)
}

#function display a dialog to select a data column
selectDataColumn <- function(readData){
	tt <- tktoplevel()
	numDataCols <- ncol(readData)
	rbValue <- tclVar(1)
	done <- tclVar(0)
	tkgrid(tklabel(tt,text="Select a data column from the table"))

	for(i in 1:numDataCols) {
		rb <- tkradiobutton(tt, variable=rbValue, value=i)
		tkgrid(tklabel(tt,text=colnames(readData[i])),rb)
	}

	OnOK <- function()
	{
		assign("dataCol", as.integer(tclvalue(rbValue)), envir = .GlobalEnv)
		tkdestroy(tt)
		tclvalue(done) <- 1
	}

	OK.but <- tkbutton(tt,text="OK",command=OnOK)
	tkgrid(OK.but)
	tkfocus(tt)
	tkwait.variable(done)	#make this thread waits for the selection thread
}

#begin of the program

#default parameters 
nBins <- tclVar(12)
dataCol <- 1; 
kernels <- c("gaussian", "rectangular", "triangular", "epanechnikov", 
	"biweight", "cosine", "optcosine")
rbVal <- tclVar(kernels[1])

# user needs to open a data file
chooseDataFile();

base <- tktoplevel()
tkwm.title(base,'Smooting techniques')
mainFrm <- tkframe(base)

img <- tkrplot(mainFrm,doPlot)

nBinsFrm <- tkframe(mainFrm)
tkpack(tklabel(nBinsFrm, text='Number of Bins', width=15),side='top')
tkpack(tkscale(nBinsFrm,command=replot,from=2,to=100,showvalue=TRUE,
               variable=nBins, resolution=1,orient='horiz'))

tkpack(img, side='left')

tkpack(nBinsFrm,side='top')

rbFrm <- tkframe(mainFrm)

tkpack(tklabel(rbFrm, text='Kernel Density Estimations', width=20),side='top')
sapply(kernels, mkRadioButtons, rbFrm)

tkpack(rbFrm,side='top',pady=c(0,10))

bFrm = tkframe(mainFrm)
tkpack(tkbutton(bFrm,text='Open data file',command=openDataFile),side='left')
tkpack(tkbutton(bFrm,text='Quit',command=destroy),side='left')


tkpack(bFrm,side='top',pady=c(0,10))

tkpack(mainFrm)

