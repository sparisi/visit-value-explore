VCA = [1 1 0
    1 1 1
    1 0 0
    0 0 0
    0 0 0
    0 0 0
    0 0 0];

VVA = zeros(size(VCA));

gamma_vv = 0.99;
s = [1 2, 1 3 2 2];
sn = [2 5, 3 2 2 3];
a = [1 2, 2 1 1 3];
D = [0 1, 0 0 0 0]';
sa = sub2ind(size(VCA),s,a);


for i = 1 : 1000
    pseudo_reward = sum(VCA(sa),2) .* ~D' + max(sum(VCA,2)) / (1 - gamma_vv) * D';
    E_VV2 = pseudo_reward + gamma_vv * min(VVA(sn,:),[],2)' .* ~D' - VVA(sa);
    VVA(sa) = VVA(sa) + lrate * E_VV2;
end



%%
VCA = [1 1 0
    1 1 1
    1 1 1
    1 1 1
    0 0 0];

VVA = zeros(size(VCA));

gamma_vv = 0.4;
s = [1 2, 1 3 2 2 3 3 4 4 4];
sn = [2 5, 3 2 2 3 3 4 4 4 3];
a = [1 2, 2 1 1 3 2 3 2 3 1];
D = [0 1, 0 0 0 0 0 0 0 0 0]';
sa = sub2ind(size(VCA),s,a);


for i = 1 : 1000
    pseudo_reward = sum(VCA(sa),2) .* ~D' + max(sum(VCA,2)) / (1 - gamma_vv) * D';
    E_VV2 = pseudo_reward + gamma_vv * min(VVA(sn,:),[],2)' .* ~D' - VVA(sa);
    VVA(sa) = VVA(sa) + lrate * E_VV2;
end
