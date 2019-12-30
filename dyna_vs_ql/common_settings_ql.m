if ~exist('trial', 'var'), trial = 2; end % Default seed
if ~exist('do_plot', 'var'), do_plot = 0; end % No plot by default
if ~exist('optimistic', 'var'), optimistic = 0; end
if ~exist('long_horizon', 'var'), long_horizon = 0; end
if ~exist('mdp_name', 'var'), mdp_name = 'GridworldSparseSmall'; end
if ~exist('deep_depth', 'var'), deep_depth = 50; end
if ~exist('gamma_vv', 'var'), gamma_vv = 0.99; end

rng(trial)

switch mdp_name
    case 'GridworldSparseVerySmall'
        mdp = GridworldSparseVerySmall; 
        maxsteps = 5; 
        budget = 100; 
        totstates_can_visit = sum(mdp.isopen(:));
    case 'GridworldSparseSmall'
        mdp = GridworldSparseSmall; 
        maxsteps = 11; 
        budget = 2500; 
        totstates_can_visit = sum(mdp.isopen(:));
    case 'GridworldSparseSimple'
        mdp = GridworldSparseSimple; 
        maxsteps = 11; 
        budget = 2500; 
        totstates_can_visit = sum(mdp.isopen(:));
    case 'GridworldSparseWall'
        mdp = GridworldSparseWall; 
        maxsteps = 330; 
        budget = 100000; 
        totstates_can_visit = sum(mdp.isopen(:));
    case 'DeepGridworld'
        mdp = DeepGridworld; 
        maxsteps = 55; 
        budget = 10000; 
        totstates_can_visit = sum(mdp.isopen(:));
    case 'Taxi'
        mdp = Taxi; 
        maxsteps = 33; 
        budget = 20000; 
        totstates_can_visit = sum(mdp.isopen(:)) * 2^3 - (3+2*3+1*3);
    case 'DeepSea'
        mdp = DeepSea(deep_depth); 
        maxsteps = mdp.N; 
        budget = 100000; 
        totstates_can_visit = sum(1:mdp.N) * 2;
        long_horizon = 0; % Horizon is fixed to the size of the environment
end
if long_horizon, maxsteps = 2 * maxsteps; end

gamma = 0.99;
mdp.gamma = gamma;

K = mdp.rewardUB / (1 - gamma); % Constant for UCB

allstates = mdp.allstates;
if mdp.dstate == 2
    X = unique(allstates(:,1));
    Y = unique(allstates(:,2));
end
allactions = 1 : size(mdp.allactions,2);
nactions = length(allactions);
nstates = size(allstates,1);

memory_size = min(budget, inf);
s = nan(1,memory_size);
sn = nan(1,memory_size);
a = nan(1,memory_size);
r = nan(1,memory_size);
done = nan(1,memory_size);
sa = nan(1,memory_size);
t = 0;

% If everything is deterministic, we need to save only one tuple (s,a,s',r,d)
first_visit = nan(1,nstates*nactions);
first_t = 0;

Qzero = zeros(nstates,nactions); % Q-function (neutral init)
Qopt  = (Qzero + 1) * K; % Optimistic Q

QT = Qzero; % Target Q
if optimistic, QB = Qopt; else, QB = QT; end % Behavior Q

VC = zeros(nstates,1); % Visit count for states
VCA = zeros(nstates,nactions); % Visit count for state-action pairs

VVA = zeros(nstates,nactions); % Visit value for state-action pairs

totsteps = 1;
episode = 1;

epsilon = 1; % For e-greedy base QL exploration
epsilon_decay = exp(log(0.1) / budget); % Exponential decay s.t. epsilon = 0.1 at the end

beta = 0.1; % Coefficient for exploration bonus
lrate = 0.5;
bsize = 1024; % Batch size for bootstrapping algorithms

episodes_eval = 1;
if strcmp(mdp_name, 'DeepSea'), episodes_eval = 2; end % 1 bomb, 1 treasure
steps_eval = maxsteps;

policy_eval.drawAction = @(s)randi(nactions, 1, size(s,2));
J_history = evaluate_policies(mdp, episodes_eval, steps_eval, policy_eval);

setting_str = ['ql/res/' char(mdp_name)];
if strcmp('DeepSea', mdp_name), setting_str = [setting_str num2str(mdp.N)]; end
if optimistic, setting_str = [setting_str '_OPT']; end
if long_horizon, setting_str = [setting_str '_LONG']; end
mkdir(setting_str)

save_list = {'J_history', 'VC_history', ...
    'VCA', 'VC', 'VVA', 'gamma_vv', ...
    'QT', 'QB', 'gamma', ...
    'mdp', 'maxsteps', 'budget', 'episodes_eval', 'steps_eval', 'optimistic', 'long_horizon'};
