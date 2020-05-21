import csv
import os
import glob
import shutil

id=20
path = "Trace_data/ID%s/*.csv"%(id)
event_dir="Trace_data/ID%s/event/"%(id)
trace_dir="Trace_data/ID%s/kbtrace/"%(id)
ot_dir="Trace_data/ID%s/ot/"%(id)

fname_list=[]
#
#os.remove(event_dir)
#os.remove(trace_dir)
#os.remove(ot_dir)


os.mkdir(event_dir)
os.mkdir(trace_dir)
os.mkdir(ot_dir)

phrases_list=[]


for fname in sorted(glob.glob(path),reverse=True):
    print(fname)
    fname_list.append(fname)


    type=(fname.split('/')[2]).split('-')[0]
    

    phrases=fname.split('_')[2:-2]
    
    if phrases_list:
        if phrases==phrases_list[-1]:
#            print(phrases_list)
            continue
    phrases_list.append(phrases)
    
    
    if type == 'ot':


        shutil.move(fname, ot_dir)
    if type == 'kbtrace':
        shutil.move(fname, trace_dir)

    if type == 'event':
    
    
        shutil.move(fname, event_dir)

    if type != 'ot' and type != 'kbtrace' and type != 'event':
        continue

