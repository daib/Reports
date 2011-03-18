OBJS=eigenVV.o main.o loadmat.o gs.o
CC=gcc
CXX=g++
INC=
VPATH=

OPTS= -g
LIBS= 

CLIBS =	-llapack -lblas 
CFLAGS = $(INC) -O3 -Wall

evv: $(OBJS)
	$(CXX)  $^ $(LIBS) $(OPTS) -o $@ $(CLIBS)

%.o:%.cpp 
	@$(CXX) -c $(CFLAGS) $(OPTS) $< -o $@ 

%.o:%.c 
	@$(CC) -c $(CFLAGS) $(OPTS) $< -o $@ 

.PHONY: clean
clean: 
	rm $(OBJS) evv 
