import numpy as np

import random


file = open('PhraseSets/phrases2.txt','r')
txt=file.readlines()
new_txt=[]
ave_word=[]
low_lim=5
up_lim=45
for i in range(len(txt)):
    if len(list(txt[i])) >=low_lim and len(list(txt[i]))<=up_lim:
        new_phrase=txt[i]
        new_txt.append('shawnshenjx\t'+new_phrase.capitalize() )
        ave_word.append(len(new_phrase.split(' ')))

print('PhraseSets-------------')
ave_word1=np.mean(ave_word)
print('average number of words in a phrase: '+str(np.mean(ave_word)))
print('number of phrases: '+str(len(new_txt)))

print('--------------------------')

file1 = open("new_phrases1.txt","w")
file1.writelines(new_txt)
new_txt1=new_txt
file1.close()



import numpy as np
from collections import Counter

file = open('enronmobile/mobile_orig_nonum.txt','r')
txt=file.readlines()
new_txt=[]
ave_word=[]
punctuations = '''!()-[]{};:'"\,<>./?@#$%^&*_~'''

for i in range(len(txt)):
    if len(list(txt[i])) >=low_lim and len(list(txt[i]))<=up_lim:
        
        new_phrase_ =((txt[i]).split('\t')[1]).split(' .')[0]
        new_phrase = ""
        for char in new_phrase_:
            if char not in punctuations:
                new_phrase=new_phrase+char
        new_txt.append('shawnshenjx\t'+new_phrase.capitalize() )
        ave_word.append(len(new_phrase.split(' ')))


print('enronmobile-------------')

print('average number of words in a phrase: '+str(np.mean(ave_word)))
ave_word2=np.mean(ave_word)
print('number of phrases: '+str(len(new_txt)))

words=[]
for line in new_txt:
    words += line.split()


print ('number of unique words: '+str(len(Counter(words))))

file1 = open("new_phrases2.txt","w")
file1.writelines(new_txt)
new_txt2=new_txt
file1.close()





file2 = open("new_phrases_total.txt","w")
total_new_txt=new_txt1+new_txt2
random.shuffle(total_new_txt)
file2.writelines(total_new_txt)
file2.close()

words=[]
for line in total_new_txt:
    words += line.split()

print('--------------------------')

print ('total dataset:')

print('average number of words in a phrase: '+str(np.mean([ave_word1,ave_word2])))

print('number of phrases: '+str(len(total_new_txt)))

print ('number of unique words: '+str(len(Counter(words))))

print ('total number of words: '+str(len(words)))

