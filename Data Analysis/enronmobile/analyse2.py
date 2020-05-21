
import numpy as np
from collections import Counter

file = open('mobile_orig_nonum.txt','r')
txt=file.readlines()
new_txt=[]
ave_word=[]
punctuations = '''!()-[]{};:'"\,<>./?@#$%^&*_~'''

for i in range(len(txt)):
    if len(txt[i].split(' ')) >=2 and len(txt[i].split(' '))<=5:
        
        new_phrase_ =((txt[i]).split('\t')[1]).split(' .')[0]
        new_phrase = ""
        for char in new_phrase_:
            if char not in punctuations:
                new_phrase=new_phrase+char
        new_txt.append(new_phrase+'\n')
        ave_word.append(len(new_phrase.split(' ')))

print('average number of words in a phrase: '+str(np.mean(ave_word)))
print('number of the phrases: '+str(len(new_txt)))

words=[]
for line in new_txt:
    words += line.split()

print ('number of unique words: '+str(len(Counter(words))))


file1 = open("new_phrases2.txt","w")
file1.writelines(new_txt)





file1.close()

