#!/usr/bin/perl

# Returns the lines in one file that aren't in the other.
#
# Copyright 2011 by Keith Vertanen
#

use strict;

if ( @ARGV < 2 )
{
    print "$0 <master file> <not in this file>\n"; 
    exit(1);
}

my $masterFile;
my $notFile;
my $line;
my %not;

($masterFile, $notFile) = @ARGV;

open(IN, $notFile);
while ($line = <IN>)
{
	$line =~ s/[\n\r]//g;
	$not{$line} = 1;
}
close(IN);

open(IN, $masterFile);
while ($line = <IN>)
{
	$line =~ s/[\n\r]//g;
	if (!$not{$line})
	{
		print $line . "\n";
	}
}
close(IN);



