if step == 1
    P1 = zeros(mdp.n, mdp.n);
    P2 = P1;
    P3 = P1;

    P3 = eye(size(P3)) * (1 - mdp.p);
    P3 = P3 + diag(ones(1,mdp.n-1) * mdp.p / 2, 1);
    P3 = P3 + diag(ones(1,mdp.n-1) * mdp.p / 2, -1);
    P3(1,1) = (1 - mdp.p) + mdp.p / 2;
    P3(end,end) = (1 - mdp.p) + mdp.p / 2;

    P1 = P1 + diag(ones(1,mdp.n-1) * (1 - mdp.p), 1);
    P1 = P1 + diag(ones(1,mdp.n-1) * mdp.p, -1);
    P1(1,1) = mdp.p;
    P1(end,end) = (1 - mdp.p);

    P2 = P2 + diag(ones(1,mdp.n-1) * mdp.p, 1);
    P2 = P2 + diag(ones(1,mdp.n-1) * (1 - mdp.p), -1);
    P2(1,1) = (1 - mdp.p);
    P2(end,end) = mdp.p;
end

%%
[~, PI] = egreedy(QB(:,:,1)', 0);
PI = PI';

PPI = bsxfun(@times, P1, PI(:,1)) + ...
    bsxfun(@times, P2, PI(:,2)) + ...
    bsxfun(@times, P3, PI(:,3));
V(:,end+1) = sum((eye(size(PPI)) - gamma * PPI) \ (mdp.r .* PI), 2);
Vt(:,end+1) = V(s(t),end);

if step == 1
    PI_STAR = zeros(size(PI));
    PI_STAR(1:end-1,1) = 1;
    PI_STAR(end,end) = 1;

    PPI_STAR = bsxfun(@times, P1, PI_STAR(:,1)) + ...
        bsxfun(@times, P2, PI_STAR(:,2)) + ...
        bsxfun(@times, P3, PI_STAR(:,3));
    V_STAR = sum((eye(size(PPI_STAR)) - gamma * PPI_STAR) \ (mdp.r .* PI_STAR), 2);
end

Vt_STAR(:,end+1) = V_STAR(s(t),end);
