clearvars -except trial mdp_name alg_name do_plot optimistic long_horizon setting_str 
close all

common_settings_ql

QB = repmat(QB, 1, 1, 10); % Use 10 Q-functions
QB = QB + randn(size(QB)); % Randomize

% Regularizer = v / l || Q - Qprior ||^2
v = maxsteps^2 / 25;
l = v * 10;

% Qprior ~ N(0, l), fixed at the beginning
% Qprior = randn(size(QB)) * sqrt(l);
Qprior = zeros(size(QB));

%% Collect data and learn
while totsteps < budget
    
    step = 0;
    state = mdp.initstate(1);
    
    % Animation + print counter
    if do_plot, disp(episode), mdp.showplot, end 
    
    % Run the episodes until maxsteps or done state
    head = randi(size(QB,3)); % Sample head and keep it fixed for the episode
    while (step < maxsteps) && (totsteps < budget)
        
        step = step + 1;
        t = mod(t, memory_size) + 1;
        [~, s(t)] = ismember(state',allstates,'rows');

        % Action selection
        Qstep = QB(s(t),:,head);
        action = egreedy(Qstep', 0);
        
        % Simulate one step and store data
        step_and_store

        % Q-learning
        tt = 1 : min(max(totsteps, t), memory_size);
        for i = 1 : size(QB,3)
            mb = randperm(length(tt), min(length(tt), bsize)); % Random mask
            Qi = QB(:,:,i);
            Qip = Qprior(:,:,i);
            E = r(mb) + gamma * max(Qi(sn(mb),:),[],2)' .* ~done(mb) - Qi(sa(mb));
            E = E + (v / l * ( Qip(sa(mb)) - Qi(sa(mb)) ));

            [xx, yy] = unique(sa(mb));
            for j = xx
                idx = j == sa(mb);
                Qi(j) = Qi(j) + lrate * mean(E(idx));
            end
            
            QB(:,:,i) = Qi;
        end

        tt = 1 : min(max(totsteps, t), memory_size);
        E_T = r(tt) + gamma * max(QT(sn(tt),:),[],2)' .* ~done(tt) - QT(sa(tt));
        [xx, yy] = unique(sa(tt));
        for i = xx
            idx = i == sa(tt);
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
    end
    
    episode = episode + 1;

end
