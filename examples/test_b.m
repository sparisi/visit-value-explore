% state indices
% [ 1 4 7 ]
% [ 2 5 8 ]
% [ 3 6 9 ]
%
% reward map
% [ 0 0 0 ]
% [ 0 0 0 ]
% [ 1 0 2 ]
% the middle state is a "loop" state
%
% actions are 1, 2, 3, 4 = left, right, up, down

clear all
mdp = GridworldSparseVerySmall;

lrate = 0.1;
gamma = 0.99;
gamma_vv = 0.99;
alpha = 0.1;
data_type = 2; % ALL STATE-ACTION PAIR!
infinite = true; % TERMINAL VS NON-TERMINAL
remove_left = true; % REMOVE LEFT FROM FIRST STATE

K = 2 / (1 - gamma);
VCA = zeros(9,4);

X = 1:3;
Y = 1:3;
[XX, YY] = meshgrid(X,Y);
XX = XX';
YY = YY';
allstates = [XX(:) YY(:)];
allactions = [1, 2, 3, 4];

generate_data

% update count
for i = 1 : length(sa)
    VCA(sa(i)) = VCA(sa(i)) + 1;
end 

if infinite
    D(:) = 0;
end

% REMOVE LEFT FROM FIRST STATE
if remove_left
    VCA(sa(1)) = 0;
    s(1) = [];
    a(1) = [];
    sn(1) = [];
    sa(1) = [];
    D(1) = [];
    R(1) = [];
end

%%
test_learn

%% plots
close all

all = [policy_vv_n(:); expl_vv_n(:); policy_vv_ucb(:); expl_vv_ucb(:); Q(:); Q_AUG(:); policy_ucb1(:); expl_ucb1(:)];
range = [min(all) max(all)];
range = [];

% make_map_count(VCA, 'vca');

make_map((Q), 'greedy', range);

make_map((Q_AUG), 'bonus', range);

make_map((policy_ucb1), 'ucb1', range);
% make_map((expl_ucb1), 'ucb1 (ucb only)', range);

make_map((policy_vv_n), 'vv_n', range);
% make_map((expl_vv_n), 'vv_n (vv only)', range);

make_map((policy_vv_ucb), 'vv_ucb', range);
% make_map((expl_vv_ucb), 'vv_ucb (vv only)', range);

% autolayout
