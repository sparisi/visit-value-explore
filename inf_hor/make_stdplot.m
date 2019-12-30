clear all
close all

N = 55;
list_alg = {"vv_ucb", "vv_n", "boot_thom", "ucb1", "bonus", "egreedy"};
n_trials = 50;

MSVE = zeros(length(list_alg),n_trials,50000);

j = 0;
figure(), hold all
h = {};
for alg = list_alg
    j = j + 1;
    for seed = 1 : n_trials
        load(['ql\res\Chain' num2str(N) '\' char(alg{:}) '_' num2str(seed) '.mat'])
        MSVE(j,seed,:) = (mean((V_STAR - V).^2, 1));
    end
    tmp = shadedErrorBar(1:50000,squeeze(mean(MSVE(j,:,:),2)),squeeze(std(MSVE(j,:,:),[],2)),{},0.1,0);
    h{j} = tmp.mainLine;
end
legend([h{:}], list_alg, 'Interpreter', 'none');
