#!/usr/bin/perl

# Go through a list of Enron message files looking
# for the text block that is a message written on
# a Blackberry (assuming the user hasn't changed
# the default signature).
#
# Copyright 2011 by Keith Vertanen
#

use strict;

if ( @ARGV < 2 )
{
    print "$0 <list of files> <output base name>\n"; 
    exit(1);
}

my $listFile;
my $outBase;
my $line;
my $i;
my $j;

my @msg;
my $msgLine;

my $headerIndex;
my $dashIndex;
my $sigIndex;
my $blankIndex;
my $subjIndex;
my $fwdIndex;
my $notesIndex;
my $endIndex;
my $fromIndex;
my $toIndex;
my $origIndex;
my $outNum = 0;
my $nonBlank;

($listFile, $outBase) = @ARGV;

open(IN, $listFile);

# Read in the next file containing a message
while ($line = <IN>)
{
	$line =~ s/[\n\r]//g;

	# Read in all the lines of a specific message file
	@msg = ();
	open(IN_MSG, $line);
	while ($msgLine = <IN_MSG>)
	{
		$msgLine =~ s/[\n\r]//g;
		push @msg, $msgLine;
	}
	close(IN_MSG);

	# Go through the lines, looking for the Blackberry signature
	$i = 0;
	$headerIndex = "";
	$dashIndex = "";
	$sigIndex = "";
	$blankIndex = "";
	$subjIndex = "";
	$fwdIndex = "";
	$notesIndex = "";
	$endIndex = "";
	$fromIndex = "";
	$toIndex = "";
	$origIndex = "";

	while ($i < @msg)
	{
		$msgLine = $msg[$i];

		# Track the last message header line seen
		if ($msgLine =~ /^[A-Za-z0-9\-]+\:\s/)
		{
			$headerIndex = $i;
#			print $msgLine . "\n";

			# Note if this is the subject header line
			if ($msgLine =~ /^Subject:/)
			{
				$subjIndex = $i;
#				print "SUBJ: $msgLine \n";
			}
			# Make note of the from field
			elsif ($msgLine =~ /^From\:/)
			{
				$fromIndex = $i;
			}
			# Also note the To: field
			elsif ($msgLine =~ /^To\:/)
			{
				$toIndex = $i;
			}
		}
		# A line that only had a CR/LF immediately after the header line
		elsif ((!$msgLine) && (!$blankIndex) && ($i == ($headerIndex + 1)))
		{
			$blankIndex = $i;
#			print $blankIndex . "\n";
		}
		# Note where the message might be the start of a forward
		elsif ((!$fwdIndex) && (lc($msgLine) =~ /forwarded by /))
		{
			$fwdIndex = $i;
		}
		# Checked for start of quoted message
		elsif ((!$origIndex) && (lc($msgLine) =~ /original message:/))
		{
			$origIndex = $i;
		}
		# Note where the message might be the start of a Lotus Notes style reply.
		# We look for something like <Richard.B.Sanders@enron.com>
		elsif ((!$notesIndex) && ($msgLine =~ /\<[A-Za-z0-9\-\.]+\@[A-Za-z0-9\-\.]+\>/))
		{
			$notesIndex = $i;
#			print "NOTES: $msgLine \n";
		}

		# A dashed line preceeds the Blackberry signature
		elsif ($msgLine =~ /^-----------/)
		{
			$dashIndex = $i;
#			print $dashIndex . "\n";
		}
		# The actual signature (case insensitive)
		elsif (lc($msgLine) =~ /sent from my blackberry/)
		{
			$sigIndex = $i;
#			print $msgLine . "\n";

			# Now see if we have the preceeding things 
			if (($headerIndex) &&
				($blankIndex) &&
				($dashIndex) &&
				($sigIndex) &&
				($headerIndex < $blankIndex) &&
				($blankIndex < $dashIndex) &&
				($dashIndex < $sigIndex))
			{

				# Go to right before the signature, unless we
				# spotted a forward or Lotus Notes style reply.
				$endIndex = $dashIndex;
				if ($fwdIndex)
				{
					$endIndex = $fwdIndex;
				}
				if (($notesIndex) && ($notesIndex < $endIndex))
				{
					$endIndex = $notesIndex;
				}
				if (($origIndex) && ($origIndex < $endIndex))
				{
					$endIndex = $origIndex;
				}

#				print "END INDEX:   $endIndex \n";
#				print "FWD INDEX:   $fwdIndex \n";
#				print "NOTES INDEX: $notesIndex \n";

				# Check to be sure the message will actually
				# contain a non-blank line (might be all blank
				# if it was just a forwarded message).
				$nonBlank = "";
				for ($j = $blankIndex + 1; $j < $endIndex; $j++)
				{
					if ($msg[$j])
					{
						$nonBlank = 1;
					}
				}

				if ($nonBlank)
				{
					open(OUT, ">" . $outBase . $outNum);
					$outNum++;

					print OUT "$line" . "\n";
					
					print OUT $msg[$fromIndex] . "\n";
					print OUT $msg[$toIndex] . "\n";
					print OUT $msg[$subjIndex] . "\n";
					
					for ($j = $blankIndex + 1; $j < $endIndex; $j++)
					{
						print OUT $msg[$j] . "\n";
					}
					close(OUT);
				}
			}

			$headerIndex = "";
			$dashIndex = "";
			$sigIndex = "";
			$blankIndex = "";
			$subjIndex = "";
			$fwdIndex = "";
			$notesIndex = "";			
			$endIndex = "";
			$fromIndex = "";
			$toIndex = "";
			$origIndex = "";
		}

		$i++;
	}

}
close(IN);

