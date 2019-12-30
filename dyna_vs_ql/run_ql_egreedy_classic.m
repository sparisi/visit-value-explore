clearvars -except trial mdp_name alg_name do_plot optimistic long_horizon setting_str deep_depth
close all

common_settings_ql

%% Collect data and learn
while totsteps < budget
    
    step = 0;
    state = mdp.initstate(1);
    
    % Animation + print counter
    if do_plot, disp(episode), mdp.showplot, end 
    
    % Run the episodes until maxsteps or done state
    while (step < maxsteps) && (totsteps < budget)
        
        step = step + 1;
        [~, s] = ismember(state',allstates,'rows');

        % Action selection
        action = egreedy( QB(s,:)', epsilon );
        
        % Simulate one step and store data
        step_and_store_classic

        % Q-learning
        E = r + gamma * max(QB(sn,:),[],2)' .* ~done - QB(s,a);
        QB(s,a) = QB(s,a) + lrate * E;
        E = r + gamma * max(QT(sn,:),[],2)' .* ~done - QT(s,a);
        QT(s,a) = QT(s,a) + lrate * E;
        
        % Evaluation
        evaluation
        
        % Continue
        state = nextstate;
        totsteps = totsteps + 1;
        epsilon = epsilon * epsilon_decay;
        if done, break, end

    end

    % Plot
    if do_plot
        updateplot('Visited states',totsteps,[sum(VC>0),totstates_can_visit],1)
    end
    
    episode = episode + 1;

end
