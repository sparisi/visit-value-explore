import pickle
import numpy as np
from scipy.io import loadmat

n_exp = 20
envs = ['DeepSea50']
envs = ['DeepGridworld', 'GridworldSparseSimple', 'GridworldSparseSmall', 'GridworldSparseWall', 'Taxi']
settings = ['', '_OPT']
settings = ['', '_OPT', '_LONG', '_OPT_LONG']
names = ['vv_ucb', 'vv_n', 'brlsvi', 'boot', 'boot_thom', 'ucb1', 'bonus', 'egreedy', 'random']

v_target = [2550]
v_target = [55, 25, 23, 2425, 252]
j_target = [3.01669792e-1]
j_target = [1.72314623, 0.92274469, 4.52724072, 2.90417253e3, 11.32078931]

t1 = dict()
for e_idx, e in enumerate(envs):
    t2 = dict()
    for s in settings:
        t3 = dict()
        for n in names:
            v = list()
            j = list()
            t4 = dict()
            for i in range(1, n_exp + 1):
                f = loadmat('ql/ql/res/%s%s/%s_%d.mat' % (e, s, n, i))
                v.append(f['VC_history'][0])
                j.append(f['J_history'][0])
            v_ratio = np.array(v) / v_target[e_idx] * 100
            j_ratio = np.array(j) / j_target[e_idx] * 100
            t4['VC_ratio_mean'] = np.mean(v_ratio, axis=0)[-1]
            t4['J_ratio_mean'] = np.mean(j_ratio, axis=0)[-1]
            t4['VC_ratio_std'] = 2 * np.std(v_ratio, axis=0)[-1] / np.sqrt(n_exp)
            t4['J_ratio_std'] = 2 * np.std(j_ratio, axis=0)[-1] / np.sqrt(n_exp)
            t3[n] = t4
        t2[s] = t3
    t1[e] = t2

for i, e in enumerate(envs):
    for s in settings:
        for n in names:
            print(e, s, n, t1[e][s][n])

pickle.dump(t1, open('t.pkl', 'wb'))
