% Simulate transition
[nextstate, r(t), done(t)] = mdp.simulator(state, action);
if mdp.realtimeplot, set(mdp.handleEnv.CurrentAxes.Title, 'String', num2str(step-1)), end

% Store data
[~, sn(t)] = ismember(nextstate',allstates,'rows');
[~, a(t)] = ismember(action',allactions);
sa(t) = sub2ind(size(QB),s(t),a(t));

% Save first visit time step
if VCA(s(t), a(t)) == 0
    first_t = first_t + 1;
    first_visit(first_t) = t;
end

% Increase count
VC(s(t)) = VC(s(t)) + 1;
VCA(s(t),a(t)) = VCA(s(t),a(t)) + 1;
