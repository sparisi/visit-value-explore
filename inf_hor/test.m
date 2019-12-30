maxsteps = 50000;
for N = 50
    for trial = 1
        gamma = 0.99;
        gamma_vv = 0.999;

        %%
        run_egreedy_inf
        save('egreedy')
        fprintf('r %e, vc %d, std %e\n', R, sum(VCA(:)>=1), std(VCA(:)))
%         imagesc(VCA')
        imagesc(VC')
        colorbar
        
        %%
        run_bonus_inf
        save('bonus')
        fprintf('r %e, vc %d, std %e\n', R, sum(VCA(:)>=1), std(VCA(:)))
%         imagesc(VCA')
        imagesc(VC')
        colorbar

        %%
        run_vv_n_inf
        save('vv_n')
        fprintf('r %e, vc %d, std %e\n', R, sum(VCA(:)>=1), std(VCA(:)))
%         imagesc(VCA')
        imagesc(VC')
        colorbar
        
        %%
        run_vv_ucb_inf
        save('vv_ucb')
        fprintf('r %e, vc %d, std %e\n', R, sum(VCA(:)>=1), std(VCA(:)))
%         imagesc(VCA')
        imagesc(VC')
        colorbar
        
        %%
        run_ucb1_inf
        save('ucb1')
        fprintf('r %e, vc %d, std %e\n', R, sum(VCA(:)>=1), std(VCA(:)))
%         imagesc(VCA')
        imagesc(VC')
        colorbar

        %%
        run_boot_thom_inf
        save('boot_thom')
        fprintf('r %e, vc %d, std %e\n', R, sum(VCA(:)>=1), std(VCA(:)))
%         imagesc(VCA')
        imagesc(VC')
        colorbar
    end
end
