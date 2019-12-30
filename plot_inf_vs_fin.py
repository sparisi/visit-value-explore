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
    parser.add_argument('--folder', default='dyna_vs_ql/ql/res/')
    parser.add_argument('--moving', type=int, default=1)
    parser.add_argument('--n', type=int, default=20)
    args = parser.parse_args()

    sns.set_context("paper")
    sns.set_style('darkgrid', {'legend.frameon':True})

    fig = plt.figure()
    gs = gridspec.GridSpec(2,2)
    gs.update(wspace=0.1, hspace=0.12)

    alg_name = ['vv_ucb', 'vv_n', 'egreedy', 'brlsvi', 'vv_ucb_classic', 'vv_n_classic', 'egreedy_classic', 'brlsvi_finite']
    legend = ['\nInfinite Mem.', 'Ours (UCB Reward)', 'Ours (Count Reward)', r'$\epsilon$' + '-greedy', 'Rand. Prior (Osband 2019)', '\nNo Mem.', 'Ours (UCB Reward)', 'Ours (Count Reward)', r'$\epsilon$' + '-greedy', '\nFinite Mem.', 'Rand. Prior (Osband 2019)']

    env_dict = {"GridworldSparseSmall" : "Gridworld (Prison)", "GridworldSparseSimple" : "Gridworld (Toy)"}
    var_dict = {"VC_history" : "States Discovered", "J_history" : "Discounte Return"}

    i = 0
    for var in ["VC_history", "J_history"]:
        for env in ["GridworldSparseSimple", "GridworldSparseSmall"]:
            i += 1
            if i == 1 or i == 2:
                ax = plt.subplot(gs[i-1],title=env_dict[env])
            else:
                ax = plt.subplot(gs[i-1])
            palette = itertools.cycle(sns.color_palette(n_colors=4))
            lines = itertools.cycle(["-","-","-","-","--","--","--","--"])
            plt.tick_params(labelsize=3)
            for alg in alg_name:
                add_line(alg, env, var, ax, moving=args.moving, lc=next(palette), ls=next(lines))
            if i == 1 or i == 3:
                plt.ylabel(var_dict[var])

    extra1 = Rectangle((100, 0), 1, 1, fc="w", fill=False, edgecolor='none', linewidth=0)
    extra2 = Rectangle((100, 0), 1, 1, fc="w", fill=False, edgecolor='none', linewidth=0)
    extra3 = Rectangle((100, 0), 1, 1, fc="w", fill=False, edgecolor='none', linewidth=0)
    handles = ax.lines
    handles.insert(4,extra1)
    handles.insert(0,extra2)
    handles.insert(-1,extra3)

    plt.suptitle("Infinite Memory\nvs\nNo Memory", y=0.9, x=1.02, fontsize='x-large')

    leg = plt.legend(handles=handles, labels=legend, bbox_to_anchor=(1.04, 1.6), loc='upper left')
    frame = leg.get_frame()
    frame.set_facecolor('white')

    picsize = fig.get_size_inches() / 1.3
    picsize[0] *= 2
    picsize[1] *= 1.1
    fig.set_size_inches(picsize)

    plt.savefig('inf_vs_fin.pdf', bbox_inches='tight', pad_inches=0)
