#!/usr/bin/python

import os
import re
import math
import commands

nX = 3
nY = 3

north = 1 
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
        currentNode = int(m.group(1))
        routingTable[currentNode] = [] 

    m = tablePat.search(line)
    if m != None:
        #print m.group(1)
        m = burstPat.search(m.group(1))
        while m != None:
            #print m.group(1)
            routingTable[currentNode].append(int(m.group(1))) 
            m = burstPat.search(m.group(2))

ROUTING.close()

#function returns list of links in a flow connecting src and dst
def flowLinks(src, dst):
    links = []
    currentPos = src 
    while currentPos != dst:
        currentX = math.floor(currentPos/nY)
        currentY = currentPos % nY

        dstX = math.floor(dst / nY)
        dstY = dst % nY

        if routingTable.get(currentPos) == None:
            #default XY routing
            if currentX > dstX:
                currentX -= 1
            elif currentX <dstX:
                currentX += 1
            elif currentY > dstY:
                currentY -= 1
            elif currentY < dstY:
                currentY += 1
        else:
            #routing table
            dir = routingTable[currentPos][dst]
            if dir == north:
                currentY += 1
            elif dir == south:
                currentY -= 1
            elif dir == east:
                currentX += 1
            elif dir == west:
                currentX -= 1
            else:
                print 'Invalid value for direction'
                print dir
        
        nextPos = currentX * nY + currentY
        links.append(str(int(currentPos)) + r'_' + str(int(nextPos)))

        currentPos = nextPos

    return links

trace = 'trace'
map = 'map.txt'
taskGraph = 'task_graph.txt'
action = 'sends'
r = 'plot.R'
graph = 'graphs'


#map from links to the set of flows going through the link
linkFlows = {} 


#map from thread to IP
threadIP = {} 
flowBufferSpace = {}

MAP = open(map, 'r')

mappingPat = re.compile(r'(\d+)\s+(\d+)')
for line in MAP:
    m = mappingPat.search(line)
    if m != None:
        threadIP[m.group(1)] = int(m.group(2))
    
MAP.close

R = open(r, 'w')

R.write(r'postscript("' + graph + '.ps")\npar(mfrow=c(2,1))\n')

TRACE = open(trace, 'r')

TASKGRAPH = open(taskGraph, 'r')

taskGraphPat = re.compile(r'(\d+)\s+(\d+)\s+(\d+)')

for line in TASKGRAPH:
    m = taskGraphPat.match(line)
    if m != None:

        fst = m.group(1)
        snd = m.group(2)

        src = threadIP[fst]
        dst = threadIP[snd]

        bufSize = int(m.group(3)) * 4
        currentSent = 0

        print fst + r'[' + str(src) + r'] ' + snd + r'[' + str(dst) + ']'

        flow = 's' + fst + '_' + snd

        FLOW = open(flow, 'w')

        timingPat = re.compile(r'Time\s+(\d+)\s+node\s+' + str(src) + r'\s+' + action + r'\s+(\d+)\s+to\s+' + str(dst))

        TRACE.seek(0)

        for line in TRACE:
            m = timingPat.search(line) 
            if m != None: 
                currentSent += (int(m.group(2)) - 1)
                if currentSent >= bufSize:
                    FLOW.write(m.group(1) + '\n')
                    currentSent = 0

        R.write(flow + r' = diff(read.table("' + flow+ '\")[,1])\n')
        R.write(r'plot(' + flow + ', type=\"l\")\n')


        #compute links on a path
        for l in flowLinks(src, dst):
            if linkFlows.get(l) == None:
                linkFlows[l] = [] 
            linkFlows[l].append(flow)

        FLOW.close()

        flow = 's' + snd + '_' + fst

        FLOW = open(flow, 'w')

        timingPat = re.compile(r'Time\s+(\d+)\s+node\s+' + str(dst) + r'\s+' + action + r'\s+(\d+)\s+to\s+' + str(src))

        TRACE.seek(0)

        for line in TRACE:
            m = timingPat.search(line) 
            if m != None: 
                FLOW.write(m.group(1) + '\n')

        R.write(flow + r' = diff(read.table("' + flow + '\")[,1])\n')
        R.write(r'plot(' + flow + ', type=\"l\")\n')


        #compute links on a path
        for l in flowLinks(dst, src):
            if linkFlows.get(l) == None:
                linkFlows[l] = [] 
            linkFlows[l].append(flow)

        FLOW.close()


TASKGRAPH.close()

TRACE.close()

# generate traffic for each link
for key in linkFlows:
    cmd = 'cat '
    for i in linkFlows[key]:
        cmd += i + r' ' 
    cmd += '| sort -n > l' + key
    print cmd
    commands.getstatusoutput(cmd)

    R.write('l' + key + '= diff(read.table("l' + key + '")[,1])\n')
    R.write('plot(l' + key + ',type="l")\n')

R.close()

commands.getstatusoutput('r -f ' + r + '; ps2pdf ' + graph + '.ps ' + graph + '.pdf; open ' + graph + '.pdf')
