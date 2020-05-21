import numpy as np

file = open('phrases2.txt','r')
txt=file.readlines()
new_txt=[]
ave_word=[]
for i in range(len(txt)):
    if len(txt[i].split(' ')) >=2 and len(txt[i].split(' '))<=5:
        new_phrase=txt[i]
        new_txt.append(new_phrase)
        ave_word.append(len(new_phrase.split(' ')))

print('average number of words in a phrase: '+str(np.mean(ave_word)))
print('number of the phrases: '+str(len(new_txt)))

file1 = open("new_phrases.txt","w")
file1.writelines(new_txt)
file1.close()
