
# Prepare a fixed version of each message, 
# removes duplicate messages.

cat human0b.txt >human_fixed.txt
cat human1b.txt >>human_fixed.txt

perl SortHuman.pl human_fixed.txt human_sorted.txt



