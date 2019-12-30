clear all
n_act = 5;
qmax = 100;
gamma_w = 0.99;
vmax = (1/(1-gamma_w) + sqrt(2*log(n_act-1))) / (1 - gamma_w) + 1e-8;
v = vmax*ones(n_act,1);
q = qmax*ones(n_act,1);
q(end) = 0;
n = ones(n_act,1);
n(end) = 0;

for i = 1 : 10000
r = sqrt(2 * log(sum(n)) ./ n(1:end-1));
e = r + gamma_w * vmax - v(1:end-1);
e(end+1) = 0;
v = v + 0.1 * e;
end
mean(e.^2)

ucb = q + v * (1 - gamma_w) * qmax
ucb(end)>ucb(1)





%%

clear all
n_act = 5;
qmax = 100;
gamma_w = 0.99;
vmax = (1 + sqrt(2*log(n_act-1))) / (1 - gamma_w) + 1e-8;
v = vmax*ones(n_act,1);
q = qmax*ones(n_act,1);
q(end) = 0;
n = ones(n_act,1);
n(end) = 0;

for i = 1 : 10000
r = sqrt(2 * log(sum(n)) ./ n(1:end-1));
e = r + gamma_w * vmax - v(1:end-1);
e(end+1) = 0;
v = v + 0.1 * e;
end
mean(e.^2)

ucb = q + v * qmax
ucb(end)>ucb(1)


