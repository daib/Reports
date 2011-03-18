#!/usr/bin/perl

use strict;

my $trace = "trace";
my $map = "map.txt";
my $taskGraph = "task_graph.txt";
my $action = "send";
my $R = "plot.R";
my $graph = "graphs";

#mao from thread to ip
my %threadIP = ();

#my $src = 1;
#my $dst = 2;

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
    if(/^(\d+)\s+(\d+)/)
    {
        my $src = $threadIP{$1};
        my $dst = $threadIP{$2};
        print "$1\[$src\] $2\[$dst\]\n";

        seek(TRACE, 0, 0);

        my $flow = "s$1_$2";
        
        open FLOW,">$flow" or die $!;

        while(<TRACE>)
        {
            if(/Time\s+(\d+)\s+node\s+$src\s+$action\s+(\d+)\s+to\s+$dst/)
            {
                print FLOW "$1 $2\n";
            }
        }
       
        print R "$flow = diff(read.table(\"$flow\")[,1])\n"; 
        print R "plot($flow, type=\"l\")\n";

        close FLOW;

        $flow = "s$2_$1";
        
        open FLOW,">$flow" or die $!;

        seek(TRACE, 0, 0);

        while(<TRACE>)
        {
            if(/Time\s+(\d+)\s+node\s+$dst\s+$action\s+(\d+)\s+to\s+$src/)
            {
                print FLOW "$1 $2\n";
            }
        }
        
        print R "$flow = diff(read.table(\"$flow\")[,1])\n"; 
        print R "plot($flow, type=\"l\")\n";

        close FLOW;
    }
}

close TASKGRAPH;

close R;

close TRACE;

system "ps2pdf $graph.ps $graph.pdf; open $graph.pdf";
