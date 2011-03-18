OBJS=autocovariance.o loadmat.o fourier.o timing.o
CC=gcc
CXX=g++
INC=
VPATH=

OPTS= -g
LIBS= -lrt

CLIBS =	
CFLAGS = $(INC) -O3 -Wall

autocovariance: $(OBJS)
	$(CXX)  $^ $(LIBS) $(OPTS) -o $@ $(CLIBS)

%.o:%.cpp 
	@$(CXX) -c $(CFLAGS) $(OPTS) $< -o $@ 

%.o:%.c 
	@$(CC) -c $(CFLAGS) $(OPTS) $< -o $@ 

.PHONY: clean
clean: 
	rm $(OBJS) autocovariance 
