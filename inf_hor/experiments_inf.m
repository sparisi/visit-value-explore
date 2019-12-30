maxsteps = 200000;
for alg_name = ["vv_n", "vv_ucb", "egreedy", "bonus", "boot_thom", "ucb1"]
    gamma = 0.99;
    gamma_vv = 0.999;
    for N = 5 : 2 : 59
        for trial = 1 : 50
            fprintf('dim: %d, trial: %d\n', N, trial)
            
            feval(['run_' char(alg_name) '_inf'])
            save([setting_str '/' char(alg_name) '_' num2str(trial)], save_list{:})
        end
    end
end
