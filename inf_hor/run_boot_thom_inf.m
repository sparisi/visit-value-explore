clearvars -except trial N maxsteps gamma gamma_vv alg_name
close all

common_settings_inf

QB = repmat(QB, 1, 1, 10); % Use 10 Q-functions
QB = QB + randn(size(QB)); % Randomize

%% Collect data and learn
step = 0;
state = mdp.initstate(1);
while totsteps <= maxsteps
    
    step = step + 1;
    t = step;
    s(t) = state;
    
    % Action selection
    head = randi(size(QB,3),1,nactions); % Sample Q(s,a_i) from random head for each a_i
    q_idx = sub2ind(size(QB), repmat(s(t),1,nactions), 1:nactions, head);
    action = egreedy(QB(q_idx)', 0);
    
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
    for i = randi(size(QB,3)) % Random mask
        Qi = QB(:,:,i);
        E = r(t) + gamma * max(Qi(sn(t),:),[],2)' .* ~done(t) - Qi(sa(t));
        Qi(sa(t)) = Qi(sa(t)) + lrate * E;
        QB(:,:,i) = Qi;
    end
    
    % Continue
    state = sn(t);
    totsteps = totsteps + 1;
    
    if mod(step,100) == 0, VC_history(:,end+1) = VC; end

end

