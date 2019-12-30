precision = 1e-18;

Q = zeros(9,4);
Q_AUG = Q; % r + beta / sqrt(n(s,a))

VVA_N = VCA;
VVA_N(:) = 0;

maxU_ucb1 = (1 + sqrt(2 * log(4)));
maxU_vv_n = (1 + sqrt(2 * log(1 + (1 - gamma_vv) + 2) / (1 - gamma_vv)));

VVA_UCB = VCA;
VVA_UCB(:) = (1 / (1 - gamma_vv) + sqrt(2 * log(3))) / (1 - gamma_vv);

vv_ucb_ok = false;
vv_n_ok = false;
q_ok = false;
q_aug_ok = false;

for i = 1 : 50000
    pseudo_reward = VCA(sa);
    pseudo_reward = pseudo_reward .* ~D' + max(VCA(:)) ./ (1 - gamma_vv) .* D';
    E_VV_N = pseudo_reward + gamma_vv * min(VVA_N(sn,:),[],2) .* ~D' - VVA_N(sa);
    VVA_N(sa) = VVA_N(sa) + lrate * E_VV_N;

    pseudo_reward = sqrt(2 * bsxfun(@times, log(sum(VCA(s,:), 2)), 1 ./ VCA(sa)));
    pseudo_reward = pseudo_reward .* ~D' + pseudo_reward ./ (1 - gamma_vv) .* D';
    E_VV_UCB = pseudo_reward + gamma_vv * max(VVA_UCB(sn,:),[],2) .* ~D' - VVA_UCB(sa);
    VVA_UCB(sa) = VVA_UCB(sa) + lrate * E_VV_UCB;
    
    E = R + gamma * max(Q(sn,:),[],2)' .* ~D - Q(sa)';
    Q(sa) = Q(sa) + lrate * E';
    
    R_AUG = alpha ./ sqrt(VCA(sa))';
    E_AUG = R + R_AUG + gamma * max(Q_AUG(sn,:),[],2)' .* ~D - Q_AUG(sa)';
    Q_AUG(sa) = Q_AUG(sa) + lrate * E_AUG';
    
	vv_n_ok = mean(E_VV_N.^2) < precision;
	vv_ucb_ok = mean(E_VV_UCB.^2) < precision;
	q_ok = mean(E.^2) < precision;
	q_aug_ok = mean(E_AUG.^2) < precision;
    
    if vv_n_ok && vv_ucb_ok && q_ok && q_aug_ok, break, end
end
fprintf('vv_n error: %e\n', mean(E_VV_N.^2))
fprintf('vv_ucb error: %e\n', mean(E_VV_UCB.^2))
fprintf('q error: %e\n', mean(E.^2))
fprintf('q_aug error: %e\n', mean(E_AUG.^2))

%%

% Q(VCA~=0) = K-1;
% K = Q;

policy_vv_n = get_ucb(Q, (1 - gamma_vv) * VVA_N, K, maxU_vv_n);
expl_vv_n   = get_ucb(0, (1 - gamma_vv) * VVA_N, K, maxU_vv_n);

policy_vv_ucb = Q + K .* (1 - gamma_vv) .* VVA_UCB;
expl_vv_ucb   = 0 + K .* (1 - gamma_vv) .* VVA_UCB;

policy_ucb1 = get_ucb(Q, VCA, K, maxU_ucb1);
expl_ucb1   = get_ucb(0, VCA, K, maxU_ucb1);
