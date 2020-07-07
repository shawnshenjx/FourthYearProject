import numpy as np
import numpy.matlib
import math
import random
import os
import xml.etree.ElementTree as ET

import tensorflow as tf
import tensorflow_probability as tfp
from utils import *

class Model():
	def __init__(self, args, logger):
		self.logger = logger

		# ----- transfer some of the args params over to the model

		# model params
		self.rnn_size = args.rnn_size
		self.train = args.train
		self.nmixtures = args.nmixtures
		self.kmixtures = args.kmixtures
		self.batch_size = args.batch_size if self.train else 1 # training/sampling specific
		self.tsteps = args.tsteps if self.train else 1 # training/sampling specific
		self.alphabet = args.alphabet
		# training params
		self.dropout = args.dropout
		self.grad_clip = args.grad_clip
		# misc
		self.tsteps_per_ascii = args.tsteps_per_ascii
		self.data_dir = args.data_dir

		self.graves_initializer = tf.compat.v1.truncated_normal_initializer(mean=0., stddev=.075, seed=None, dtype=tf.float32)
		self.window_b_initializer = tf.compat.v1.truncated_normal_initializer(mean=0., stddev=0., seed=None, dtype=tf.float32) # hacky initialization

		self.logger.write('\tusing alphabet{}'.format(self.alphabet))
		self.char_vec_len = len(self.alphabet) + 1 #plus one for <UNK> token
		self.ascii_steps = args.tsteps/args.tsteps_per_ascii


		# ----- build the basic recurrent network architecture
		cell_func = tf.contrib.rnn.LSTMCell # could be GRUCell or RNNCell
		self.cell0 = cell_func(args.rnn_size, state_is_tuple=True, initializer=self.graves_initializer)
		self.cell1 = cell_func(args.rnn_size, state_is_tuple=True, initializer=self.graves_initializer)
		self.cell2 = cell_func(args.rnn_size, state_is_tuple=True, initializer=self.graves_initializer)

		if (self.train and self.dropout < 1): # training mode
			self.cell0 = tf.contrib.rnn.DropoutWrapper(self.cell0, output_keep_prob = self.dropout)
			self.cell1 = tf.contrib.rnn.DropoutWrapper(self.cell1, output_keep_prob = self.dropout)
			self.cell2 = tf.contrib.rnn.DropoutWrapper(self.cell2, output_keep_prob = self.dropout)

		self.input_data = tf.placeholder(dtype=tf.float32, shape=[None, self.tsteps, 3])
		self.target_data = tf.placeholder(dtype=tf.float32, shape=[None, self.tsteps, 3])
		self.istate_cell0 = self.cell0.zero_state(batch_size=self.batch_size, dtype=tf.float32)
		self.istate_cell1 = self.cell1.zero_state(batch_size=self.batch_size, dtype=tf.float32)
		self.istate_cell2 = self.cell2.zero_state(batch_size=self.batch_size, dtype=tf.float32)

		#slice the input volume into separate vols for each tstep
		inputs = [tf.squeeze(input_, [1]) for input_ in tf.split(self.input_data, self.tsteps, 1)]
		#build cell0 computational graph
		outs_cell0, self.fstate_cell0 = tf.contrib.legacy_seq2seq.rnn_decoder(inputs, self.istate_cell0, self.cell0, loop_function=None, scope='cell0')


	# ----- build the gaussian character window
		def get_window(alpha, beta, kappa, c):
			# phi -> [? x 1 x ascii_steps] and is a tf matrix
			# c -> [? x ascii_steps x alphabet] and is a tf matrix
			ascii_steps = c.get_shape()[1].value #number of items in sequence
			phi = get_phi(ascii_steps, alpha, beta, kappa)
			window = tf.matmul(phi,c)
			window = tf.squeeze(window, [1]) # window ~ [?,alphabet]
			return window, phi

		#get phi for all t,u (returns a [1 x tsteps] matrix) that defines the window
		def get_phi(ascii_steps, alpha, beta, kappa):
			# alpha, beta, kappa -> [?,kmixtures,1] and each is a tf variable
			u = np.linspace(0,ascii_steps-1,ascii_steps) # weight all the U items in the sequence
			kappa_term = tf.square( tf.subtract(kappa,u))
			exp_term = tf.multiply(-beta,kappa_term)
			phi_k = tf.multiply(alpha, tf.exp(exp_term))
			phi = tf.reduce_sum(phi_k,1, keep_dims=True)
			return phi # phi ~ [?,1,ascii_steps]

		def get_window_params(i, out_cell0, kmixtures, prev_kappa, reuse=True):
			hidden = out_cell0.get_shape()[1]
			n_out = 3*kmixtures
			with tf.variable_scope('window',reuse=reuse):
				window_w = tf.get_variable("window_w", [hidden, n_out], initializer=self.graves_initializer)
				window_b = tf.get_variable("window_b", [n_out], initializer=self.graves_initializer)
				tf.summary.histogram('window_w_summary',window_w)
				tf.summary.histogram('window_b_summary', window_b)
			abk_hats = tf.nn.xw_plus_b(out_cell0, window_w, window_b) # abk_hats ~ [?,n_out]
			abk = tf.exp(tf.reshape(abk_hats, [-1, 3*kmixtures,1])) # abk_hats ~ [?,n_out] = "alpha, beta, kappa hats"

			alpha, beta, kappa = tf.split(abk, 3, 1) # alpha_hat, etc ~ [?,kmixtures]
			kappa = kappa + prev_kappa
			return alpha, beta, kappa # each ~ [?,kmixtures,1]

		self.init_kappa = tf.placeholder(dtype=tf.float32, shape=[None, self.kmixtures, 1])
		self.char_seq = tf.placeholder(dtype=tf.float32, shape=[None, self.ascii_steps, self.char_vec_len])
		prev_kappa = self.init_kappa
		prev_window = self.char_seq[:,0,:]

		#add gaussian window result
		reuse = False
		for i in range(len(outs_cell0)):
			[alpha, beta, new_kappa] = get_window_params(i, outs_cell0[i], self.kmixtures, prev_kappa, reuse=reuse)
			window, phi = get_window(alpha, beta, new_kappa, self.char_seq)
			outs_cell0[i] = tf.concat((outs_cell0[i],window), 1) #concat outputs
			outs_cell0[i] = tf.concat((outs_cell0[i],inputs[i]), 1) #concat input data
			prev_kappa = new_kappa
			prev_window = window
			reuse = True
		#save some attention mechanism params (useful for sampling/debugging later)
		self.window = window
		self.phi = phi
		self.new_kappa = new_kappa
		self.alpha = alpha


	# ----- finish building LSTMs 2 and 3
		outs_cell1, self.fstate_cell1 = tf.contrib.legacy_seq2seq.rnn_decoder(outs_cell0, self.istate_cell1, self.cell1, loop_function=None, scope='cell1')

		outs_cell2, self.fstate_cell2 = tf.contrib.legacy_seq2seq.rnn_decoder(outs_cell1, self.istate_cell2, self.cell2, loop_function=None, scope='cell2')

	# ----- start building the Mixture Density Network on top (start with a dense layer to predict the MDN params)
		n_out = self.nmixtures * 10 # params = 10 parameters per Gaussian
		with tf.variable_scope('mdn_dense'):
			mdn_w = tf.get_variable("output_w", [self.rnn_size, n_out], initializer=self.graves_initializer)
			mdn_b = tf.get_variable("output_b", [n_out], initializer=self.graves_initializer)
			tf.summary.histogram('mdn_w_summary', mdn_w)
			tf.summary.histogram('mdn_b_summary', mdn_b)

		out_cell2 = tf.reshape(tf.concat(outs_cell2, 1), [-1, args.rnn_size]) #concat outputs for efficiency
		output = tf.nn.xw_plus_b(out_cell2, mdn_w, mdn_b) #data flows through dense nn


	# ----- build mixture density cap on top of second recurrent cell
		def gaussian3d(x1, x2, x3, mu1, mu2, mu3, s1, s2, s3, rho12, rho23, rho31):

			x_mu1 = tf.subtract(x1, mu1)
			x_mu2 = tf.subtract(x2, mu2)
			x_mu3 = tf.subtract(x3, mu3)

			m11 = tf.square(s1)
			m12 = tf.multiply(tf.multiply(s1,s2),rho12)
			m13 = tf.multiply(tf.multiply(s1,s3),rho31)
			m21 = m12
			m22 = tf.square(s2)
			m23 = tf.multiply(tf.multiply(s2, s3), rho23)
			m31 = m13
			m32 = m23
			m33 = tf.square(s3)

			a11=tf.multiply(m33,m22)-tf.square(m23)
			a12=tf.multiply(m13,m23)-tf.multiply(m33,m12)
			a13=tf.multiply(m12,m23)-tf.multiply(m13,m22)

			a22=tf.multiply(m33,m11)-tf.square(m13)
			a23=tf.multiply(m12,m13)-tf.multiply(m11,m23)

			a33=tf.multiply(m11,m22)-tf.square(m12)

			a21=a12
			a31=a13
			a32=a23

			D=tf.multiply(m11,a11)+tf.multiply(m12,a12)+tf.multiply(m13,a13)+1e-20

			d11=tf.div(a11,D)
			d12=tf.div(a12,D)
			d13=tf.div(a13,D)
			d21=tf.div(a21,D)
			d22=tf.div(a22,D)
			d23=tf.div(a23,D)
			d31=tf.div(a31,D)
			d32=tf.div(a32,D)
			d33=tf.div(a33,D)


			Z=tf.multiply(tf.square(x_mu1),d11)+tf.multiply(tf.square(x_mu2),d22)+tf.multiply(tf.square(x_mu3),d33) + 2 * tf.multiply(tf.multiply(x_mu1, x_mu2), d12) + 2 * tf.multiply(tf.multiply(x_mu1, x_mu3), d13) + 2 * tf.multiply(tf.multiply(x_mu2, x_mu3), d23)

			power_e=tf.exp(tf.div(-Z,2))

			regularize_term=tf.multiply(tf.pow(2*np.pi,tf.div(3.0,2.0)),tf.sqrt(D))

			gaussian=tf.div(power_e,regularize_term)






			#
			#
			# 		# define gaussian mdn (eq 24, 25 from http://arxiv.org/abs/1308.0850)
			#
			#
			#
			# tfd=tfp.distributions
			#
			# # print(mu1.get_shape().as_list,s1.get_shape(),x1.get_shape(),mu1.get_shape(),s1.get_shape())
			#
			#
			#
			#
			# # with tf.Session() as sess:
			# # 	print(sess.run(tf.shape(mu1),tf.shape(x1),tf.shape(s1),tf.shape(rho31)))
			#
			#
			#
			# # mu_=tf.stack([mu1,mu2,mu3])
			#
			# mu_ = tf.stack([mu1, mu2, mu3], 0)
			#
			# mu = tf.transpose(mu_)
			#
			# len_=tf.shape(x1)
			#
			# len=tf.reshape(len_[0],[])
			#
			# # mu = tf.stack([mu_]*len)
			#
			#
			# #stack multiple mu, create a matrix of shape [len(x1),3] and use for loop to feel it, same with the covariiance matrix OR use append
			#
			#
			#
			#
			#
			# cov=tf.zeros([len,3,3])
			# cov_mat11=tf.square(s1)
			# cov_mat12=rho12 * s1 * s2
			# cov_mat13=rho31 * s1 * s3
			# cov_mat21=rho12 * s1 * s2
			# cov_mat22=tf.square(s2)
			# cov_mat23=rho23 * s2 * s3
			# cov_mat31=rho31 * s1 * s3
			# cov_mat32=rho23 * s2 * s3
			# cov_mat33=tf.square(s3)
			#
			# cov[:, 0, 0] = cov_mat11
			# cov[:, 0, 1] = cov_mat12
			# cov[:, 0, 2] = cov_mat13
			# cov[:, 1, 0] = cov_mat21
			# cov[:, 1, 1] = cov_mat22
			# cov[:, 1, 2] = cov_mat23
			# cov[:, 2, 0] = cov_mat31
			# cov[:, 2, 1] = cov_mat32
			# cov[:, 2, 2] = cov_mat33
			#
			# #stack multiple cov
			#
			# # cov =tf.stack([cov_]*len)
			#
			# mvn=tfd.MultivariateNormalFullCovariance(loc=mu,convariance_matrix=cov)
			#
			# X_ = tf.stack([x1, x2, x3], 0)
			#
			# X = tf.transpose(X_)
			#
			# gaussian=mvn.prob(X)
			#
			#
			#
			# #
			# # x_mu1 = tf.subtract(x1, mu1)
			# # x_mu2 = tf.subtract(x2, mu2)
			# # x_mu3 = tf.subtract(x3, mu3)
			#
			# #
			# #
			# # X_=tf.stack([x_mu1,x_mu2,x_mu3],0)
			# #
			# # X=tf.reshape(X_,[3,1])
			# #
			# # XT=tf.reshape(X_,[1,3])
			# #
			# #
			# #
			# # Z=tf.matmul(tf.matmul(XT,tf.transpose(cov_mat)),X)
			# #
			# # power_e=tf.exp(tf.div(-Z,2))
			# #
			# # regularize_term=tf.multiply(tf.pow(tf.multiply(2,np.pi),tf.div(3,2)),tf.square(cov_mat))
			#
			# # gaussian = tf.div(power_e, regularize_term)
			return gaussian

		def get_loss(pi, x1_data, x2_data, x3_data, mu1, mu2, mu3, sigma1, sigma2, sigma3, rho12,rho23, rho31):
			# define loss function (eq 26 of http://arxiv.org/abs/1308.0850)
			gaussian = gaussian3d(x1_data, x2_data,x3_data, mu1, mu2, mu3, sigma1, sigma2, sigma3, rho12, rho23, rho31)
			term = tf.multiply(gaussian, pi)
			term = tf.reduce_sum(term, 1, keep_dims=True) #do inner summation
			term = -tf.log(tf.maximum(term, 1e-20)) # some errors are zero -> numerical errors.


			return tf.reduce_sum(term) #do outer summation

		# now transform dense NN outputs into params for MDN
		def get_mdn_coef(Z):
			# returns the tf slices containing mdn dist params (eq 18...23 of http://arxiv.org/abs/1308.0850)

			pi_hat, mu1_hat, mu2_hat, mu3_hat, sigma1_hat, sigma2_hat, sigma3_hat, rho_hat12, rho_hat23, rho_hat31 = tf.split(Z[:, 0:], 10, 1)
			self.pi_hat, self.sigma1_hat, self.sigma2_hat, self.sigma3_hat = \
										pi_hat, sigma1_hat, sigma2_hat, sigma3_hat # these are useful for bias method during sampling

			pi = tf.nn.softmax(pi_hat) # softmax z_pi:
			mu1 = mu1_hat; mu2 = mu2_hat; mu3=mu3_hat # leave mu1, mu2 as they are
			sigma1 = tf.exp(sigma1_hat); sigma2 = tf.exp(sigma2_hat); sigma3 = tf.exp(sigma3_hat) # exp for sigmas
			rho12 = tf.tanh(rho_hat12); rho23 = tf.tanh(rho_hat23); rho31 = tf.tanh(rho_hat31) # tanh for rho (squish between -1 and 1)rrr

			return [pi, mu1, mu2, mu3, sigma1, sigma2, sigma3, rho12, rho23, rho31]

		# reshape target data (as we did the input data)
		flat_target_data = tf.reshape(self.target_data,[-1, 3])
		[x1_data, x2_data, x3_data] = tf.split(flat_target_data, 3, 1) #we might as well split these now

		[self.pi, self.mu1, self.mu2, self.mu3, self.sigma1, self.sigma2, self.sigma3, self.rho12, self.rho23, self.rho31] = get_mdn_coef(output)

		loss = get_loss(self.pi, x1_data, x2_data, x3_data, self.mu1, self.mu2,self.mu3, self.sigma1, self.sigma2, self.sigma3, self.rho12, self.rho23, self.rho31)
		self.cost = loss / (self.batch_size * self.tsteps)

		# ----- bring together all variables and prepare for training
		self.learning_rate = tf.Variable(0.0, trainable=False)
		self.decay = tf.Variable(0.0, trainable=False)
		self.momentum = tf.Variable(0.0, trainable=False)

		tvars = tf.trainable_variables()
		grads, _ = tf.clip_by_global_norm(tf.gradients(self.cost, tvars), self.grad_clip)

		for g in grads:
			with tf.name_scope('gradients'):
				tf_grad_norm=tf.sqrt(tf.reduce_mean(g**2))
				tf_gradnorm_summary = tf.summary.scalar('grad_norm',tf_grad_norm)
				break

		if args.optimizer == 'adam':
			self.optimizer = tf.train.AdamOptimizer(learning_rate=self.learning_rate)
		elif args.optimizer == 'rmsprop':
			self.optimizer = tf.train.RMSPropOptimizer(learning_rate=self.learning_rate, decay=self.decay, momentum=self.momentum)
		else:
			raise ValueError("Optimizer type not recognized")
		self.train_op = self.optimizer.apply_gradients(list(zip(grads, tvars)))

		self.merged = tf.summary.merge_all()

		# ----- some TensorFlow I/O
		self.sess = tf.InteractiveSession()
		self.saver = tf.train.Saver(tf.global_variables())
		self.sess.run(tf.global_variables_initializer())

		# ----- for restoring previous models
	def try_load_model(self, save_path):
		load_was_success = True # yes, I'm being optimistic
		global_step = 0
		try:
			save_dir = '/'.join(save_path.split('/')[:-1])
			ckpt = tf.train.get_checkpoint_state(save_dir)
			load_path = ckpt.model_checkpoint_path
			self.saver.restore(self.sess, load_path)
		except:
			self.logger.write("no saved model to load. starting new session")
			load_was_success = False
		else:
			self.logger.write("loaded model: {}".format(load_path))
			self.saver = tf.train.Saver(tf.global_variables())
			global_step = int(load_path.split('-')[-1])
		return load_was_success, global_step
