clearvars -except trial mdp_name alg_name do_plot optimistic long_horizon setting_str deep_depth gamma_vv
close all

common_settings_ql

maxU = (1 + sqrt(2 * log(1 + (1 - gamma_vv) + 2) / (1 - gamma_vv)));
VVA = zeros(nstates,nactions); % State-action visit value

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
        UCB = get_ucb(QB(s(t),:), (1 - gamma_vv) * VVA(s(t),:), K, maxU);
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
        pseudo_reward = VCA(sa(tt)) .* ~done(tt) + max(VCA(:)) ./ (1 - gamma_vv) .* done(tt);
        E_VV = pseudo_reward + gamma_vv * min(VVA(sn(tt),:),[],2)' .* ~done(tt) - VVA(sa(tt));
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
        if mdp.dstate == 2
            [V, opt] = max(QT,[],2);
%             subimagesc('Q-function',X,Y,QT',1)
%             subimagesc('V-function',X,Y,V',1)
%             subimagesc('Action',X,Y,opt',1)
% 
%             subimagesc('Visit count',X,Y,VC',1)
%             subimagesc('Visit count (A)',X,Y,VCA',1)
% 
%             subimagesc('Pseudo visit count',X,Y,VVA',1)
%             
%             UCB = get_ucb(QB, VCA, K, maxU);
%             subimagesc('UCB count',X,Y,UCB',1)
%             UCB = get_ucb(QB, (1 - gamma_vv) * VVA, K, maxU);
%             subimagesc('UCB count (pVC)',X,Y,UCB',1)
        end
        if episode == 1, autolayout, end
    end
    
    episode = episode + 1;

end
