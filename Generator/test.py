
import glob
import os


print('good')
for ID in range(20):
    # for id in np.arange(20,21,1):
    path = '/Users/junxiaoshen/Documents/FourthYearProject/Generator/Trace_data_processed/ID%s/*.csv' % (ID + 1)

    for fname in sorted(glob.glob(path), reverse=True):
        print(fname)
        phrases = fname.split('_')[3:-2]

        phrases_join = ' '.join(phrases)
        print(phrases)
        print(phrases_join)
        print(len(phrases_join))
        
