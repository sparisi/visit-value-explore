clearvars -except trial mdp_name alg_name do_plot optimistic long_horizon setting_str deep_depth gamma_vv
close all

common_settings_ql

maxU = (1 + sqrt(2 * log(nactions - 1))) / (1 - gamma_vv);
VVA = (1 / (1 - gamma_vv) + sqrt(2 * log(nactions - 1))) / (1 - gamma_vv) * ones(nstates,nactions) + 1e-8;

%% Collect data and learn
while totsteps < budget
    
    step = 0;
    state = mdp.initstate(1);
    
    % Animation + print counter
    if do_plot, disp(episode), mdp.showplot, end 
    
    % Run the episodes until maxsteps or done state
    while (step < maxsteps) && (totsteps < budget)
        
        step = step + 1;
        t = mod(t, memory_size) + 1;
        [~, s(t)] = ismember(state',allstates,'rows');

        % Action selection
        UCB = QB(s(t),:) + K * (1 - gamma_vv) * VVA(s(t),:);
        action = egreedy(UCB',0);
        
        % Simulate one step and store data
        step_and_store
        
        % Q-learning
        tt = first_visit(1:first_t);
        E = r(tt) + gamma * max(QB(sn(tt),:),[],2)' .* ~done(tt) - QB(sa(tt));
        QB(sa(tt)) = QB(sa(tt)) + lrate * E;
        E = r(tt) + gamma * max(QT(sn(tt),:),[],2)' .* ~done(tt) - QT(sa(tt));
        QT(sa(tt)) = QT(sa(tt)) + lrate * E;
        
        % VV-learning
        pseudo_reward = sqrt(2 * bsxfun(@times, log(sum(VCA(s(tt),:), 2))', 1 ./ (VCA(sa(tt)))));
        pseudo_reward = pseudo_reward .* ~done(tt) + pseudo_reward ./ (1 - gamma_vv) .* done(tt);
        E_VV = pseudo_reward + gamma_vv * max(VVA(sn(:,tt),:),[],2)' .* ~done(tt) - VVA(sa(tt));
        VVA(sa(tt)) = VVA(sa(tt)) + lrate * E_VV;
        
        % Evaluation
        evaluation
            
        % Continue
        state = nextstate;
        totsteps = totsteps + 1;
        if done(t), break, end
        
    end

    % Plot
    if do_plot
        updateplot('Visited states',totsteps,[sum(VC>0),totstates_can_visit],1)
    end
    
    episode = episode + 1;

end
