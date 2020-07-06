import numpy as np
import tensorflow as tf
import pickle as pickle
from scipy.stats import multivariate_normal

from utils import *

def sample_gaussian3d(mu1, mu2, mu3, s1, s2, s3, rho12, rho23, rho31):
    mean = [mu1, mu2,mu3]
    cov = [[s1*s1, rho12*s1*s2,rho31*s1*s3], [rho12*s1*s2,s2*s2,rho23*s2*s2],[rho31*s1*s3,rho23*s2*s3, s3*s3]]
    x = np.random.multivariate_normal(mean, cov, 1)
    return x[0][0], x[0][1], x[0][2]

def get_style_states(model, args):
    c0, c1, c2 = model.istate_cell0.c.eval(), model.istate_cell1.c.eval(), model.istate_cell2.c.eval()
    h0, h1, h2 = model.istate_cell0.h.eval(), model.istate_cell1.h.eval(), model.istate_cell2.h.eval()
    if args.style is -1: return [c0, c1, c2, h0, h1, h2] #model 'chooses' random style

    with open(os.path.join(args.data_dir, 'styles.p'),'rb') as f:
        style_strokes, style_strings = pickle.load(f, encoding='latin1')

    style_strokes, style_string = style_strokes[args.style], style_strings[args.style]
    style_onehot = [to_one_hot(style_string, model.ascii_steps, args.alphabet)]
        
    style_stroke = np.zeros((1, 1, 3), dtype=np.float32)
    style_kappa = np.zeros((1, args.kmixtures, 1))
    prime_len = 500 # must be <= 700
    
    for i in range(prime_len):
        style_stroke[0][0] = style_strokes[i,:]
        feed = {model.input_data: style_stroke, model.char_seq: style_onehot, model.init_kappa: style_kappa, \
                model.istate_cell0.c: c0, model.istate_cell1.c: c1, model.istate_cell2.c: c2, \
                model.istate_cell0.h: h0, model.istate_cell1.h: h1, model.istate_cell2.h: h2}
        fetch = [model.new_kappa, \
                 model.fstate_cell0.c, model.fstate_cell1.c, model.fstate_cell2.c,
                 model.fstate_cell0.h, model.fstate_cell1.h, model.fstate_cell2.h]
        [style_kappa, c0, c1, c2, h0, h1, h2] = model.sess.run(fetch, feed)
    return [c0, c1, c2, np.zeros_like(h0), np.zeros_like(h1), np.zeros_like(h2)] #only the c vectors should be primed

def sample(input_text, model, args):
    # initialize some parameters
    one_hot = [to_one_hot(input_text, model.ascii_steps, args.alphabet)]         # convert input string to one-hot vector
    [c0, c1, c2, h0, h1, h2] = get_style_states(model, args) # get numpy zeros states for all three LSTMs
    kappa = np.zeros((1, args.kmixtures, 1))   # attention mechanism's read head should start at index 0
    prev_x = np.asarray([[[0, 0, 0]]], dtype=np.float32)     # start with a pen stroke at (0,0)

    strokes, pis, windows, phis, kappas = [], [], [], [], [] # the data we're going to generate will go here

    finished = False ; i = 0
    while not finished:
        feed = {model.input_data: prev_x, model.char_seq: one_hot, model.init_kappa: kappa, \
                model.istate_cell0.c: c0, model.istate_cell1.c: c1, model.istate_cell2.c: c2, \
                model.istate_cell0.h: h0, model.istate_cell1.h: h1, model.istate_cell2.h: h2}
        fetch = [model.pi_hat, model.mu1, model.mu2, model.mu3, model.sigma1_hat, model.sigma2_hat, model.sigma3_hat, model.rho12, model.rho23, model.rho31, \
                 model.window, model.phi, model.new_kappa, model.alpha, \
                 model.fstate_cell0.c, model.fstate_cell1.c, model.fstate_cell2.c,\
                 model.fstate_cell0.h, model.fstate_cell1.h, model.fstate_cell2.h]
        [pi_hat, mu1, mu2, mu3, sigma1_hat, sigma2_hat,sigma3_hat, rho12, rho23, rho31, window, phi, kappa, alpha, \
                 c0, c1, c2, h0, h1, h2] = model.sess.run(fetch, feed)
        
        #bias stuff:
        sigma1 = np.exp(sigma1_hat - args.bias) ; sigma2 = np.exp(sigma2_hat - args.bias); sigma3 = np.exp(sigma3_hat - args.bias)
        pi_hat *= 1 + args.bias # apply bias
        pi = np.zeros_like(pi_hat) # need to preallocate
        pi[0] = np.exp(pi_hat[0]) / np.sum(np.exp(pi_hat[0]), axis=0) # softmax
        
        # choose a component from the MDN
        idx = np.random.choice(pi.shape[1], p=pi[0])
        
        x1, x2 , x3= sample_gaussian3d(mu1[0][idx], mu2[0][idx], mu3[0][idx], sigma1[0][idx], sigma2[0][idx],sigma3[0][idx], rho12[0][idx],rho23[0][idx],rho31[0][idx])

        # store the info at this time step
        windows.append(window)
        phis.append(phi[0])
        kappas.append(kappa[0].T)
        pis.append(pi[0])
        strokes.append([mu1[0][idx], mu2[0][idx], mu3[0][idx], sigma1[0][idx], sigma2[0][idx],sigma3[0][idx], rho12[0][idx],rho23[0][idx],rho31[0][idx]])

        # test if finished (has the read head seen the whole ascii sequence?)
        # main_kappa_idx = np.where(alpha[0]==np.max(alpha[0]));
        # finished = True if kappa[0][main_kappa_idx] > len(input_text) else False
        finished = True if i > args.tsteps else False
        
        # new input is previous output
        prev_x[0][0] = np.array([x1, x2, x3], dtype=np.float32)
        i+=1

    windows = np.vstack(windows)
    phis = np.vstack(phis)
    kappas = np.vstack(kappas)
    strokes = np.vstack(strokes)


    return strokes, phis, windows, kappas


