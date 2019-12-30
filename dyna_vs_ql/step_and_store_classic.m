% Simulate transition
[nextstate, r, done] = mdp.simulator(state, action);
if mdp.realtimeplot, set(mdp.handleEnv.CurrentAxes.Title, 'String', num2str(step-1)), end

% Store data
[~, sn] = ismember(nextstate',allstates,'rows');
[~, a] = ismember(action',allactions);

% Increase count
VC(s) = VC(s) + 1;
VCA(s,a) = VCA(s,a) + 1;
