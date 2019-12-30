clearvars -except trial N maxsteps gamma gamma_vv alg_name
close all

common_settings_inf

maxU = (1 + sqrt(2 * log(nactions)));

%% Collect data and learn
step = 0;
state = mdp.initstate(1);
while totsteps <= maxsteps
    
    step = step + 1;
    t = step;
    s(t) = state;
    
    % Action selection
    UCB = get_ucb(QB(s(t),:), VCA(s(t),:), maxU);
    action = egreedy(UCB',0);
    
    % Simulate transition
    [sn(t), r(t), done(t)] = mdp.simulator(state, action);
    R = R + gamma^(step-1) * r(t);
    a(t) = action;
    sa(t) = sub2ind(size(QB),s(t),a(t));
    
    % Increase count
    VC(s(t)) = VC(s(t)) + 1;
    VCA(s(t),a(t)) = VCA(s(t),a(t)) + 1;
    
    % Evaluate V-function with Bellman expect. eq.
    evaluate_bellman
    
    % Q-learning
    E = r(t) + gamma * max(QB(sn(t),:),[],2)' .* ~done(t) - QB(sa(t));
    QB(sa(t)) = QB(sa(t)) + lrate * E;
    
    % Continue
    state = sn(t);
    totsteps = totsteps + 1;
    
    if mod(step,100) == 0, VC_history(:,end+1) = VC; end

end

