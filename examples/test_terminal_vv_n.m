clear all

gamma_vv = 0.;
gamma_vv = 0.0001;
gamma_vv = 0.99;
VVA = zeros(4,3);
s  = [1 2, 1 3 2 2];
sn = [2 4, 3 2 2 3];
a  = [1 2, 2 1 1 3];
D  = [0 1, 0 0 0 0]';
sa = sub2ind(size(VVA),s,a);
VCA = zeros(size(VVA));
VCA(sa) = 1;
VCA(1) = 2;

pseudo_reward = VCA(sa) .* ~D' + VCA(sa) / (1 - gamma_vv) .* D';
for i = 1 : 1000
    E_VV = pseudo_reward + gamma_vv * min(VVA(sn,:),[],2)' .* ~D' - VVA(sa);
    VVA(sa) = VVA(sa) + 0.1 * E_VV;
end

mean(E_VV.^2)
VVA(2,2) > VVA(2,:)

maxU = 1 + sqrt(2 * log(1 + (1 - gamma_vv) + 2) / (1 - gamma_vv)) + 1e-8;
UCB = get_ucb(0, VVA * (1 - gamma_vv), 1, maxU);
UCB(2,2) < UCB(2,:)


%%
clear all

gamma_vv = 0.;
gamma_vv = 0.0001;
gamma_vv = 0.99;
VVA = zeros(4,3);
s  = [1 2, 1 3 2 2 3 3 4 4 4];
sn = [2 4, 3 2 2 3 3 4 4 4 3];
a  = [1 2, 2 1 1 3 2 3 2 3 1];
D  = [0 1, 0 0 0 0 0 0 0 0 0]';
sa = sub2ind(size(VVA),s,a);
VCA = zeros(size(VVA));
VCA(sa) = 1;
VCA(1) = 2;

pseudo_reward = VCA(sa) .* ~D' + VCA(sa) / (1 - gamma_vv) .* D';
for i = 1 : 1000
    E_VV = pseudo_reward + gamma_vv * min(VVA(sn,:),[],2)' .* ~D' - VVA(sa);
    VVA(sa) = VVA(sa) + 0.1 * E_VV;
end

mean(E_VV.^2)
VVA(2,2) > VVA(2,:)

maxU = 1 + sqrt(2 * log(1 + (1 - gamma_vv) + 2) / (1 - gamma_vv)) + 1e-8;
UCB = get_ucb(0, VVA * (1 - gamma_vv), 1, maxU);
UCB(2,2) < UCB(2,:)
