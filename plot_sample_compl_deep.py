import os
import numpy as np
import argparse
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.gridspec as gridspec
import seaborn as sns
import itertools
from scipy.io import loadmat
from labellines import labelLine, labelLines


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--env', default='DeepSea')
    parser.add_argument('--folder', default='ql/ql/res/')
    parser.add_argument('--ymax', type=int, default=1e5)
    args = parser.parse_args()

    sns.set_context("paper")
    sns.set_style('darkgrid', {'legend.frameon':True})

    fig = plt.figure()
    gs = gridspec.GridSpec(1,4)
    gs.update(wspace=0.09, hspace=0.05)

    all_algs = ['vv_ucb', 'vv_n', 'brlsvi', 'boot', 'boot_thom', 'ucb1', 'bonus', 'egreedy', 'random']
    all_c = sns.color_palette(n_colors=9)
    all_legend = ['Ours (UCB Reward)', 'Ours (Count Reward)', 'Rand. Prior (Osband 2019)', 'Bootstr. (Osband 2016a)', 'Thompson (D\'Eramo 2019)', 'UCB1 (Auer 2002)', 'Expl. Bonus (Strehl 2008)', r'$\epsilon$' + '-greedy']
    dict_c = dict(zip(all_algs, all_c))
    dict_leg = dict(zip(all_algs, all_legend))

    alg_name = ['vv_ucb', 'vv_n', 'brlsvi', 'boot', 'bonus']

    title_dict = {'DeepSea' : 'Deep Sea'}
    opt_dict = {'DeepSea' : 0}
    label_dict = {'DeepSea' : 'Depth N'}

    ax = fig.add_subplot(111)
    plt.tick_params(labelsize=3)
    lines = itertools.cycle(["-","--",":"])
    trials = 10
    N_list = np.arange(5,59,2)
    points = np.nan * 5e5 * np.ones((trials, len(N_list), len(alg_name)))

    for alg, k in zip(alg_name, np.arange(len(alg_name))):
        for n, j in zip(N_list, np.arange(len(N_list))):
            for i in range(trials):
                f = args.folder + args.env + str(n) + '/' + alg + '_' + str(i+1)
                try:
                    data_file = loadmat(f)['J_history'].flatten()
                except:
                    print('Cannot read    [', f, ']')
                    continue
                try:
                    points[i,j,k] = (np.argwhere(data_file>opt_dict[args.env])[0]+1)*50
                except:
                    print('Failed run     [', f, ']')
                    continue

        c = dict_c[alg]

        mu = np.nanmean(points[:,:,k], axis=0)
        ax.plot(N_list, mu, linewidth=2, color=c, linestyle=':', marker='o', fillstyle='none')
        mu = np.mean(points[:,:,k], axis=0)
        std = np.std(points[:,:,k], axis=0)
        ci = 1.96 * std / np.sqrt(points.shape[0])
        # l = ax.plot(N_list, mu, linewidth=2, color=c, marker='o')
        ax.errorbar(N_list, mu, yerr=ci, elinewidth=1.5, linewidth=2, color=c, marker='o')
        ax.margins(x=0)

    l0 = ax.plot(N_list, N_list**2, color='k', linestyle='--', label=("$N^{{{}}}$").format(2))
    l1 = ax.plot(N_list, N_list**2.5, color='k', linestyle='--', label=("$N^{{{}}}$").format(2.5))
    l2 = ax.plot(N_list, N_list**2.7, color='k', linestyle='--', label=("$N^{{{}}}$").format(2.7))
    l3 = ax.plot(N_list, N_list**3, color='k', linestyle='--', label="$N^3$")
    l4 = ax.plot(N_list, N_list**4, color='k', linestyle='--', label="$N^4$")

    labelLines(plt.gca().get_lines(), xvals=[53,53,53,40,17])

    ax.set_ylim([50, args.ymax])
    plt.xticks(np.arange(5,60,4))
    plt.xlabel(label_dict[args.env])
    plt.ylabel('Steps to Learn')
    for tick in ax.xaxis.get_major_ticks():
        tick.label.set_fontsize(6)
        tick.set_pad(-3)
    for tick in ax.yaxis.get_major_ticks():
        tick.label.set_fontsize(6)
        tick.set_pad(-3)

    plt.suptitle("Empirical\nSample Complexity\non the " + title_dict[args.env], y=0.83, x=1.12, fontsize='x-large')
    l_list = [ax.lines[i] for i in range(1,len(alg_name)*2+1,2)]
    leg = plt.legend(handles=l_list, labels=[dict_leg[x] for x in alg_name], bbox_to_anchor=(1.04, 0.55), loc='upper left')
    frame = leg.get_frame()
    frame.set_facecolor('white')

    picsize = fig.get_size_inches() / 1.3
    picsize[0] *= 1.1
    picsize[1] *= 0.9
    fig.set_size_inches(picsize)

    plt.savefig(args.env + "_sample_comp.pdf", bbox_inches='tight', pad_inches=0)
