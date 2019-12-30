import os
import numpy as np
import argparse
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.patches import Rectangle
import matplotlib.gridspec as gridspec
import seaborn as sns
import itertools
from scipy.io import loadmat


def moving_average(data, window=4):
    return np.convolve(data, np.ones(int(window)) / float(window), 'same')


def shaded_plot(ax, data, x_scale=1., **kwargs):
    x = np.arange(data.shape[1]) * x_scale
    mu = np.mean(data, axis=0)
    std = np.std(data, axis=0)
    ci = 1.96 * std / np.sqrt(data.shape[0])
#    ax.fill_between(x, mu - ci, mu + ci, alpha=0.2, edgecolor="none", linewidth=0, **kwargs)
    ax.plot(x, mu, linewidth=2, **kwargs)
    ax.margins(x=0)


def add_line(name, env, var, ax, lc='b', ls='-', moving=1):
    data_all = []
    for i in range(1,args.n+1):
        f = args.folder + env + '/' + name + '_' + str(i)
        try:
            data_file = loadmat(f)[var].flatten()
        except:
            print('Cannot read    [', f, ']')
            continue
        if var == 'VC_history':
            data_file = data_file[:100000]
        if var == 'J_history':
            data_file = data_file[:2000]
        data_all.append(data_file)
    data_all = np.array(data_all)
    if data_all.shape[0] == 0:
        print('No data    [', name, ']')
        return
    if moving > 1:
        for i in range(data_all.shape[0]):
           data_all[i,:] = moving_average(data_all[i,:], args.moving)
    x_scale = 1.
    if var == 'J_history':
        x_scale = 50.
    shaded_plot(ax, data_all, x_scale=x_scale, color=lc, linestyle=ls)
    plt.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
    plt.xlabel('Steps')
    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize(6)
        tick.set_pad(-3)
    for tick in ax.yaxis.get_major_ticks():
        tick.label.set_fontsize(6)
        tick.set_pad(-3)




if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--folder', default='ql/ql/res/')
    parser.add_argument('--moving', type=int, default=1)
    parser.add_argument('--n', type=int, default=20)
    args = parser.parse_args()

    sns.set_context("paper")
    sns.set_style('darkgrid', {'legend.frameon':True})

    fig = plt.figure()
    gs = gridspec.GridSpec(2,2)
    gs.update(wspace=0.1, hspace=0.12)

    alg_name = ['vv_ucb', 'vv_n']
    alg_dict = {'vv_ucb' : 'UCB Reward', 'vv_n' : 'Count Reward'}
    gamma_list = np.append(np.arange(0,1,0.1), 0.99999)

    env_dict = {"GridworldSparseSmall" : "Gridworld (Prison)", "GridworldSparseSimple" : "Gridworld (Toy)"}
    var_dict = {"VC_history" : "States Discovered", "J_history" : "Discounted Return"}

    i = 0
    for var in ["J_history"]:
        # for env in ["GridworldSparseSimple", "GridworldSparseSmall"]:
        for env in ["GridworldSparseSimple"]:
            for alg in alg_name:
                i += 1
                ax = plt.subplot(gs[i-1],title=alg_dict[alg])
                ax.set_title(alg_dict[alg],size=11)
                palette = itertools.cycle(sns.color_palette(n_colors=13))
                lines = itertools.cycle(["-","-","-","-","-",":",":",":",":",":",":"])
                plt.tick_params(labelsize=3)
                for gamma in gamma_list:
                    add_line(alg + '_' + '{:d}'.format(int(gamma*100)), env, var, ax, moving=args.moving, lc=next(palette), ls=next(lines))
                if i == 1 or i == 3:
                    plt.ylabel(var_dict[var])
                add_line('count', env, var, ax, moving=args.moving, lc='k', ls='--')

    plt.suptitle("Impact of W-Function\nDiscount " r'$\gamma_w$', y=0.9, x=1.02, fontsize='x-large')

    leg = plt.legend(handles=ax.lines, labels=["0", "0.1", "0.2", "0.3", "0.4", "0.5.", "0.6", "0.7", "0.8", "0.9", "0.99999", "UCB1"], bbox_to_anchor=(1.05, 0.77), loc='upper left', ncol=2)
    frame = leg.get_frame()
    frame.set_facecolor('white')

    picsize = fig.get_size_inches() / 1.3
    picsize[0] *= 2
    picsize[1] *= 1.1
    fig.set_size_inches(picsize)

    plt.savefig('gamma_sens.pdf', bbox_inches='tight', pad_inches=0)
