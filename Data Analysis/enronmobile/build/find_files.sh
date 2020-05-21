
# Go through all the files in the ENRON_DIR directory
# and look for the magic text "Sent from my Blackberry"


# All the message files
find ${ENRON_DIR} -type f >files_all.txt
ALL=`wc -l files_all.txt`

# Only ones with the Blackberry text
find ${ENRON_DIR} -type f -exec grep -ilH "Sent from my Blackberry" {} \; >files_mobile.txt
MOBILE=`wc -l files_mobile.txt`

# Find the set without Blackberry text
perl GetLinesNotIn.pl files_all.txt files_mobile.txt >files_nonmobile.txt
NONMOBILE=`wc -l files_nonmobile.txt`

echo FILE COUNT
echo  ${ALL}
echo  ${MOBILE}
echo  ${NONMOBILE}






