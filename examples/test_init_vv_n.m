clear all
n_act = 5;
qmax = 100;
gamma_w = 0.99;
vmin = 0;
v = vmin * ones(n_act,1);
q = qmax * ones(n_act,1);
q(end) = 0;
n = ones(n_act,1);
n(end) = 0;

for i = 1 : 10000
r = n(1:end-1);
e = r + gamma_w * vmin - v(1:end-1);
e(end+1) = 0;
v = v + 0.1 * e;
end
mean(e.^2)

max_u = (1 + sqrt(2 * log(1 + (1 - gamma_w) + (n_act-2)) / (1 - gamma_w)));
ucb = get_ucb(1, v * (1 - gamma_w), qmax, max_u);
ucb(end) > ucb(1)
