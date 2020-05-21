
# Get the text of any Blackberry message and
# output it to the text subdirectory

rm human*
find orig -iname 'orig*' >files_orig.txt

# Randomize the order of the files, just so 
# humans don't get all the messages from
# the same person.
perl RandomizeLines.pl files_orig.txt 100

perl PrepHuman.pl files_orig.txt human 2









