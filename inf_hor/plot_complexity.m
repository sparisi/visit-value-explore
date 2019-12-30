clear all
close all

list_alg = ["vv_ucb", "vv_n", "boot_thom", "ucb1", "bonus", "egreedy"];
n_trials = 50;

N = 5;
e_list = linspace(1e-24,1e-5,500);
V_diff = inf(length(list_alg),n_trials,length(e_list));

j = 0;
for alg = list_alg
    j = j + 1;
    for seed = 1 : n_trials
        load(['ql\res\Chain' num2str(N) '\' char(alg) '_' num2str(seed) '.mat'])
        V_diff(j,seed,:) = sum(((Vt_STAR - Vt) > e_list')', 1);
    end
end

mu = squeeze(mean(V_diff,2));
semilogx(e_list,mu')
yl = ylim;
ylim([yl(1) yl(2)*1.1])

legend(list_alg)
