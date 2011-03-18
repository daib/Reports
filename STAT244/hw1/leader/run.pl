#!/usr/bin/perl

use strict;


my $thresholdStep = 20;
my $minThreshold = 140;
my $maxThreshold = $minThreshold + 1600;

my $threshold = $minThreshold;

my $file = "res";

while($maxThreshold > $threshold)
{

system("./leader $threshold f > $file");
if(! open parsedFile, $file)
{
	die "Can't open my $file to read: $! \n";
}


my $ssq = -1;
my $nClusters = -1;
while(<parsedFile>)
{
	if(/The total sum of sums of squares (\d+.?\d*)/)
	{
		$ssq = $1;
	}

	if(/There are (\d+) clusters/)
	{
		$nClusters = $1;
	}
}

#print "$threshold $nClusters $ssq\n";

close parsedFile;

system("./leader $threshold t > $file");
if(! open parsedFile, $file)
{
	die "Can't open my $file to read: $! \n";
}


my $ssq_k = -1;
while(<parsedFile>)
{
	if(/The total sum of sums of squares (\d+.?\d*)/)
	{
		$ssq_k = $1;
	}

}

print "$threshold\t$nClusters\t$ssq\t$ssq_k\n";

close parsedFile;


$threshold = $threshold + $thresholdStep;
}
