clear all
do_plot = 0;
long_horizon = 0;
optimistic = 0;
mdp_name = ["DeepSea"];

for deep_depth = 59
    for trial = 1 : 10
        fprintf('%d %d\n', deep_depth, trial)
        for alg_name = [ ...
                  "ql_vv_n", ...
                  "ql_vv_ucb", ...
                ]
%             alg_name
            feval(['run_' char(alg_name)])
            save([setting_str '/' char(alg_name) '_' num2str(trial) '.mat'], save_list{:})
        end
    end
end
