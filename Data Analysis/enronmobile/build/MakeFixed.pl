#!/usr/bin/perl

# Given a single file used for human manual
# correction, spit back out a per message
# files.  Also computes various stats about
# the total set of messages.
#
# Optionally outputs all message sentences
# to a specified file (also all unique 
# sentences).
#
# Copyright 2011 by Keith Vertanen
#

use strict;

if ( @ARGV < 3 )
{
    print "$0 <human corrected fie> <base name> [output sentences] [output unique sentences]\n"; 
    exit(1);
}

my $listFile;
my $outBase;
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
my $uniqueFrom;
my %allFrom;
my $totalLines;
my $totalWords;
my @chunks;
my %allLines;
my $uniqueLines;
my $outSent;
my $outUnique;

($listFile, $outBase, $outSent, $outUnique) = @ARGV;

open(IN, $listFile);

if ($outSent)
{
	open(OUT_SENT, ">", $outSent);
}
if ($outUnique)
{
	open(OUT_UNIQUE, ">", $outUnique);
}

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
		}
		else
		{
			# This happens for "</O=ENRON/OU=NA/CN=RECIPIENTS/CN=RZIVIC>"
			$fromEmail = $from;
			$fromEmail =~ s/From: //;
		}
		
		# Track total unique from users
		if (!$allFrom{$fromEmail})
		{
			$uniqueFrom++;
		}
		$allFrom{$fromEmail}++;

		# Read in all the message lines until we hit the seperator line
		while (($line = <IN>) && ($line !~ /=========/))
		{
			$line =~ s/[\n\r]//g;

			# Skip lines that start with # since we want to delete them			
			if (($line) && ($line !~ /^\#/))
			{
				$msg = $msg . $line . "\n";
				$totalLines++;

				# Track number of words in the message lines
				@chunks = split(/\s+/, $line);
				$totalWords += @chunks;

				# Track the number of unique message lines
				if (!$allLines{$line})
				{
					$uniqueLines++;
					if ($outUnique)
					{
						print OUT_UNIQUE $line . "\n";
					}
				}

				$allLines{$line}++;

				if ($outSent)
				{
					print OUT_SENT $line . "\n";
				}
			}
		}

		if ($msg)
		{
			open(OUT, ">" . $outBase . $count);

			print OUT $path . "\n";
			print OUT $from . "\n";
			print OUT $to . "\n";
			print OUT $subj . "\n";
			print OUT $msg;
		
			close(OUT);

			$count++;
		}

	}

}
close(IN);

print "TOTALS\n";
print " Messages              $count \n";
print " Unique senders        $uniqueFrom \n";
print " Message lines         $totalLines \n";
print " Message words         $totalWords \n";
print " Unique message lines  $uniqueLines \n";

if ($outSent)
{
	close(OUT_SENT);
}

if ($outUnique)
{
	close(OUT_UNIQUE);
}
