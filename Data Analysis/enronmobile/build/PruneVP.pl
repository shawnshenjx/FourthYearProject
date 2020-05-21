
# Remove lines that have VP that we don't like.
#
# Optionally an extra two input files can be 
# sent in and we eliminate lines from these
# files according to what happens in the main
# input file.
#
# Also optionally can enforce a minimum number
# of words per sentence and the precense of
# a sentence ending VP word (.!?).
#
# Copyright 2011 by Keith Vertanen

use strict;

if ( @ARGV < 3 )
{
    print "$0 <invalid VP file> <in VP file> <out VP file> [in orig] [out orig] [in NVP] [out NVP] [min words] [end symbol] [no numbers]\n";
	exit(1);
}

my $word;
my %words;
my $wordFile;
my $inFile;
my $line;
my @chunks;
my $i;
my $OOV;
my $wordLower;
my $outFile;
my $inFile2;
my $outFile2;
my $inFile3;
my $outFile3;
my $line2;
my $line3;
my $minWords;
my $endVP;
my $noNum;
my $id;
my $text;

($wordFile, $inFile, $outFile, $inFile2, $outFile2, $inFile3, $outFile3, $minWords, $endVP, $noNum) = @ARGV;

# Read in the dictionary
open(IN, $wordFile);
while ($line = <IN>)
{
    $line =~ s/[\n\r]//g;
    @chunks = split(/\s{1,}/, $line);

    # Could be a dictionary or just a word list, or a dictionary with probs
    if (@chunks >= 1)
    {
		$word = lc($chunks[0]);
		$words{$word} = 1;
    }

}
close(IN);

open(OUT, ">" . $outFile);
open(IN, $inFile);

if ($inFile2)
{
	open(IN2, $inFile2);
}
if ($outFile2)
{
	open(OUT2, ">" . $outFile2);
}
if ($inFile3)
{
	open(IN3, $inFile3);
}
if ($outFile3)
{
	open(OUT3, ">" . $outFile3);
}

while ($line = <IN>)
{
    $line =~ s/[\n\r]//g;
    @chunks = split(/\s{1,}/, $line);

	if ($inFile2)
	{
		$line2 = <IN2>;
	}
	if ($inFile3)
	{
		$line3 = <IN3>;
	}

	$i = 0;
	$OOV = 0;

	# See if we need to eliminate due to a non-allowed word
	while (($i < @chunks) && (!$OOV))
	{
		$word = $chunks[$i];
		$wordLower = lc($word);

		if ($words{$wordLower})
		{
			$OOV = 1;
		}

		# See if we need to check for a good end of sentence VP word
		if (($i == (@chunks - 1)) && ($endVP))
		{
			if (($wordLower !~ /\.period/) &&
				($wordLower !~ /\!exclamation-point/) &&
				($wordLower !~ /\?question-mark/))
			{
				$OOV = 1;
			}
		}

		$i++;
	}

	# See if we need to eliminate based on too few words.
	# Subtract one for the ID column and one for the ending VP.
	if (($minWords) && ((@chunks - 2) < $minWords))
	{
		$OOV = 1;
	}

	# Check the original text for precense of a number.
	if (($noNum) && ($inFile2))
	{
		
		@chunks = split(/\t/, $line2);
		($id, $text) = (@chunks);

		if ($text =~ /[0-9]/)
		{
			$OOV = 1;
		}
	}

	if (!$OOV)
	{
		print OUT $line . "\n";

		if ($outFile2)
		{
			print OUT2 $line2;
		}
		if ($outFile3)
		{
			print OUT3 $line3;
		}
	}
}
close(IN);
close(OUT);

if ($inFile2)
{
	close(IN2);
}
if ($outFile2)
{
	close(OUT2);
}
if ($inFile3)
{
	close(IN3);
}
if ($outFile3)
{
	close(OUT3);
}
