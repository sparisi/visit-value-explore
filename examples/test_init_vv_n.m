clear all
n_act = 5;
qmax = 100;
qmin = 0;
kappa = qmax - qmin;
gamma_w = 0.99;
vmin = 0;
v = vmin * ones(n_act,1);
q = qmax * ones(n_act,1);
q(end) = 0;
n = ones(n_act,1) / (1-gamma_w);
n(end) = 0;
n(end-1) = 1;

r = n(1:end-1);
for i = 1 : 100000
e = r + gamma_w * vmin - v(1:end-1);
e(end+1) = 0;
v = v + 0.01 * e;
end
mean(e.^2)

umax = (1 + sqrt(2 * log(1 + (1 - gamma_w) + (n_act-2)) / (1 - gamma_w))) + 1e-8;
ucb = get_ucb(q', v' * (1 - gamma_w), kappa, umax)';
abs(ucb(end) - ucb(end-1)) / max(abs(ucb))
