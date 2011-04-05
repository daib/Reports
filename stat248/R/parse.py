#!/usr/bin/python

import os
import re

nX = 3
nY = 3

north = 3 
south = 2
east = 3
west = 4

currentNode = -1

routing = 'network_config'

nodeSig = '@NODE'
tableSig = 'routing_scheme table'

routingTable = {}

ROUTING = open(routing, 'r')

nodePat = re.compile(nodeSig + r'\s+(\d+)')
tablePat = re.compile(tableSig + r'\s+(.*)')
burstPat = re.compile(r'\s*(\d+)(.*)')

for line in ROUTING: 
    m = nodePat.search(line)
    if m != None:
        currentNode = m.group(1) 
        routingTable[currentNode] = [] 

    m = tablePat.search(line)
    if m != None:
        #print m.group(1)
        m = burstPat.search(m.group(1))
        while m != None:
            #print m.group(1)
            routingTable[currentNode].append(m.group(1)) 
            m = burstPat.search(m.group(2))

f.close()

