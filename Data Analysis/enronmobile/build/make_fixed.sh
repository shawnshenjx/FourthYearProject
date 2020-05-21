
# Prepare a fixed version of each message in a seperate file
mkdir -p fixed
rm fixed/fixed*

perl MakeFixed.pl human_sorted.txt fixed/fixed all_sentences.txt all_sentences_unique.txt



