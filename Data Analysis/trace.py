import csv
import numpy as np
import matplotlib.pyplot as plt
import glob
import os

from scipy.signal import savgol_filter

id=19
# for id in np.arange(20,21,1):
path = "Trace_data/ID%s/kbtrace/*.csv"%(id)
path2 = "Trace_data_processed/ID%s"%(id)

#os.mkdir(path2)
fname_list=[]
phrases_list=[]
phrases_list_join=[]
num_words_list=[]
time_list=[]
wpm_list=[]
#path = "*.csv"

ignore=0
for fname in sorted(glob.glob(path),reverse=True):
    print(fname)
    fname_list.append(fname)

    phrases=fname.split('_')[2:-2]

#    if phrases!=['a', 'letter', 'is', 'being', 'sent', 'today']:
#        continue

    print(phrases)
    if phrases_list:
        if phrases==phrases_list[-1]:
            continue
    phrases_list.append(phrases)
    phrases_join=' '.join(phrases)

    phrases_list_join.append(phrases_join)


    #num_words=len(phrases)
    num_words=len(phrases_list_join[-1])/5
    print(phrases_list_join[-1])
#    print(num_words)
    num_words_list.append(num_words)
    x=[]
    y=[]
    z=[]
    t=[]
    pos_list=[]



    with open(fname, newline='') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in spamreader:
            if row==[]:
                continue
            row_split=row[0].split(',')
            x.append(float(row_split[0]))
            y.append(float(row_split[1]))
            z.append(float(row_split[2]))
            t.append(float(row_split[3]))
            pos_list.append([float(row_split[0]),float(row_split[1]),float(row_split[2])])


#    t_difference=[]
#    for i in range(len(t)-1):
#        t_difference.append(t[i+1]-t[i])

#    plt.hist(t_difference)
#    plt.xlabel('time difference')
#    plt.ylabel('Frequency')
    #plt.show()

    down_key=np.transpose([0,-0.1,-0.1])
    L=0.05
    pos_down=[]


#    print(int(len(z)//2))
#    print(len(z))
    z_new=[]
    x_new=[]
    y_new=[]
    t_new=[]
    pos_list_new=[]
#    for i in z[::2]:
    for i in z:
        if np.abs(i)<= 0.1:
            z_new.append(i)
            x_new.append(x[z.index(i)])
            y_new.append(y[z.index(i)])
            t_new.append(t[z.index(i)])
            pos_list_new.append(pos_list[z.index(i)])
    t_new=sorted(t_new)




    average_z=np.mean(z_new[int(len(z_new)//2):-1])
#    value=[i for i in z if np.abs(i-average_z)<0.03]
    value_list=[]
    index_list=[]
    for i in z_new:
        if np.abs(i-average_z)<0.005:
            value_list.append(i)
            index_list.append(z_new.index(i))

    if value_list==[]:
        ignore+=1
        continue
#        print('ignore '+str(ignore))

#    print(value)
#    print(value_list)
#    print(index_list)
    start_index=int(np.round(index_list[1]*0.5))
#        print('start index '+str(start_index))
    first_index=start_index

#    x=x[start_index:]
#    y=y[start_index:]
#    z=z[start_index:]



#
#    for i in range(len(x)):
#        if np.linalg.norm(pos_list[i]-down_key)<=L:
#            pos_down.append(pos_list[i])



#
##    for i in range(len(pos_down)):
##        print(pos_list.index(pos_down[i]))
#
#


#
#
#   plt.figure(figsize=(12, 9))
#
#   plt.subplot(331)
#   plt.plot(x_new[first_index:])
#   plt.title('x')
#   plt.subplot(332)
#   plt.plot(y_new[first_index:])
#   plt.title('y')
#   plt.subplot(333)
#   plt.plot(z_new[first_index:])
#   plt.title('z')
#
#
#   window_size=81
#
#   x_new_s=savgol_filter(x_new[::2], window_size, 3)
#   y_new_s=savgol_filter(y_new[::2], window_size, 3)
#   z_new_s=savgol_filter(z_new[::2],window_size , 3)
#
#   plt.subplot(334)
#   plt.plot(x_new)
#   plt.title('x')
#   plt.subplot(335)
#   plt.plot(y_new)
#   plt.title('y')
#   plt.subplot(336)
#   plt.plot(z_new)
#   plt.title('z')
##
#
##    z_new=[i for i in (z[::2]) if np.abs(i) <= 0.4]
##    x_new=[i for i in (x[::2]) if x[::2].index(i)==]
#
##    x_new=[i for i in np.diff(x[::2]) if np.abs(i) <= 0.02]
##    y_new=[i for i in np.diff(y[::2]) if np.abs(i) <= 0.02]
##
##
##    plt.subplot(334)
##    plt.plot(np.gradient(x_new))
##    plt.title('x')
##    plt.subplot(335)
##    plt.plot(np.gradient(y_new))
##    plt.title('y')
##    plt.subplot(336)
##    plt.plot(np.gradient(z_new))
##    plt.title('z')
#
##
##    window_size=301
##
##    x_new_diff=savgol_filter(np.diff(x[::2]), window_size, 3)
##    y_new_diff=savgol_filter(np.diff(y[::2]), window_size, 3)
##    z_new_diff=savgol_filter(np.diff(z[::2]),window_size , 3)
##    plt.subplot(337)
##    plt.plot(np.gradient(x_new
##    ))
##    plt.title('x-gradient')
##    plt.subplot(338)
##    plt.plot(np.gradient(y_new
##    ))
##    plt.title('y-gradient')
##    plt.subplot(339)
##    plt.plot(np.gradient(z_new
##    ))
##    plt.title('z-gradient')
#   plt.subplot(337)
#   plt.plot(x_new[first_index:])
#   plt.title('x')
#   plt.subplot(338)
#   plt.plot(y_new[first_index:])
#   plt.title('y')
#   plt.subplot(339)
#   plt.plot(z_new[first_index:])
#   plt.title('z')
#
#
#   plt.show()




#
#    for i in range(len(pos_down)-1):
#        if pos_list.index(pos_down[i+1])-pos_list.index(pos_down[i])!=1:
#            first_index=pos_list.index(pos_down[i])
#            continue
#
#    for i in reversed(range(len(pos_down)-1)):
#        if pos_list.index(pos_down[i+1])-pos_list.index(pos_down[i])!=1:
#            last_index=pos_list.index(pos_down[i])
#            continue
#

#    first_index=pos_list.index(pos_down[1])
#    last_index=pos_list.index(pos_down[-1])

#    first_index=1
#    last_index=-2


#    last_index=-2
#    print(pos_list_new)
#    final_trace=pos_list_new[first_index:]
#
#    final_time=t_new[first_index:]
    final_trace=pos_list_new
    final_time=t_new

    final_trace=np.reshape(final_trace,(len(final_trace),3))
    final_time=np.reshape(final_time,(len(final_time),1))
    final_data=np.concatenate((final_trace,final_time),axis=1)
    fname_modified=fname.split('/')[3]

    # np.savetxt('Trace_data_processed/ID%s/%s'%(id,fname_modified),final_data)

#    print(t_new[-2])
#    print(t_new[first_index])
#    print(t_new)
    time=t_new[-1]-t_new[0]

    time_list.append(time)

    wpm=num_words/(time/(1000*60))

    wpm_list.append(wpm)
    print('complete time: '+str(time/1000)+'seconds')
    print('word per mininute:'+str(wpm))


print('average word per mininute: '+str(np.mean(wpm_list)))
