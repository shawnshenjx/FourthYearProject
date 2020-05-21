#!/usr/bin/perl

# Given a list of the original parsed messages,
# create 1 or more output files for editing by
# the humans.
#
# Copyright 2011 by Keith Vertanen
#

use strict;

if ( @ARGV < 3 )
{
    print "$0 <list of files> <base name> <num humans>\n"; 
    exit(1);
}

my $listFile;
my $outBase;
my $line;
my $i;
my $j;
my $numHuman;
my $msgLine;
my @OUT;
my $count;
my $path;
my $from;
my $to;
my $subj;
my $num;

($listFile, $outBase, $numHuman) = @ARGV;

open(IN, $listFile);

for ($i = 0; $i < $numHuman; $i++)
{
	open($OUT[$i], ">" . $outBase . $i);
}

# Read in the next file containing a message
while ($line = <IN>)
{
	$line =~ s/[\n\r]//g;

	open(IN_MSG, $line);

	$path = <IN_MSG>;
	$from = <IN_MSG>;
	$to   = <IN_MSG>;
	$subj = <IN_MSG>;

	if (($path) && ($from) && ($to) && ($subj))
	{
		$num = $count % $numHuman;

		# Keep the header information intact
		print { $OUT[$num] } $path;
		print { $OUT[$num] } $from;
		print { $OUT[$num] } $to;
		print { $OUT[$num] } $subj;
		print { $OUT[$num] } "\n";

		# Now fix up the body text with a sentence on each line
		while ($msgLine = <IN_MSG>)
		{			
			$msgLine =~ s/[\n\r]//g;

			# Lines that are blank are dropped
			if ($msgLine)
			{
				# Split based on likely sentence boundaries

				$msgLine =~ s/([a-z\)\"][\.\?\!])[ ]{1,}([A-Z])/$1\n$2/g;

				print { $OUT[$num] } $msgLine . "\n";
			}
		}

		# Seperate the messages 
		print { $OUT[$num] } "======================\n";
	   
		$count++;
	}

	close(IN_MSG);
		
}
close(IN);

for ($i = 0; $i < $numHuman; $i++)
{
	close($OUT[$i]);
}
