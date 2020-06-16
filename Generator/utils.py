import numpy as np
import math
import random
import os
import pickle as pickle
import xml.etree.ElementTree as ET

from utils import *


import csv
import numpy as np
import matplotlib.pyplot as plt
import glob
import os
dir


class DataLoader():
    def __init__(self, args, logger, limit = 500):
        self.data_dir = args.data_dir
        self.alphabet = args.alphabet
        self.batch_size = args.batch_size
        self.tsteps = args.tsteps
        self.data_scale = args.data_scale # scale data down by this factor
        self.ascii_steps = int(args.tsteps/args.tsteps_per_ascii)
        self.logger = logger
        self.limit = limit # removes large noisy gaps in the data

        data_file = os.path.join(self.data_dir, "strokes_training_data.cpkl")


        if not (os.path.exists(data_file)) :
            self.logger.write("\tcreating training data cpkl file from raw source")
            self.preprocess(data_file)

        self.load_preprocessed(data_file)
        self.reset_batch_pointer()

    def preprocess(self,data_file):
        # create data file from raw xml files from iam handwriting source.
        self.logger.write("\tparsing dataset...")

        asciis = []
        strokes = []
        for ID in range(20):
            # for id in np.arange(20,21,1):
            path = 'Trace_data_processed\ID%s\*.csv' % (ID + 1)

            for fname in sorted(glob.glob(path), reverse=True):
                #     print (fname)
                phrases = fname.split('_')[3:-2]

                phrases_join = ' '.join(phrases)

                pos_list = []
                t = []

                with open(fname, newline='') as csvfile:
                    spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
                    #             counter=0|
                    for row in spamreader:
                        if row == []:
                            continue
                        pos_list.append([float(row[0]), float(row[1]), float(row[2])])
                        t.append(float(row[3]))

                asciis.append(phrases_join)
                strokes.append(pos_list)

        assert (len(strokes) == len(asciis)), "There should be a 1:1 correspondence between stroke data and ascii labels."
        f = open(data_file, "wb")
        pickle.dump([strokes, asciis], f, protocol=2)
        f.close()

        self.logger.write("\tfinished parsing dataset. saved {} lines".format(len(strokes)))


    def load_preprocessed(self, data_file):
        f = open(data_file,"rb")
        [self.raw_stroke_data, self.raw_ascii_data] = pickle.load(f, encoding='latin1')
        f.close()

        # goes thru the list, and only keeps the text entries that have more than tsteps points
        self.stroke_data = []
        self.ascii_data = []
        self.valid_stroke_data = []
        self.valid_ascii_data = []
        counter = 0

        # every 1 in 20 (5%) will be used for validation data
        cur_data_counter = 0
        self.raw_stroke_data = sorted(self.raw_stroke_data, key=len)
        for i in range(len(self.raw_stroke_data)):
            data = self.raw_stroke_data[i]

            cur_data_counter = cur_data_counter + 1
            data = np.array(data, dtype=np.float32)
            if cur_data_counter % 20 == 0:
                self.valid_stroke_data.append(data)
                self.valid_ascii_data.append(self.raw_ascii_data[i])
            else:
                self.stroke_data.append(data)
                self.ascii_data.append(self.raw_ascii_data[i])

        # minus 1, since we want the ydata to be a shifted version of x data
        self.num_batches = int(len(self.stroke_data) / self.batch_size)
        self.logger.write("\tloaded dataset:")
        self.logger.write("\t\t{} train individual data points".format(len(self.stroke_data)))
        self.logger.write("\t\t{} valid individual data points".format(len(self.valid_stroke_data)))
        self.logger.write("\t\t{} batches".format(self.num_batches))

    def validation_data(self):
        # returns validation data
        x_batch = []
        y_batch = []
        ascii_list = []
        for i in range(self.batch_size):
            valid_ix = i%len(self.valid_stroke_data)
            data = self.valid_stroke_data[valid_ix]
            # data = self.valid_stroke_data[i]
            data=np.array(data)
            pad=int(np.shape(self.stroke_data[-1])[0]-np.shape(data)[0])
            # print('pad'+str(pad))
            pad_half=int(round(pad / 2))
            data=np.concatenate((np.zeros((int(pad-pad_half),3)),data,np.zeros((pad_half,3))), axis=0)
            x_batch.append(np.copy(data[:self.tsteps]))
            y_batch.append(np.copy(data[1:self.tsteps+1]))
            ascii_list.append(self.valid_ascii_data[valid_ix])
        one_hots = [to_one_hot(s, self.ascii_steps, self.alphabet) for s in ascii_list]
        return x_batch, y_batch, ascii_list, one_hots

    def next_batch(self):
        # returns a randomized, tsteps-sized portion of the training data
        x_batch = []
        y_batch = []
        ascii_list = []
        for i in range(self.batch_size):
            data = self.stroke_data[i]
            data=np.array(data)
            pad=int(np.shape(self.stroke_data[-1])[0]-np.shape(data)[0])
            pad_half = int(round(pad / 2))
            data = np.concatenate((np.zeros((int(pad - pad_half), 3)), data, np.zeros((pad_half, 3))), axis=0)
            x_batch.append(np.copy(data[:self.tsteps]))
            y_batch.append(np.copy(data[1:self.tsteps+1]))
            ascii_list.append(self.ascii_data[self.idx_perm[self.pointer]])
            self.tick_batch_pointer()
        one_hots = [to_one_hot(s, self.ascii_steps, self.alphabet) for s in ascii_list]
        return x_batch, y_batch, ascii_list, one_hots

    def tick_batch_pointer(self):
        self.pointer += 1
        if (self.pointer >= len(self.stroke_data)):
            self.reset_batch_pointer()
    def reset_batch_pointer(self):
        self.idx_perm = np.random.permutation(len(self.stroke_data))
        self.pointer = 0

    # utility function for converting input ascii characters into vectors the network can understand.
    # index position 0 means "unknown"
def to_one_hot(s, ascii_steps, alphabet):
    steplimit=3e3; s = s[:3e3] if len(s) > 3e3 else s # clip super-long strings
    seq = [alphabet.find(char) + 1 for char in s]
    if len(seq) >= ascii_steps:
        seq = seq[:ascii_steps]
    else:
        seq = seq + [0]*int(ascii_steps - int(len(seq)))
    one_hot = np.zeros((int(ascii_steps),len(alphabet)+1))
    one_hot[np.arange(int(ascii_steps)),seq] = 1
    return one_hot

# abstraction for logging
class Logger():
    def __init__(self, args):
        self.logf = '{}train_scribe.txt'.format(args.log_dir) if args.train else '{}sample_scribe.txt'.format(args.log_dir)
        with open(self.logf, 'w') as f: f.write("project by shawn shen")

    def write(self, s, print_it=True):
        if print_it:
            print(s)
        with open(self.logf, 'a') as f:
            f.write(s + "\n")
