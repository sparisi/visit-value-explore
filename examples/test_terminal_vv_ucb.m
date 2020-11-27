clear all

gamma_vv = 0.;
gamma_vv = 0.01;
gamma_vv = 0.99;
vmax = (1 / (1 - gamma_vv) + sqrt(2 * log(4-1))) / (1 - gamma_vv) + 1e-8;
umax = vmax * (1 - gamma_vv);
VVA = ones(4,3) * vmax;
s  = [1 2, 1 3 2 2];
sn = [2 4, 3 2 2 3];
a  = [1 2, 2 1 1 3];
D  = [0 1, 0 0 0 0]';
sa = sub2ind(size(VVA),s,a);
VCA = zeros(size(VVA));
VCA(sa) = 1;
VCA(1) = 2;

ucb = sqrt(2 * log(sum(VCA(s,:), 2)) ./ (VCA(sa)'))';
pseudo_reward = ucb .* ~D' + ucb / (1 - gamma_vv) .* ~D';
for i = 1 : 1000
    E_VV = pseudo_reward + gamma_vv * max(VVA(sn,:),[],2)' .* ~D' - VVA(sa);
    VVA(sa) = VVA(sa) + 0.1 * E_VV;
end

mean(E_VV.^2)
VVA(2,2) < VVA(2,:)

%%
clear all

gamma_vv = 0.;
gamma_vv = 0.0001;
gamma_vv = 0.99;
vmax = (1 / (1 - gamma_vv) + sqrt(2 * log(4-1))) / (1 - gamma_vv) + 1e-8;
umax = vmax * (1 - gamma_vv);
VVA = ones(4,3) * vmax;
s  = [1 2, 1 3 2 2 3 3 4 4 4];
sn = [2 4, 3 2 2 3 3 4 4 4 3];
a  = [1 2, 2 1 1 3 2 3 2 3 1];
D  = [0 1, 0 0 0 0 0 0 0 0 0]';
sa = sub2ind(size(VVA),s,a);
VCA = zeros(size(VVA));
VCA(sa) = 1;
VCA(1) = 2;


ucb = sqrt(2 * log(sum(VCA(s,:), 2)) ./ (VCA(sa)'))';
pseudo_reward = ucb .* ~D' + ucb / (1 - gamma_vv) .* ~D';
for i = 1 : 1000
    E_VV = pseudo_reward + gamma_vv * max(VVA(sn,:),[],2)' .* ~D' - VVA(sa);
    VVA(sa) = VVA(sa) + 0.1 * E_VV;
end

mean(E_VV.^2)
VVA(2,2) < VVA(2,:)
