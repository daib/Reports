OBJS=main.o btree1.o loadmat.o timing.o
CC=gcc
CXX=g++
INC=
VPATH=

OPTS= -g
LIBS= -lrt

CLIBS =	
CFLAGS = $(INC) -O3 -Wall

bintree: $(OBJS)
	$(CXX)  $^ $(LIBS) $(OPTS) -o $@ $(CLIBS)

%.o:%.cpp 
	@$(CXX) -c $(CFLAGS) $(OPTS) $< -o $@ 

%.o:%.c 
	@$(CC) -c $(CFLAGS) $(OPTS) $< -o $@ 

.PHONY: clean
clean: 
	rm $(OBJS) bintree 
