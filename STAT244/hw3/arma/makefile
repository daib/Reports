OBJS=arma.o armalk.o as154.o brent.o linmin.o mnbrak.o powell.o \
	 nrutil.o loadmat.o amoeba.o
CC=gcc
CXX=g++
INC=
VPATH=

OPTS= -g -m32
LIBS=

CLIBS=
CFLAGS= $(INC) -O3 -fPIC
FFLAGS=-fPIC

arma: $(OBJS)
	$(CXX) $^ $(LIBS) $(OPTS) -o $@ $(CLIBS)

armalk.so: armalk.o as154.o
	cc -shared -o armalk.so armalk.o as154.o

.PHONY: clean
clean: 
	rm $(OBJS) arma armalk.so 

	
