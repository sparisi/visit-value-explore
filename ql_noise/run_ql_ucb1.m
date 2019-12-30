clearvars -except trial mdp_name alg_name do_plot optimistic long_horizon setting_str 
close all

common_settings_ql

maxU = (1 + sqrt(2 * log(nactions)));

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
        UCB = get_ucb(QB(s(t),:), VCA(s(t),:), maxU);
        action = egreedy(UCB',0);
        
        % Simulate one step and store data
        step_and_store

        % Q-learning
        tt = 1 : min(max(totsteps, t), memory_size);
        E_B = r(tt) + gamma * max(QB(sn(tt),:),[],2)' .* ~done(tt) - QB(sa(tt));
        E_T = r(tt) + gamma * max(QT(sn(tt),:),[],2)' .* ~done(tt) - QT(sa(tt));
        [xx, yy] = unique(sa(tt));
        for i = xx
            idx = i == sa(tt);
            QB(i) = QB(i) + lrate * mean(E_B(idx));
            QT(i) = QT(i) + lrate * mean(E_T(idx));
        end

        % Evaluation
        evaluate_bellman
        
        % Continue
        state = nextstate;
        totsteps = totsteps + 1;
        if done(t), break, end

    end

    % Plot
    if do_plot
        updateplot('Visited states',totsteps,[sum(VC>0),totstates_can_visit],1)
        if mdp.dstate == 2
            [V, opt] = max(QT,[],2);
%             subimagesc('Q-function',X,Y,QT',1)
%             subimagesc('V-function',X,Y,V',1)
%             subimagesc('Action',X,Y,opt',1)
%             subimagesc('Visit count',X,Y,VC',1)

%             UCB = get_ucb(QB, VCA, maxU);
%             subimagesc('UCB count',X,Y,UCB',1)
        end
        if episode == 1, autolayout, end
    end
    
    episode = episode + 1;

end

