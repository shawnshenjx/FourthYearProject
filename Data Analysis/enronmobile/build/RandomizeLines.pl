
# Randomizes the lines in a text file.  This is done by outputting each line to 
# a random temporary file and then at the end concatenating all the files 
# together.  This is done to avoid having to read the whole file into memory.
# 
# Note: we only use two temporary files and can be run repeatidly to mix things up.
#
# Copyright 2011 by Keith Vertanen

use strict;

if ( @ARGV < 2 )
{
    print "$0 <filename> <number mixes>\n"; 
    exit(1);
}

my $listFile;
my $numMixes;

($listFile, $numMixes) = @ARGV;

my $line;
my $randNum;
my $i = 0;

while ($i < $numMixes)
{

	# Read in every line and output to one of the temporary files
	open(IN, $listFile);
	open(OUT1, ">RandomizeLinesTemp1.txt");
	open(OUT2, ">RandomizeLinesTemp2.txt");

	while($line = <IN>)
	{
		$line =~ s/[\n]//g;
		
		if (rand() < 0.50)
		{
			print OUT1 $line . "\n";
		}
		else
		{
			print OUT2 $line . "\n";
		}
	}
	close(IN);
	close(OUT1);
	close(OUT2);

	# Now we merge the two files into the original
	open(OUT, ">" . $listFile);
	open(IN1, "RandomizeLinesTemp1.txt");
	open(IN2, "RandomizeLinesTemp2.txt");
	while($line = <IN1>)
	{
		$line =~ s/[\n]//g;
		print OUT $line . "\n";
	}
	while($line = <IN2>)
	{
		$line =~ s/[\n]//g;
		print OUT $line . "\n";
	}
	close(OUT);
	close(IN1);
	close(IN2);

	unlink "RandomizeLinesTemp1.txt";
	unlink "RandomizeLinesTemp2.txt";

	$i++;
}