# plots parameters from the attention mechanism
def window_plots(phis, windows, save_path='.'):
    import matplotlib.cm as cm
    import matplotlib as mpl
    mpl.use('Agg')
    import matplotlib.pyplot as plt
    plt.figure(figsize=(16,4))
    plt.subplot(121)
    plt.title('Phis', fontsize=20)
    plt.xlabel("ascii #", fontsize=15)
    plt.ylabel("time steps", fontsize=15)
    plt.imshow(phis, interpolation='nearest', aspect='auto', cmap=cm.jet)
    plt.subplot(122)
    plt.title('Soft attention window', fontsize=20)
    plt.xlabel("one-hot vector", fontsize=15)
    plt.ylabel("time steps", fontsize=15)
    plt.imshow(windows, interpolation='nearest', aspect='auto', cmap=cm.jet)
    plt.savefig(save_path)
    plt.clf() ; plt.cla()


def multivariate_normal(x1, x2, x3, mu1=0., mu2=0., mu3=0., s1=1., s2=1., s3=1., rho12=0., rho23=0., rho31=0.):



    mean = [mu1, mu2, mu3]
    cov = [[s1 * s1, rho12 * s1 * s2, rho31 * s1 * s3], [rho12 * s1 * s2, s2 * s2, rho23 * s2 * s2],
           [rho31 * s1 * s3, rho23 * s2 * s3, s3 * s3]]

    x = [x1, x2, x3]

    pdf=multivariate_normal.pdf(x,mean,cov)
    return pdf


# a heatmap for the probabilities of each pen point in the sequence
def gauss_plot(strokes, title, figsize = (20,2), save_path='.'):
    import matplotlib.mlab as mlab
    import matplotlib.cm as cm
    import matplotlib as mpl
    mpl.use('Agg')
    import matplotlib.pyplot as plt
    plt.figure(figsize=figsize) #
    buff = 1 ; epsilon = 1e-4
    minx, maxx = np.min(strokes[:,0])-buff, np.max(strokes[:,0])+buff
    miny, maxy = np.min(strokes[:,1])-buff, np.max(strokes[:,1])+buff
    minz, maxz = np.min(strokes[:, 2]) - buff, np.max(strokes[:, 1]) + buff
    delta = abs(maxx-minx)/400. ;

    x = np.arange(minx, maxx, delta)
    y = np.arange(miny, maxy, delta)
    z = np.arange(minz, maxz, delta)
    X, Y ,Z= np.meshgrid(x, y ,z)
    for i in range(strokes.shape[0]):
        gauss = multivariate_normal(X, Y, Z, mu1=strokes[i,0], mu2=strokes[i,1], mu3=strokes[i,2] ,s1=strokes[i,3], s2=strokes[i,4],s3=strokes[i,5]) # sigmaxy=strokes[i,4] gives error
        Z += gauss/(np.max(gauss) + epsilon)

    plt.title(title, fontsize=20)
    plt.imshow(Z)
    plt.savefig(save_path)
    plt.clf() ; plt.cla()




# plots the stroke data (handwriting!)
def line_plot(strokes, title, figsize = (20,20), save_path='.'):
    import matplotlib as mpl
    mpl.use('Agg')
    import matplotlib.pyplot as plt
    plt.figure(figsize=figsize)

    plt.figure(1)
    ax1 = plt.subplot(311)

    plt.plot(strokes[:,0], strokes[:,1],'b-', linewidth=2.0) #draw a stroke

    ax2 = plt.subplot(312)

    plt.plot(strokes[:,1], strokes[:, 2], 'b-', linewidth=2.0)  # draw a stroke

    ax3 = plt.subplot(313)


    plt.plot(strokes[:, 0], strokes[:, 2], 'b-', linewidth=2.0)  # draw a stroke
    # ax = plt.axes(projection='3d')
    # ax.scatter3D(strokes[:,0], strokes[:,1],strokes[:,2], 'gray')


    # ax.view_init(30, )

    ax1.set_title(title,  fontsize=20)
    ax2.set_title(title, fontsize=20)
    ax3.set_title(title, fontsize=20)

    plt.savefig(save_path)
    plt.clf() ; plt.cla()
