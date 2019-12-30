if ~exist('trial', 'var'), trial = 2; end % Default seed
if ~exist('N', 'var'), N = 5; end
if ~exist('maxsteps', 'var'), maxsteps = 100000; end
if ~exist('gamma', 'var'), gamma = 1 - 1 / maxsteps; end
if ~exist('gamma_vv', 'var'), gamma_vv = 1 - 1 / maxsteps; end

rng(trial)

mdp = Chain(N);
totstates_can_visit = mdp.n;

mdp.gamma = gamma;
K = mdp.rewardUB / (1 - gamma); % Constant for UCB
% K = 1;

nactions = length(mdp.allactions);
nstates = size(mdp.allstates,1);

memory_size = min(maxsteps, inf);
s = nan(1,memory_size);
sn = nan(1,memory_size);
a = nan(1,memory_size);
r = nan(1,memory_size);
done = nan(1,memory_size);
sa = nan(1,memory_size);
t = 0;

QB = zeros(nstates,nactions); % Q-function (neutral init)
VC = zeros(nstates,1); % Visit count for states
VCA = zeros(nstates,nactions); % Visit count for state-action pairs

VVA = zeros(size(QB));

totsteps = 1;
lrate = 0.1;
R = 0;
V = [];
Vt = [];
V_STAR = [];
Vt_STAR = [];

setting_str = ['ql/res/' char('Chain') num2str(N)];
mkdir(setting_str)

VC_history = [];

save_list = {'VCA', 'VC', 'VVA', 'gamma_vv', ...
    'QB', 'gamma', ...
    'mdp', 'maxsteps', ...,
    'VC_history', 'R', ...
    'V', 'Vt', 'V_STAR', 'Vt_STAR'};
