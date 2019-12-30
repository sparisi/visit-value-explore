import os
import numpy as np
import argparse
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.gridspec as gridspec
import seaborn as sns
import itertools
from scipy.io import loadmat


eps = np.linspace(0,1e-5,200)

def moving_average(data, window=4):
    return np.convolve(data, np.ones(int(window)) / float(window), 'same')


def shaded_plot(ax, data, x_scale=1., **kwargs):
    mu = np.mean(data, axis=0)
    std = np.std(data, axis=0)
    ci = 1.96 * std / np.sqrt(data.shape[0])
    ax.fill_between(eps, mu - ci, mu + ci, alpha=0.2, edgecolor="none", linewidth=0, **kwargs)
    ax.plot(eps, mu, linewidth=2, **kwargs)
    # ax.margins(x=0)


def shaded_plot_msve(ax, data, x_scale=1., **kwargs):
    x = np.arange(data.shape[1]) * x_scale
    mu = np.mean(data, axis=0)
    std = np.std(data, axis=0)
    ci = 1.96 * std / np.sqrt(data.shape[0])
    ax.fill_between(x, mu - ci, mu + ci, alpha=0.2, edgecolor="none", linewidth=0, **kwargs)
    ax.plot(x, mu, linewidth=2, **kwargs)
    ax.margins(x=0)


def add_line(name, N, ax, lc='b', ls='-', moving=1):
    data_all = []
    for i in range(1,args.n+1):
        f = args.folder + "Chain" + str(N) + '/' + name + '_' + str(i)
        try:
            data = loadmat(f)
            data_file = data['Vt_STAR'].flatten() - data['Vt'].flatten()
        except:
            print('Cannot read    [', f, ']')
            continue
        data_file = np.sum(data_file[:,None] > eps[:,None].T, axis=0)
        data_all.append(data_file)
    data_all = np.array(data_all)
    if data_all.shape[0] == 0:
        print('No data    [', name, ']')
        return
    if moving > 1:
        for i in range(data_all.shape[0]):
           data_all[i,:] = moving_average(data_all[i,:], args.moving)
    shaded_plot(ax, data_all, color=lc, linestyle=ls)
    plt.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
    plt.xlabel(r'$\varepsilon$')
    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize(6)
        tick.set_pad(-3)
    for tick in ax.yaxis.get_major_ticks():
        tick.label.set_fontsize(6)
        tick.set_pad(-3)


def add_line_msve(name, N, ax, lc='b', ls='-', moving=1):
    data_all = []
    for i in range(1,args.n+1):
        f = args.folder + "Chain" + str(N) + '/' + name + '_' + str(i)
        try:
            data_file = np.mean((loadmat(f)['V'] - loadmat(f)['V_STAR'])**2, axis=0)
            data_file = data_file[0::25]
        except:
            print('Cannot read    [', f, ']')
            continue
        data_all.append(data_file)
    data_all = np.array(data_all)
    if data_all.shape[0] == 0:
        print('No data    [', name, ']')
        return
    if moving > 1:
        for i in range(data_all.shape[0]):
           data_all[i,:] = moving_average(data_all[i,:], args.moving)
    shaded_plot_msve(ax, data_all, color=lc, linestyle=ls)
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
    parser.add_argument('--folder', default='inf_hor/ql/res/')
    parser.add_argument('--moving', type=int, default=1)
    parser.add_argument('--n', type=int, default=50)
    args = parser.parse_args()

    sns.set_context("paper")
    sns.set_style('darkgrid', {'legend.frameon':True})

    fig = plt.figure()
    gs = gridspec.GridSpec(1,4)
    gs.update(wspace=0.05, hspace=0.05)

    all_algs = ['vv_ucb', 'vv_n', 'brlsvi', 'boot', 'boot_thom', 'ucb1', 'bonus', 'egreedy', 'random']
    all_c = sns.color_palette(n_colors=9)
    all_legend = ['Ours (UCB Reward)', 'Ours (Count Reward)', 'Rand. Prior (Osband 2019)', 'Bootstr. (Osband 2016a)', 'Thompson (D\'Eramo 2019)', 'UCB1 (Auer 2002)', 'Expl. Bonus (Strehl 2008)', r'$\epsilon$' + '-greedy']
    dict_c = dict(zip(all_algs, all_c))
    dict_leg = dict(zip(all_algs, all_legend))

    alg_name = ['vv_ucb', 'vv_n', 'boot_thom', 'ucb1', 'bonus', 'egreedy']

    ax = fig.add_subplot(141,title='N = 27')
    plt.tick_params(labelsize=3)
    for alg in alg_name:
        add_line(alg, 27, ax, moving=args.moving, lc=dict_c[alg])
    plt.ylabel('Sample Complexity')

    ax = fig.add_subplot(142,title='N = 55')
    plt.tick_params(labelsize=3)
    for alg in alg_name:
        add_line(alg, 55, ax, moving=args.moving, lc=dict_c[alg])

    ax = fig.add_subplot(143,title='N = 27')
    plt.tick_params(labelsize=3)
    for alg in alg_name:
        add_line_msve(alg, 27, ax, moving=args.moving, lc=dict_c[alg])
    plt.ylabel('MSVE')

    ax = fig.add_subplot(144,title='N = 55')
    plt.tick_params(labelsize=3)
    for alg in alg_name:
        add_line_msve(alg, 55, ax, moving=args.moving, lc=dict_c[alg])

    plt.suptitle("           Chainworld", y=0.78, x=0.95, fontsize='x-large')

    leg = plt.legend(handles=ax.lines, labels=[dict_leg[x] for x in alg_name], bbox_to_anchor=(1.01, 0.75), loc='upper left')
    frame = leg.get_frame()
    frame.set_facecolor('white')

    picsize = fig.get_size_inches() / 1.3
    picsize[0] *= 3
    picsize[1] *= 0.9
    fig.set_size_inches(picsize)

    plt.savefig("Chainworld_res.pdf", bbox_inches='tight', pad_inches=0)
