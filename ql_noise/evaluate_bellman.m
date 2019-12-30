if step == 1

    mmdp = feval(mdp_name);
    
    n = size(mmdp.allstates,1);
    
    P1 = zeros(n, n);
    P2 = P1;
    P3 = P1;
    P4 = P1;

    ns1 = mmdp.simulator(mmdp.allstates',1);
    ns2 = mmdp.simulator(mmdp.allstates',2);
    ns3 = mmdp.simulator(mmdp.allstates',3);
    ns4 = mmdp.simulator(mmdp.allstates',4);
    
    [~, sn1] = ismember(ns1',mmdp.allstates,'rows');
    [~, sn2] = ismember(ns2',mmdp.allstates,'rows');
    [~, sn3] = ismember(ns3',mmdp.allstates,'rows');
    [~, sn4] = ismember(ns4',mmdp.allstates,'rows');
    
    P1(sub2ind(size(P1),1:n,sn1')) = mdp.probT(1) + mdp.probT(2) / 4;
    P1(sub2ind(size(P1),1:n,1:n)) = P1(sub2ind(size(P1),1:n,1:n)) + mdp.probT(3);
    P1(sub2ind(size(P1),1:n,sn2')) = P1(sub2ind(size(P1),1:n,sn2')) + mdp.probT(2) / 4;
    P1(sub2ind(size(P1),1:n,sn3')) = P1(sub2ind(size(P1),1:n,sn3')) + mdp.probT(2) / 4;
    P1(sub2ind(size(P1),1:n,sn4')) = P1(sub2ind(size(P1),1:n,sn4')) + mdp.probT(2) / 4;
    
    P2(sub2ind(size(P1),1:n,sn1')) = mdp.probT(2) / 4;
    P2(sub2ind(size(P1),1:n,1:n)) = P2(sub2ind(size(P1),1:n,1:n)) + mdp.probT(3);
    P2(sub2ind(size(P1),1:n,sn2')) = P2(sub2ind(size(P1),1:n,sn2')) + mdp.probT(1) + mdp.probT(2) / 4;
    P2(sub2ind(size(P1),1:n,sn3')) = P2(sub2ind(size(P1),1:n,sn3')) + mdp.probT(2) / 4;
    P2(sub2ind(size(P1),1:n,sn4')) = P2(sub2ind(size(P1),1:n,sn4')) + mdp.probT(2) / 4;

    P3(sub2ind(size(P1),1:n,sn1')) = mdp.probT(2) / 4;
    P3(sub2ind(size(P1),1:n,1:n)) = P3(sub2ind(size(P1),1:n,1:n)) + mdp.probT(3);
    P3(sub2ind(size(P1),1:n,sn2')) = P3(sub2ind(size(P1),1:n,sn2')) + mdp.probT(2) / 4;
    P3(sub2ind(size(P1),1:n,sn3')) = P3(sub2ind(size(P1),1:n,sn3')) + mdp.probT(1) + mdp.probT(2) / 4;
    P3(sub2ind(size(P1),1:n,sn4')) = P3(sub2ind(size(P1),1:n,sn4')) + mdp.probT(2) / 4;

    P4(sub2ind(size(P1),1:n,sn1')) = mdp.probT(2) / 4;
    P4(sub2ind(size(P1),1:n,1:n)) = P4(sub2ind(size(P1),1:n,1:n)) + mdp.probT(3);
    P4(sub2ind(size(P1),1:n,sn2')) = P4(sub2ind(size(P1),1:n,sn2')) + mdp.probT(2) / 4;
    P4(sub2ind(size(P1),1:n,sn3')) = P4(sub2ind(size(P1),1:n,sn3')) + mdp.probT(2) / 4;
    P4(sub2ind(size(P1),1:n,sn4')) = P4(sub2ind(size(P1),1:n,sn4')) + mdp.probT(1) + mdp.probT(2) / 4;

    if isa(mdp,'GridworldSparseSmall')
        [~, prison] = ismember([4 4],mmdp.allstates,'rows');
        P1(prison,:) = P1(prison,:) * (1e-8);
        P1(prison,prison) = P1(prison,prison) + (1 - 1e-8);
        P1(prison,:) = P1(prison,:) / sum(P1(prison,:));
    end
    if isa(mdp,'GridworldSparseVerySmall')
        [~, prison] = ismember([2 2],mmdp.allstates,'rows');
        P1(prison,:) = P1(prison,:) * (1e-8);
        P1(prison,prison) = P1(prison,prison) + (1 - 1e-8);
        P1(prison,:) = P1(prison,:) / sum(P1(prison,:));
    end
    
    [xx, yy] = find(mmdp.reward);
    [~, ri] = ismember([xx yy], mmdp.allstates,'rows');
    R = zeros(n,4);
    tmp = mmdp.reward';
    R(ri,:) = repmat(tmp(ri),1,4);
end

%%
[~, PI] = egreedy(QT(:,:,1)', 0);
PI = PI';

PPI = bsxfun(@times, P1, PI(:,1)) + ...
    bsxfun(@times, P2, PI(:,2)) + ...
    bsxfun(@times, P3, PI(:,3)) + ...
    bsxfun(@times, P4, PI(:,4));
[xx, yy] = find(mmdp.reward > 0);
[~, ri] = ismember([xx yy], mmdp.allstates,'rows');
PPI(ri,:) = 0;
PPI(ri,:) = 0;

V = sum((eye(size(PPI)) - gamma * PPI) \ (R .* PI), 2);

J_history(end+1) = V(1);
VC_history(totsteps) = sum(VC>0);
