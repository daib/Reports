OBJS=leader.o
CC=gcc
CXX=g++
INC=
VPATH=

OPTS= -g
LIBS= 

CLIBS =	
CFLAGS = $(INC) -O3 -Wall

leader: $(OBJS)
	$(CXX)  $^ $(LIBS) $(OPTS) -o $@ $(CLIBS)

%.o:%.cpp 
	@$(CXX) -c $(CFLAGS) $(OPTS) $< -o $@ 

%.o:%.c 
	@$(CC) -c $(CFLAGS) $(OPTS) $< -o $@ 

.PHONY: clean
clean: 
	rm $(OBJS) leader 
