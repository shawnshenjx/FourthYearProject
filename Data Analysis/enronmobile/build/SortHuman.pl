#!/usr/bin/perl

# Given a single file used for human manual
# correction, spit back out a version that
# is sorted by the from email address and
# subject.
#
# This is used so we can manually remove
# messages that are likely duplicates.
#
# Copyright 2011 by Keith Vertanen
#

use strict;

if ( @ARGV < 2 )
{
    print "$0 <human corrected file> <output name>\n"; 
    exit(1);
}

my $outFile;
my $listFile;
my $line;
my $i;
my $j;
my $count;
my $path;
my $from;
my $to;
my $subj;
my $num;
my $blank;
my $msg;
my $fromEmail;
my %all;
my $key;

($listFile, $outFile) = @ARGV;

open(IN, $listFile);

# Read in the next file containing all the messages
while ($line = <IN>)
{
	$path  = $line;
	$from  = <IN>;
	$to    = <IN>;
	$subj  = <IN>;
	$blank = <IN>;
	$msg   = "";

	$path =~ s/[\n\r]//g;
	$from =~ s/[\n\r]//g;
	$to   =~ s/[\n\r]//g;
	$subj =~ s/[\n\r]//g;

	# Do nothing if we don't have a complete set of stuff
	if (($path) && ($from) && ($to) && ($subj))
	{
		# Extract just the email address of the from person
		if ($from =~ /([A-Za-z0-9\-\.]+\@[A-Za-z0-9\-\.]+)/)
		{
			$fromEmail = lc($1);
#		print "EMAIL: $fromEmail \n";
		}
		else
		{
			# This happens for "</O=ENRON/OU=NA/CN=RECIPIENTS/CN=RZIVIC>"
			$fromEmail = $from;
			$fromEmail =~ s/From: //;
#		print "EMAIL:  $fromEmail\n";
		}

		# Extract the sent email a

#		print "SUBJ: $subj \n";
		
		# Read in all the message lines until we hit the seperator line
		while (($line = <IN>) && ($line !~ /=========/))
		{
			$line =~ s/[\n\r]//g;

			# Skip lines that start with # since we want to delete them			
			if (($line) && ($line !~ /^\#/))
			{

				if ($line !~ /[A-Z]/)
				{
					print "ERR?: $line \n";
				}

				$msg = $msg . $line . "\n";
			}
		}

		if ($msg)
		{			
			$key = $fromEmail . " " . $subj . " " . $msg;

			# There could be multiple things stored in this key
			$all{$key} .= $path . "\n" . $from . "\n" . $to . "\n" . $subj . "\n" . "\n" . $msg . "======================\n";


#			print $path . "\n";
#			print $from . "\n";
#			print $to . "\n";
#			print $subj . "\n";
#			print $msg;
		
		}

	}

}
close(IN);

open(OUT, ">" . $outFile);

foreach $key (sort keys %all)
{
	print OUT $all{$key};
}

close(OUT);
