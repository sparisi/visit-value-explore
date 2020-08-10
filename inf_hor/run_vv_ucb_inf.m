clearvars -except trial N maxsteps gamma gamma_vv alg_name
close all

common_settings_inf

max_VVA = (1 / (1 - gamma_vv) + sqrt(2 * log(nactions - 1))) / (1 - gamma_vv) + 1e-8;
maxU = max_VVA * (1 - gamma_vv);
VVA = max_VVA * ones(nstates,nactions) + 1e-8;

%% Collect data and learn
step = 0;
state = mdp.initstate(1);
while totsteps <= maxsteps
    
    step = step + 1;
    t = step;
    s(t) = state;
    
    % Action selection
    UCB = QB(s(t),:) + K * (1 - gamma_vv) * VVA(s(t),:);
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
    
    % VV-learning
    pseudo_reward = sqrt(2 * bsxfun(@times, log(sum(VCA(s(t),:), 2))', 1 ./ (VCA(sa(t)))));
    E_VV = pseudo_reward + gamma_vv * max(VVA(sn(:,t),:),[],2)' - VVA(sa(t));
    VVA(sa(t)) = VVA(sa(t)) + lrate * E_VV;
    
    % Continue
    state = sn(t);
    totsteps = totsteps + 1;
    
    if mod(step,100) == 0, VC_history(:,end+1) = VC; end
    
end

