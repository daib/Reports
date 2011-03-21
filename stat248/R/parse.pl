#!/usr/bin/perl

use strict;

###### Routing section
my $nX = 3;
my $nY = 3;

my $north = 1;
my $south = 2;
my $east = 3;
my $west = 4;

my $currentNode = -1;

my $routing = "network_config";

my $nodeSig = "\@NODE";
my $tableSig = "routing_scheme table";

my %routingTable = ();


open ROUTING, $routing or die $!;

while(<ROUTING>)
{
    if(/$nodeSig\s+(\d+)/)
    {
        $currentNode = $1;         
        $routingTable{$currentNode} = [];
        #print "Current node $currentNode \n";
    } 


    if(/$tableSig\s+(.*)/)
    {
        while(/\s+(\d+)(.*)/)
        {
            #print "\t$1\n";
            push (@{$routingTable{$currentNode}}, $1);
            $_ = $2;
        } 
    }
}

close ROUTING;

sub flowLinks
{
    my $src = $_[0]; 
    my $dst = $_[1];
    my @links = qw();
    
    my $currentPos = $src;
    
    while($currentPos ne $dst)
    {
        my $nextPos = -1;
        #next pos
        if($routingTable{$currentPos} ne undef)
        {
            #default XY routing
            my $currentX = $currentPos / $nY;
            my $currentY = $currentPos % $nY;

            my $dstX = $dst / $nY
            my $dstY = $dst % $nY;

            if($currentX > $dstX)
            {
                $currentX--;     
            }
            else if($currentX < $dstX)
            {
                $currentX++;
            }
            else if($currentY > $dstY)
            {
                $currentY--;
            }
            else if($currentY < $dstY)
            {
                $currentY++;
            }
            
            $nextPos = $currentX * $nY + $currentY;
        }
        else
        {
            #table routing
            my $dir = $routingTable{$currentPos}[$dst];
            if($dir == $north)
            {
                $nextPos = $currentPos + 1;
            }
            if($dir == $south)
            {
                $nextPos = $currentPos - 1;
            }
            if($dir == $east)
            {
                $nextPos = $currentPos + $nY;
            }
            if($dir == $west)
            {
                $nextPos = $currentPos - $nY;
            }
        }
        
        push(@links, "$currentPos\_$nextPos");

        $currentPos = $nextPos;
    }

    return @links;
}

###### Parsing section

my $trace = "trace";
my $map = "map.txt";
my $taskGraph = "task_graph.txt";
my $action = "sends";
my $R = "plot.R";
my $graph = "graphs";


#map from links to set of flows going through the links
%linkFlows = ();

#map from thread to ip
my %threadIP = ();
my %flowBufSpace = ();

if ($#ARGV > 1)
{
    $trace = $ARGV[0];
}

open MAP, $map or die $!;

while(<MAP>)
{
    if(/(\d+)\s+(\d+)/)
    {
        $threadIP{$1} = $2;
        print "thread $1 IP $2\n";
    }
}

close MAP;

open R, ">$R" or die $!;

print R "postscript(\"$graph.ps\")\npar(mfrow=c(2,1))\n";


open TRACE, $trace or die $!;

open TASKGRAPH, $taskGraph or die $!;

while(<TASKGRAPH>)
{
    if(/^(\d+)\s+(\d+)\s+(\d+)/)
    {
        my $src = $threadIP{$1};
        my $dst = $threadIP{$2};
        my $bufSize = $3 * 4;
        my $currentSent = 0;

        print "$1\[$src\] $2\[$dst\]\n";

        seek(TRACE, 0, 0);

        my $flow = "s$1_$2";
        
        open FLOW,">$flow" or die $!;

        while(<TRACE>)
        {
            if(/Time\s+(\d+)\s+node\s+$src\s+$action\s+(\d+)\s+to\s+$dst/)
            {
                $currentSent += ($2 - 1); 
                if($currentSent >= $bufSize)
                {
                    #print FLOW "$1 $currentSent\n";
                    print FLOW "$1\n";
                    $currentSent = 0;
                }
            }
        }
       
        print R "$flow = diff(read.table(\"$flow\")[,1])\n"; 
        print R "plot($flow, type=\"l\")\n";

        #compute links on a path
        foreach my $link ( &flowLinks($src, $dst))
        {
            if($linkFlows{$link} eq undef)
            {
                $linkFlows{$link} = [];
            }
            
            push (@{$linkFlows{$link}}, $flow);
        }

        close FLOW;

        $flow = "s$2_$1";
        
        open FLOW,">$flow" or die $!;

        seek(TRACE, 0, 0);

        while(<TRACE>)
        {
            if(/Time\s+(\d+)\s+node\s+$dst\s+$action\s+(\d+)\s+to\s+$src/)
            {
                print FLOW "$1\n";
            }
        }
        
        print R "$flow = diff(read.table(\"$flow\")[,1])\n"; 
        print R "plot($flow, type=\"l\")\n";

        #compute links on a path
        foreach my $link ( &flowLinks($dst, $src))
        {
            if($linkFlows{$link} eq undef)
            {
                $linkFlows{$link} = [];
            }
            
            push (@{$linkFlows{$link}}, $flow);
        }

        close FLOW;
    }
}

close TASKGRAPH;

close R;

close TRACE;

system "r -f $R; ps2pdf $graph.ps $graph.pdf; open $graph.pdf";
