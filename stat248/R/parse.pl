#!/usr/bin/perl

use strict;

my $trace = "trace";
my $map = "map.txt";
my $taskGraph = "task_graph.txt";

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

open TRACE, $trace or die $!;

open TASKGRAPH, $taskGraph or die $!;

while(<TASKGRAPH>)
{
    if(/^(\d+)\s+(\d+)/)
    {
        my $src = $threadIP{$1};
        my $dst = $threadIP{$2};
        print "$1 $src $2 $dst\n";

        seek(TRACE, 0, 0);

        my $flow = "s$1-$2";
        
        open FLOW,">$flow" or die $!;

        while(<TRACE>)
        {
            if(/Time (\d+) node $src sends (\d+) to $dst/)
            {
                print FLOW "$1 $2\n";
            }
        }
        
        close FLOW;
    }
}

close TASKGRAPH;
close TRACE;

